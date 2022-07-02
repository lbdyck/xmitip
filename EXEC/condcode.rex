/*====================== REXX Exec ==================================*
 *  Name:       condcode                                             *
 *  Type:       Rexx Exec                                            *
 *                                                                   *
 *  Purpose:    Retrieve Condition Codes for each prior step.        *
 *  Abstract:   Follow MVS control blocks to the STEP CONTROL TABLE, *
 *              then decipher status bytes to display what occurred  *
 *              for each of the prior steps.                         *
 *                                                                   *
 *  Syntax:     %condcode                                            *
 *                                                                   *
 *  Example:    %condcode                                            *
 *                                                                   *
 *  Author:     Kenneth E. Tomiak                                    *
 *  Date:       2003-03-13  2003.072                                 *
 *  E-Mail:     <K.Tomiak@Schunk-Associates.com>                     *
 *  SNAIL-MAIL: Schunk AND AssocIATES, INC.                          *
 *              7 INNES AVENUE                                       *
 *              P.O. BOX 474                                         *
 *              NEW PALTZ, NY 12561-0474                             *
 *              U.S.A.                                               *
 *  PHONE:      (845) 256-1010                                       *
 *  FAX2EMAIL:  (888) 785-7710                                       *
 *  WEB:        HTTP://WWW.Schunk-Associates.COM                     *
 *                                                                   *
 *                                                                   *
 *  Important Guidelines:                                            *
 *  This code was written as an information gathering sub-routine    *
 *  intended to be called and its results used as the invoker saw    *
 *  fit. It was intended to be a report generator. With that thought *
 *  in mind, carefully consider whether your change affects how a    *
 *  parsing program will interpret the output. If a flaw in the      *
 *  original format is found, it will have to be corrected, and then *
 *  any parsing invokers will have to verify they still work. Please *
 *  make note of such activity so that the callers are forewarned.   *
 *  Use the line below to show you made format changes.              *
 *            >>>>> FORMAT CHANGES <<<<<                             *
 *                                                                   *
 *  Disclaimers:                                                     *
 *  I have no special knowledge of the inner workings of the         *
 *  operating system. I attempted to return one value back to        *
 *  indicate the same value you would have received if you used      *
 *  NOTIFY= on the jobcard. I was working on using the highest       *
 *  numeric COND CODE, unless there was a SYSTEM abend, unless       *
 *  there was a USER abend. It then became desirable to show the     *
 *  outcome of all of the steps, just as most IEFACTRT exits show    *
 *  in your JESMSGLG. At that point I included LASTABEND= to show    *
 *  what the jct indicates and HIGHCOND= to show what may be         *
 *  considered the most severe error of the job using the COND CODE, *
 *  SYSTEM, USER sequence described above.                           *
 *                                                                   *
 *  The original code was developed and tested using the DATA AREAS  *
 *  manuals and MACLIB entries from OS/390 2.10 and z/OS 1.2. My     *
 *  testing includes steps that are designed to fail. Not every      *
 *  system abend, user abend, nor return code value; but at least    *
 *  two of each.                                                     *
 *                                                                   *
 *  I support my code using a best-effort philosophy. As long as I   *
 *  have access to an image where I can test, I will maintain it as  *
 *  best as I can. If you find a flaw, please do let me know.        *
 *                                                                   *
 *  The code released by Kenneth E. Tomiak does not alter anything.  *
 *  It follows control blocks that are outside of the IBM defined    *
 *  'Programming Interface'. BUYER BEWARE! Your decision to execute  *
 *  this code means you accept responsibility for the consequences.  *
 *  What could go wrong? If control blocks are changed or used in    *
 *  some way I did not anticipate you may find this loops wildly;    *
 *  tries to access storage it should not; or other yet to be        *
 *  conceived problems. BUYER BEWARE! Always test this in a sandbox  *
 *  MVS image if you have concerns.                                  *
 *                                                                   *
 *  In no event will the author be liable to the user of this code   *
 *  for any damages. Including, but not limited to, any lost         *
 *  profits, lost savings or other incidental, consequential or      *
 *  special damages arising out of the operation of or inability to  *
 *  operate this code, even if the user has been advised of the      *
 *  possibility of such damages.                                     *
 *                                                                   *
 *  With that stated, enjoy all this has to offer.                   *
 *                                                                   *
 *===================================================================*
 *                                                                   *
 * History of changes (top entry is the most recent change)          *
 *                                                                   *
 * 2004-04-22 Lionel B. Dyck <lionel.b.dyck@kp.org>                  *
 *            Correction for high condition code testing/report      *
 *                                                                   *
 * 2003-06-20 Kenneth E. Tomiak <K.Tomiak@Schunk-Associates.com>     *
 *            >>>>> FORMAT CHANGES <<<<<                             *
 *            lengthened static 0's on Harry's "U" abend corrections *
 *            and converted not equal compares to ><.                *
 *            Coded "S" indent in a different manner. Removed logic  *
 *            inclusion of sctxabcc = '00' until I see it ever       *
 *            occurs when sctabcnd = '04'. I did find assembler      *
 *            invoked abends were not being handled properly so I    *
 *            had to do some logic changes, too.                     *
 *                                                                   *
 * 2003-04-19 Harry van Burik <h.vanburik@pinkroccade.com>           *
 *            >>>>> FORMAT CHANGES <<<<<                             *
 *            Several minor corrections to formatting                *
 *            Indent step level "S" abend.                           *
 *            Increase length of User abend to four digits.          *
 *            Added a check of sctxabcc=00 under sctabcnd=04.        *
 *                                                                   *
 * 2003-03-26 Kenneth E. Tomiak <K.Tomiak@Schunk-Associates.com>     *
 *            >>>>> FORMAT CHANGES <<<<<                             *
 *            Fixed compare of high_cond when using sctsexec and     *
 *            removed "R" if no abend occurred.                      *
 *                                                                   *
 * 2003-03-24 Lionel B. Dyck <lionel.b.dyck@kp.org>                  *
 *            >>>>> FORMAT CHANGES <<<<<                             *
 *            Split the JOB= line into two lines.                    *
 *            Set last_abend and high_cond to 0.                     *
 *                                                                   *
 * 2003-03-18 Kenneth E. Tomiak <K.Tomiak@Schunk-Associates.com>     *
 *            >>>>> FORMAT CHANGES <<<<<                             *
 *            Format Jctacode, show lastabend and highest condcode,  *
 *            include SSIB jobid, and completed changes to swareq.   *
 *                                                                   *
 * 2003-03-17 Kenneth E. Tomiak <K.Tomiak@Schunk-Associates.com>     *
 *            Correct sctsexec from 9,1 to 8,2,                      *
 *            replaced Foreground check with first step check.       *
 *                                                                   *
 * 2003-03-17 Lionel B. Dyck <lionel.b.dyck@kp.org>                  *
 *            Add test for Foreground environment.                   *
 *                                                                   *
 * 2003-03-16 Lionel B. Dyck <lionel.b.dyck@kp.org>                  *
 *            >>>>> FORMAT CHANGES <<<<<                             *
 *            Nop other message for sctabcnd if not 04.              *
 *                                                                   *
 * 2003-03-14 Lionel B. Dyck <lionel.b.dyck@kp.org>                  *
 *            >>>>> FORMAT CHANGES <<<<<                             *
 *            Minor cleanup (comments and spacing),                  *
 *            Changed wording of the generated messages,             *
 *            Changed for 4 bytes for Jctacode.                      *
 *                                                                   *
 * 2003-03-14 Kenneth E. Tomiak <K.Tomiak@Schunk-Associates.com>     *
 *            Added check for steps bypassed due to a RESTART= and   *
 *            spruced up the comments, far more than any code I      *
 *            usually write. Hopefully this will make it easy to     *
 *            understand and maintain.                               *
 *                                                                   *
 * 2003-03-13 Kenneth E. Tomiak <K.Tomiak@Schunk-Associates.com>     *
 *            Inserted SWAREQ routine from code written by:          *
 *            Gilbert Saint-flour <gsf@pobox.com>                    *
 *                                                                   *
 * 2003-03-13 Kenneth E. Tomiak <K.Tomiak@Schunk-Associates.com>     *
 *            Revamped code received from:                           *
 *            Lionel B. Dyck <Lionel.B.Dyck@KPM.org>                 *
 *            Original code submitted by:                            *
 *            Barry Gilder <gilderb@anz.com>                         *
 *                                                                   *
 *===================================================================*/

