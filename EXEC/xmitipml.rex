        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITIPML                                        *
         *                                                            *
         * Function:  Mail Lookup for XMITIP                          *
         *                                                            *
         * Syntax:    %xmitipml name "/" table-name                   *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            e-mail: lbdyck@gmail.com                        *
         *                                                            *
         * History:                                                   *
         *            2009-03-20 - Change for new XMITLDAP parms      *
         *            2008-11-10 - Update to use new ldap directory   *
         *            2006-06-20 - Correction to use hlq for delete   *
         *                         (was already used for alloc)       *
         *            2003-11-13 - Changes with minor corrections     *
         *                         thanks to Jose Miguel Lopez Tomas  *
         *                       - Correctly add Name to the table    *
         *                       - Add ISPF message for duplicate add *
         *                         attempts                           *
         *            2003-08-26 - change to use the directory entry  *
         *                         preferredRfc822Originator for the  *
         *                         correct e-mail address             *
         *            2001-12-04 - change to use XMIT001 message      *
         *            2001-11-02 - fix misleading dup                 *
         *            2001-10-10 - clean up ldap variables            *
         *            2001-07-23 - force atype to null                *
         *            2001-06-25 - fix gldsrch                        *
         *            2001-06-21 - minor correction for startup       *
         *            2000-11-24 - add upper case e-address           *
         *            2000-11-21 - fit cols 1-72                      *
         *            2000-11-16 - cleanup                            *
         *            2000-11-13 - creation                           *
         *                                                            *
         * ---------------------------------------------------------- */

        /* ----------------------------------------------------- *
         * Get any input options                                 *
         * ----------------------------------------------------- */
         parse arg option "/" table_name

        /* ----------------------------------------------------- *
         * Set defaults                                          *
         * ----------------------------------------------------- */
         x = xmitldap()
         parse value x with ldap_s "/" ldap_o "/" _d "/" _w "/" x ,
                            '/' ldap_name ldap_mail
         dd         = "ldap"random(999)
         ldap_table = dd
         null       = ""
         error      = 0
         ldap_s     = strip(ldap_s)
         ldap_o     = strip(ldap_o)

        /* ----------------------------------------------------- *
         * Test to see if this is enabled                        *
         * ----------------------------------------------------- */
         if ldap_s = 0 then do
            smsg = "Invalid"
            lmsg = "This function is not enabled on your system".
            Address ISPExec "Setmsg msg(xmit001)"
            exit 4
            end

        /* ----------------------------------------------------- *
         * If no parameters call the display routine             *
         * ----------------------------------------------------- */
         if length(option) > 0 then call test_option
                               else error = 1
         if error = 1 then signal display
                      else Address ISPExec "Control Nondispl Enter"

        /* ----------------------------------------------------- *
         * Display the prompt panel for input                    *
         * ----------------------------------------------------- */
         Display:
         error = 0
         do forever
            lact  = null
            Address ISPExec
            "Display Panel(xmitipml)"
            if rc > 4 then exit 4
            call test_option
            if error = 0 then call start
            end

        /* ----------------------------------------------------- *
         * Start of the process                                  *
         * ----------------------------------------------------- */
         Start:
         Address TSO

        /* ----------------------------------------------------- *
         * Allocate the work file for the ldap search            *
         * ----------------------------------------------------- */
         if sysvar('sysuid') = sysvar('syspref')
            then hlq = sysvar('syspref')
            else hlq = sysvar('syspref')"."sysvar('sysuid')
         work_dsn = "'"hlq"."dd".list'"
         "Alloc f("dd") ds("work_dsn") new spa(90,90) tr"

        /* ----------------------------------------------------- *
         * Now invoke the ldap search command.                   *
         * ----------------------------------------------------- */
         cmd = 'GLDSRCH ENVAR("LIBPATH=/")' ,
               '/ -h' ldap_s ,
               '-b "ou=people,dc=kp,dc=org" ' ,
               _d _w ,
               '"'ldap_name''option'"' ,
               ">DD:"dd
         cmd

        /* ----------------------------------------------------- *
         * Read the results and free/delete the work file        *
         * ----------------------------------------------------- */
         "Execio * diskr" dd " (finis stem ldap."
         call msg 'off'
         "Free f("dd")"
         "delete" work_dsn

        /* ----------------------------------------------------- *
         * Test to see if we had any hits                        *
         * ----------------------------------------------------- */
         if ldap.0 = 0 then do
            smsg = "Not Found"
            lmsg = "Name:" option "not found - try again"
            Address ISPExec "Setmsg msg(xmit001)"
            return
            end

        /* ----------------------------------------------------- *
         * Setup Table environment                               *
         * ----------------------------------------------------- */
         cn    = 0
         table = 0
         Address ISPExec

        /* ----------------------------------------------------- *
         * Now process thru the results getting name/address     *
         * ----------------------------------------------------- */
         do i = 1 to ldap.0
            work = strip(ldap.i)
            /* sample mail=lbdyck@gmail.com     */
            if left(work,length(ldap_name)) = ldap_name then do
               parse value work with (ldap_name)ename "," .
               if words(ename) = 3 then do
                  parse value ename with ln mn rn
                  ename = ln mn"." rn
                  end
               end
            if left(work,length(ldap_mail)) = ldap_mail then do
                parse value work with (ldap_mail)eaddr
                call add_address
                end
            end

        /* ----------------------------------------------------- *
         * Display the LDAP Results Table                        *
         * ----------------------------------------------------- */
          mult_sels = 0
          crp = 1
          rowcrp = 0
          disp:
          do forever
             zcmd = null
             if mult_sels = 0 then do
               "TBTop" ldap_table
               "TBSkip" ldap_table "Number("crp")"
                  "TBDispl" ldap_table "Panel(xmitipmt)" ,
                          "Csrrow("rowcrp") AutoSel(No)"
               end
             else
               "TBDispl" ldap_table
             t_rc = rc
             mult_sels = ztdsels
             if t_rc > 7 then do
                "TBEnd" ldap_table
                return
                end
             Select
               When zsel = "S" then do
                    lact = "Added"
                    zsel = null
                    lact = "Added"
                    eaddru = translate(eaddr)
                    atype  = null
                    "TBAdd" table_name "order"
                    if rc > 0 then do
                       lact = "Dup"
                       smsg = "Duplicate"
                       lmsg = "The address you attempted to add" ,
                              "to the XMITIP address book already" ,
                              "exists."
                       "Setmsg Msg(xmit001)"
                       end
                    "TBMod" ldap_table
                    end
               Otherwise nop
               end
               zsel = null
          end

         return

        /* ----------------------------------------------------- *
         * If option is * or x* or *x then set error as too      *
         *    many names could be returned with that query.      *
         * ----------------------------------------------------- */
         Test_option:
         error = 0
         if option = "*" then error = 1
         if length(option) = 2 then do
            if right(option,1) = "*" then error = 1
            if left(option,1)  = "*" then error = 1
            end
         if error = 1 then do
            smsg = "Error!"
            lmsg = "A name of" option "is too generic.     Try" ,
                      "something more specific."
            Address ISPExec "Setmsg msg(xmit001)"
            end
         return

        /* ----------------------------------------------------- *
         * Add the name and address to our selection table       *
         * ----------------------------------------------------- */
         Add_Address:
         if table = 0 then call open_table
         "TBAdd" ldap_table "order"
         return

        /* ----------------------------------------------------- *
         * Open the ldap mail lookup table                       *
         * ----------------------------------------------------- */
         Open_Table:
         table = 1
         "TBCreate" ldap_table "Keys(eaddr) Names(lact ename) Share"
         "TBSort"   ldap_table "Fields(ename,c,a)"
         return
