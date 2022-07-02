        /* --------------------  rexx procedure  -------------------- */
           ver = "0.8"
        /* Name:      Logit                                           *
         *                                                            *
         * Function:  Log a message into a log data set.              *
         *                                                            *
         *            Designed to be called by a CLIST or REXX Exec   *
         *            to log items of interest.                       *
         *                                                            *
         *            The log data set should never be processed      *
         *            interactively. It should be copied and the      *
         *            copy reviewed.                                  *
         *                                                            *
         *            Note that the log data set must be defined      *
         *            such that everyone can write into it.           *
         *                                                            *
         *            The log message will be written with a          *
         *            header:                                         *
         *            yyyymmdd hh:mm:ss jobname userid systemid       *
         *               message text                                 *
         *                                                            *
         *            It is recommended that the log data set be      *
         *            allocated RECFM=VB LRECL=255 BLKSIZE=0          *
         *            with a large primary and a secondary in tracks  *
         *            or blocks as the calculation for free space     *
         *            is based on allocated-used space from listdsi   *
         *            so the more granular the better.                *
         *                                                            *
         *            The test for free space requires at least 2     *
         *            free space units (blocks or tracks).            *
         *                                                            *
         *            See the LOGITCPY to copy and clear the log.     *
         *                                                            *
         * NOTE:      If the Log Data Set has no remaining space      *
         *            then there will be no attempt to write the      *
         *            log entry and this exec will return with        *
         *            a return code of 4.                             *
         *                                                            *
         * Syntax:    %logit log_data_set log_message_text            *
         *                                                            *
         *            The log_data_set must be pre-allocated and      *
         *            if accessed using DISP=MOD. If the data set     *
         *            can not be allocated because it is in use       *
         *            then it is attempted n more times before        *
         *            giving up (where n is defined in this code.     *
         *                                                            *
         *            The log_message text may be mixed case and      *
         *            does not require any quotes or other special    *
         *            formatting.                                     *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *          2008-11-06 - 0.8 add jobid to the standard header *
         *                       use option logjobid to switch ON/off *
         *                     - use stem log. instead of queued msg  *
         *                       (other lines may already be queued)  *
         *          2008-07-17 - 0.7 code clearing: use quotes        *
         *                     - avoid use of names (variable/section)*
         *                       which may cause conflicts because    *
         *                       the names are already reserved or    *
         *                       builtin functions:                   *
         *                        - sleep - _sleep_ - sub_sleep       *
         *                          (Label corresponds to a BIF name) *
         *          2008-04-28 - 0.6 Add Return before SLEEP routine  *
         *          2004-04-12 - 0.5 Correct setting of Sleep var     *
         *          2004-04-03 - 0.4 Change to require a minimum of   *
         *                       2 free space units                   *
         *          2004-04-02 - 0.3 Change Exit to Return            *
         *                       Test if there is space available     *
         *                       in the log data set before writing   *
         *                       to avoid a D37 abend                 *
         *          2004-04-02 - Add version and change jobname/userid*
         *                       to 8 chars in length                 *
         *          2004-04-02 - Correct call to Sleep routine        *
         *          2004-04-02 - Improve comments and add header      *
         *          2004-04-01 - Creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
        parse arg logds logmsg

        logds    = strip(logds)
        logmsg   = strip(logmsg)

        logjobid = "Y"           /* Y/n - add JOBID to the header */

        /* ---------------------------- *
         * Test that we have both parms *
         * ---------------------------- */
         if logds = "" then do
            say "Logit: Error - invalid syntax"
            say "       No parameters provided."
            say "       Exiting."
            return 8
            end
         if logmsg = "" then do
            say "Logit: Error - invalid syntax"
            say "       No log message text provided."
            say "       Exiting."
            return 8
            end

        /* ------------------------------------ *
         * Determine if the log data set exists *
         * ------------------------------------ */
         _x_ = listdsi(logds)
         if sysreason > 0 then do
            say "Logit: Error - the log data set:" logds
            say "      " sysdsn(logds)
            say "        Exiting...."
            return 8
            end
         _sysalloc_ = sysalloc
         _sysused_  = sysused
         select;
           when ( _sysused_ = "N/A"          ) then nop;
           when ( _sysalloc_ - _sysused_ < 2 ) then return 4
           otherwise nop;
         end;

        /* ------------------------------------------------------ *
         * Define the number of seconds to sleep between attempts *
         * ------------------------------------------------------ */
         _sleep_ = 1

        /* ----------------------------------- *
         * Define the number of retry attempts *
         * ----------------------------------- */
         retry = 10

         dd = "logit"random(999)
         c  = 1
         _x_ = msg("off")

         do forever
            c = c + 1
            if c > retry then return 4
            "alloc f("dd") mod ds("logds") reuse"
            rcode = rc
            if rcode > 0 then _x_ = sub_sleep(_sleep_)
            else do
                 if logjobid = "Y" ,
                 then _jobid_ = left(sub_jobid(),9) ;
                 else _jobid_ = ""
                 log.1 = date('s') time('n') ,
                         left(mvsvar("symdef","jobname"),8)"",
                         _jobid_""left(sysvar('sysuid'),8) ,
                         left(mvsvar('sysname'),8) ,
                         logmsg
                 log.0 = 1
                 "Execio * diskw" dd "(stem log. FINIS)"
                 "Free f("dd")"
                 leave
                 end
            end
         return

        /* --------------------------------------------------- *
         * Sleep Routine. This routine will call the USS Sleep *
         * routine and sleep for 1 second.                     *
         * --------------------------------------------------- */
         sub_sleep:
           parse arg _sleep_
           call syscalls("ON")           /* allow calls to omvs */
           address "SYSCALL" "SLEEP ("_sleep_")"
          return 0

 sub_jobid:
   tcb      = ptr(540)
   tiot     = ptr(tcb+12)
   jscb     = ptr(tcb+180)
   ssib     = ptr(jscb+316)
   jobid    = stg(ssib+12,8)
   return jobid

  ptr: return c2d(storage(d2x(arg(1)),4))
  stg: return storage(d2x(arg(1)),arg(2))