Rexx_condcode:

  Parse Upper Arg Other_Junk         /* No parameters are used       */

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* MAIN procedure which invokes sub-functions.                       */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
  Numeric Digits 12
  Call Init_condcode
  Call Main_condcode
  Call Term_condcode
  Exit Final_Rc

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* Initialize variables used by the code.                            */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
Init_condcode:

/*-------------------------------------------------------------------*/
/* Follow the control blocks to the Step Control Table.              */
/*-------------------------------------------------------------------*/
/* Psa                                 Prefix Save Area              */
/* Psa@540                             Pointer of PSATOLD            */
/* Psa@540=>tcb                        Task Control Block            */
/* Psa@540=>tcb+181                    Pointer of TCBJSCBB           */
/* Psa@540=>tcb+181=>jscb              JOBSTEP Control BLock         */
/* Psa@540=>tcb+181=>jscb+261          Pointer to Job Control Table  */
/* Psa@540=>tcb+181=>jscb+261=>jct     Job Control Table             */
/* Psa@540=>tcb+181=>jscb+261=>jct+329 Pointer to Step Control Table */
/* Psa@540=>tcb+181=>jscb+261=>jct+329=>sct       Step Control Table */
/*-------------------------------------------------------------------*/
  Psatold  = Storage(D2x(540),4)
  Tcbjscbb = Storage(D2x(C2d(Psatold)+181),3)
  Jscbjct  = Swareq(Storage(D2x(C2d(Tcbjscbb)+261),3))
  Currsct  = Swareq(Storage(D2x(C2d(Tcbjscbb)+329),3))
  Jscbstep = C2d(Storage(D2x(C2d(tcbjscbb)+228),1)) /* Step number   */
  jscbssib = STORAGE(D2X(C2D(tcbjscbb)+316),4)    /* Pointer to SSIB */
  ssibjbid = STORAGE(D2X(C2D(jscbssib)+12),8)     /* job identifier  */

