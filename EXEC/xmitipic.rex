        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITIPIC                                        *
         *                                                            *
         * Function:  Create an iCalendar File that can be e-mailed   *
         *            or downloaded                                   *
         *                                                            *
         * Syntax:    %xmitipic                                       *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            2007-09-11 - Updates to remove blank line and   *
         *                         change type from text to request   *
         *            2004-05-04 - Corrections thx to Joe Schwarzbauer*
         *            2003-09-02 - Creation                           *
         *                                                            *
         * ---------------------------------------------------------- *
         * Copyright 2003 by Lionel B. Dyck                           *
         * ---------------------------------------------------------- */

         parse arg options

         Address ISPExec
         "Vget (zapplid)"
         if zapplid <> "XMIT" then do
            "Select CMD(%"sysvar('sysicmd') options ") Newappl(XMIT)" ,
                "passlib scrname(XMITIPIC)"
            exit 0
            end

        /* -------------------------- *
         * Call setup to get defaults *
         * -------------------------- */
         call setup
         parse value "" with null type

        /* --------------------- *
         * Parse out the Options *
         * --------------------- */
         parse value options with icalds .
         if icalds <> null then type = 1

        /* ---------------------------- *
         * Display the prompting panels *
         * ---------------------------- */
         Start:
         "Display Panel(xmitipcc)"
         if rc > 0 then exit
         "Vget (from) Profile"
         icfrom = from
         if icalds = null then do
            "Display Panel(xmitipvp)"
            if rc > 0 then exit
            if sysdsn(icalds) = "OK" then do
               zedsmsg = "Error."
               zedlmsg = icalds "already exists.  Please delete it",
                        "or specify a new name."
              "Setmsg msg(isrz001)"
              signal start
              end
           end

        /* ---------------------------- *
         * Process the iCalendar Prompt *
         * ---------------------------- */
         Do_Calendar:
         if icdur = 0 then ictype = "VTODO"
                      else ictype = "VEVENT"
         ical.1 = "BEGIN:VCALENDAR"
         ical.2 = "METHOD:REQUEST"
         ical.3 = "VERSION:2.0"
         ical.4 = "PRODID:-//XMITIP" ver"//NONSGML zOS E-Mail//EN"
         ical.5 = "BEGIN:"ictype
         stamp_time = time('n')
         parse value stamp_time with hh":"mm":"ss
         stamp_time = right(hh+100,2)right(mm+100,2)"00"
         ical.6 = "DTSTAMP:"date('s')"T"stamp_time
         ical.7 = "SEQUENCE:0"
         if pos('"',icfrom) = 0 then do
            icfpos = pos(atsign,icfrom)
            icfrom = left(icfrom,icfpos-1)
            icfrom = translate(icfrom," ",".")
            end
         else do
              parse value icfrom with '"'icfrom'"'.
              end
         icfn = null
         do icx = 1 to words(icfrom)
            icw = word(icfrom,icx)
            if length(icw) > 1 then do
               parse value icw with icc 2 icr
               icfn = strip(icfn  translate(icc)""icr)
               end
            else icfn = strip(icfn  translate(icw)".")
            end
         ical.8 = "ORGANIZER;ROLE=CHAIR:"icfn
         if left(icdate,1) = "+" then do
             icdate = substr(icdate,2)
             d      = date('b') + icdate
             icdate = date("s",d,"b")
            end
         else do
              parse value icdate with mm"/"dd"/"yy
              icdate = "20"yy""right(mm+100,2)""right(dd+100,2)
              end
         ictm   = right(ictm+10000,4)
         ical.9 = "DTSTART:"icdate"T"ictm"00"
         if datatype(right(icdur,1)) = "NUM" then
            icdur = icdur"M"
         ical.10 = "SUMMARY:"ictitle
         icalc = 10
         if ictype = "VEVENT" then do
            icalc = icalc + 1
            ical.icalc = "DURATION:PT"icdur
            end
         icalc = icalc + 1
         ical.icalc = "DESCRIPTION:"ictext1
         if ictext2 <> null then call add_ical ictext2
         if ictext3 <> null then call add_ical ictext3
         if ictext4 <> null then call add_ical ictext4
         if ictext5 <> null then call add_ical ictext5
         if ictext6 <> null then call add_ical ictext6
         if ictext7 <> null then call add_ical ictext7
         if ictext8 <> null then call add_ical ictext8
         if ictext9 <> null then call add_ical ictext9
         if ictexta <> null then call add_ical ictexta
         if ictextb <> null then call add_ical ictextb
         if icloc <> null then do
            icalc = icalc + 1
            ical.icalc = "LOCATION:"icloc
            end
         icalc = icalc + 1
         ical.icalc = "END:"ictype
         icalc = icalc + 1
         ical.icalc = "END:VCALENDAR"
         Address TSO
         wtime  = right(time('s') + 10,2)
         eddd   = "XM"wtime""right(time('l'),4)
         "Alloc ds("icalds") new spa(1,1) tr",
            "Recfm(v b) lrecl(80)" ,
            "blksize(9004)",
            "Unit("vio") f("eddd")"
         "Execio * diskw" eddd "(finis stem ical."
         "Free f("eddd")"
         drop ical. eddd

         if type = null then exit
         Address ISPExec
         zedsmsg = ""
         zedlmsg = "Your iCalendar file has been constructed" ,
                   "and may now be used as an e-mail attachment",
                   "or downloaded for use."
         "Setmsg msg(isrz001)"
         "Browse Dataset("icalds")"
         exit

        /* ------------------------------------- *
         * Add the iCalendar Description records *
         * ------------------------------------- */
         Add_iCal: procedure expose icalc ical.
           parse arg data
           icalc = icalc + 1
           ical.icalc = " "data
           return

        /* --------------------------------- *
         * Perform Setup by calling XMITIPCU *
         * --------------------------------- */
         Setup:
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
                   /*   antispoof is always last         */
                   /*   finish CU with double separator  */
                   /*   cu_add for specials ...          */

         AtSign   = strip(AtSign)
         return
