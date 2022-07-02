        /* --------------------  rexx procedure  -------------------- *
         * Name:      LDAPMAIL                                        *
         *                                                            *
         * Function:  Mail Lookup via LDAP                            *
         *                                                            *
         * Syntax:    %LDAPMAIL name                                  *
         *            or                                              *
         *            %LDAPMAIL / name                                *
         *                                                            *
         *            if / is used then information returned via      *
         *            rexx say statements which can be trapped        *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * Notes:     Find *custom* for local customizations          *
         *                                                            *
         * History:                                                   *
         *            03/24/10 - Update and use XMITLDAP for server   *
         *                       plus added testing                   *
         *            08/26/03 - Fixup name so middle initial has .   *
         *                     - change to use the directory entry    *
         *                       preferredRfc822Originator for the    *
         *                       correct e-mail address               *
         *            10/31/01 - add / (batch mode) option            *
         *            06/21/01 - fix in case user doesn't have omvs   *
         *            11/21/00 - generalize                           *
         *            11/16/00 - cleanup                              *
         *            11/13/00 - creation                             *
         *                                                            *
         * ---------------------------------------------------------- */

        /* ----------------------------------------------------- *
         * Get any input options                                 *
         * ----------------------------------------------------- */
         parse arg option

        /* --------------------------------------------------------- *
         * Test for batch option and set batch = 1 (true)            *
         * or - (false)                                              *
         * --------------------------------------------------------- */
         if pos("/",option) > 0 then do
            batch = 1
            parse value option with "/" option
            option = strip(option)
            end
         else batch = 0

        /* ----------------------------------------------------- *
         * Set defaults by getting the information from XMITLDAP *
         * ----------------------------------------------------- */
         x = xmitldap()
         parse value x with ldap_s "/" ldap_o "/" _d "/" _w "/" x ,
                            '/' ldap_name ldap_mail
         dd         = "ldap"random(999)
         ldap_table = dd
         error      = 0
         ldap_s     = strip(ldap_s)
         ldap_o     = strip(ldap_o)

         null       = ""
         count      = 0

        /* ----------------------------------------------------- *
         * Test to see if this is enabled                        *
         * ----------------------------------------------------- */
         if ldap_s = 0 then do
            zedsmsg = "Invalid"
            zedlmsg = "This function is not enabled on your system".
            if batch then say zedlmsg
            else Address ISPExec "Setmsg msg(isrz001)"
            exit 4
            end

        /* ----------------------------------------------------- *
         * If no parameters call the display routine             *
         * ----------------------------------------------------- */
         if length(option) > 0 then call test_option
                              else error = 1
         if batch then
            if error = 1 then do
            say "Error - no valid options provided." ,
                "Try again."
            exit 4
            end
            else signal start
         if error = 1 then signal display
                      else Address ISPExec "Control Nondispl Enter"

        /* ----------------------------------------------------- *
         * Display the prompt panel for input                    *
         * ----------------------------------------------------- */
         Display:
         error = 0
         do forever
            Address ISPExec
            "Display Panel(LDAPMLP)"
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
         "Alloc f("dd") ds("dd".list) new spa(90,90) tr"

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
         "delete "dd".list"

        /* ----------------------------------------------------- *
         * Test to see if we had any hits                        *
         * ----------------------------------------------------- */
         if ldap.0 = 0 then do
            zedsmsg = "Not Found"
            zedlmsg = "Name:" option "not found - try again"
            if batch then say zedlmsg
                     else Address ISPExec "Setmsg msg(isrz001)"
            return
            end

        /* ----------------------------------------------------- *
         * Setup Table environment                               *
         * ----------------------------------------------------- */
         cn    = 0
         table = 0
         if batch = 0 then
            Address ISPExec

        /* ----------------------------------------------------- *
         * Now process thru the results getting name/address     *
         * ----------------------------------------------------- */
         parse value '' with hit ename eaddr
         do i = 1 to ldap.0
            work = strip(ldap.i)
            if left(work,4) = 'uid='
               then if hit = 1 then call add_address
               else hit = 1
            if left(work,length(ldap_name)) = ldap_name then do
               parse value work with (ldap_name)ename "," .
               if words(ename) = 3 then do
                  parse value ename with ln mn rn
                  ename = ln mn"." rn
                  end
               end
            if left(work,length(ldap_mail)) = ldap_mail then do
                parse value work with (ldap_mail)eaddr
                end
            end

        /* --------------------------------------------------------- *
         * If batch mode then exit now                               *
         * --------------------------------------------------------- */
         if batch then exit 0

         /* ---------------------- *
          * If no hits then say so *
          * ---------------------- */
          if count = 0 then do
            zedsmsg = "No Hits"
            zedlmsg = "No e-mail addresses were found for this search."
            if batch then say zedlmsg
            else Address ISPExec "Setmsg msg(isrz001)"
             return
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
                  "TBDispl" ldap_table "Panel(ldapmlt)" ,
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
            zedsmsg = "Error!"
            zedlmsg = "A name of" option "is too generic.  Try" ,
                      "somthing more specific."
            if batch then say zedlmsg
                     else Address ISPExec "Setmsg msg(isrz001)"
            end
         return

        /* ----------------------------------------------------- *
         * Add the name and address to our selection table       *
         * ----------------------------------------------------- */
         Add_Address:
         if length(ename) = 0 then return
         if length(eaddr) = 0 then return
         if batch then do
            say "Name:" ename
            say "Addr:" eaddr
            return
            end
         if table = 0 then call open_table
         "TBAdd" ldap_table "order"
         ename = null
         eaddr = null
         count = count + 1
         return

        /* ----------------------------------------------------- *
         * Open the ldap mail lookup table                       *
         * ----------------------------------------------------- */
         Open_Table:
         table = 1
         "TBCreate" ldap_table "Names(ename lact eaddr) Share"
         "TBSort"   ldap_table "Fields(ename,c,a)"
         return
