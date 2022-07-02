        /* --------------------  rexx procedure  -------------------- *
         * Name:      mailfile                                        *
         *                                                            *
         * Function:  Used in ISPF 3.4 to pass a file to XMITIP       *
         *                                                            *
         * Syntax:    %mailfile dsname                                *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            03/16/01 - creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         parse arg dsn

        /* ----------------------------------------- *
         * Test Data Set Organization for Sequential *
         * ----------------------------------------- */
         call listdsi dsn
         if sysdsorg <> "PS" then
            if pos("(",dsn) = 0 then do
               zedsmsg = "Error"
               zedlmsg = "The requested data set must be a sequential",
                         "data set. Try again."
               Address ISPExec "Setmsg Msg(isrz001)"
               exit 4
               end

        /* ------------------------------- *
         * Now invoke the XMITIP Front End *
         * ------------------------------- */
         "%xmitipfe file("dsn")"
