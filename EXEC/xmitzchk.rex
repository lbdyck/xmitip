        /* --------------------  rexx procedure  -------------------- *
         * Name:      zbchecks (published as xmitzchk in XMITIP pack) *
         *                                                            *
         * Function:  sub routine for various checkings ...           *
         *                                                            *
         * Syntax:    _chk_parms="<CHK>DSNTYPE</CHK><DSN>"dsn"</DSN>" *
         *            _result_ = xmitzchk(_chk_parms_)                *
         *            interpret _result_                              *
         *                                                            *
         * Author:    Hartmut Beckmann                                *
         *                                                            *
         * History:                                                   *
         *          2008-09-01 - remove never executed "exit"         *
         *          2008-08-28 - compiled exec - fix calltype problem *
         *                     - uniform msgid                        *
         *          2008-07-11 - bug fix: procedure expose .. jobname *
         *          2008-07-10 - add function to determine security   *
         *                       system (RACF ACF2 TopSecret) and     *
         *                       retrieve infos for                   *
         *                         SECSYSTEM SECUID SECUNAME          *
         *          2008-05-07 - _initial_                            *
         *                       return a string depending on FMT     *
         *                       XML - XML string to be parsed        *
         *                       CMD - REXX statements to interpret   *
         *                                                            *
         *                       DSNTYPE - <DSNTYPE>value</DSNTYPE>...*
         *                                 <DDNAME>value</DDNAME>     *
         *                       DSNTYPE - dsntype = 'value' ; ...    *
         *                                 ddname  = 'value' ;        *
         * ---------------------------------------------------------- */

        _x_ = sub_init() ;
        parse arg _all_parms_
        parse var _all_parms_ 1 _arg_parms_ "###" _run_parms_
        parse var _arg_parms_ 1 . ,
                              1 . "<CHK>" _chktype_ "</CHK>" .  ,
                              1 . "<DSN>" _dsname_  "</DSN>" .  ,
                              1 . "<FMT>" _format_  "</FMT>" .  ,
                              1 .
        _r_string_ = "nop;" ; _r_rcode_ = 1 ;
        select ;
          when ( translate(_chktype_) = "DSNTYPE" ) ,
            then do ;
                      _r_string_ = sub_dsntype(""_dsname_"") ;
                 end;
          when ( translate(_chktype_) = "SECURITY" ) ,
            then do ;
                      _r_string_ = sub_security() ;
                 end;
          otherwise nop;
        end;

        if _format_ = "CMD" ,
        then do ;
                 _r_string_ = sub_xml_2cmd(_r_string_) ;
             end;

        select;
          when ( rexxinv = "COMMAND"    ) then exit   _r_rcode_  ;
          when ( rexxinv = "FUNCTION"   ) then return _r_string_ ;
          when ( rexxinv = "SUBROUTINE" ) then return _r_string_ ;
          otherwise do;
                        say ""msgid"unknown call type: "rexxinv"."
                    end;
        end
        exit

