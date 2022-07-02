        /* --------------------  rexx procedure  -------------------- *
         * Name:      setsdsfk                                        *
         *                                                            *
         * Function:  Set PFK for XMITSDSF                            *
         *                                                            *
         * Syntax:    %setsdsfk option                                *
         *            where option is:                                *
         *                  blank for RTF                             *
         *                  C for CSV                                 *
         *                  H for HTML                                *
         *                  P for PDF                                 *
         *                  R for RTF                                 *
         *                  T for Text                                *
         *                  Z for Zip text                            *
         *                  ? for help                                *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *          2007-11-09 - revised                              *
         *          2007-07-04 - use zdel as command delimiter        *
         *          2002-10-14 - add CSV option                       *
         *          2002-04-01 - add ZIP option                       *
         *          2001-12-07 - add HTML option                      *
         *          2007-03-20 - null short message                   *
         *                     - if prefix <> userid set userid.sdsf  *
         *          2001-03-16 - creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         arg opt
         _x_ = sub_init() ;

        /* ---------------------------------------------------------- *
         * Get into Address ISPEXEC, then test for applid.            *
         * if not correct then recurse with desired applid.           *
         * ---------------------------------------------------------- */
         Address ISPExec
         "Vget (zapplid)"
         if zapplid <> _applid_  then do
            "Select CMD(%"sysvar('sysicmd') opt ") Newappl("_applid_")"
            exit 0
            end

        /* --------------------------------------------------- *
         * Test the provided option to set the format type for *
         * %xmitsdsf.                                          *
         * --------------------------------------------------- */
         opt = translate(left(opt,1))
         Select
           When ( opt = "?" ) ,
             then do ;
                     _x_ = sub_help() ;
                     if gol.0 > 0 ,
                     then _x_ = gol_out() ;
                     exit ;
                  end;
           When ( opt = "C" ) then option = "CSV"
           When ( opt = "H" ) then option = "HTML"
           When ( opt = "P" ) then option = "PDF"
           When ( opt = "R" ) then option = "RTF"
           When ( opt = "T" ) then option = "Text"
           When ( opt = "Z" ) then option = "ZIP"
           Otherwise do
                        option = "RTF"
                     end
           End
         opt = left(option,1)

        /* --------------- *
         * set list dsname *
         * --------------- */
         if sysvar('syspref') <> sysvar('sysuid') then
            ldsn = "'"sysvar('sysuid')".sdsf'"
         else ldsn = "sdsf.list"

        /* ------------------------------ *
         * Set the default for the PFK 06 *
         * and set the label for PF6      *
         * ------------------------------ */
         zpf06     = sub_init_cmd() ;
         zpfl06    = "PrtEMail"

        /* ----------------------------------- *
         * Save the Updated PFK in the Profile *
         * ----------------------------------- */

         "Vput (Zpf06 Zpfl06) Profile"

        /* ------------------- *
         * Now inform the User *
         * ------------------- */
         zedsmsg = ""
         zedlmsg = "Program Function Key 06 set for "_applname_,
                   "E-Mail using format option:" option
         "Setmsg msg(isrz001)"
      exit ;

 sub_init:
   parse value "" with null _opt_ _option_ ,
                       _applid_ _applname_ _applcmd_
   parse source _xenv_ _xtype_ _xmyname_ .
   gol.0 = 0
   select ;
     when ( pos("IOF",_xmyname_)  > 0 ) ,
       then do ;
               _applid_   = "IOF"        ;
            end;
     when ( pos("SDSF",_xmyname_) > 0 ) ,
       then do ;
               _applid_   = "ISF"        ;
            end;
     otherwise nop ;
   end;
   select ;
     when ( _applid_ = "IOF" ) ,
       then do ;
               _applname_ = "IOF"        ;
            end;
     when ( _applid_ = "ISF" ) ,
       then do ;
               _applname_ = "SDSF"       ;
            end;
     otherwise nop ;
   end;
 return 0 ;

 sub_init_cmd:
   address ispexec "vget (zdel)"
   _std_cmd_ = "%xmitsdsf"   /* standard XMITIP interface      */
   select ;
     when ( _applid_ = "IOF"  ) ,
       then do ;
               _applcmd_  = "sd da("ldsn")"
               _applcmd_  = _applcmd_""zdel"up max"
               _applcmd_  = _applcmd_""zdel"sn 99999"
               _applcmd_  = _applcmd_""zdel"snapclos"
               _applcmd_  = _applcmd_""zdel"tso "_std_cmd_ ldsn opt""
            end;
     when ( _applid_ = "ISF"  ) ,
       then do ;
               _applcmd_  = "print odsn" ldsn "* new"
               _applcmd_  = _applcmd_""zdel"pt"zdel"pt close"
               _applcmd_  = _applcmd_""zdel"tso "_std_cmd_ ldsn opt""
            end;
     otherwise nop ;
   end;
 return _applcmd_ ;

 gol:     procedure expose null gol.
   /* generate output lines */
   parse arg _data_
   gol.0 = gol.0 + 1
   gidx = gol.0
   gol.gidx = left(_data_,80) ;
   return 0

 gol_out: procedure expose null gol.
    finame = "DD"time("S")
    tmp.0 = gol.0
    ADDRESS TSO
    "alloc fi("finame") recfm(f,b) lrecl(80) ",
           "new delete cylinder",
           "UNIT(VIO) " ,
           "space(1,1) reuse dsorg(PS) "
    "EXECIO * DISKW "finame" (STEM gol. FINIS)"
    _x_ = sub_show("D="finame" F=VIEW ")
    "FREE FI("finame")"
   return 0

 sub_show:
   parse arg 1 . "D=" ddname . ,
             1 . "F=" ddfunc . ,
             1 . "M=" ddmem  . ,
             1 .
          idname = overlay("ID",ddname,1,2)
          if ddfunc = "EDIT" ,
          then nop
          else ddfunc = "VIEW"
          ddfunc = "BROWSE"
        ADDRESS ISPEXEC
        "CONTROL ERRORS RETURN"
          "LMINIT DATAID(idname)   DDNAME("finame") enq(shr"
          select;
            when (left(ddfunc,3) = "BRO" ) ,
              then ispf_service_parms = null
            otherwise ,
                   ispf_service_parms = "PANEL(ISREDDE)"
          end ;
          if ddfunc = "EDIT" ,
          then do
                   "CONTROL ERRORS CANCEL"
               end
          ispf_service = ddfunc
          ""ispf_service " DATAID("idname") " ispf_service_parms
          "LMFREE DATAID("idname")                 "
   return 0

 sub_help:
   "Vget (Zpf06 Zpfl06) Profile"
   "vget (zdel)"
   x=gol("                                                  ");
   x=gol(" Syntax:    %"_xmyname_"  option                  ");
   x=gol("                                                  ");
   x=gol("            where option is:                      ");
   x=gol("                  blank for RTF                   ");
   x=gol("                  C for CSV                       ");
   x=gol("                  H for HTML                      ");
   x=gol("                  P for PDF                       ");
   x=gol("                  R for RTF                       ");
   x=gol("                  T for Text                      ");
   x=gol("                  Z for Zip text                  ");
   x=gol("                  ? for help                      ");
   x=gol("                                                  ");
   x=gol(""copies("-",80)"                                  ");
   x=gol("                                                  ");
   txt = " actual settings for Zpf06 (label and command",
           "- delimiter zdel = "zdel")";
   x=gol(""txt"                                             ");
   x=gol(" "                                               "");
   x=gol(" label: "zpfl06                                  "");
   x=gol("   cmd: "zpf06                                   "");
   x=gol(" "                                               "");
 return 0 ;
