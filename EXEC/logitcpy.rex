        /* --------------------  rexx procedure  -------------------- *
         * Name:      LOGITCPY                                        *
         *                                                            *
         * Function:  To copy the LOGIT log data set and optionally   *
         *            reinitialize it                                 *
         *                                                            *
         * Syntax:    %logitcpy input_log output_log option           *
         *                                                            *
         *            input_log is the current log data set name      *
         *                                                            *
         *            output_log is the data set to be created        *
         *            containing a copy of the input_log              *
         *                                                            *
         *            clear is optional and if specified will         *
         *            empty out the input_log                         *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *          2008-07-17 - code clearing: use quotes            *
         *                     - avoid use of names (variable/section)*
         *                       which may cause conflicts because    *
         *                       the names are already reserved or    *
         *                       builtin functions:                   *
         *                        - sleep - _sleep_ - sub_sleep       *
         *                          (Label corresponds to a BIF name) *
         *          2008-01-21 - correct sysvar(logds) with sysdsn(..)*
         *          2005-02-03 - Change message logit: to logitcpy:   *
         *          2004-04-14 - Change retry count to 100 from 10    *
         *          2004-04-12 - Minor correction in sleep variable   *
         *          2004-04-02 - creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         arg logds output clear

         if sysdsn(logds) <> "OK" then do
            say "LOGITCPY Error: The input log data set:" logds
            say sysdsn(logds)
            say "Exiting..."
            exit 8
            end

         if sysdsn(output) = "OK" then do
            say "LOGITCPY Error: The output log data set:" output
            say "                already exists. Please try again."
            say "                The output can not already exist."
            say "Exiting..."
            exit 8
            end

        /* ------------------------------------------------------ *
         * Define the number of seconds to sleep between attempts *
         * ------------------------------------------------------ */
         _sleep_ = 1

        /* ----------------------------------- *
         * Define the number of retry attempts *
         * ----------------------------------- */
         retry = 100

         dd = "logit"random(999)
         c  = 1
         _x_ = msg("off")

         do forever
            c = c + 1
            if c > retry then do
               say "Logitcpy: Allocation of the log data set:" logds
               say "       failed after" retry "attempts."
               exit 4
               end
            "alloc f("dd") shr ds("logds") reuse"
            if rc > 0 then iterate
            "Execio * diskr" dd "(finis stem in."
            if clear <> "" then do
            queue date("s") time("n") ,
                  mvsvar("symdef","jobname") sysvar("sysuid") ,
                  mvsvar("sysname") ,
                  "Log data set copied to" output "and cleared."
               "Execio 1 diskw" dd "(finis"
               end
            "Free f("dd")"
            "Alloc f("dd") ds("output") new like("logds")"
            "Execio * diskw" dd "(finis stem in."
            "Free f("dd")"
            leave
            end

        /* --------------------------------------------------- *
         * Sleep Routine. This routine will call the USS Sleep *
         * routine and sleep for 1 second.                     *
         * --------------------------------------------------- */
         sub_sleep:
           parse arg _sleep_
           call syscalls("ON")           /* allow calls to omvs */
           address "SYSCALL" "SLEEP ("_sleep_")"
          return 0