/*-------------------------------------------------------------------*/
/* Save A Few Fields From The Jct.                                   */
/*-------------------------------------------------------------------*/
  Jctjstat =     Storage(D2x(C2d(Jscbjct)+  5),1)   /* Job Status    */
  Jctjname =     Storage(D2x(C2d(Jscbjct)+  8),8)   /* Job Name      */
  Jctjfail = C2x(Storage(D2x(C2d(Jscbjct)+ 52),1))  /* Job Failure   */
  Jctacode =     Storage(D2x(C2d(Jscbjct)+168),4)   /* Job Abend     */

  Job_Stat = c2x(jctjstat)
  If (Bitand('20'x,jctjstat) = '20'x) Then,
    Do
      Job_Stat = job_stat "Cancelled By Condition Codes"
    End
  If (Bitand('08'x,jctjstat) = '08'x) Then,
    Do
      Job_Stat = job_stat "JCT ABend"
    End
  If (Bitand('04'x,jctjstat) = '04'x) Then,
    Do
      Job_Stat = job_stat "Job Failed"
    End
  If (Bitand('02'x,jctjstat) = '02'x) Then,
    Do
      Job_Stat = job_stat "Catalog Job"
    End

  select
    when (Left(C2x(Jctacode),2) = '40') |,
         (Left(C2x(Jctacode),2) = '80') |,
         (Left(C2x(Jctacode),2) = 'C0') Then,
      Do
        Last_Abend = "U"right("0000"c2d(Right(Jctacode,2)),4)
      End
    when (C2x(jctjstat) >< '00') Then,
      Do
        Last_Abend = "S"substr(C2x(Jctacode),3,3)
      End
    otherwise,
      Do
        Last_Abend = 0
      End
  End

  High_Cond = "R000"

  Final_Rc = 0
  Return

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* The meat and potatoes of the code.                                */

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* Loop through every SCT.                                           */
/*   Determine the status of the step.                               */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
Main_condcode:
/*-------------------------------------------------------------------*/
/* Jct+32=>1st Sct                                                   */
/*-------------------------------------------------------------------*/
  Thissct  = Swareq(Storage(D2x(C2d(Jscbjct)+32),3))

  Do until ((Thissct = '10'x) | (Thissct = Currsct))

                        /* Internal Step Status                      */
    Sctsstat =    C2x(Storage(D2x(C2d(Thissct) +  4),1))

                        /* Step Status Code passed to initiator      */
    Sctsexec =    C2d(Storage(D2x(C2d(Thissct) +  8),2))

                        /* Name of step that called procedure        */
    Sctsclpc =  Strip(Storage(D2x(C2d(Thissct) + 44),8))

                        /* Step name                                 */
    Sctsname =  Strip(Storage(D2x(C2d(Thissct) + 52),8))

                        /* Step SYStem Code                          */
    Sctssysc =    c2x(Storage(D2x(C2d(Thissct) + 62),2))

                        /* Pointer to SCT Extension                  */
    Sctxbttr = Swareq(Storage(D2x(C2d(Thissct) + 68),3))

                        /* Program name                              */
    Sctpgmnm =        Storage(D2x(C2d(Thissct) +108),8)

                        /* 8th slot  (looks like abend code to me)   */
    Sctabcnd =    C2x(Storage(D2x(C2d(Thissct) +160),1))

                        /* Start End status flags                    */
    Sctstend =        Storage(D2x(C2d(Thissct) +172),1)

