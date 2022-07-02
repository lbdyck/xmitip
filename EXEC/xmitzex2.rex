        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITZEX2 User Exit to check the address(es),    *
         *            used for: TO CC BCC ERRORSTO REPLYTO            *
         *                                                            *
         * Function:  XMITIP User Exit                                *
         *                                                            *
         * Syntax:    x = xmitzex2()                                  *
         *                                                            *
         *            parameters are to be passed within the parens   *
         *            and must be processed by this code (XML format).*
         *                                                            *
         *      check_send_to                                         *
         *      Use the XMITIPCU variable 'check_send_to'             *
         *      to define the name exit routine you want to use,      *
         *      i. e. check_send_to = "XMITZEX2"                      *
         *         or check_send_to = "XMITZEX2 (additional_parms)"   *
         *                                                            *
         *      coding in xmitip to call the routine                  *
         *      interpret "chk_val = "check_send_to"('"checkparm"')"  *
         *                                                            *
         *      checkparm for this sample:                            *
         *          "<GLBID>"     msgid       "</GLBID>"      fix     *
         *          "<ATSIGN>"    AtSign      "</ATSIGN>"     fix     *
         *          "<PARMS>"additional_parms "</PARMS>"      fix     *
         *          "<ADDRFROM>"  _old_from_  "</ADDRFROM>"   fix     *
         *                                                            *
         *          "<ADDRTO>"    _old_to_    "</ADDRTO>"     var     *
         *          "<ADDRCC>"    _old_cc_    "</ADDRCC>"     var     *
         *          "<ADDRBCC>"   _old_bcc_   "</ADDRBCC>"    var     *
         *          "<ADDRREPLY>" _old_reply_ "</ADDRREPLY>"  var     *
         *          "<ADDRERROR>" _old_error_ "</ADDRERROR>"  var     *
         *                                                            *
         *      This routine checks the used mail address(es) and     *
         *      returns either                                        *
         *        - <TOKEN>.</TOKEN>- preferred technique             *
         *        - null string     - no changes                      *
         *        - number          - rcode                           *
         *        - xml like string - rcode new values (*)            *
         *          (*) text 'NULL' - reset keyword value to NULL     *
         *          supported keywords: TO CC BCC ERRORSTO REPLYTO    *
         *          All other are only passed and are fix.            *
         *                                                            *
         * History:                                                   *
         *          2009-12-08 - add missed comma (continue line)     *
         *                       ..  = STEMPUSH("addrto","addrcc", ,  *
         *          2009-11-26 - new parm variable <CALLEDAS>         *
         *                       (called as is the name of this mod:  *
         *                        LMODs don't know their own name)    *
         *          2009-05-25 - use correct variable names           *
         *                        _old_to_     _new_to_               *
         *                        _old_cc_     _new_cc_               *
         *                        _old_bcc_    _new_bcc_              *
         *                        _old_reply_  _new_reply_            *
         *                        _old_error_  _new_error_            *
         *                     - full support of STEMPULL/STEMPUSH    *
         *                       - all variables which can be         *
         *                         changed are initially set to N/A   *
         *                     - use var prefix _old_* and _new_*     *
         *          2009-01-26 - Compare old and new values and give  *
         *                       back all parms with changed values   *
         *                     - add ADDRREPLY and ADDRERROR          *
         *                                                            *
         *          2008-09-24 - Creation (Werner, Hartmut)           *
         *                                                            *
         * ---------------------------------------------------------- */
 signal on novalue name sub_novalue
  parse arg _all_parms_
  parse var _all_parms_ 1 . ,
                1 . "<CALLEDAS>"  _calledas_  "</CALLEDAS>"  .  ,
                1 .
  _junk_ = sub_init();
  if _modtyp_ = "EXEC" ,
  then interpret " _junk_ = trace('n'); "; /*compiler*/

  rcode = sub_get_parms()
  if rcode = 0 ,
  then do;
          _r_val_ = sub_main() ;
          parse var _r_val_ 1 rcode _r_val_more_
          _r_val_ = strip(_r_val_)
          if _r_val_more_ = "" ,
          then _r_val_info_ = "<EMPTY>"
          else _r_val_info_ = ""_r_val_
       end;
  else do;
          _r_val_info_ = "parm error"
          _r_val_ = rcode
       end;

  if rcode = 0 ,
  then do;
          select;
            when ( _stem_push_pull_available_ = "YES" ) ,
              then do;
                          parm_Token = STEMPUSH("addrto","addrcc",  ,
                             "addrbcc","addrreply","addrerror")
                          _r_val_ = 0" <TOKEN>"parm_Token"</TOKEN>"
                   end;
            otherwise do;
                          _r_val_ = _r_val_
                      end;
          end
       end;

  if _debug_ = "ON" ,
  then do;
          say ""_glbid_" "msgid"(DEBUG) return string/value:"
          say ""_glbid_" "msgid"(DEBUG) rcode="rcode
          say ""_glbid_" "msgid"(DEBUG) values: "_r_val_info_
          say ""_glbid_" "msgid"(DEBUG) exit ends"
       end;

  do i = 1 to msg.0
         say left(" ",10)""msgid""msg.i
  end
  if rexxinv = "COMMAND" ,
  then exit
  else return _r_val_

 /* ---------------------------------------------------------- */
sub_init:
  /* to get the correct name for MSGID don't use other cmds before */
  parse source ,
    rexxenv rexxinv rexxname rexxdd rexxdsn . rexxtype addrspc .
  parse value "" with _null_
  myname = rexxname
  if myname = "?" ,
  then do;
           sysicmd = sysvar("sysicmd")
           syspcmd = sysvar("syspcmd")
           myname  = word(_calledas_" "sysicmd" "syspcmd" XMITZEX2",1)
       end;
  msgid = left(myname": ",10)
  if rexxdd = "?" ,
  then _modtyp_ = "LMOD"
  else _modtyp_ = "EXEC"
  msg.0   = 0
  parse value "" with ,
      _old_to_ _old_cc_ _old_bcc_ _old_reply_ _old_error_ ,
              ""
  _stem_push_pull_available_ = "NO"
  global_vars = ,
     "_null_ msg.",
     "msgid _modtyp_ " ,
     "_old_to_ _old_cc_ _old_bcc_ _old_reply_ _old_error_",
     "_new_to_ _new_cc_ _new_bcc_ _new_reply_ _new_error_",
     "addrfrom _glbid_ _AtSign_ _parms_ _info_ _debug_  ",
     "_stem_push_pull_available_ ",
     ""
 return 0

sub_get_parms:
  rcode = 0
  parse var _all_parms_ 1 . ,
                        1 . "<TOKEN>"    _token_    "</TOKEN>"    .  ,
                        1 .
 if _token_ = "" ,
 then do;
          parse var _all_parms_ 1 . ,
                    1 . "<ADDRTO>"    _old_to_    "</ADDRTO>"    .  ,
                    1 . "<ADDRCC>"    _old_cc_    "</ADDRCC>"    .  ,
                    1 . "<ADDRBCC>"   _old_bcc_   "</ADDRBCC>"   .  ,
                    1 . "<ADDRREPLY>" _old_reply_ "</ADDRREPLY>" .  ,
                    1 . "<ADDRERROR>" _old_error_ "</ADDRERROR>" .  ,
                    1 . "<ADDRFROM>"  _addrfrom_  "</ADDRFROM>"  .  ,
                    1 . "<GLBID>"     _glbid_     "</GLBID>"     .  ,
                    1 . "<ATSIGN>"    _AtSign_    "</ATSIGN>"    .  ,
                    1 . "<PARMS>"     _parms_     "</PARMS>"     .  ,
                    1 . "<INFO>"      _info_      "</INFO>"      .  ,
                    1 . "<DEBUG>"     _debug_     "</DEBUG>"     .  ,
                    1 .
      end;
 else do;
          _stem_push_pull_available_ = "YES"
          StemRead = StemPull(_token_)
          if StemRead /= 0 ,
          then do;
                  _x_ = sub_msg_gen("ERROR - parms can not be found.")
                  _x_ = sub_msg_gen("        Stempull RC="stemread".")
                  return 8
               end;
          if symbol("glbid") = "VAR" ,
          then _glbid_ = glbid
          else _glbid_ = "n/a"
          do i = 1 to parmfix.0
             _val_ = i"-"parmfix.i.1
             select ;
               when ( translate(parmfix.i.1) = "ADDRFROM" ) ,
                 then _addrfrom_  = parmfix.i.2
               when ( translate(parmfix.i.1) = "GLBID"    ) ,
                 then _glbid_     = parmfix.i.2
               when ( translate(parmfix.i.1) = "ATSIGN"   ) ,
                 then _atsign_    = parmfix.i.2
               when ( translate(parmfix.i.1) = "PARMS"    ) ,
                 then _parms_     = parmfix.i.2
               when ( translate(parmfix.i.1) = "INFO"     ) ,
                 then _info_      = parmfix.i.2
               when ( translate(parmfix.i.1) = "DEBUG"    ) ,
                 then _debug_     = parmfix.i.2
               otherwise nop
             end
          end
          do i = 1 to parmvar.0
             _val_ = i"-"parmvar.i.1
             select ;
               when ( translate(parmvar.i.1) = "ADDRTO"   ) ,
                 then _old_to_    = parmvar.i.2
               when ( translate(parmvar.i.1) = "ADDRCC"   ) ,
                 then _old_cc_    = parmvar.i.2
               when ( translate(parmvar.i.1) = "ADDRBCC"  ) ,
                 then _old_bcc_   = parmvar.i.2
               when ( translate(parmvar.i.1) = "ADDRREPLY") ,
                 then _old_reply_ = parmvar.i.2
               when ( translate(parmvar.i.1) = "ADDRERROR") ,
                 then _old_error_ = parmvar.i.2
               otherwise nop
             end
          end
      end;

   _addrfrom_  = strip(_addrfrom_)
   _glbid_     = strip(_glbid_)
   _AtSign_    = strip(_AtSign_)
   _parms_     = strip(_parms_)
   _info_      = strip(_info_)
   _debug_     = strip(_debug_)

   _old_to_    = strip(_old_to_)
   _old_cc_    = strip(_old_cc_)
   _old_bcc_   = strip(_old_bcc_)
   _old_reply_ = strip(_old_reply_)
   _old_error_ = strip(_old_error_)

   _new_to_    = strip(_old_to_)
   _new_cc_    = strip(_old_cc_)
   _new_bcc_   = strip(_old_bcc_)
   _new_reply_ = strip(_old_reply_)
   _new_error_ = strip(_old_error_)

   addrto      = "N/A"
   addrcc      = "N/A"
   addrbcc     = "N/A"
   addrreply   = "N/A"
   addrerror   = "N/A"

  _debug_ = translate(_debug_)
  if _debug_ = "ON" ,
  then do;
          say ""_glbid_" "msgid"(DEBUG) exit starts"
          say ""_glbid_" "msgid"(DEBUG)"
       end;

  return 0

 sub_msg_gen: procedure expose (global_vars)
   parse arg _msg_line_ ;
   msg.0 = msg.0 + 1 ;
   idx   = msg.0
   msg.idx = _msg_line_
  return 0

 sub_xml_gen:
   parse arg _parms_
   parse var _parms_ 1 _xml_key_ _xml_val_
   _xml_key_ = translate(strip(_xml_key_))
   _xml_val_ = strip(_xml_val_)
   _str_ = "<"_xml_key_">"_xml_val_"</"_xml_key_">"
  return _str_

       /**************************************************************
        * Trap uninitialized variables                               *
        **************************************************************/
        sub_novalue:
        Say " "
        Say ""_glbid_""msgid"ERROR"
        Say "Variable" ,
           condition("Description") "undefined in line" sigl":"
        Say sourceline(sigl)
        if sysvar("SYSENV") <> "FORE" then exit 8
        say "Report the error in this application along with the",
            "syntax used."
        exit 8


 /* -------------------------------------------------------------- */
 /* main routine to check and manipulate              CUSTOMIZE    */
 /*   Return a number (error code) or a XML like string            */
 /* -------------------------------------------------------------- */
 sub_main:

   MaxCC = 0
   _xmlstr_    = _null_

 /* your code starts ... */


 /* your code ends   ... */

 /* --------------------------------------------------------------- */
 /* The following keywords are honoured by XMITIP                   */
 /* ADDRTO  ADDRCC  ADDRBCC  REPLYTO  ERRORSTO                      */
 /* Finally build the xml string: keyword    value                  */
 /* --------------------------------------------------------------- */
  if _new_to_    /= _old_to_    ,
  then do;
         _xmlstr_   = _xmlstr_""sub_xml_gen("ADDRTO   "_new_to_   "") ;
         addrto     = _new_to_
       end;
  if _new_cc_    /= _old_cc_    ,
  then do;
         _xmlstr_   = _xmlstr_""sub_xml_gen("ADDRCC   "_new_cc_   "") ;
         addrcc     = _new_cc_
       end;
  if   _new_bcc_   /= _old_bcc_   ,
  then do;
         _xmlstr_   = _xmlstr_""sub_xml_gen("ADDRBCC  "_new_bcc_  "") ;
         addrbcc    = _new_bcc_
       end;
  if _new_reply_ /= _old_reply_ ,
  then do;
         _xmlstr_   = _xmlstr_""sub_xml_gen("REPLYTO  "_new_reply_"");
         addrreply  = _new_reply_
       end;
  if _new_error_ /= _old_error_   ,
  then do;
         xmlstr_    = _xmlstr_""sub_xml_gen("ERRORSTO "_new_error_"");
         addrerror  = _new_error_
       end;

  select
     when ( MaxCC > 0                ) then sub_main_val = MaxCC
     when ( strip(_xmlstr_) = _null_ ) then sub_main_val = ""
     otherwise                              sub_main_val = 0" "_xmlstr_
  end
  Return sub_main_val

