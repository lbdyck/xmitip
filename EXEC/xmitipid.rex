        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITIPID                                        *
         *                                                            *
         * Function:  Test the validity of an e-mail address          *
         *            by accessing a ldap mail address server         *
         *                                                            *
         * Syntax:    %xmitipid address                               *
         *                                                            *
         * Return:    0 = successful - address found                  *
         *            4 = address not found                           *
         *            8 = ldap server did not respond                 *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * Customizations Required: see below for *custom*            *
         *                                                            *
         * NOTE: If you do not want to use this exec then find *exit* *
         *                                                            *
         * It should be noted that customizations for this exec are   *
         * not included in XMITIPCU for various reasons (trust me).   *
         *                                                            *
         * Assumptions:                                               *
         *   1. GLD.SGLDLNK is in your linklist                       *
         *                                                            *
         * History:                                                   *
         *          2009-03-20 - Update for new XMITLDAP parms        *
         *          2008-11-10 - Update to use new directory          *
         *          2008-07-07 - Update to resolve issue with compiler*
         *          2007-10-16 - Add retry 3 times on ldap query      *
         *          2005-02-15 - If rc from search is 81 then the     *
         *                       ldap server is down. set it so.      *
         *          2004-03-30 - Improvements on local node lookup    *
         *                       Change from preferredRFC822... to    *
         *                       mail= (much much faster)             *
         *          2004-03-02 - Elimiante test for xmitipcu idval    *
         *          2003-08-26 - Add option to always check the id    *
         *                       Change from using mail=address to    *
         *                       preferredRfc822Originator=address    *
         *                       as this is the best address to look  *
         *                       for.                                 *
         *          2003-03-24 - remove references to b64_load        *
         *          2002-02-06 - make ddname more random (use time)   *
         *          2001-11-05 - test for idval of 3 and exit         *
         *          2001-10-10 - clean up ldap variables              *
         *          2001-06-21 - fix gldsrch in case user does not    *
         *                       have an omvs racf segment.           *
         *          2001-05-29 - xmitipcu char option                 *
         *          2001-04-26 - add AtSign support                   *
         *          2000-11-21 - clean up                             *
         *          2000-11-09 - creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         arg _address_ ldapopt

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

        /* Ensure correct Email-Address translation for ldap : */
        LdapAtSign    = "@"
        AtSign        = left(strip(AtSign),1)
        if AtSign /= LdapAtSign then
           _address_ = translate(_address_,LdapAtSign,AtSign)

        /* ------------------------------------------------------------ *
         * call xmitldap for ldap server location                       *
         * ------------------------------------------------------------ */
         x=xmitldap()
         parse value x with ldap_s "/" ldap_o "/" _d "/" _w ,
                      "/" local_nodes "/" ldap_name ldap_mail
         if ldap_s = 0 then exit 0
         ldap_s = strip(ldap_s)
         ldap_o = strip(ldap_o)
         ldapcount = 0

        /* ----------------------------------------------------- *
         * Setup work                                            *
         * ----------------------------------------------------- */
         Start:
         work_dd = "ldap"right(time('l'),4)
        "Alloc f("work_dd") new spa(1,1) tr"

        /* ----------------------------------------------------- *
         * Test to see if the address node is one we want to chk *
         * ----------------------------------------------------- */
         parse value _address_ with . (LdapAtSign) node
         local_nodes = translate(local_nodes)
         node = translate(node)
         hit = 0
         do i = 1 to words(local_nodes)
            if pos(word(local_nodes,i),node) > 0 then hit = 1
            end
         if hit = 0 then
            signal out_a_here

        /* ----------------------------------------------------- *
         * Call the LDAP Search command                          *
         * ----------------------------------------------------- */
         cmd = 'GLDSRCH ENVAR("LIBPATH=/")' ,
               '/ -h' ldap_s ,
               '-b "ou=people,dc=kp,dc=org" ' ,
               _d  _w ,
               '"'ldap_mail''_address_'"' ,
               ">DD:"work_dd
         cmd
         x_rc = rc

        /* ----------------------------------------------------- *
         * Test for results, if any                              *
         * ----------------------------------------------------- */
         "Execio * diskr" work_dd "(finis stem ldap."
         call msg 'off'
         "Free f("work_dd")"


        /* --------------------------------- *
         * Test return from the LDAP search. *
         *                                   *
         * Retry 3 times if necessary.       *
         * --------------------------------- */
         if x_rc > 0
            then if ldapcount < 2
            then do
            ldapcount = ldapcount + 1
            /* ----------------------------- *
             * Wait 5 seconds and then retry *
             * ----------------------------- */
            call syscalls('ON')  /* allow calls to omvs */
            sleep_sec = 5
            address 'SYSCALL' 'SLEEP ('sleep_sec')'
            signal start
            end


        /* ----------------------------------------------------- *
         * If the return from the search is 1 then server not ok *
         * If the return from the search is 81 then the server is*
         * down.                                                 *
         * ----------------------------------------------------- */
         if x_rc = 1  then exit 8
         if x_rc = 81 then do
            Say "Error encountered accessing the LDAP Server" ldap_s
            Say "Proceeding without LDAP Server."
            Say " "
            exit 8
            end

        /* ----------------------------------------------------- *
         * Return code 0 is good, 4 means not found              *
         * ----------------------------------------------------- */
         if ldap.0 = 0 then exit 4
                       else exit 0
        /* ----------------------------------------------------- *
         * Leave                                                 *
         * ----------------------------------------------------- */
         Out_A_Here:
            "Free f("work_dd")"
            exit 0