/*-------------------------------------------------------------------*/
/* Piece together a procstep.stepname combination.                   */
/*-------------------------------------------------------------------*/
    If (Sctsclpc >< " ") Then,
      Do
        Procstep = Left(Sctsclpc"."Sctsname,17)
      End
    Else,
      Do
        Procstep = Left(Sctsname,17)
      End

/*-------------------------------------------------------------------*/
/* Determine final status of step.                                   */
/*-------------------------------------------------------------------*/
    Sctxabcc = Storage(D2x(C2d(Sctxbttr)+112),4)
    select
      when (Jscbstep = 1) then,
        do
          cond_code = "Active"
          Queue left(procstep,30) left(SCTpgmnm,9) Cond_Code
          leave
        end
      when (Sctsstat = '01') Then,
        Do
          Cond_Code = "FLUSH - STEP WAS NOT EXECUTED"
        End
      when (Bitand('10'x,Sctstend) = '10'x) Then,
        Do
          Cond_Code = "FLUSH -",
            "STEP WAS NOT RUN BECAUSE OF CONDITION CODES," ,
            "STEP WAS NOT EXECUTED."
        End
      when (Sctabcnd = '04') Then,
        Do
          Sctxabcc = Storage(D2x(C2d(Sctxbttr)+112),4)
          select
            when (Left(C2x(Sctxabcc),2) = '40') |,
                 (Left(C2x(Sctxabcc),2) = '80') |,
                 (Left(C2x(Sctxabcc),2) = 'C0') Then,
              Do
                Cond_Code = "U"right("0000"c2d(Right(Sctxabcc,3)),4)
                If (Cond_code > High_cond) then,
                  High_Cond = Cond_code
              End
            when (Left(C2x(Sctxabcc),2) = '00') |,
                 (Left(C2x(Sctxabcc),2) = '04') |,
                 (Left(C2x(Sctxabcc),2) = '84') Then,
              Do
                Cond_Code = "S"substr(C2x(Sctxabcc),3,3)
                If (Cond_code > High_cond) then,
                  High_Cond = Cond_code
              End
            otherwise nop
          End
        End
      when (Bitand('C0'x,Sctstend) = 'C0'x) Then,
        Do
          Cond_Code = Right("     "sctsexec,5)
          sctsexec = right(sctsexec+100000,4)
          If ("R"sctsexec > High_cond) then,
            High_Cond = "R"sctsexec
        End
      when (Bitand('40'x,Sctstend) = '40'x) Then,
        Do
          Cond_Code = "BYPASSED DUE TO RESTART - STEP WAS NOT EXECUTED"
        End
      otherwise,
        do
          Cond_Code = "Help me!",
            sctsstat'-'sctsexec'-'sctssysc'-'sctabcnd'-'c2x(sctstend)
        end
    end