sub_init:
  parse value "" with _null_
  /* to get the correct name for MSGID don't use other cmds before */
  parse source ,
    rexxenv rexxinv rexxname rexxdd rexxdsn . rexxtype addrspc .
  myname = rexxname
  if myname = "?" ,
  then do ;
           myname = sysvar("sysicmd")
           if length(myname) = 0 ,
           then  myname = sysvar("syspcmd")
       end;
  msgid = left(myname": ",10)
  jobname = mvsvar("symdef","jobname")
 return 0


        /* ----------------------------------------------------- *
         * Test for temporary dsname                             *
         *                                                       *
         * sample temp: SYS08127.T065808.RA000.SYSLBD.R0A90256   *
         * sample temp: SYS08128.T074204.RA000.A100740.R0718098  *
         * sample temp: SYS08178.T134501.RA000.V100740T.R0F81129 *
         *                                                       *
         * words = 5                                             *
         *                  length                               *
         * - 1st: SYSnnnnn     8                                 *
         * - 2nd: Tnnnnnn      7                                 *
         * - 3rd: RAnnn        5                                 *
         * - 4th: jobname      n                                 *
         * - 5th: R_alpha_     8                                 *
         *                                                       *
         * ----------------------------------------------------- */
        sub_dsntype: procedure expose _null_ jobname
          _dsntype_ = "PERM" ;
          parse arg _dsname_
          if left(_dsname_,1) = "'" ,
          then do ;
                  _dsname_ = strip(translate(_dsname_,"","'"))
               end;
          _wdsname_ = translate(_dsname_,' ','.')
          _qual1_   = word(_wdsname_,1)
          _qual2_   = word(_wdsname_,2)
          _qual3_   = word(_wdsname_,3)
          _qual4_   = word(_wdsname_,4)
          _qual5_   = word(_wdsname_,5)

          _qual1_   = translate(_qual1_,"++++++++++","0123456789")
          _qual2_   = translate(_qual2_,"++++++++++","0123456789")
          _qual3_   = translate(_qual3_,"++++++++++","0123456789")

          select;
            when ( words(_wdsname_)          /= 5          ) then nop ;
            when ( _qual1_                   /= "SYS+++++" ) then nop ;
            when ( _qual2_                   /= "T++++++"  ) then nop ;
            when ( _qual3_                   /= "RA+++"    ) then nop ;
            when ( _qual4_                   /= jobname    ) then nop ;
            when ( length(_qual5_)           /= 8          ) then nop ;
            when ( left(_qual5_,1)           /= "R"        ) then nop ;
            when ( datatype(_qual5_,"ALPHA") /= 1          ) then nop ;
            otherwise do;
                                         _dsntype_ = "TEMP"
            end;
          end;

        /* ---------------------------- *
         * If Temp then find the DDName *
         * ---------------------------- */
          _ddname_ = _null_
          if _dsntype_ = "TEMP" ,
          then do ;
                  call outtrap 'trap.'
                  Address TSO,
                    'lista status sysnames'
                  call outtrap 'off'
                  do i = 1 to trap.0
                     if strip(trap.i) /= _dsname_ then iterate
                     i = i + 1
                     _ddname_ = word(trap.i,1)
                     leave
                  end
               end;
         _str_ = _null_
         _str_ = _str_""sub_xml_gen("DSNTYPE "_dsntype_"") ;
         _str_ = _str_""sub_xml_gen("DDNAME  "_ddname_ "") ;
         return _str_

 /* ---------------------------------------------------------------- *
  * code adapted from Mark Zelden's great tool IPLINFO               *
  *                                                                  *
  * ---------------------------------------------------------------- *
  * formats:                                                         *
  *  RACF: lu                                                        *
  *        USER=userid NAME=user name OWNER=...  CREATED= ...        *
  *         DEFAULT-GROUP=JUDFLTUX ....                              *
  *         ATTRIBUTES=SPECIAL                                       *
  *         ...                                                      *
  *         --------------------                                     *
  *                                                                  *
  *        listuser _id_ NORACF TSO    only possible with _id_       *
  *    (1) USER=userid                                               *
  *                                                                  *
  *        NO TSO INFORMATION                                        *
  *                                                                  *
  *                                                                  *
  *    (2) USER=userid                                               *
  *                                                                  *
  *        TSO INFORMATION                                           *
  *        ---------------                                           *
  *        ACCTNUM= acct                                             *
  *        DEST= LOCAL                                               *
  *        PROC= TSOSYS                                              *
  *        SIZE= 00262144                                            *
  *        MAXSIZE= 00262144                                         *
  *        UNIT= 3390                                                *
  *        USERDATA= 0000                                            *
  *        COMMAND=                                                  *
  * ---------------------------------------------------------------- */
sub_security: procedure expose _null_
_str_ = _null_
CVT      = C2d(Storage(10,4))                /* point to CVT         */
CVTVERID = Storage(D2x(CVT - 24),16)         /* "user" software vers.*/
CVTRAC   = C2d(Storage(D2x(CVT + 992),4))    /* point to RACF CVT    */
RCVTID   = Storage(D2x(CVTRAC),4)            /* point to RCVTID      */
select ;
 when (RCVTID="RTSS") then _secsys_="TOPSECRET" /* RTSS is TopSecret */
 when (RCVTID="RCVT") then _secsys_="RACF"   /* RCVT is RACF         */
 otherwise                 _secsys_=RCVTID   /* ACF2 SECNAME = RCVTID*/
end;
parse value "" with _secuid_   _secuname_ _secowner_ _seccreated_ ,
                    _secdftgr_ _secattr_  _sectso_
