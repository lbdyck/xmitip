        /* --------------------  rexx procedure  -------------------- */
         ver = "1.10"
        /* Name:      sdsfext                                         *
         *                                                            *
         * Function:  A generalized SDSF extraction process that will *
         *            extract a specific ddname for all matching jobs *
         *            that are in the JES2 SPOOL. The extraction is   *
         *            performed to a preallocated dataset referenced  *
         *            by a dd statement in the batch tmp.             *
         *                                                            *
         * Syntax:    %sdsfext jobname ddname outdd jobnum (options   *
         *                                                            *
         *            Where:                                          *
         *                                                            *
         *            jobname is the name of the job to extract       *
         *                    or * for the current jobname            *
         *                    if * then active is set on              *
         *                                                            *
         *            ddname is the ddname to be extracted            *
         *            or                                              *
         *            (ddname1 ddname2 ...)                           *
         *            or                                              *
         *            * for all ddnames                               *
         *                                                            *
         *            ddname may be coded as stepname.ddname where    *
         *                stepname is the jcl stepname not the step   *
         *                found in a proc.                            *
         *                or stepname.procstep.ddname                 *
         *                                                            *
         *            outdd is the ddname where the extracted data    *
         *                  is to be directed                         *
         *                                                            *
         *            jobnum is the job number for the desired job    *
         *                                                            *
         *            ( is required if any options are specified      *
         *                                                            *
         *            options currently supported are:                *
         *                                                            *
         *            ACTIVE   - only process jobs that are currently *
         *                       executing.                           *
         *                     - set on if jobname is *               *
         *                                                            *
         *            DEBUG    - will echo the generated SDSF cmds    *
         *                                                            *
         *            INPUT    - will allow selection of input data   *
         *                                                            *
         * Example:  %sdsfext smtp logfile report                     *
         *                                                            *
         *           This will extract the ddname LOGFILE for each    *
         *           occurance of the job SMTP in the spool with the  *
         *           output going to preallocated dd REPORT.          *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            2008-12-01 - use quotes for x2c strings         *
         *            2004-06-12 - Update from Rick Turnbull to       *
         *                         capture all ddnames                *
         *            2004-06-10 - Update from Billy Smith            *
         *                       - add TOP command after Filter       *
         *                         Procstep                           *
         *            2004-05-04 - Updates from Daryl Johnson         *
         *                       - use mvsvar for jobname             *
         *                       - change test for NP in SDSF output  *
         *            2004-03-17 - Add INPUT option                   *
         *            2003-10-02 - Corrections thanks to Rick Turnbull*
         *                         when filtering for stepname        *
         *            2002-11-02 - correct jobname * for active       *
         *            2002-10-18 - add set display on (for debug)     *
         *            2002-10-17 - change to use X instead of PT      *
         *                       - support procstep                   *
         *            2002-10-15 - allow multiple ddnames and stepname*
         *                       - change from sdsf to isfafd         *
         *                       - add debug option                   *
         *            2002-10-13 - allow jobname of * for current job *
         *            2002-08-27 - add jobnum option thanks to        *
         *                         Pedro Cunha                        *
         *            2002-05-22 - add ACTIVE option                  *
         *            2002-05-21 - add test for no matches            *
         *            2002-05-20 - creation                           *
         *                                                            *
         * ---------------------------------------------------------- */
         arg input

        /* ---------------------------- *
         * validate the first parameter *
         * ---------------------------- */
         if words(input) < 3 then do
            say "Error: Invalid syntax.  A jobname, ddname, and outdd",
                "are required."
            say "Try again......"
            exit 8
            end

        /* ------------------------------- *
         * Now parse out the input options *
         * ------------------------------- */
         parse value input with jobname more
         if left(more,1) <> "(" then
            parse value more with ddname outdd jobnum "(" options
         else
            parse value more with "("ddname")" outdd jobnum "(" options

        /* -------------------------------------------- *
         * Test if jobname is * and get current jobname *
         * -------------------------------------------- */
         if jobname = "*" then do
            jobname = mvsvar("symdef","jobname")
            if pos("ACTIVE",options) = 0 then
               options = options "ACTIVE"
            end

        /* -------------------------------- *
         * Set Defaults                     *
         * -------------------------------- */
         parse value "" with null active stepname debug input
         call msg "off"

        /* ------------------- *
         * Process any options *
         * ------------------- */
         if length(options) > 0 then do
            if wordpos("ACTIVE",options) > 0 then active = 1
            if wordpos("DEBUG",options)  > 0 then debug  = 1
            if wordpos("INPUT",options)  > 0 then input  = 1
            end

        /* ---------------------------------------------------------- *
         * First find all jobs that match the provided jobname. Build *
         * a list of jobid's.                                         *
         * ---------------------------------------------------------- */
         out.1 = "PRE" jobname
         out.2 = "OWNER"
         if active = 1 then
            out.3 = "DA"
         else
            out.3 = "ST"
         out.0 = 3
         if active <> 1 then do
            out.4 = "sort st-date a"
            out.0 = 4
            end
         "Alloc f(isfin) new spa(1,1) tr" ,
               "recfm(f b) lrecl(80) blksize(3200) reuse"
         "Execio * diskw isfin (Finis stem out."
         if debug <> null then do
            say " >>> Job selection processing"
            do ix = 1 to out.0
               say " >>> " out.ix
               end
               say " "
            end
         call do_sdsf
         call get_jobids

        /* ------------------------------ *
         * Test for any jobs that matched *
         * ------------------------------ */
         if length(jobs) = 0 then do
            say "No matching jobs for" jobname
            say "Exiting...."
            exit 8
            end

        /* --------------------------------------- *
         * Now for each job get the dd and extract *
         * --------------------------------------- */
         out.1 = "PRE" jobname
         out.2 = "OWNER"
         if active = 1 then
            out.3 = "DA"
         else
            out.3 = "ST"
         out.4 = "PT FILE" outdd
         out.5 = "SORT OFF"
         out.6 = "Set Display On"
         oc = 6
         if input = 1 then do
            oc = oc + 1
            out.oc = "Input On"
            end

         do j = 1 to words(jobs)
            say "Processing Jobs for" jobname
            jid = word(jobs,j)
            say "                   " jid
            oc = oc + 1
            out.oc = "SELECT" jobname jid
            oc = oc + 1
            out.oc = "FIND" jobname
            if (ddname = "*") then do  /* StateAuto Modification */
                oc = oc + 1            /* StateAuto Modification */
                out.oc = "++X"         /* StateAuto Modification */
                end                    /* StateAuto Modification */
            else do                    /* StateAuto Modification */
            oc = oc + 1
            out.oc = "++?"
            do ddw = 1 to words(ddname)
               if pos(".",word(ddname,ddw)) > 0 then do
                  parse value word(ddname,ddw) with stepname"."sddname
                  oc = oc + 1
                  out.oc = "FILTER STEPNAME" stepname
                  if pos(".",sddname) = 0 then procstep = null
                     else parse value sddname with procstep"."sddname
                  if procstep <> null then do
                     oc = oc + 1
                     out.oc = "FILTER PROCSTEP" procstep
                     end
                  oc = oc + 1
                  out.oc = "TOP"
                  oc = oc + 1
                  out.oc = "FIND" sddname
                  end
               else do
                    oc = oc + 1
                    out.oc = "FIND" word(ddname,ddw)
                    end
               oc = oc + 1
               out.oc = "++X"
               if stepname <> null then do
                  oc = oc + 1
                  out.oc  = "FILTER OFF"
                  stepname = null
                  end
               end
            oc = oc + 1
            if active = 1 then
               out.oc = "DA"
            else
               out.oc = "ST"
            end
         end
         oc = oc + 1
         out.oc = "PT CLOSE"
         "Alloc f(isfin) new spa(1,1) tr" ,
               "recfm(f b) lrecl(80) blksize(3200) reuse"
         "Execio * diskw isfin (Finis stem out."
         if debug <> null then do
            do ix = 1 to oc
               say " >>> " out.ix
               end
               say " "
            end
         call do_sdsf
         exit

        /* ---------------------- *
         * Get job id information *
         * ---------------------- */
         Get_JobIDs:
         hit = 0
         jobs = null
         do i = 1 to sdsf.0
            if left(sdsf.i,1) = "1" then hit = 0
            sdsf.i = translate(sdsf.i," ",x2c("06"))
            if active = null then
               if pos("SDSF STATUS DISPLAY",sdsf.i) > 0 then
                  hit = 1
            if active = 1 then
               if pos("SDSF DA",sdsf.i) > 0 then
                  hit = 1
            if hit = 0 then iterate
            if pos(" NP",sdsf.i) > 0 then do
               hit = 2
               jobpos = pos("JOBNAME",sdsf.i)
               idpos  = pos("JOBID",translate(sdsf.i))
               iterate
               end
            if hit = 1 then iterate
            if substr(sdsf.i,jobpos,1) = " " then iterate
            sdsfjob = strip(substr(sdsf.i,jobpos,8))
            if sdsfjob = jobname then do
               seljobid = strip(substr(sdsf.i,idpos,8))
               if pos(seljobid,jobs) = 0 then
               if jobnum = null then
                  jobs = strip(seljobid jobs)
               else if jobnum = seljobid
                       then jobs = jobnum
               end
            end
         return

        /* ------------------------------ *
         * Call SDSF and Read the Results *
         * ------------------------------ */
         Do_SDSF:
         "Alloc f(isfout) new spa(15,15) tr reuse"
         Address Linkmvs "sdsf"
         x_rc = rc
         "Execio * diskr isfout (finis stem sdsf."
         "Free f(isfin isfout) delete"
         if x_rc > 0 then say ">>>>>>>>>> SDSF RC:" x_rc
         if debug <> null then
            do ix = 1 to sdsf.0
               say strip(sdsf.ix,"t")
               end
         return
