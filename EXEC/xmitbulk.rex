        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITBULK                                        *
         *                                                            *
         * Function:  Send bulk e-mail based upon input from          *
         *            a dataset                                       *
         *                                                            *
         * Syntax:    %xmitbulk bulk-dsn FROM from-addr options       *
         *                                                            *
         *            where:                                          *
         *                                                            *
         *            bulk-dsn is a sequential dataset                *
         *                                                            *
         *            contents (starting in column 1):                *
         *            To: recipient-email-address                     *
         *            Cc: recipient-email-address-c1                  *
         *            Cc: recipient-email-address-c2                  *
         *            Subject: subject                                *
         *            text                                            *
         *            text                                            *
         *            ..                                              *
         *            >file format                                    *
         *            file text                                       *
         *            file text                                       *
         *            To: recipient-email-address                     *
         *            Subject: subject                                *
         *            text                                            *
         *            text                                            *
         *            ..                                              *
         *                                                            *
         *            Or                                              *
         *                                                            *
         *            dd:bulkdd                                       *
         *                                                            *
         *            where bulkdd is the ddname for the bulk data    *
         *                                                            *
         *            The To: tag is the delimiter between mail       *
         *                                                            *
         *            CC: indicates whom else to copy on the mail     *
         *                and must follow its respective TO:          *
         *                May be repeated for multiple addresses      *
         *                                                            *
         *            From from-email-address                         *
         *                 this is the e-mail address of the          *
         *                 sender (and where replies will be          *
         *                 sent).                                     *
         *                                                            *
         *            >file format                                    *
         *              - The >file indicates that all records        *
         *                following are to be processed as a file     *
         *                attachment.                                 *
         *              - format is the xmitip format for the file    *
         *                attachment                                  *
         *                                                            *
         * Optional keywords:                                         *
         *                                                            *
         *            html - send text as html (rich text) message    *
         *            config - an xmitip configuration file           *
         *                     (see XMITIP users guide for CONFIG     *
         *                      option).                              *
         *            configdd - an xmitip configuration dd           *
         *                                                            *
         * Dependencies:                                              *
         *            Invokes XMITIP                                  *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            05/16/06 - Add CONFIG and CONFIGDD options      *
         *            12/02/03 - Add CC option                        *
         *            02/05/03 - Add subject for >file                *
         *            06/17/02 - Add subject to report                *
         *            05/13/02 - Several corrections                  *
         *            04/29/02 - Add HTML option                      *
         *            01/11/02 - Creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         parse arg options
         uopt = translate(options)
         parse var options bulkdsn .
         parse var uopt bulkdsn opt
         parse value "" with null hopt html config
         filedd = "XMB"random(9999)

         if word(opt,1) = "FROM" then
            from = "From" word(options,3)
          else from = ""

         if wordpos("HTML",opt) > 0 then do
            hopt = "as html"
            html = "html"
            end

         if wordpos("CONFIG",opt) > 0 then do
            wp = wordpos("CONFIG",opt) + 1
            config = "CONFIG" word(opt,wp)
            end

         if wordpos("CONFIGDD",opt) > 0 then do
            wp = wordpos("CONFIGDD",opt) + 1
            config = "CONFIGDD" word(opt,wp)
            end

         dd = 0
         if left(bulkdsn,3) = "DD:" then do
            parse var bulkdsn "DD:"bdd
            dd = 1
            end
         else if sysdsn(bulkdsn) <> "OK" then do
                 say "Error on input dataset:" bulkdsn
                 say sysdsn(bulkdsn)
                 exit 8
                 end

          if dd = 0 then do
             bdd = "bulk"random(9999)
             "Alloc f("bdd") ds("bulkdsn") shr reuse"
             end
          "Execio * diskr" bdd "(finis stem in."
          if dd = 0 then
             "Free  f("bdd")"

          parse value "" with null to subject file format

          do i = 1 to in.0
             Select
             when translate(word(in.i,1)) = "TO:"
                  then do
                       if to <> null then call do_xmit
                       parse var in.i . to .
                       drop out.
                       parse value "" with file format xmcc
                       c = 1
                       cc = null
                       end
             when translate(word(in.i,1)) = "CC:"
                  then do
                       parse var in.i . ccaddr
                       cc = strip(cc ccaddr)
                       end
             when translate(word(in.i,1)) = "SUBJECT:"
                  then do
                       parse var in.i . subject
                       subject = strip(subject)
                       end
             when translate(word(in.i,1)) = ">FILE"
                  then do
                       parse var in.i file format .
                       if length(format) > 0 then
                          format = "Format" format
                       file.0 = 0
                       lrecl  = 0
                       end
             otherwise do
                       if file = null then do
                          out.c = in.i
                          c     = c + 1
                          end
                       else do
                            f = file.0 + 1
                            file.f = in.i
                            file.0 = f
                            if length(file.f) > lrecl
                               then lrecl = length(file.f)
                            end
                       end
             end
          end
          call do_xmit
          Exit 0

          Do_Xmit:
             say " "
             Say "Sending e-mail to:" to hopt
             if words(cc) > 0 then do
                do cci = 1 to words(cc)
                   Say "             copy:" word(cc,cci)
                   end
                xmcc = "CC ("cc")"
                end
             Say "          subject:" subject
             say " "
             Queue "  "
             if hopt <> null then
                Queue "<html><body><pre>"
             do x = 1 to c-1
                Queue out.x
                end
             if hopt <> null then
                Queue "</pre><p>"
             if file = null then
                "XMITIP" to "MSGQ Subject '"subject"'" from html,
                         xmcc config
             else do
                  call msg "off"
                  "Alloc f("filedd") new spa(30,30) tr" ,
                        "recfm(v b) lrecl("lrecl+4") blksize(0)"
                  "Execio * diskw" filedd "(finis stem file."
                  "XMITIP" to "MSGQ Subject '"subject"'" from html ,
                          "filedd" filedd format xmcc
                  "Free f("filedd")"
                  drop file.
                  end
             return
