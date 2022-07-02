        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITIPTD                                        *
         *                                                            *
         * Function:  Send e-mails on a timed delivery (scheduled)    *
         *            basis. The key is that this utility should be   *
         *            invoked in a batch job that is scheduled by     *
         *            the batch production scheduling system to run   *
         *            once per day (e.g. 4am)                         *
         *                                                            *
         * Syntax:    %xmitiptd control-dataset debug                 *
         *                                                            *
         *            control-dataset contains the control            *
         *                    statements that drive this code         *
         *                    (see below for statement definitions)   *
         *            debug - optional and used for diagnostics       *
         *                    DEBUG will trace the entire exec        *
         *                    MDEBUG will set XMITIP to DEBUG status  *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            2007-12-05 - Minor Cleanup                      *
         *            2007-12-04 - Creation                           *
         *                                                            *
         * ---------------------------------------------------------- */
         parse value "" with null cds debug mdebug

         arg cds debug

         if debug = "DEBUG" then trace "?i"
         if debug = "MDEBUG" then mdebug = "debug"
         if cds = null then do
            say "Error: Invalid syntax."
            say "       You must specify the data set name of a "
            say "       control data set to be used."
            exit 16
            end

         if left(cds,1) = "'" ,
            then parse value cds with "'"cdsnq"'"
            else cdsnq = cds

        /* ------------------------------------ *
         * Process Control Data Set Information *
         * ------------------------------------ */
         call outtrap "mem."
         "Listd" cds "Members"
         call outtrap "off"
         do m = 7 to mem.0
            mem = word(mem.m,1)
            if left(mem,2) = "TD" then call do_it
            end
         exit 0

        /* ------------------------------------------------------------ *
         * Do_It routine processes the member statement extracting the  *
         * control information thus:                                    *
         *                                                              *
         * statement - contents                                         *
         * 1 - day(s) of the week (Sunday, Monday, ...)                 *
         *     multiple days are allowed separated by blanks            *
         *     or a day of the month (e.g. 15)                          *
         *     multiple are allowed separated by blanks                 *
         * 2 - Name of the owner of this request or the contact         *
         *     person. Should have name and e-mail address              *
         * 3 - SUBJECT: subject of the e-mail in xmitip format          *
         *     (the word SUBJECT: is required)                          *
         *     xmitip variables are allowed                             *
         * 4 - dataset name of a sequential or a member of a pds with   *
         *     a xmitip addressfile                                     *
         * 5 - dataset name of a sequential file or a member of a pds   *
         *     with the message text to be delivered                    *
         * 6 - REPLYTO e-mail address to receive any bounces or replies *
         *     to the sent e-mail                                       *
         * ------------------------------------------------------------ */
         do_it:
         parse value "" with day owner subject address message reply
         drop cdsm.
         "Alloc f(cdsm) ds('"cdsnq"("mem")') shr reuse"
         "Execio * diskr cdsm (finis stem cdsm."
         "Free  f(cdsm)"
         day     = cdsm.1
         owner   = cdsm.2
         subject = strip(cdsm.3)
         address = strip(cdsm.4)
         message = strip(cdsm.5)
         reply   = strip(cdsm.6)

        /* ------------------------ *
         * Validate the information *
         * ------------------------ */
         if strip(day)      = null then call error "Day"

        /* --------------------------------- *
         * Check day of week or day of month *
         * --------------------------------- */
         wd  = translate(date('w'))
         day = translate(day)
         hit = 0
         if pos(wd,day) > 0 then hit = 1
         do x = 1 to words(day)
            if datatype(word(day,x)) = "NUM"
               then if word(day,x) = word(date('n'),1) then hit = 1
            end
         if hit = 0 then return

         if length(owner)   = 0    then call error "Owner"
         if length(subject) = 0    then call error "Subject"
         if length(address) = 0    then call error "Address"
         if length(message) = 0    then call error "Message"
         if length(reply)   = 0    then call error "Reply"
         if pos("@",reply)  = 0    then call error "Reply"
         if left(translate(subject),8) <> "SUBJECT:"
                                  then call error "Subject"
         subject = strip(substr(subject,9))
         address = "'"address"'"
         message = "'"message"'"
         if listdsi(address) > 0  then call error "Address"
         if listdsi(message) > 0  then call error "Message"

         cmd = "%xmitip * from" reply ,
               "subject '"subject"'"   ,
               "msgds" message ,
               "addressfile" address mdebug
         Say "The Generated XMITIP command is:"
         say " "
         say cmd
         say " "
         cmd

         Return

        /* ------------- *
         * Error routine *
         * ------------- */
         Error:
         parse arg error
         Say "Error found in statement:" error
         error = translate(error)
         if wordpos("ADDRESS MESSAGE",error) > 0 then do
            say sysmsglvl1
            say sysmsglvl2
            end
         say " "
         say "Provided statements:"
         do i = 1 to cdsm.0
            say cdsm.i
            end
         Exit 16
