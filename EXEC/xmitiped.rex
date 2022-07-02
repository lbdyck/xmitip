        /* --------------------  rexx procedure  -------------------- *
         * Name:      xmitiped                                        *
         *                                                            *
         * Function:  e-mail the file/filedd currently being edited   *
         *            by invoking the xmitip ispf dialog passing      *
         *            the dataset name / ddname                       *
         *                                                            *
         * Syntax:    %xmitiped to-address                            *
         *                                                            *
         *            to-address is optional                          *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            05/08/08 - Add option for XML and CMD by Hartmut*
         *            05/07/08 - support temp. datasets by Hartmut    *
         *            08/13/01 - fix to initialize _null_ variable    *
         *            05/17/01 - creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         Address ISREdit

        /* --------------------------------------------------------- *
         * Begin Edit Macro with optional parameter                  *
         * --------------------------------------------------------- */
         "Macro (to)"

        /* --------------------------------------------------------- *
         * Test the status of the data.  We can't e-mail data that   *
         * is in a Changed and Not Saved state.                      *
         * --------------------------------------------------------- */
         "(CHANGED) = DATA_CHANGED"
         If changed = "YES"  THEN do
            zedsmsg = "Data Not Saved."
            zedlmsg = "Your data is not saved. Save it and",
                      "then execute the XMITIPED Edit",
                      "command."
            Address ISPExec "Setmsg Msg(isrz001)"
            exit 8
            End

        /* --------------------------------------------------------- *
         * Initialize Defaults                                       *
         * --------------------------------------------------------- */
         _null_ = ""

        /* --------------------------------------------------------- *
         * Get Dataset Name and Member                               *
         * --------------------------------------------------------- */
         "(DSNAME) = DATASET"

        /* ---------------------------------------------------- *
         * determine dsntype (PERM TEMP)                        *
         * and get ddname for temp. dataset                     *
         * ---------------------------------------------------- */
         dsntype = "PERM" ; ddname = _null_
         _fmt_ = "CMD"
         _fmt_ = "XML"
         _zchk_parm_ = _null_
         _zchk_parm_ = _zchk_parm_"<CHK>DSNTYPE</CHK>"
         _zchk_parm_ = _zchk_parm_"<FMT>"_fmt_"</FMT>"
         _zchk_parm_ = _zchk_parm_"<DSN>"dsname"</DSN>"
         _result_ = xmitzchk(""_zchk_parm_"") ;
         if _fmt_ = "CMD" ,
         then do ;
                  interpret _result_  ; nop ;
              end;
         else do ;
                  parse var _result_ ,
                         1 . ,
                         1 ."<DSNTYPE>" dsntype "</DSNTYPE>" . ,
                         1 ."<DDNAME>"  ddname  "</DDNAME>"  . ,
                         1 .
              end;

        /* --------------------------- *
         * If temp. then use ddname    *
         * else qualify *              *
         * --------------------------- */
         if ddname = _null_ ,
         then do ;
                 "(DSNMEM) = MEMBER"
                 if dsnmem <> _null_ ,
                 then dsname = "'"dsname"("dsnmem")'"
                 else dsname = "'"dsname"'"
                 _parm_ = "file("dsname")"
              end;
         else do ;
                 _parm_ = "filedd("ddname")"
              end;

        /* --------------------------------------------------------- *
         * Build the parms for the XMITIPFE command                  *
         * --------------------------------------------------------- */
         if to <> _null_ then
            _parm_ = "To("to") "_parm_
         else
            _parm_ = ""_parm_
         _parm_ = _parm_" Subject(Edit Dataset)"

         Address ISPExec "Select Cmd(%xmitipfe "_parm_")"

         exit
