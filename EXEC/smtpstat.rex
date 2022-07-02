        /* --------------------  rexx procedure  -------------------- *
         * Name:      smtpstat                                        *
         *                                                            *
         * Function:  generate smtp statistics                        *
         *                                                            *
         * Local Customization is required.  Find *CUSTOM*            *
         *                                                            *
         * Syntax:    %smtpstat logfile csvfile ( options             *
         *                                                            *
         *            logfile is required and references the SMTP     *
         *                    LOGFILE data                            *
         *                    * may be coded as DD:ddname             *
         *                                                            *
         *            csvfile is optional                             *
         *            may be dsname or dd:ddname                      *
         *                                                            *
         *            ( required to separate the options              *
         *                                                            *
         *            Valid options:                                  *
         *                                                            *
         *            NORPT                                           *
         *             do not create the report file                  *
         *            NOCSV                                           *
         *             do not create the csv file                     *
         *            NOLOC                                           *
         *             no details of local mail                       *
         *            NOEXT                                           *
         *             no details of external mail                    *
         *            NODET                                           *
         *             no details                                     *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *          2009-03-20 - Update for new xmitldap parms        *
         *          2008-11-10 - Update for new xmitldap parm         *
         *          2004-06-07 - No command options noloc/noext/nodet *
         *                       thx to eric hamtiaux                 *
         *          2004-05-17 - Remove size (invalid) from text page *
         *                       message line in the report           *
         *          2004-03-30 - Add ldap lookup of address for       *
         *                       Summary Info report section          *
         *          2004-03-04 - Minor typo correction                *
         *          2004-02-10 - Add options                          *
         *          2004-02-09 - Add EZA5501I mail too large          *
         *                       and thus discarded                   *
         *          2003-12-01 - Change Sort blksizes from 0 to 27998 *
         *          2003-11-12 - Correction for report title          *
         *          2003-08-30 - Fix those lines > 80                 *
         *          2003-08-29 - Redesign to sort using real SORT     *
         *                     - put report to dd REPORT              *
         *                       so SYSTSPRT is now sysout            *
         *                     - add summary count by sender          *
         *          2003-08-28 - Minor cleanup                        *
         *          2003-08-27 - Enhance to report on all mail and    *
         *                       include date/time stamps             *
         *          2003-07-21 - Add Mail Reject stats                *
         *          2003-04-21 - Add Text Messaging stats             *
         *                       (assuming to addr is all numeric)    *
         *          2002-12-10 - Fix if no messages (thx John Kamp)   *
         *          2002-07-15 - Correciton for one counter           *
         *          2002-06-24 - Add test for non-logfile and exit    *
         *          2002-06-14 - Sort list of outside mail and mail   *
         *                       larger than limit                    *
         *          2002-05-22 - Allow logfile to be a DDname         *
         *          2002-05-20 - Major changes to csv reporting       *
         *          2002-01-31 - Updates for nje deliveries           *
         *                     - report remote nodes that deliver     *
         *                       to this site                         *
         *          2001-09-21 - fix long records in code             *
         *                     - clean up format for limit in report  *
         *          2001-07-31 - add report of over xM messages       *
         *          2001-06-29 - fix divide by zero                   *
         *          2001-06-28 - correction for starting in mid-log   *
         *          2000-12-18 - creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         arg options

         parse value options with logfile csvfile "(" options

        /* ---------------------------------------------------------- *
         * Test for a passed logfile dsname and if none then          *
         * let the user know and terminate.                           *
         * ---------------------------------------------------------- */
         if length(logfile) = 0 then do
            say "Error: No logfile data set name provided."
            say "       Find a SMTP logfile data set and try again."
            say "       Ending........"
            Exit 16
            end

        /* ---------------------------------------------------------- *
         * Test for a passed csvfile dsname and if none then          *
         * let the user know and terminate.                           *
         * ---------------------------------------------------------- */
         csvdd = ""
         if length(csvfile) = 0 then nop
         else do
            if left(csvfile,3) = "DD:" then
               parse value csvfile with "DD:"csvdd
            else
            if "OK" = sysdsn(csvfile) then do
                say "Error: The csvfile dataset already exists"
                say "       and it must not. Try again with a new"
                say "       dataset name that doesn't exist."
                say "       Ending........"
                Exit 16
                end
             end

        /* --------------- *
         * Process Options *
         * --------------- */
         if wordpos("NOCSV",options) > 0 then nocsv = 1
                                         else nocsv = 0
         if wordpos("NORPT",options) > 0 then norpt = 1
                                         else norpt = 0
         if wordpos("NOLOC",options) > 0 then noloc = 1  /* eha */
                                         else noloc = 0  /* eha */
         if wordpos("NOEXT",options) > 0 then noext = 1  /* eha */
                                         else noext = 0  /* eha */
         if wordpos("NODET",options) > 0 then nodet = 1  /* eha */
                                         else nodet = 0  /* eha */

        /* ---------------------------------------------------------- *
         * setup default values for use in the code                   *
         * ---------------------------------------------------------- */
         Parse value "" with null fromd fromt tod tot nodes anodes ,
                             savedate senders local_nodes

         call init_daily

         parse value "0 0 0 0" with arecipients absmtp areceive aerror
         parse value "0 0 0 0" with alocal aother atotal_bytes anje
         parse value "0 0 0 0" with remoteu atot_notes maxc days
         parse value "0 0 0 0" with amax_deliver amax_mail aover_1m atot_1m
         parse value "0 0 0 0" with pager areject localu max_from
         parse value "0 0 0 0" with max_to discard adiscard discardc
         parse value "0 0 0"   with id_bad id_good id_unk

         parse value "P L R" with op ol or

         rep_c = 0
         csv_c = 1
         csv.csv_c = 'Day,Date,Time,System,Sent,Received,"Average size",' ,
              || '"Total Recipients","Local Recipients","NJE Recipients",' ,
              || '"Other Recipients","Error Notices","Max Recipients",' ,
              || '"Max Mail Size","# Mails > 1MB","Avg Mail > 1MB",',
              || '"Total Bytes","Total Pages","Total Reject","Discarded"'
         maxlrecl = length(csv.csv_c)

         sysname = mvsvar('sysname')
         numeric digits 15

        /* ---------------------------------- *
         * Set Limit for reporting at 10M - 1 *
         * *CUSTOM*                           *
         * ---------------------------------- */
         limit = 10000000 - 1

        /* ---------------------------------------------------------- *
         * setup ddname name and allocate the logfile                 *
         * then read it all in and free it.                           *
         * ---------------------------------------------------------- */
         if left(logfile,3) = "DD:" then do
            parse value logfile with "DD:"dd
            "Execio * diskr" dd "(finis stem in."
            end
         else do
              dd = "smtp"random(9999)
              "Alloc f("dd") shr reuse ds("logfile")"
              "Execio * diskr" dd "(finis stem in."
              "Free  f("dd")"
              end

        /* -------------------------------------------------------- *
         * Process first 10 records of the logfile to validate that *
         * it is a logfile.  If not then exit and tell someone.     *
         * -------------------------------------------------------- */
         hit = 0
         do i = 1 to 10
            if pos("EZA",in.i,1) > 0 then hit = 1
            end
            if hit = 0 then do
               say "Error: The logfile does not appear to be a valid",
                   "SMTP LOGFILE."
               say "First 5 records found:"
               do i = 1 to 5
                  say in.i
                  end
               say "Exiting ...."
               exit 8
               end

        /* ---------------------------------------------------------- *
         * Process the logfile contents categorizing and counting     *
         * the records we are interested in.                          *
         * ---------------------------------------------------------- */
          do i = 1 to in.0
             if pos("EZA5125",in.i) > 0 then iterate
             if pos("EZA5126",in.i) > 0 then iterate
             parse value in.i with x tod tot .
             if savedate = null then do
                savedate = tod
                savetime = tot
                end
             if tod <> savedate then call new_date
             savedate = tod
             savetime = tot
             Select
                When pos("EZA5460",in.i) > 0 then
                     if fromd = null then
                        parse value in.i with x fromd fromt .
                When pos("EZA5501I",in.i) > 0 then do
                     discard  = discard + 1
                     adiscard = adiscard + 1
                     discardc = discardc + 1
                     parse value in.i with msg date time . "<"dfrom">" .
                     time = left(time,8)
                     discard.discardc = date time dfrom
                     end
                When pos("EZA5461I",in.i) > 0 then do
                        parse value in.i with . "Helo Domain:" node .
                        if wordpos(translate(node),nodesu) = 0 then do
                           nodes  = nodes node
                           anodes = anodes node
                           nodesu = translate(nodes)
                           end
                        end
                When pos("EZA5474I",in.i) > 0 then do
                     bsmtp  = bsmtp + 1
                     absmtp = absmtp + 1
                     parse value in.i with msg date time . "Note" ,
                           note . "<"fuid">" bytes "Bytes" .
                     note  = note + 0
                     enote = note
                     note.note  = bytes
                     anote.note = bytes
                     note.uid.note = fuid
                     tot_notes    = tot_notes + 1
                     total_bytes  = total_bytes + bytes
                     max_mail     = max(max_mail,bytes)
                     if bytes > 999999 then do
                        over_1m = over_1m + 1
                        tot_1m  = tot_1m + bytes
                        end
                     note.note.count = 0
                     anote.note.count = 0
                     note.summ = strip(note.summ note)
                     if bytes > limit then do
                        parse value in.i with . "<"maxf">" .
                        maxc  = maxc + 1
                        maxm.maxc = date time maxf bytes
                        if length(maxf) > max_from
                           then max_from = length(maxf)
                        end
                     end
                When pos("EZA5550I",in.i) > 0 then do
                     reject = reject + 1
                     areject = areject + 1
                     end
                When pos("EZA5472I",in.i) > 0 then do
                     error  = error + 1
                     aerror = aerror + 1
                     end
                When pos("EZA5475I",in.i) > 0 then do
                     receive  = receive + 1
                     areceive = areceive + 1
                     parse value in.i with . "Note" note ,
                            . "From <"enote">" ,
                            bytes "Bytes" .
                     if enote = null then enote = "Unknown"
                     note  = note + 0
                     note.note = bytes
                     anote.note = bytes
                     note.uid.note = enote
                     tot_notes    = tot_notes + 1
                     if bytes > 999999 then do
                        over_1m = over_1m + 1
                        tot_1m  = tot_1m + bytes
                        end
                     max_mail     = max(max_mail,bytes)
                     total_bytes  = total_bytes + bytes
                     note.note.count = 0
                     anote.note.count = 0
                     note.summ  = strip(note.summ note)
                     anote.summ = strip(anote.summ note)
                     end
                When pos("EZA5476I",in.i) > 0 then do
                     recipients  = recipients + 1
                     arecipients = arecipients + 1
                     if pos(" at ",in.i) = 0 then
                     parse value in.i with x rdate rtime . ,
                           "Note" enote . "<"tuid">"
                     else
                     parse value in.i with x rdate rtime . ,
                           "Note" enote . tuid .
                     enote = enote + 0
                     if datatype(note.enote.count) <> "NUM" then
                        note.enote.count = 0
                     if datatype(anote.enote.count) <> "NUM" then
                        anote.enote.count = 0
                     note.enote.count  = note.enote.count + 1
                     anote.enote.count = anote.enote.count + 1
                     max_deliver  = max(max_deliver,note.enote.count)
                     if left(note.uid.enote,8) = "NOTE.UID"
                        then note.uid.enote = "Unknown"
                    /* -------------------------------------------------- *
                     * *CUSTOM*                                           *
                     *                                                    *
                     * Each installation needs to customize the following *
                     * to test for the local domains for your company.    *
                     *                                                    *
                     * Each test needs to update the counters and call    *
                     * add_local                                          *
                     * -------------------------------------------------- */
                     Select
                        When pos("KP.ORG",translate(tuid)) > 0 then do
                           local  = local + 1
                           alocal = alocal + 1
                           call add_local
                           end
                        When pos("KAISER.ORG",translate(tuid)) > 0 then do
                           local  = local + 1
                           alocal = alocal + 1
                           call add_local
                           end
                        When pos("KAIPERM.ORG",translate(tuid)) > 0 then do
                           local  = local + 1
                           alocal = alocal + 1
                           call add_local
                           end
                        When pos(" at ",in.i) > 0 then do
                           nje   = nje + 1
                           anje  = anje + 1
                           call add_local
                           end
                        Otherwise do
                           other  = other + 1
                           aother = aother + 1
                           remoteu = remoteu + 1
                           parse value tuid with tow"@".
                           if datatype(tow) = "NUM" then do
                              tot_pages = tot_pages + 1
                              end
                           remote.remoteu = strip(note.uid.enote) ,
                                            tuid rdate rtime
                           if length(tuid) > max_to
                              then max_to = length(tuid)
                           if length(note.uid.enote) > max_from
                              then max_from = length(note.uid.enote)
                           end
                       End
                     end
                Otherwise nop
             end
          end

        /* ----------------------------------------------------------- *
         * Have processed all of the SMTP Logfile.                     *
         * Now close out the daily report and create the final report. *
         * ----------------------------------------------------------- */
          call new_date
          call final_report
          if norpt = 0 then
             "Execio * diskw REPORT (Finis stem report."
          if nocsv = 0 then
             if length(csvfile) > 0 then
                call do_csvreport

          exit

        /* --------------------------------- *
         * Add information for local e-mails *
         * --------------------------------- */
         Add_Local:
           localu = localu + 1
           local_mail.localu = strip(note.uid.enote) tuid rdate rtime
           if length(note.uid.enote) > max_from
              then max_from = length(note.uid.enote)
           if length(tuid) > max_to
              then max_to = length(tuid)
           return

        /* ------------------------ *
         * Process individual dates *
         * ------------------------ */
         New_Date:
         days = days + 1
         atot_1m = atot_1m + tot_1m
         aover_1m = aover_1m + over_1m
         atot_notes   = atot_notes + tot_notes
         amax_mail    = max(amax_mail,max_mail)
         atotal_bytes = atotal_bytes + total_bytes
         amax_deliver = max(amax_deliver,max_deliver)
         pager        = pager + tot_pages

         if length(csvfile) = 0 then do
            call init_daily
            return
            end

         c   = words(note.summ)
         if c = 0 then
            avg = 0
         else
            avg = total_bytes/tot_notes
         parse value avg with avg"." .
         if over_1m > 0 then
            avg_1m = tot_1m/over_1m
         else
           avg_1m = 0
         parse value avg_1m with avg_1m"." .
         csv_c = csv_c + 1
         dow = date('w',savedate,'u')
         csv.csv_c = dow','savedate','savetime','sysname','bsmtp',' ,
            || receive','avg','recipients','local','nje','other',' ,
            || error','max_deliver','max_mail','over_1m','avg_1m',' ,
            || total_bytes','tot_pages','reject','discard
         call init_daily
         return

        /* ----------------------------- *
         * Initialize the daily counters *
         * ----------------------------- */
         Init_Daily:
         parse value "0 0 0 0" with recipients bsmtp receive error
         parse value "0 0 0 0" with local other total_bytes nje
         parse value "0 0 0 0" with tot_notes tot_pages reject discard
         parse value "0 0 0 0" with max_deliver max_mail over_1m tot_1m
         return

        /* --------------------------- *
         * Now generate the csv report *
         * --------------------------- */
         Do_CSVreport:
         if csvdd = null then do
             do ic = 1 to csv_c
                if length(csv.ic) > maxlrecl then
                   maxlrecl = length(csv.ic)
                end
            "Alloc f("dd") new spa(90,90) release",
              "dsname("csvfile") recfm(v b)",
              "lrecl("maxlrecl+4") blksize(0)"
            "Execio * diskw" dd "(finis stem csv."
            "Free f("dd")"
            end
         else "Execio * diskw" csvdd "(finis stem csv."
         return

        /* ------------------------ *
         * Add record to the Report *
         * ------------------------ */
         Add_Report: procedure expose rep_c report.
         parse arg line
         if norpt = 1 then return
         rep_c = rep_c + 1
         report.rep_c = line
         return

        /* ---------------------------------------------------------- *
         * Now report out the statistics we gleaned from the          *
         * SMTP Logfile using Add_Report subroutine.                  *
         * ---------------------------------------------------------- */
         Final_Report:
          avg = atotal_bytes/atot_notes
          parse value avg with avg"." .
          Call Add_Report " "
          Call Add_Report "SMTP Statistics from" fromd fromt "to" tod tot ,
              mvsvar('sysname')
          Call Add_Report left("Category",30) right("Count",14)
          Call Add_Report left("-",35,"-")
          fnum = trans_num(absmtp)
          Call Add_Report left("Host Messages Sent :",30) right(fnum,14)
          fnum = trans_num(areceive)
          Call Add_Report left("SMTP Message Received :",30) right(fnum,14)
          fnum = trans_num(atotal_bytes)
          Call Add_Report left("SMTP Total Bytes Sent :",30) right(fnum,14)
          fnum = trans_num(avg)
          Call Add_Report left("SMTP Average E-Mail Size:",30) right(fnum,14)
          fnum = trans_num(arecipients)
          Call Add_Report left("SMTP Recipients Total :",30) right(fnum,14)
          fnum = trans_num(alocal)
          Call Add_Report left("SMTP Recipients Local :",30) right(fnum,14)
          fnum = trans_num(anje)
          Call Add_Report left("SMTP Recipients NJE :",30) right(fnum,14)
          fnum = trans_num(aother)
          Call Add_Report left("SMTP Recipients Other :",30) right(fnum,14)
          fnum = trans_num(aerror)
          Call Add_Report left("SMTP Error Notices :",30) right(fnum,14)
          fnum = trans_num(pager)
          Call Add_Report left("SMTP Text Pages Sent :",30) right(fnum,14)
          fnum = trans_num(areject)
          Call Add_Report left("SMTP Rejected Mail :",30) right(fnum,14)
          fnum = trans_num(adiscard)
          Call Add_Report left("SMTP Discarded Mail:",30) right(fnum,14)

        /* --------------------------------------------------------- *
         * Report max and avg values                                 *
         * --------------------------------------------------------- */
          if aover_1m > 0 then
             avg_1m = atot_1m/aover_1m
          else
            avg_1m = 0
          parse value avg_1m with avg_1m"." .
          /* set csv final total records */
          csv_c = csv_c + 1
          csv.csv_c = "   "
          csv_c = csv_c + 1
          csv.csv_c = "final,summary,report,"sysname','absmtp',' ,
             || areceive','avg','arecipients','alocal','anje','aother',' ,
             || aerror','amax_deliver','amax_mail','aover_1m','avg_1m',' ,
             || atotal_bytes','pager','areject','adiscard

          Call Add_Report left("Maximum Recipients :",30) ,
                          right(amax_deliver,14)
          amax_mail = trans_num(amax_mail)
          Call Add_Report left("Maximum Mail Size :",30) right(amax_mail,14)
          Call Add_Report left("# Mails over 1MB in size:",30) ,
                          right(aover_1m,14)
          avg_1m = trans_num(avg_1m)
          Call Add_Report left("Average size of mail>1mb:",30) ,
                          right(avg_1m,14)

        /* --------------------------------------------------------- *
         * Report on the Nodes who sent us e-mail                    *
         * --------------------------------------------------------- */
         if words(anodes) > 0 then do
            csv_c = csv_c + 1
            csv.csv_c = "   "
            csv_c = csv_c + 1
            csv.csv_c = "Nodes Messages Received From"
            end
         if words(anodes) > 0 then do
            w = words(anodes)
            Call Add_Report " "
            Call Add_Report left("Nodes Received from :",30) right(w,14)
            do i = 1 to w
               Call Add_Report "->" word(anodes,i)
                csv_c = csv_c + 1
                csv.csv_c = '"From Node",'word(anodes,i)
               end
            end

        /* --------------------------------------------------------- *
         * Report all messages over limit                            *
         * --------------------------------------------------------- */
         if maxc > 0 then do
            csv_c = csv_c + 1
            csv.csv_c = " "
            csv_c = csv_c + 1
            csv.csv_c = "Messages over size limit (sorted by size)"
            csv_c = csv_c + 1
            csv.csv_c = "Date,Time,From,Size"
            Call Add_Report " "
            limit = trans_num(limit)
            Call Add_Report "The following senders messages exceeded the" ,
                            "limit of:" limit "(sorted by size)"
            Call Add_Report " "
            Call Add_Report left("Date",8) left("Time",8) ,
                 left("From",max_from+2) "Bytes"
            maxm.0 = maxc
            call sort_bigusers
            do i = 1 to maxc
               parse value maxm.i with date time from size
               size = strip(size)
               csv_c = csv_c + 1
               csv.csv_c = date","time","from","size
               size = trans_num(size)
               Call Add_Report date time left(from,max_from+2) size
              end
           end

        /* --------------------------------------------------------- *
         * Report all discarded messages (too large to send)         *
         * --------------------------------------------------------- */
         if discardc > 0 then do
            csv_c = csv_c + 1
            csv.csv_c = " "
            csv_c = csv_c + 1
            csv.csv_c = "Discarded Messages - not sent as too large"
            csv_c = csv_c + 1
            csv.csv_c = "Date,Time,From"
            Call Add_Report " "
            Call Add_Report "The following messages were discarded from:"
            Call Add_Report " "
            Call Add_Report left("Date",8) left("Time",8) "From"
            Call Add_Report " "
            discard.0 = discardc
            call sort_discards
            do i = 1 to discard.0
               parse value discard.i with d t f
               call add_report left(d,8) left(t,8) f
               csv_c = csv_c + 1
               csv.csv_c = d","t","f
               end
            end

        /* ------------------------------------ *
         * Now Sort the Loca and Remote Details *
         * ------------------------------------ */
         local_mail.0 = localu
         remote.0     = remoteu

         call sort_local
         call sort_remoteids

        /* ----------------------------------- *
         * Report messages sent to text pagers *
         * ----------------------------------- */
         if pager > 0 then do
            csv_c = csv_c + 1
            csv.csv_c = " "
            csv_c = csv_c + 1
            csv.csv_c = "Text Messaging Pages Sent"
            csv_c = csv_c + 1
            csv.csv_c = "Date,Time,From,To"
            Call Add_Report " "
            Call Add_Report "The following messages were sent to text" ,
                "messaging devices:"
            Call Add_Report " "
            Call Add_Report left("Date",8) left("Time",8) ,
                            left("From",max_from+2) "To"
            do i = 1 to remote.0
               parse value remote.i with from to date time
               parse value to with tow"@".
               if datatype(tow) <> "NUM" then iterate
               Call Add_Report date time left(from,max_from+2) ,
                               left(to,max_to+2)
               csv_c = csv_c + 1
               csv.csv_c = date','time','from','to
               call sender_summary 'p'
               end
            end

         /* ---------------------------- *
          * Report messages sent locally *
          * ---------------------------- */
          if localu > 0 & noloc = 0 & nodet = 0 then do     /* eha */
            csv_c = csv_c + 1
            csv.csv_c = " "
            csv_c = csv_c + 1
            csv.csv_c = "Messages Sent Inside the Company"
            csv_c = csv_c + 1
            csv.csv_c = "Date,Time,From,To"
            Call Add_Report " "
            Call Add_Report "The following messages were sent locally"
            Call Add_Report " "
            Call Add_Report left("Date",8) left("Time",8) ,
                            left("From",max_from+2) "To"
            do i = 1 to localu
               parse value local_mail.i with from to date time
               parse value to with tow"@".
               if datatype(tow) = "NUM" then iterate
               Call Add_Report date time left(from,max_from+2) ,
                               left(to,max_to+2)
               csv_c = csv_c + 1
               csv.csv_c = date','time','from','to
               call sender_summary 'l'
               end
            end

         /* ------------------------------- *
          * Report messages sent externally *
          * ------------------------------- */
          if remote.0 > 0 & noext = 0 & nodet = 0 then do   /* eha */
            csv_c = csv_c + 1
            csv.csv_c = " "
            csv_c = csv_c + 1
            csv.csv_c = "Messages Sent Outside Company"
            csv_c = csv_c + 1
            csv.csv_c = "Date,Time,From,To"
            Call Add_Report " "
            Call Add_Report "The following messages were sent outside"
            Call Add_Report " "
            Call Add_Report left("Date",8) left("Time",8) ,
                            left("From",max_from+2) "To"
            do i = 1 to remote.0
               parse value remote.i with from to date time
               parse value to with tow"@".
               if datatype(tow) = "NUM" then iterate
               Call Add_Report date time left(from,max_from+2) ,
                               left(to,max_to+2)
               csv_c = csv_c + 1
               csv.csv_c = date','time','from','to
               call sender_summary 'r'
               end
            end

        /* --------------------------------- *
         * Report Sender Summary Information *
         * --------------------------------- */
         summ.0 = 0
         if length(senders) > 0 then do
            sender_c = words(senders)
            do i = 1 to sender_c
               summ.i = word(senders,i)
               end
            summ.0 = i
            call Sort_Summary
            csv_c = csv_c + 1
            csv.csv_c = " "
            csv_c = csv_c + 1
            csv.csv_c = "Summary Information by Sender"
            csv_c = csv_c + 1
            csv.csv_c = "From,Count,Pager,Local,Remote,Flag"
            Call Add_Report " "
            Call Add_Report "Sender Summary Report "
            Call Add_Report " "
            Call Add_Report left("From",max_from+2) right("Count",8) ,
                            right("Pager",8) right("Local",8) ,
                            right("Remote",8) "Flag"
            do i = 1 to summ.0
               from =  summ.i
               count = senders.from
               x = test_mail(from)
               if x = 0 then id_flag = "OK"
               if x = 4 then id_flag = "NG"
               if x = 12 then id_flag = "UNK"
               Call Add_Report left(from,max_from+2) ,
                               right(trans_num(count),8) ,
                               right(trans_num(senders.from.op),8) ,
                               right(trans_num(senders.from.ol),8) ,
                               right(trans_num(senders.from.or),8),
                               id_flag
               csv_c = csv_c + 1
               csv.csv_c = from','senders.from","senders.from.op"," ,
                           senders.from.ol","senders.from.or","id_flag
               end
            if id_good + id_bad > 0 then do
               call Add_Report "Good Addresses:" id_good ,
                               "Invalid Addresses:" id_bad ,
                               "Unknown Addresses:" id_unk ,
               csv_c = csv_c + 1
               csv.csv_c = "Good Addresses,"id_good ,
                           ",Invalid Addresses,"id_bad ,
                           ",Unknown Addresses,"id_unk
               end
            end

         Return

        /* -------------------------------- *
         * Build Sender Summary Information *
         * -------------------------------- */
         Sender_Summary:
         arg opt
         from = translate(from)
         if wordpos(from,senders) = 0 then do
            senders = senders from
            senders.from = 1
            if opt = op then senders.from.op = 1
                        else senders.from.op = 0
            if opt = ol then senders.from.ol = 1
                        else senders.from.ol = 0
            if opt = or then senders.from.or = 1
                        else senders.from.or = 0
            end
         else do
              senders.from = senders.from + 1
              senders.from.opt = senders.from.opt + 1
              end
         return

        /* ----------------------------------------------- *
         * Sort the list of userids that exceed max bytes  *
         * ----------------------------------------------- */
         Sort_BigUsers: procedure expose maxm.
         /* Simple bubble sort of "stem' by stem.1
            Ken Singer, Shell Oil, Houston          */

           if maxm.0 = 1 then return /* simple sort !*/
           ctr =  maxm.0
           do y = 1 to  ctr - 1
              do x = y+1 to ctr
                 pre = word(maxm.x,4)
                 next = word(maxm.y,4)
                 if pre < next then do
                    /* swap these 2 entries */
                    t1 = maxm.y ;
                    maxm.y = maxm.x
                    maxm.x = t1
                    end
              end x
           end y
         return

        /* ----------------------------------------------- *
         * Sort the list of discarded from addresses       *
         * ----------------------------------------------- */
         Sort_Discards: procedure expose discard.
         /* Simple bubble sort of "stem' by stem.1
            Ken Singer, Shell Oil, Houston          */

           if discard.0 = 1 then return /* simple sort !*/
           ctr =  discard.0
           do y = 1 to  ctr - 1
              do x = y+1 to ctr
                 pre = word(discard.x,3)
                 next = word(discard.y,3)
                 if pre < next then do
                    /* swap these 2 entries */
                    t1 = discard.y ;
                    discard.y = discard.x
                    discard.x = t1
                    end
              end x
           end y
         return

        /* ----------------------------------------------- *
         * Sort the list of userids that send local mail   *
         * ----------------------------------------------- */
         Sort_Local: procedure expose local_mail. max_from

           if local_mail.0 = 1 then return /* simple sort !*/
           "Alloc f(sysout) ds(*) reuse"
           "Alloc f(sortin) unit(sysallda) spa(90,90) tr" ,
               "recfm(v b) lrecl(150) blksize(27998)"
           "Alloc f(sortout) unit(sysallda) spa(90,90) tr" ,
               "recfm(v b) lrecl(150) blksize(27998)"
           "Alloc f(sysin) unit(sysallda) spa(1,1) tr" ,
               "recfm(f b) lrecl(80) blksize(23440) reuse"
           sortcc.1 = " SORT FIELDS=(5,"max_from",CH,A)"
           "Execio * diskw sysin (finis stem sortcc."
           "Execio * diskw sortin (finis stem local_mail."
           drop local_mail.
           "Call *(Sort)"
           "Execio * diskr sortout (finis stem local_mail."
           "Free f(sysin sortin sortout sysout)"
           "Alloc f(sysin) ds(*) reuse"
         return

        /* ----------------------------------------------- *
         * Sort the list of userids that send outside mail *
         * ----------------------------------------------- */
         Sort_RemoteIDs: procedure expose remote. max_from

           if remote.0 = 1 then return /* simple sort !*/
           "Alloc f(sysout) ds(*) reuse"
           "Alloc f(sortin) unit(sysallda) spa(90,90) tr" ,
               "recfm(v b) lrecl(150) blksize(0)"
           "Alloc f(sortout) unit(sysallda) spa(90,90) tr" ,
               "recfm(v b) lrecl(150) blksize(0)"
           "Alloc f(sysin) unit(sysallda) spa(1,1) tr" ,
               "recfm(f b) lrecl(80) blksize(0) reuse"
           sortcc.1 = " SORT FIELDS=(5,"max_from",CH,A)"
           "Execio * diskw sysin (finis stem sortcc."
           "Execio * diskw sortin (finis stem remote."
           drop remote.
           "Call *(Sort)"
           "Execio * diskr sortout (finis stem remote."
           "Free f(sysin sortin sortout sysout)"
           "Alloc f(sysin) ds(*) reuse"
         return

        /* --------------------------------------- *
         * Sort the Sender Summary List of Senders *
         * --------------------------------------- */
         Sort_Summary: procedure expose summ. max_from

           "Alloc f(sysout) ds(*) reuse"
           "Alloc f(sortin) unit(sysallda) spa(90,90) tr" ,
               "recfm(v b) lrecl(150) blksize(0)"
           "Alloc f(sortout) unit(sysallda) spa(90,90) tr" ,
               "recfm(v b) lrecl(150) blksize(0)"
           "Alloc f(sysin) unit(sysallda) spa(1,1) tr" ,
               "recfm(f b) lrecl(80) blksize(0) reuse"
           sortcc.1 = " SORT FIELDS=(5,"max_from",CH,A)"
           "Execio * diskw sysin (finis stem sortcc."
           "Execio * diskw sortin (finis stem summ."
           drop summ.
           "Call *(Sort)"
           "Execio * diskr sortout (finis stem summ."
           "Free f(sysin sortin sortout sysout)"
           "Alloc f(sysin) ds(*) reuse"
         return

        /* --------------------------------------------------------- *
         * translate a number to standard format                     *
         * --------------------------------------------------------- */
          trans_num: procedure
          arg num
          str=strip(translate('0,123,456,789,abc,def', ,
                    right(num,16,','), ,
                   '0123456789abcdef'),'L',',')
          num = strip(str)
          return num

        /* ----------------------------- *
         * Get LDAP information *custom* *
         * ----------------------------- */
         Get_Nodes:
         x=xmitldap()
         parse value x with . "/" . "/" . "/" . "/" local_nodes ,
                              "/" .
         local_nodes = translate(local_nodes)
         return

        /* -------------------------------- *
         * Test e-mail address for validity *
         * *custom*                         *
         * Set to Return if not using ldap  *
         * -------------------------------- */
         Test_Mail: Procedure expose id_good id_bad ,
                    local_nodes id_unk
         arg email
         /* return 0 */
         if local_nodes = "" then call get_nodes
         rc = xmitipid(email)
         if rc > 0 then id_bad = id_bad + 1
         else do
              hit = 0
              do i = 1 to words(local_nodes)
                 if pos(word(local_nodes,i),email) > 0 then hit = 1
                 end
              if hit = 1 then
                 id_good = id_good + 1
              else do
                   id_unk = id_unk + 1
                   rc = 12
                   end
              end
         return rc
