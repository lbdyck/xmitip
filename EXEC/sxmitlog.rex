        /* --------------------  rexx procedure  -------------------- *
         * Name:      SXMITLOG                                        *
         *                                                            *
         * Function:  Save the XMITIP Log data set to a copy          *
         *            and clear by calling LOGITCPY                   *
         *                                                            *
         * Syntax:    %sxmitlog                                       *
         *                                                            *
         * Customizations:                                            *
         *            1. The notify variable to e-mail the            *
         *               log                                          *
         *            2. The input log data set name                  *
         *            3. The output save data set name hlq            *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            04/15/04 - Change to remove parms and add       *
         *                       internal variables                   *
         *                       * so automation can easily call      *
         *                     - Change xmitip format to txt          *
         *            04/05/04 - Creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         arg


        /* ---------------------------------- *
         * Define the Input Log Data Set Name *
         * ---------------------------------- */
         logdsn = "'sysl.xmitip."sysvar('sysnode')".log'"

        /* -------------------------------------------- *
         * Define the Output Save Log Data Set Name hlq *
         * -------------------------------------------- */
         save_hlq = "sysl.xmitip."sysvar('sysnode')".logsave"

        /* ---------------------- *
         * Test for logdsn status *
         * ---------------------- */
         if sysdsn(logdsn) <> "OK" then do
            say "Invalid logdsn provided:" logdsn
            say sysdsn(logdsn)
            say "Exiting...."
            exit 8
            end

        /* --------------------------------- *
         * Define the Save Log Data Set Name *
         * --------------------------------- */
         save_dsn =  "'"save_hlq".D"date('j')"'"

        /* ---------------------------------------------------- *
         * *Custom*                                             *
         * Define the Notify e-mail address and the From e-mail *
         * address.                                             *
         * ---------------------------------------------------- */
         notify = "lbdyck@gmail.com"
         from   = "lbdyck@gmail.com"

        /* ------------------------------------------ *
         * Now call LOGITCPY to do the copy and clear *
         * ------------------------------------------ */
         "%logitcpy" logdsn save_dsn "clear"

         '%xmitip' notify 'subject "xmitip log created"' ,
            'msgt "The XMITIP Log data set' logdsn 'has been' ,
            'copied to' save_dsn 'and cleared."' ,
            'From' from ,
            'File' save_dsn

        /* ----------------------------- *
         * All done so exit this routine *
         * ----------------------------- */
         exit 0

        /* ------------------------------ *
         * Report Invalid Syntax and Exit *
         * ------------------------------ */
         Invalid_Syntax:
         Say "SXMITLOG has been called with invalid syntax:"
         say "   %sxmitlog logdsn save_hlq"
         say " "
         say "Try again...."
         exit 8
