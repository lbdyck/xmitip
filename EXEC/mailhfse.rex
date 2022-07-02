        /* --------------------  rexx procedure  ------------------- *
         * Name:      MAILHFSE                                       *
         *                                                           *
         * Function:  To send via XMITIP in Report format the        *
         *            dataset(member) currently being Edited.        *
         *                                                           *
         * Syntax:    %xmitihfs e-mail@address report-opt            *
         *                                                           *
         *            report-opt if null defaults to rtf             *
         *                  anything else and txt is used.           *
         *                                                           *
         * Author:    Mrs. Lindy Mayfield                            *
         *            SAS EMEA Technical Support                     *
         *            Heidelberg, Germany                            *
         *                                                           *
         * Created from EDITMAIL to work with Edit under ISHELL      *
         *         of a file in an HFS.                              *
         * --------------------------------------------------------- *
         *         2008-10-04 - Update XMITIPCU parse                *
         *         2001-04-23 - AtSign Support (FEC)                 *
         * --------------------------------------------------------- */

        /* ----------------------------------------------------- *
         * Invoke XMITIPCU for local customization values        *
         * ----------------------------------------------------- */

        cu = xmitipcu()
        if datatype(cu) = "NUM" then exit cu

        /* ----------------------------------------------------- *
         * parse the customization defaults to use them here     *
         * ----------------------------------------------------- *
         * parse the string depending on the used separator      *
         * ----------------------------------------------------- */

        if left(cu,4) = "SEP=" ,
        then do ;
                 parse var cu "SEP=" _s_ cu
                 _s_val_d_ = c2d(_s_)
                 _s_val_x_ = c2x(_s_)
             end;
        else     _s_ = left(strip(cu),1)

        parse value cu with ,
             (_s_) _center_ (_s_) zone (_s_) smtp ,
             (_s_) vio (_s_) smtp_secure (_s_) smtp_address ,
             (_s_) smtp_domain (_s_) text_enter ,
             (_s_) sysout_class (_s_) from_center (_s_) writer ,
             (_s_) mtop (_s_) mbottom (_s_) mleft (_s_) mright ,
             (_s_) tcp_hostid (_s_) tcp_name (_s_) tcp_domain ,
             (_s_) tcp_stack  ,
             (_s_) from_default ,
             (_s_) append_domain (_s_) zip_type (_s_) zip_load ,
             (_s_) zip_hlq (_s_) zip_unit ,
             (_s_) interlink (_s_) size_limit ,
             (_s_) batch_idval (_s_) create_dsn_lrecl ,
             (_s_) receipt_type (_s_) paper_size ,
             (_s_) file_suf (_s_) force_suf ,
             (_s_) mail_relay (_s_) AtSign ,
             (_s_) ispffrom (_s_) fromreq ,
             (_s_) char (_s_) charuse (_s_) disclaim (_s_) empty_opt ,
             (_s_) font_size (_s_) def_orient ,
             (_s_) conf_msg (_s_) metric ,
             (_s_) descopt (_s_) smtp_method (_s_) smtp_loadlib ,
             (_s_) smtp_server (_s_) deflpi (_s_) nullsysout ,
             (_s_) default_hlq (_s_) msg_summary (_s_) site_disclaim ,
             (_s_) zipcont (_s_) feedback_addr (_s_) rfc_maxreclen ,
             (_s_) restrict_domain (_s_) log ,
             (_s_) faxcheck (_s_) tpageend (_s_) tpagelen,
             (_s_) from2rep (_s_) dateformat (_s_) validfrom ,
             (_s_) systcpd (_s_) restrict_hlq (_s_) default_lang ,
             (_s_) disable_antispoof (_s_) special_chars ,
             (_s_) send_from (_s_) Mime8bit ,
             (_s_) jobid (_s_) jobidl (_s_) custsym ,
             (_s_) codepage_default ,
             (_s_) encoding_default (_s_) encoding_check ,
             (_s_) check_send_from ,
             (_s_) check_send_to ,
             (_s_) smtp_array ,
             (_s_) txt2pdf_parms ,
             (_s_) xmitsock_parms ,
             (_s_) xmitipcu_infos ,
             (_s_) antispoof (_s_)(_s_) cu_add

         AtSign = strip(AtSign)
         Address ISREdit

         "MACRO (Address report)"
         if length(address) = 0 then do
            Address ISPExec
            xmt = "To Address"
            "Addpop"
            "Vget (xmto) profile"
            xminfo = xmto
            "Display Panel(xmitipds)"
            if rc > 3 then exit 4
            xmto = xminfo
            "Vput (xmto) profile"
            address = xmto
            "Rempop"
            Address ISREdit
            end
         else
           do
             if pos(AtSign,address) = 0 then do
                zedlmsg = "Error: Invalid address specified." ,
                    "Try again."
                zedsmsg = ""
                Address ISPExec "Setmsg msg(isrz001)"
                exit 16
              end
            end

        /* ----------------------- *
         * Get a from address      *
         * ----------------------- */
            Address ISPExec
            xmt = "From Address"
            "Addpop"
            "Vget (xmfrom) profile"
            xminfo = xmfrom
            "Display Panel(xmitipds)"
            if rc > 3 then exit 4
            xmfrom = xminfo
            "Vput (xmfrom) profile"
            "Rempop"
            Address ISREdit

        /* ----------------------- *
         * If no report ask        *
         * ----------------------- */
            if length(report) = 0 then do
               Address ISPExec
               xmt = "Report"
               "Addpop"
               xminfo ="TEXT or RTF"
               "Display Panel(xmitipds)"
               if rc > 3 then exit 4
               "Rempop"
               report = translate(xminfo)
               if left(report,1) = "R"
                  then report = ""
               Address ISREdit
               end

         "(dsn) = Dataset"
         "(mem) = Member"

         if mem <> "" then do
            file = "'"dsn"("mem")'"
            end
         else do
            file = "'"dsn"'"
            mem  = "File"
            end

        /* ----------------------------------------------------- *
         * Now setup for the proper report layout                *
         * ----------------------------------------------------- */
         if report = " "  then do
            report = "Format rtf/land"
            suf    = "rtf"
            end
        else do
            report = ""
            suf    = "txt"
            end

        Address ISPEXEC "VGET (HFSCWD,HFSNAME)"

        fullPath = hfscwd||hfsname

        subject = '"File:' fullpath'"'

        If Syscalls('ON') > 3
           Then do
             Say "Syscalls not active"
             Exit 0
        End

        Address SYSCALL ,
          "readfile '"fullpath"' myhfs."

        Address TSO "Alloc DD(XMIT001) SPACE(10 10) T LRECL(255)",
                    "DSORG(PS) RECFM(V B) NEW REU"

        Do i = 1 to myhfs.0
          queue myhfs.i
        End

        Address TSO "Execio" Queued() " DISKW XMIT001 (finis"

        /* ----------------------------------------------------- *
         * Now generate and invoke the XMITIP command            *
         * ----------------------------------------------------- */
         Address TSO,
         "%xmitip" address "nomsg " ,
           "subject" subject  report ,
           "From" xmfrom ,
           "filedd" XMIT001 ,
           "filedesc Edit-Member-Print Murphy"

        Address TSO "Free DD(XMIT001)"
