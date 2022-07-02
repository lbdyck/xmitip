/* REXX - TESTCU - Test XMITIP customization by displaying    *
 *                 variables set by XMITIPCU                  *
 *                                                            *
 * Note: Running this exec from a test library by issuing     *
 *       TSO EX 'test.library.exec(TESTCU)' will search       *
 *       test.library.exec first for XMITIPCU and XMITLDAP    *
 *                                                            *
 * Code contributed by Dana Mitchell dana.mitchell@ing-dm.com *
 *                                                            *
 * ---------------------------------------------------------- *
 * 2016-03-16 - add support for mailfmt keyword               *
 * 2015-12-02 - add support for starttls keyword              *
 * 2010-07-26 - correction for country codes from Hartmut     *
 * 2010-01-04 - add description to ztermcid values            *
 *            - add info about default encoding               *
 * 2009-12-11 - detail report about AtSign setting            *
 * 2009-12-03 - fix report for null antispoof                 *
 * 2009-11-24 - add cu_add plausibility check, same in XMITIP *
 * 2009-11-23 - check whether antispoof is empty or not       *
 *              (XMITIPCU template check)                     *
 * 2009-11-17 - encoding check info, warning, error           *
 * 2009-05-25 - leave exec with return 0 (called as function) *
 * 2009-05-22 - Add validfrom info to LDAP informations       *
 * 2009-03-20 - Update for additional XMITLDAP info           *
 * 2009-03-17 - support additional parms for log (LOGIT)      *
 * 2009-03-05 - support additional special_chars value cp_info*
 * 2008-12-04 - check xmitipcu_msgs                           *
 * 2008-12-01 - use quotes for x2c strings                    *
 * 2008-11-13 - allow dateformat of 'E'                       *
 * 2008-10-28 - check calling method                          *
 *            - option VIEW instead of default BROWSE         *
 * 2008-09-28 - tcp_stack, txt2pdf parms                      *
 * 2008-09-24 - check_send_to EXIT                            *
 * 2008-09-22 - change VIEW to BROWSE                         *
 * 2008-09-10 - Update to check and report on XMITLDAP        *
 * 2008-08-28 - check environment (LMOD, SYSEXEC or DSN)      *
 * ---------------------------------------------------------- */

  signal on novalue name sub_novalue

  _x_ = sub_init();

  parse upper arg _all_parms_
  parse var _all_parms_ 1 _opt_

  select;
    when ( rexxdd    = "?" ) then _rexx_env_ = "LMOD",
                                              "member (XMITIPCU)"
    when ( rexxdsn   = "?" ) then _rexx_env_ = "DD",
                                     ""rexxdd" member (XMITIPCU)"
    otherwise do;
                                  _rexx_env_ = "DSN",
                                     "'"rexxdsn"(XMITIPCU)'"
              end;
  end;

            /* ------------------------------------- *
             * Create the Output for Display - INIT  *
             * ------------------------------------- */
             call add ""msgid
             call add " Current Customization values in" ,
                          ""_rexx_env_"",
                          ""

        /* ----------------------------------------------------- *
         * Invoke XMITIPCU for local customization values        *
         * ----------------------------------------------------- */

        if abbrev(_rexx_env_,"DSN") = 1 ,
        then do;
                _rcode_ = sub_check_environment(rexxdsn);
                if _rcode_ = 0 ,
                then do;
                      "ALTLIB   act application(EXEC) da('"rexxdsn"')"
                     end;
                else do;
                      exit _rcode_
                     end;
             end;

        _ver_ = xmitipcu("VER") ;
        cu    = xmitipcu()      ;

        if abbrev(_rexx_env_,"DSN") = 1 ,
        then "ALTLIB deact application(EXEC)"

        _val_null_ = "  <nothing defined>"

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
             (_s_) tcp_hostid (_s_) tcp_hostname (_s_) tcp_domain ,
             (_s_) tcp_stack ,
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
             (_s_) encoding_default (_s_) encoding_check,
             (_s_) check_send_from ,
             (_s_) check_send_to ,
             (_s_) smtp_array ,
             (_s_) txt2pdf_parms ,
             (_s_) xmitsock_parms ,
             (_s_) xmitipcu_infos ,
             (_s_) starttls ,
             (_s_) mailfmt ,
             (_s_) antispoof (_s_)(_s_) cu_add
        /*   antispoof is always last         *
         *   finish CU with double separator  *
         *   cu_add for specials ...          */

        _s_double_ = _s_""_s_
        parse value cu with . (_s_double_) cu_add_check
        if strip(cu_add) = strip(cu_add_check) ,
        then nop
        else do;
                    _rcode_ = 12
                    say msgid "XMITIPCU parms not plausible."
                    say msgid "cu_add      : ***"cu_add"***"
                    say msgid "cu_add_check: ***"cu_add_check"***"
                 exit 12
             end;

        parse value cu with ,
           . (_s_double_) cu_add_check

             if metric = "C" then metric =     "Centimeters"
                             else metric =     "Inches"

             if datatype(rfc_maxreclen) = "NUM" ,
             then do;
                    rfc_maxreclen = rfc_maxreclen ,
                        "("word("Ignore Warn Error",rfc_maxreclen+1)")"
                  end;
             else do;
                        x_error = x_error + 1
                  end;

             antispoof     = strip(translate(antispoof,'/',x2c("01")))
             special_chars = strip(special_chars)

             parse var xmitipcu_infos ,
                 1 . "<CU#RC>"   cu_rc   "</CU#RC>"        . ,
                 1 . "<CU#MSG>"  cu_msg  "</CU#MSG>"       . ,
                 1 .
             parse var cu_msg ,
                 1 . "<MSGDEFHLQ>" default_hlq_msg "</MSGDEFHLQ>" . ,
                 1 .

            /* ------------------------------ *
             * Create the Output for Display  *
             * ------------------------------ */
             call add " "
             call add "   XMITIP version: "_ver_
             call add "-------------------"copies("-",60)
             call add "        separator:" strip(_s_)" (HEX:"c2x(_s_)")"

             _x_ = sub_check_customparms()

             if mime8bit = 0 then mimebit = "(7Bit)"
                             else mimebit = "(8Bit)"
             call add "         Mime8bit:" strip(Mime8bit) mimebit
             _val_ = strip(codepage_default)
             if _val_ = "" then _val_ = _val_null_
             call add "         codepage:" _val_
             _val_ = strip(encoding_default)
             if _val_ = "" then _val_ = _val_null_
             call add " encoding default:" _val_
             _val_ = strip(encoding_check)
             if _val_ = "" then _val_ = _val_null_
             call add "   check_encoding:" _val_
             _x_ = sub_encoding_check() ;
             call add "    append_domain:" strip(append_domain)
             AtSign = strip(AtSign)
             if length(AtSign) > 1 ,
             then ,
             call add "          AtSigns:" strip(AtSign)"",
                                         "(hex:"c2x(atsign)")"
             else ,
             call add "           AtSign:" strip(AtSign)"",
                                         "(hex:"c2x(atsign)")"
             call add "      batch_idval:" strip(batch_idval)
             call add "           center:" strip(_center_)
             call add "             char:" strip(char)
             _info_ = ""
             if charuse = 1 ,
             then _info_ = "(1 - do not use for text or rtf)"
             else _info_ = "(use everywhere)"
             call add "          charuse:" strip(charuse)" "_info_
             _info_ = ""
             call add "         conf_msg:" strip(conf_msg)
             parse var check_send_from 1 check_send_from_cmd ,
                                         check_send_from_parms
             _val_ = strip(check_send_from_cmd)
             if _val_ = "" then _val_ = _val_null_
             call add "  check_send_from:" _val_"  ",
                               " (exit routine)"
             _val_ = strip(check_send_from_parms)
             if _val_ = "" then _val_ = _val_null_
             if _val_ = _val_null_ ,
             then     call add ""right("parms:",18)"" _val_null_
             else do ;
                     _x_ = sub_xml(check_send_from_parms)
                     if xml.0 > 0 ,
                     then do ;
                             call add ""right("parms:",18)"",
                                             "<see details>"
                             do xmlidx = 1 to xml.0
                                _info_ = ""
                                _info_ = _info_""right(xml.xmlidx.1,08)
                                _info_ = _info_" = "xml.xmlidx.2
                                call add ""right("",17)" "_info_
                             end
                          end;
                  end;

             parse var check_send_to   1 check_send_to_cmd ,
                                         check_send_to_parms
             _val_ = strip(check_send_to_cmd)
             if _val_ = "" then _val_ = _val_null_
             call add "    check_send_to:" _val_"  ",
                               " (exit routine)"
             _val_ = strip(check_send_to_parms)
             if _val_ = "" then _val_ = _val_null_
             if _val_ = _val_null_ ,
             then     call add ""right("parms:",18)"" _val_null_
             else do ;
                     _x_ = sub_xml(check_send_to_parms)
                     if xml.0 > 0 ,
                     then do ;
                        call add ""right("parms:",18)" <see details>"
                        do xmlidx = 1 to xml.0
                             _info_ = ""
                             _info_ = _info_""right(xml.xmlidx.1,08)
                             _info_ = _info_" = "xml.xmlidx.2
                             call add ""right("",17)" "_info_
                          end
                          end;
                  end;

             txt2pdf_cmd = "TXT2PDF"
             _val_ = strip(txt2pdf_cmd)
             if _val_ = "" then _val_ = _val_null_
             call add "          txt2pdf: "_val_"   ",
                               " (convert routine)"
             _val_ = strip(txt2pdf_parms)
             if _val_ = "" then _val_ = _val_null_
             if _val_ = _val_null_ ,
             then     call add ""right("parms:",18)"" _val_null_
             else do ;
                     _x_ = sub_xml(txt2pdf_parms)
                     if xml.0 > 0 ,
                     then do ;
                        call add ""right("parms:",18)" <see details>"
                        do xmlidx = 1 to xml.0
                             _info_ = ""
                             _info_ = _info_""right(xml.xmlidx.1,08)
                             _info_ = _info_" = "xml.xmlidx.2
                             call add ""right("",18)" "_info_
                          end
                          end;
                  end;

             xmitsock_cmd = "XMITSOCK"
             _val_ = strip(xmitsock_cmd)
             if _val_ = "" then _val_ = _val_null_
             call add "         xmitsock: "_val_"  ",
                               " (smtp transfer type)"
             _val_ = strip(xmitsock_parms)
             if _val_ = "" then _val_ = _val_null_
             if _val_ = _val_null_ ,
             then     call add ""right("parms:",18)"" _val_null_
             else do ;
                      call add ""right("parms:",18)"" _val_
                  end;

             call add " create_dsn_lrecl:" strip(create_dsn_lrecl)
             if strip(custsym) = "" then ,
             call add "          custsym: <nothing defined>"
             else do
             call add "          custsym: <see details>"
                     _x_ = add_custsym(custsym)
                     do i = 1 to custsym.0
             call add ""right("",18)"" left(custsym.i.1,10)"=",
                                             custsym.i.2
                     end
             end
             call add "       dateformat:" strip(dateformat)
             call add "           deflpi:" strip(deflpi)
             call add "      default_hlq:" strip(default_hlq)
             if words(default_hlq_msg) > 1 ,
             then do;
                      hlq_infos  = default_hlq_msg
                      do forever
                         parse var hlq_infos . "<MSG>" _msg_ "</MSG>" ,
                                   hlq_infos
                         _msg_     = strip(_msg_)
                         if _msg_ /= "" ,
                         then call add ""right("",18)" "strip(_msg_)
                         hlq_infos = strip(hlq_infos)
                         if hlq_infos = "" then leave
                      end
                  end;
             call add "     default_lang:" strip(default_lang)
             call add "       def_orient:" strip(def_orient)
             call add "          descopt:" strip(descopt)
             if strip(disable_antispoof) = "Y" then as = "enabled"
                                               else as = "disabled"
             call add "disable_antispoof:" as
             call add "         disclaim:" strip(disclaim)
             call add "        empty_opt:" strip(empty_opt)
             call add "         faxcheck:" strip(faxcheck)
             call add "    feedback_addr:" strip(feedback_addr)
             call add "         file_suf:" strip(file_suf)
             call add "        force_suf:" strip(force_suf)
             call add "       font_ size:" strip(font_size)
             call add "         From2Rep:" strip(from2rep)
             call add "          fromreq:" strip(fromreq)
             call add "        interlink:" strip(interlink)
             call add "         ispffrom:" strip(ispffrom)
             call add "          mailfmt:" strip(mailfmt)
             parse var log 1 logdsn logparms
             logparms = strip(logparms)
             if logparms = "" ,
             then do;
                     call add ""right("log:",18)"",
                                ""strip(logdsn)
                  end;
             else do;
                     call add ""right("log:",18)"",
                                             "parms <see details>:"
                     call add ""right("",18)"",
                                "logdsn  = "strip(logdsn)
                     _x_ = sub_xml(logparms)
                     if xml.0 > 0 ,
                     then do ;
                             do xmlidx = 1 to xml.0
                                _info_ = ""
                                _info_ = _info_""right(xml.xmlidx.1,08)
                                _info_ = _info_" = "xml.xmlidx.2
                                call add ""right("",17)" "_info_
                             end
                          end;
                  end;
             call add "       mail_relay:" strip(mail_relay)
             call add "         StartTLS:" strip(starttls)
             call add "          margins:" "Top:" mtop ,
                                           "Bottom:" mbottom ,
                                           "Left:" mleft ,
                                           "Right:" mright
             call add "           metric:" metric
             call add "      msg_summary:" strip(msg_summary)
             call add "       nullsysout:" strip(nullsysout)
             call add "       paper_size:" strip(paper_size)
             call add "     receipt_type:" strip(receipt_type)
             call add "  restrict_domain:" strip(restrict_domain)
             call add "     restrict_hlq:" strip(restrict_hlq)
             call add "    rfc_maxreclen:" strip(rfc_maxreclen)
             if send_from = 1 then send_from = "Enabled"
                              else send_from = "Disabled"
             call add "        send_from:" send_from
             sd = "    site_disclaim:"
             do forever
                parse value site_disclaim with text"#"site_disclaim
                call add sd strip(text)
                if length(site_disclaim) = 0 then leave
                sd = "                  "
                end
             call add "       size_limit:" strip(size_limit)
             call add "             smtp:" strip(smtp)
             call add "      smtp_domain:" strip(smtp_domain)
             _val_ = strip(smtp_array)
             if _val_ = "" then _val_ = _val_null_
             call add "       smtp_array:" _val_
             call add "     smtp_loadlib:" strip(smtp_loadlib)
             call add "      smtp_method:" strip(smtp_method)
             call add "      smtp_secure:" strip(smtp_secure)
             call add "      smtp_server:" strip(smtp_server)
             parse var special_chars 1 cp_used sp_chars cp_info
             cp_used   = strip(cp_used)
             sp_chars  = strip(sp_chars)
             cp_info   = strip(cp_info)
             excl      = substr(sp_chars,1,1)
             basl      = substr(sp_chars,2,1)
             diar      = substr(sp_chars,3,1)
             brsl      = substr(sp_chars,4,1)
             brsr      = substr(sp_chars,5,1)
             brcl      = substr(sp_chars,6,1)
             brcr      = substr(sp_chars,7,1)
             hash      = substr(sp_chars,8,1)
             if sysvar('sysispf') = "ACTIVE" then do
                Address ISPExec "Control Errors Return"
                Address ISPExec "vget ( ztermcid)"
                if RC <> 0 then ztermcid_val = "N/A"
                else ztermcid_val = ztermcid""copies(" ",3),
                                    sub_termcid(ztermcid)
                call add "    ISPF ZTERMCID:" ztermcid_val
                end
             if cp_info = _null_ ,
             then cp_info_disp = ""
             else cp_info_disp = "("cp_info")"
             call add "    used codepage:" cp_used"    "cp_info_disp
             call add " exclamation mark:" excl
             call add "       back slash:" basl
             call add "         diaresis:" diar
             call add " bracket square l:" brsl
             call add " bracket square r:" brsr
             call add " bracket curly  l:" brcl
             call add " bracket curly  r:" brcr
             call add "             hash:" hash
             call add "          systcpd:" strip(systcpd)
             call add "     sysout_class:" strip(sysout_class)
             if tpageend = 0 then tpageend = "Warning"
                             else tpageend = "Abort"
             call add "   Text Pagel End:" tpageend
             call add "   Text Pagel Len:" strip(tpagelen)
             call add "       text enter:" strip(text_enter)
             call add "              vio:" strip(vio)
             call add "       Valid From:" strip(validfrom)
             call add "           writer:" strip(writer)
             _info_ = ""
             zip_load = strip(zip_load)
             if left(zip_load,1) = "*" ,
             then _info_ = "  (CALL via LINKLIB / STEPLIB)"
             call add "         zip_load:" strip(zip_load)" "_info_
             _info_ = ""
             call add "         zip_type:" strip(zip_type)
             call add "          zip_hlq:" strip(zip_hlq)
             call add "         zip_unit:" strip(zip_unit)
             call add "          zipcont:" strip(zipcont)
             lbl = "        antispoof:"
             as_sep = x2c("02")
             if length(antispoof) = 0 then
                antispoof = "*Null*"
             if pos(as_sep,antispoof) > 0 then do forever
                parse value antispoof with dat (as_sep) antispoof
                if length(strip(dat)) = 0 then leave
                call add lbl strip(dat)
                lbl = "                 :"
                end
                else call add "        antispoof:" antispoof
             if cu_add /= "" ,
             then do ;
             call add " "
             call add "     cu_add parms:" strip(cu_add)
                  end;
             call add " "
             if length(strip(tcp_domain""tcp_hostid""tcp_hostname)) = 0 ,
             then do ;
                     tcp_domain  = "n/a",
                                   "- please check TCP/IP environment."
                     tcp_hostid  = "n/a"
                     tcp_hostname = "n/a"
                  end;
             call add " Dynamically determined variables:"
             call add "       tcp_domain:" strip(tcp_domain)
             call add "       tcp_hostid:" strip(tcp_hostid)
             call add "     tcp_hostname:" strip(tcp_hostname)
             call add "        tcp_stack:" strip(tcp_stack)
             call add "      from_center:" strip(from_center)
             call add "     from_default:" strip(from_default)
             call add "     smtp_address:" strip(smtp_address)
             call add "             zone:" strip(zone)
             call add " "
             call add "            jobid:" strip(jobid) "",
                               "  jobidl:" strip(jobidl)" (full name)"

        /* ---------------------- */
        /* Get info from XMITLDAP */
        /* ---------------------- */
         x = xmitldap()
          parse value x with _s "/" _o "/" _d "/" _w "/" local_nodes ,
                                "/" _n _em
             call add " "
             call add " LDAP Lookup/Validation Info:"
             call add "      ldap_server:" strip(_s)
             call add "           ldap_o:" strip(_o)
             call add "           ldap_d:" strip(_d)
             call add "           ldap_w:" strip(_w)
             call add "      local_nodes:" strip(local_nodes)
             call add "        ldap_name:" strip(_n)
             call add "        ldap_mail:" strip(_em)
         if validfrom = 0 ,
         then _info_ = "       (NOTE: use of LDAP deactivated)"
         else _info_ = ""
             call add "        validfrom:" strip(validfrom)"",
                                           _info_

        /* -------------------------------- *
         * Test UDSMTP Validity             *
         * -------------------------------- */
         if smtp_method = "UDSMTP" then
            if strip(smtp_server) = "" then do
               call add " "
               call add " **********************************"
               call add " UDSMTP Error....."
               call add "        Missing smtp_server"excl
               call add " **********************************"
               x_error = x_error + 1
               end

        /* --------------------------------------------------------- *
         * test validity of zip load dsn                             *
         * --------------------------------------------------------- */
         zip_load = strip(zip_load)
         if length(zip_load) > 0 then do;
            if left(zip_load,1) = "*" ,
            then do ;
                 end;
            else do ;
                  zip_sysdsn = sysdsn(zip_load)
                  if zip_sysdsn <> "OK" then do
                     call add " "
                     call add right("zip_load:",18)" "zip_load
                     call add right("        :",18),
                              " Error - "zip_sysdsn
                     x_error = x_error + 1
                     end
                 end;
         end;

        /* --------------------------------------------------------- *
         * test dateformat and default_lang values                   *
         * --------------------------------------------------------- */
         dateformat   = strip(dateformat)
         default_lang = strip(default_lang)
         if pos(dateformat,'IEU') > 0 then nop
         else do
             if default_lang = _null_ then do
               call add " "
               call add "    dateformat / default_lang"
               call add "         : Error - dateformat other than",
                        "'U' or '<null>' "
               call add "           requires a valid value",
                        "for default_lang."
               if dateformat = _null_ ,
               then x_val = "<null>"
               else x_val = dateformat
               call add "           dateformat:   "x_val
               if default_lang = _null_ ,
               then x_val = "<null>"
               else x_val = default_lang
               call add "           default_lang: "x_val
               x_error = x_error + 1
             end
           end
         if pos("ALL",_opt_) > 0 ,
         then do;
             call add " "
             call add " Environment infos:"
             call add "-------------------"copies("-",50)
             _security_infos_ = xmitzchk("<CHK>SECURITY</CHK>")
             parse var _security_infos_ 1 . ,
                       1 . "<SECSYSTEM>"  _secsys_   "</SECSYSTEM>" . ,
                       1 . "<SECUID>"     _secuid_   "</SECUID>"    . ,
                       1 . "<SECUNAME>"   _secuname_ "</SECUNAME>"  . ,
                       1 . "<SECDFTGR>"   _secdftgr_ "</SECDFTGR>"  . ,
                       1 . "<SECATTR>"    _secattr_  "</SECATTR>"   . ,
                       1 . "<SECTSO>"     _sectso_   "</SECTSO>"    . ,
                       1 .
             call add "  security system:" strip(_secsys_)
             call add "  security userid:" strip(_secuid_)
             call add "  security u_name:" strip(_secuname_)
             call add "  security defgrp:" strip(_secdftgr_)
             call add "  security attr. :" strip(_secattr_)
             call add "  security TSOseg:" strip(_sectso_)
              end;

         call add " "

         _x_ = show_data()
            Return 0

        /* ------------------------ *
         * Add line to stem routine *
         * ------------------------ */
         add:
         parse arg data
         cu.0   = cu.0 + 1
         ctr    = cu.0
         cu.ctr = data
         return