/*
    say "sctabcnd="sctabcnd",sctxabcc="c2x(sctxabcc),
      "condcode="cond_code "high="high_cond,
      "abend="last_abend
*/
    if (left(cond_code,1) = "S") then,
      do
        Queue left(procstep,30) left(SCTpgmnm,9) " "||Cond_Code
      end
    else,
      do
        Queue left(procstep,30) left(SCTpgmnm,9) Cond_Code
      end

/*-------------------------------------------------------------------*/
/* sct+20=>nextsct or '00000010'x.                                   */
/*-------------------------------------------------------------------*/
    Thissct = Swareq(Storage(D2x(C2d(Thissct)+20),3))
  End
  Return

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* Post processing cleanup, if necessary. None required this time.   */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
Term_condcode:
  High_Cond = Strip(Strip(High_Cond,"L"," "),"L","R")
  Say "JOB="jctjname"("ssibjbid") JCTACODE="c2x(Jctacode),
    "FAIL="jctjfail "STAT="Job_Stat
  Say left(" ",22) "LASTABEND="Last_Abend,
    "HIGHESTCOND="High_cond
  Say left("Step.ProcStep",30) left("Program",9) " Code"
  Do while Queued() > 0
    parse pull stepline
    say stepline
  end
  Return

/*===================================================================*/
/* Other called routines                                             */
/*===================================================================*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* SWAREQ - AUTHOR   = Gilbert Saint-flour <gsf@pobox.com>           */
/*   Ken says - If argument is below (not sure what that means),     */
/*              add 16. Otherwise, access the QMPL and add QMATs.    */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
Swareq:  Procedure
  If Right(C2x(Arg(1)),1) >< 'F' Then  /* Swa=Below ?                */
    Do
      Result = D2c(C2d(Arg(1))+16)     /* Yes, Return Arg(1)+16      */
      Return Result
    End

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*   Ken says - During testing of condcode I never found the code    */
/*              below to be referenced. It remains here because it   */
/*              may get copied to other programs that need it.       */
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
  Sva = C2d(Arg(1))                            /* Convert to decimal */
  psatold = Storage(021C,4)                      /*     psatold      */
  tcbjscbb = Storage(D2x(C2d(psatold)+181),3)    /*     tcbjscbb     */
  jscbqmpi = Storage(D2x(C2d(tcbjscbb)+244),4)   /*     jscbqmpi     */
  qmadd = Storage(D2x(C2d(jscbqmpi)+24),4)       /*     qmadd        */
  Do While Sva>65536
    qmadd = Storage(D2x(C2d(qmadd)+12),4)     /* Next qmadd=qmadd+12 */
    Sva=sva-65536                              /* 010006F -> 000006F */
  End
  Result = ,                                 /* Add qmadd to Arg(1). */
           d2c(c2d(Storage(d2x(c2d(qmadd)+sva+1),4)) + 16)
  Return Result