select ;
 when (  _secsys_ = "RACF" ) ,
  then do;
          if _secuid_  = _null_ ,
          then do;
                  call outtrap "s."
                  "listuser"
                  call outtrap "off"
                  do idx = 1 to s.0
                     _s_ = strip(s.idx)
                     select ;
                       when ( abbrev(_s_,copies("-",10)) = 1 ) ,
                         then do ;
                                leave
                              end;
                       when ( abbrev(_s_,"ATTRIBUTES") = 1 ) ,
                         then do ;
                                parse var _s_ ,
                                      1  "ATTRIBUTES="    _secattr_  ,
                                      .
                                _secattr_    = strip(_secattr_)
                              end;
                       when ( abbrev(_s_,"DEFAULT-GROUP") = 1 ) ,
                         then do ;
                                parse var _s_ ,
                                      1  "DEFAULT-GROUP=" _secdftgr_ ,
                                      .
                                _secdftgr_   = strip(_secdftgr_)
                              end;
                       when ( abbrev(_s_,"USER=") = 1 ) ,
                         then do ;
                                parse var _s_ ,
                                      1  "USER="    _secuid_      ,
                                         "NAME="    _secuname_    ,
                                         "OWNER="   _secowner_    ,
                                         "CREATED=" _seccreated_  ,
                                      .
                                _secuid_     = strip(_secuid_)
                                _secuname_   = strip(_secuname_)
                                _secowner_   = strip(_secowner_)
                                _seccreated_ = strip(_seccreated_)
                              end;
                       otherwise nop;
                     end;
                  end;
               end;
          if _secuid_ /= _null_ ,
          then do;
                  call outtrap "s."
                  "listuser "_secuid_" NORACF TSO"
                  call outtrap "off"
                  do idx = 1 to s.0
                     _s_ = strip(s.idx)
                     if pos("TSO INFORMATION",_s_) > 0 ,
                       then do;
                               if left(_s_,2) = "NO" ,
                               then _sectso_ = "NO"
                               else _sectso_ = "YES"
                               leave /* wish no more infos */
                            end;
                  end;
               end;
       end;
 when (  _secsys_ = "TOPSECRET" ) ,
  then do;
                   cvt   = storage(10,4)
                   ascb  = storage(d2x(c2d(cvt)+568),4)
                   ascbx = storage(d2x(c2d(ascb)+108),4)
                   acee  = storage(d2x(c2d(ascbx)+200),4)
                   acex  = storage(d2x(c2d(acee)+152),4)
                   _name_= storage(d2x(c2d(acex)+261),32)
                   _secuname_   = space(strip(_name_),1)
                   _secuname_   =       strip(_name_)
       end;
  otherwise nop;
end;
         _str_ = _str_""sub_xml_gen("SECSYSTEM "_secsys_"") ;
         _str_ = _str_""sub_xml_gen("SECUID    "_secuid_"") ;
         _str_ = _str_""sub_xml_gen("SECUNAME  "_secuname_"") ;
         _str_ = _str_""sub_xml_gen("SECDFTGR  "_secdftgr_"") ;
         _str_ = _str_""sub_xml_gen("SECATTR   "_secattr_"") ;
         _str_ = _str_""sub_xml_gen("SECTSO    "_sectso_"") ;
 return _str_

 sub_xml_gen:
   parse arg _parms_
   parse var _parms_ 1 _xml_key_ _xml_val_
   _xml_key_ = translate(strip(_xml_key_))
   _xml_val_ = strip(_xml_val_)
   _str_ = "<"_xml_key_">"_xml_val_"</"_xml_key_">"
  return _str_

 sub_xml_2cmd: procedure expose _null_
   parse arg _xml_string_
   _cmd_string_ = _null_
   _xml_string_ = strip(_xml_string_)
   do forever
         if left(_xml_string_,1) /= "<" then leave
         parse var _xml_string_ 1 "<" _xml_key_ ">" .
         _xml_key_ = strip(_xml_key_)
         parse var _xml_string_ 1 . ,
                       1 "<"  (_xml_key_) ">" ,
                               _xml_val_      ,
                         "</" (_xml_key_) ">" ,
                               _xml_rest_     ,
                       1 .
         _xml_val_ = strip(_xml_val_)
         _xml_key_ = sub_lower(_xml_key_) ;
         _str_ = ""_xml_key_"='"_xml_val_"';"
         _cmd_string_ = _cmd_string_""_str_ ;
         _xml_string_ = strip(_xml_rest_)
  end
 return _cmd_string_

sub_lower: procedure expose _null_
  parse arg _str_
  chars_lower = "abcdefghijklmnopqrstuvwxyz" ;
  chars_upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" ;
  _str_ = translate(_str_,chars_lower,chars_upper) ;
  return _str_ ;
