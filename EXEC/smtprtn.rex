        /* --------------------  rexx procedure  -------------------- *
         * Name:      smtprtn                                         *
         *                                                            *
         * Function:  report e-mail addresses of all users with       *
         *            mail to receive on os/390                       *
         *                                                            *
         * Syntax:    %smtprtn uid-dd                                 *
         *                                                            *
         *            uid-dd is optional and if used references as    *
         *            ddname with the following data format:          *
         *                                                            *
         *            tso-userid e-mail.address                       *
         *                                                            *
         *            This is used to override the address lookup     *
         *            when the name from the security system does not *
         *            return a valid name for address lookup.         *
         *                                                            *
         * Process:   sdsf output job data set list for the           *
         *            smtp started task via dd SDSFIN                 *
         *            * this dd must be preallocated                  *
         *                                                            *
         *            This code requires the use of the XMITIP        *
         *            REXX application.                               *
         *                                                            *
         * Dependencies: The LDAPMAIL exec is required.               *
         *                                                            *
         * Customization Required:                                    *
         *           set variable SMTP to the name of your SMTP       *
         *           started task (may be multiple names)             *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            09/05/03 - Add more text about where to change  *
         *                       from if using xmitip                 *
         *            05/09/02 - Add uid-dsn option                   *
         *            11/30/01 - Change to use the SDSF O information *
         *            11/02/01 - Add contact information and reply    *
         *            11/02/01 - Minor cleanup                        *
         *            10/31/01 - Creation                             *
         *                                                            *
         * ---------------------------------------------------------- */

         arg uiddd

         parse value "" with dests null uids.

         if length(uiddd) > 0 then do
           "Execio * diskr" uiddd "(finis stem uids."
           end

         "Execio * diskr sdsfin (finis stem in."
         "Free f(sdsfin)"

         smtp = "SMTP TCPSMTP"

         do i = 1 to in.0
            if word(in.i,1) = "NP" then leave
            end

         do j = i+1 to in.0
            stc = word(in.j,1)
            if wordpos(stc,smtp) = 0 then iterate
            dest = word(in.j,7)
            addr = null
            if wordpos(dest,dests) > 0 then iterate
            if uids.0 <> null then do
               do ui = 1 to uids.0
                  if dest <> translate(word(uids.ui,1)) then iterate
                  addr = word(uids.ui,2)
                  end
               end
            call get_name
            if addr = null then
               call get_address
            if pos("*",name) > 0 then do
               name = translate(name," ","*")
               name = word(name,1)
               name = translate(name, ,
                      "abcdefghijklmnopqrstuvwxyz", ,
                      "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
               first = left(name,1)
               rest = substr(name,2)
               name = translate(first)rest
               end
            say "Mail found for userid:" left(dest,8) ,
                "Name:" name "at e-mail:" addr
            if strip(name) = null then iterate
            if strip(addr) = null then iterate
            dests = dests dest
            name_table.dest.1 = name
            name_table.dest.2 = addr
            end

        /* --------------------------------------------------------- *
         * Now report out what we found                              *
         * --------------------------------------------------------- */
            w = words(dests)
            do i = 1 to w
               dest = word(dests,i)
               name = name_table.dest.1
               say "Sending notification e-mail to:" name "at" ,
                    name_table.dest.2
               "NewStack"
               queue name_table.dest.1","
               queue "  "
               queue "You have received mail on TSO that needs to be" ,
                     "processed on" mvsvar('sysname')"."
               queue "For TSO Userid:" dest
               queue "  "
               queue "To do this:"
               queue "   1. Logon to TSO"
               queue "   2. If under ISPF issue TSO RECEIVE"
               queue "      or if at TSO READY issue RECEIVE"
               queue "  "
               queue "There are several reasons that this might occur:"
               queue " "
               queue "   1. An invalid recipient address"
               queue "   2. The recipient replied to an e-mail of yours"
               queue "      which did not use your offical e-mail" ,
                          " address for the from address"
               queue "  "
               queue "This may occur whenever you do not use" ,
                     "your offical e-mail"
               queue "address for the from address for mail" ,
                     "sent from TSO or Batch jobs."
               queue "  "
               queue "You may correct this by adding a FROM" ,
                     name_table.dest.2 "to your mainframe e-mail"
               queue "  "
               queue "If you are generating the e-mail using the" ,
                     "XMITIP application then:"
               queue "1. Xhen the XMITIP panel appears enter YES" ,
                     "in the Default Settings field."
               queue "2. Press enter and a popup will appear where" ,
                     "you can change or set your From e-mail address."
               queue "  "
               queue "Questions contact Lionel B. Dyck at" ,
                     "8/473-5332 or (925) 926-5332 or"
               queue "via e-mail at lbdyck@gmail.com"
               queue "  "
               "%xmitip" name_table.dest.2 "msgq subject" ,
                  "'TSO Mail Notification' from lbdyck@gmail.com" ,
                  " noconfirm"
               "DelStack"
               end
            Exit 0

        /* --------------------------------------------------------- *
         * Get the users name based on userid using RACF             *
         * --------------------------------------------------------- */
         Get_Name:
           call outtrap "trap."
           "LU" dest
           call outtrap "off"
           parse value trap.1 with . "NAME=" name "OWNER" .
           if pos(",",name) > 0 then do
              parse value name with last "," first .
              name = strip(first)"*" "*"strip(last)
              end
           else do
              Select
                 When words(name) = 2 then
                    parse value name with first last
                 When words(name) = 3 then
                    parse value name with first . last
                 Otherwise first = name
                 End
              name = strip(first)"*" "*"strip(last)
              end
           return

        /* --------------------------------------------------------- *
         * Get E-Mail via LDAP                                       *
         * --------------------------------------------------------- */
         Get_Address:
           call outtrap "trap."
           "%ldapmail /" name
           call outtrap "off"
           parse value "" with name addr
           do m = 1 to trap.0
              Select
                When word(trap.m,1) = "Name:" then
                     name = word(trap.m,2)
                When word(trap.m,1) = "Addr:" then
                     addr = word(trap.m,2)
                Otherwise nop
                end
              end
           return