sub_init:
  parse value "" with _null_
  /* to get the correct name for MSGID don't use other cmds before */
  parse source ,
    rexxenv rexxinv rexxname rexxdd rexxdsn . rexxtype addrspc .
  myname = rexxname
  if myname = "?" ,
  then do ;
           myname = sysvar("sysicmd")
           if length(myname) = 0 ,
           then  myname = sysvar("syspcmd")
       end;
  msgid = left(myname": ",10)
  cu.0  = 0
  x_error = 0
  global_vars = "_null_ msgid myname cu. x_error _opt_ _s_"
 return 0

show_data:
         if sysvar('sysispf') = "ACTIVE" then do
            xmit_dd = "C"random()
            "ALLOCATE FILE("xmit_dd") REUSE UNIT(SYSDA) SPACE(1 1)" ,
                     "CYLINDER",
                     "DSORG(PS) RECFM(V B) LRECL(255)"
            "EXECIO * DISKW" xmit_dd "(STEM cu. FINIS)"
            if x_error > 0 then do
               zedsmsg = "Errors found: "x_error
               zedlmsg = "Please check the ERROR lines below."
               Address ISPEXEC "Setmsg msg(isrz001)"
            end
            if pos("VIE",_opt_) > 0 ,
            then _se_ = "VIEW"
            else _se_ = "BROWSE"
            Address ISPEXEC "LMINIT DATAID(DATAID) DDNAME("xmit_dd")"
            Address ISPEXEC ""_se_" DATAID("dataid")"
            Address ISPEXEC "LMFREE DATAID("dataid")"
            "FREE FILE("xmit_dd")"
            end
         else do
              do i = 1 to cu.0
                 say cu.i
                 end
              end
            Return 0

       /**************************************************************
        * Trap uninitialized variables                               *
        **************************************************************/
        sub_novalue:
        Say " "
        Say "Variable" ,
           condition("Description") "undefined in line" sigl":"
        Say sourceline(sigl)
        if sysenv           <> "FORE" then exit 8
        say "Report the error in this application along with the",
            "syntax used."
        exit 8


 /* ---------------------------- *
  * separate PARMS in XML format *
  * ---------------------------- */
 sub_xml: procedure expose xml.
   parse arg xml_string
   xml.0 = 0
   do forever
      xml_string = strip(xml_string)
      if xml_string = "" then leave
      if left(xml_string,1) = "<" ,
      then do ;
                parse var xml_string 1 "<"_key_">" .
           end;
      else do ;
                say "ERROR: invalid XML parameter format "
                exit 16
           end;
      _key_ = strip(_key_)
      if _key_ = "" ,
      then do ;
                say "ERROR: no keyword found"
                exit 16
           end;
      _key_start_ = "<"_key_">"
      _key_end_   = "</"_key_">"
      parse var xml_string 1 (_key_start_) xml_string
      if pos(_key_end_,xml_string) > 0 ,
      then do ;
               parse var xml_string 1 _key_val_ (_key_end_) _rest_
               _key_val_ = strip(_key_val_)
               if _key_val_ = "" ,
               then _key_val_ = "<blank>"
           end;
      else do ;
                say "ERROR: no end tag found: "_key_end_
                exit 16
           end;
      xml.0 = xml.0 + 1
      xmlidx  = xml.0
      xml.xmlidx.1 = ""strip(_key_)
      xml.xmlidx.2 = ""strip(_key_val_)
      xml_string = _rest_
  end
  return 0

 /* ------------------------ *
  * separate custsym vars    *
  * ------------------------ */
  add_custsym: procedure expose _null_ custsym.
   parse arg custsym
   custsym = " "strip(custsym)""
   tr_char = get_tr_char(custsym) ;
   custsym_org = custsym
   custsym_trans = 0
   do i = 1 to length(custsym)
        charchk = substr(custsym,i,1)
        if charchk = "&" ,
        then do
                 if i > 1 ,
                 then charprev = substr(custsym,i-1,1)
                 else charprev = ""
                 if  strip(charprev) /= ""  then iterate ;

                 /* not " &" */
                 if i < length(custsym) ,
                 then charnext = substr(custsym,i+1,1)
                 else charnext = ""
                 if  strip(charnext) /= ""  then iterate ;

                 /* is  "& " */
                 custsym1 = substr(custsym,1,i-2)
                 custsym = custsym1""tr_char"&"substr(custsym,i+1)
                 custsym_trans = custsym_trans + 1
             end
   end
   needle = tr_char
   haystack = custsym
   tr_num = sub_needle(""needle" "haystack"") ;
   custsym_var   = _null_
   cv            = 0
   do until length(custsym) = 0
      parse value custsym with " &"sym symv
      cv = cv + 1
      custsym.0 = cv
      custsym_var = custsym_var" &"translate(sym)" "
      custsym.cv.1 = strip("&"translate(sym))
      parse var symv symbol_var " &" syml
      custsym.cv.2 = translate(strip(symbol_var)," ",tr_char)
      if length(strip(syml)) > 0 ,
      then custsym = " &"syml
      else custsym = _null_
    end

 return 0

        /* ----------------------------------------------- *
         * find an translation char not used in the string *
         * one of the following chars should fit ...       *
         * ----------------------------------------------- */
         get_tr_char: procedure expose _null_
           parse arg parms
           ndl.1 = "41"X
           ndl.2 = "01"X
           ndl.3 = "02"X
           ndl.4 = "03"X
           ndl.5 = "04"X
           ndl.6 = "05"X
           ndl.0 = 6
           tr_char = _null_
           do i = 1 to ndl.0
               _n_ = sub_needle(""ndl.i" "parms"") ;
               if _n_ = 0 ,
               then do ;
                       tr_char = ndl.i  ;
                       leave
                    end;
           end
         return tr_char

        /* ----------------------------------------------- *
         * get the number of occurences                    *
         * ----------------------------------------------- */
 sub_needle: procedure expose _null_
  parse arg parms
  parse var parms ndl" "haystack
  _n_  = ,
     length(space(translate(haystack,ndl,ndl""xrange('00'x,'FF'x)),0))
   return _n_ ;

        /* --------------------------------------------------- *
         * check encoding environment                          *
         *                                                     *
         *                                                     *
         * --------------------------------------------------- */
 sub_encoding_check:
   codepage_default = strip(codepage_default)
   encoding_default = strip(encoding_default)
   _enc_parms_ = ""
   _enc_parms_ = ""_enc_parms_"<MODE>TEST</MODE>"
   _enc_parms_ = ""_enc_parms_"<CP>"codepage_default"</CP>"
   _enc_parms_ = ""_enc_parms_"<ENC>"encoding_default"</ENC>"
   _enc_parms_ = "<HEADER>"_enc_parms_"</HEADER>"
   _enc_env_ = xmitzqen(_enc_parms_)
   parse var _enc_env_ _enc_env_rcode_ _enc_env_text_
   _enc_env_text_ = strip(_enc_env_text_)
   select;
     when ( _enc_env_rcode_ = 0 ) then nop
     when ( _enc_env_rcode_ = 2 ) then ,
       do;
          call add "      >>>>   Info:   <"_enc_env_text_">"
       end ;
     when ( _enc_env_rcode_ = 4 ) then ,
       do;
          call add "    >>>>  Warning:  " _enc_env_text_
       end ;
     otherwise do ;
          call add " >>>>>>>>   Error: "_enc_env_text_
          x_error = x_error + 1
        end ;
   end;
  return 0

 sub_check_customparms: procedure expose (global_vars) ,
              cu cu_add cu_add_check
   maxcc = 0
   if strip(cu_add) = strip(cu_add_check) ,
   then nop
   else do;
            x_error = x_error + 1
            call add right("parm check",17)":",
                     "ERROR - configuration mismatch."
            call add " "
            counter = 0
            do forever
                parse var cu (_s_) cu_val (_s_) cu
                if strip(cu) = "" ,
                then leave
                else do;
                counter = counter + 1
                       cu = _s_" "cu
                       call add right(counter,3,0)": "strip(cu_val)
                     end;
            end
             _x_ = show_data()
            exit 8
         end
  return maxcc

 sub_termcid:
   parse arg termcid .
   if datatype(termcid) = "NUM" ,
   then termcid = termcid + 0
   else termcid = ""
   select
    when ( termcid = ""   ) then ret_val = ""
    when ( termcid =   37 ) then ret_val = "(USA                 )"
    when ( termcid = 1047 ) then ret_val = "(USA                 )"
    when ( termcid = 1140 ) then ret_val = "(B NL P BR CDN USA  E)"
    when ( termcid = 1141 ) then ret_val = "(Austria, Germany   E)"
    when ( termcid = 1142 ) then ret_val = "(Denmark, Norway    E)"
    when ( termcid = 1143 ) then ret_val = "(Finland, Sweden    E)"
    when ( termcid = 1144 ) then ret_val = "(Italy              E)"
    when ( termcid = 1145 ) then ret_val = "(Spain              E)"
    when ( termcid = 1146 ) then ret_val = "(GB (UK)            E)"
    when ( termcid = 1147 ) then ret_val = "(France             E)"
    when ( termcid = 1148 ) then ret_val = "(multinational      E)"
    when ( termcid = 1153 ) then ret_val = "(Romania, Poland    E)"
    when ( termcid =  273 ) then ret_val = "(Austria, Germany    )"
    when ( termcid =  275 ) then ret_val = "(Brazil -old-        )"
    when ( termcid =  277 ) then ret_val = "(Denmark, Norway     )"
    when ( termcid =  278 ) then ret_val = "(Finland, Sweden     )"
    when ( termcid =  280 ) then ret_val = "(Italy               )"
    when ( termcid =  284 ) then ret_val = "(Spain               )"
    when ( termcid =  285 ) then ret_val = "(GB                  )"
    when ( termcid =  297 ) then ret_val = "(France              )"
    otherwise                    ret_val = ""
   end
  return ret_val

 sub_check_environment: procedure expose (global_vars)
   parse arg _rexxdsn_
   maxcc = 0
   _rexxdsn_ = strip(translate(_rexxdsn_,"","'")) /* without apost */
   members.1.1 = "XMITIP"
   members.2.1 = "XMITIPCU"
   members.0   = 2
   do i = 1 to members.0
       _dsn_mem_ = "'"_rexxdsn_"("members.i.1")'"
       _sysdsn_ = sysdsn(_dsn_mem_)
       members.i.2 = _sysdsn_
       if _sysdsn_ = "OK" ,
       then do;
            end;
       else do;
                maxcc = max(maxcc,12)
            end;
   end
   if maxcc = 0 ,
   then nop;
   else do;
         call add " "
         call add msgid"This exec is exlicity called."
         call add msgid"In this case the following members are needed",
                       "in this library, too."
         call add msgid" "
         call add msgid""left("Library  ",8)" - '"_rexxdsn_"'"
         call add msgid" "
         call add msgid""left("Member   ",8)" - Status"
         call add msgid""left("---------",8)"   "copies("-",30)
              do i = 1 to members.0
                 call add msgid""left(members.i.1,8)" - "members.i.2
              end
         call add msgid" "
         call add msgid"endig with rcode="maxcc"."
         _x_ = show_data()
        end;
  return maxcc
