/* Rexx by LZfD Stuttgart                                             */
/*                                                                    */
/* ------------------------------------------------------------------ */
/*  TESTCUHT  - TESTCU help tool                                      */
/*               (c)  Werner Tomek                                    */
/*                    <Host Betriebssysteme>                          */
/*                    <Landeszentrum f}r Datenverarbeitung (LZfD)>    */
/* ------------------------------------------------------------------ */
/*                                                                    */
/*  function:                                                         */
/*                                                                    */
/*  show (in raw format) all parameters set by XMITIPCU               */
/*                                                                    */
/* ------------------------------------------------------------------ */
/*  2009-12-15 01.01 HB - fix cu_add                                  */
/*  2009-12-08 01.00 WT - initial                                     */
/* ------------------------------------------------------------------ */
/*  count parameters:                                                 */
/*        count > 84: xmitip/xmitipcu version > 09.11                 */
/*  future: new parms will be added at the end,                       */
/*          exactly before antispoof                                  */
/* ------------------------------------------------------------------ */
 _junk_ = sub_init();

Ver      = XMITIPCU("VER")
_junk_ = sub_prolog("XMITIPCU-Version =" Ver)
call      BPXWDYN "Info DD(SYSEXEC) INRTDSN(MyDSName.)"
_junk_   = OutTrap("LA.")
"LISTA"  "STATUS"
_junk_   = OutTrap("OFF")
do       I = 2 to LA.0
         if Left(LA.I,10) = " " then iterate
         if Left(LA.I,1) <> " " then,
            Dsn = Strip(SubStr(LA.I,1,44))
         if Left(LA.I,11) <> " SYSEXEC" then iterate
         do until I > LA.0
            if Sysdsn("'"Dsn"(XMITIPCU)'") = "OK" then do
               t = "Member XMITIPCU found in" Dsn
               _junk_ = sub_prolog(t)
               I = LA.0
               leave
            end
            I = I + 1
            if Left(LA.I,10) = " " then iterate
            if Left(LA.I,2) = " " then do
               t = "Member XMITIPCU not found in SYSEXEC concat"
               _junk_ = sub_prolog(t)
               leave
            end
            Dsn = Strip(SubStr(LA.I,1,44))
            if Sysdsn("'"Dsn"(XMITIPCU)'") <> "OK" then iterate
         end
end
CU       = XMITIPCU()
Parse    var CU "SEP=" ParseBy . CU
W        = 0
Parm.    = ""
ParseBy2 = ParseBy""ParseBy
Parse var CU CU (ParseBy2) cu_add
do       until CU = ""
         Parse var CU NextVal (ParseBy) CU
         NextVal = sub_nextval(NextVal)
         W = W + 1
         Parm.W = strip(NextVal)
end
NextVal = sub_nextval(cu_add)
W = W + 1
Parm.W = strip(NextVal)
Parm.0   = W

Name.    = ""
Name.0   = 0
ML       = 0

Call     AddName "_center_"
Call     AddName "zone"
Call     AddName "smtp"
Call     AddName "vio"
Call     AddName "smtp_secure"
Call     AddName "smtp_address"
Call     AddName "smtp_domain"
Call     AddName "text_enter"
Call     AddName "sysout_class"
Call     AddName "from_center"
Call     AddName "writer"
Call     AddName "mtop"
Call     AddName "mbottom"
Call     AddName "mleft"
Call     AddName "mright"
Call     AddName "tcp_hostid"
Call     AddName "tcp_name"
Call     AddName "tcp_domain"
Call     AddName "tcp_stack"
Call     AddName "from_default"
Call     AddName "append_domain"
Call     AddName "zip_type"
Call     AddName "zip_load"
Call     AddName "zip_hlq"
Call     AddName "zip_unit"
Call     AddName "interlink"
Call     AddName "size_limit"
Call     AddName "batch_idval"
Call     AddName "create_dsn_lrecl"
Call     AddName "receipt_type"
Call     AddName "paper_size"
Call     AddName "file_suf"
if parm.0 > 84 then ,
Call     AddName "force_suf"
Call     AddName "mail_relay"
Call     AddName "AtSign"
Call     AddName "ispffrom"
Call     AddName "fromreq"
Call     AddName "char"
Call     AddName "charuse"
Call     AddName "disclaim"
Call     AddName "empty_opt"
Call     AddName "font_size"
Call     AddName "def_orient"
Call     AddName "conf_msg"
Call     AddName "metric"
Call     AddName "descopt"
Call     AddName "smtp_method"
Call     AddName "smtp_loadlib"
Call     AddName "smtp_server"
Call     AddName "deflpi"
Call     AddName "nullsysout"
Call     AddName "default_hlq"
Call     AddName "msg_summary"
Call     AddName "site_disclaim"
Call     AddName "zipcont"
Call     AddName "feedback_addr"
Call     AddName "rfc_maxreclen"
Call     AddName "restrict_domain"
Call     AddName "log"
Call     AddName "faxcheck"
Call     AddName "tpageend"
Call     AddName "tpagelen"
Call     AddName "from2rep"
Call     AddName "dateformat"
Call     AddName "validfrom"
Call     AddName "systcpd"
Call     AddName "restrict_hlq"
Call     AddName "default_lang"
Call     AddName "disable_antispoof"
Call     AddName "cpID spec_chars comment"
Call     AddName "send_from"
Call     AddName "Mime8bit"
Call     AddName "jobid"
Call     AddName "jobidl"
Call     AddName "custsym"
Call     AddName "codepage_default"
Call     AddName "encoding_default"
if parm.0 > 84 then ,
Call     AddName "encoding_check"
Call     AddName "check_send_from"
Call     AddName "check_send_to"
Call     AddName "smtp_array"
Call     AddName "txt2pdf_parms"
Call     AddName "xmitsock_parms"
Call     AddName "xmitipcu_infos"
Call     AddName "antispoof"
Call     AddName "cu_add"


_junk_ = sub_prolog("XMITIPCU sets" W "parameters:")
_junk_ = sub_prolog(" ")

do       W = 1 to Parm.0
         select;
           when ( name.w = "antispoof" ) ,
             then do;
                     _sep_ = x2c("02")
                     _antispoof_ = parm.w
                     _count_ = 0
                     do forever
                        parse var _antispoof_ _part_ (_sep_) _antispoof_
                        _count_ = _count_ + 1
                        t = "Parm" Right(" "W,3) ,
                            Left(Name.W" "_count_,ML),
                            "=" strip(_part_)
                        _junk_ = sub_params(t)
                        if strip(_antispoof_) = "" then leave
                     end
                  end;
             otherwise do;
                     t = "Parm" Right(" "W,3),
                         Left(Name.W,ML),
                         "=" Parm.W
                     _junk_ = sub_params(t)
                  end;
         end;
         if Word(Parm.W,1) <> "xmitlzfd" then iterate
         t = "XMITZEX2 =" XMITZEX2(Parm.W)
         _junk_ = sub_params(t)
end
_junk_ = sub_epilog(" ")

do i = 1 to prolog.0 ;  _junk_ = sub_gol(prolog.i) ; end ;
do i = 1 to params.0 ;  _junk_ = sub_gol(params.i) ; end ;
do i = 1 to epilog.0 ;  _junk_ = sub_gol(epilog.i) ; end ;

if sub_stemview("gol.") = "OK" ,
then nop
else do
         do idx = 1 to gol.0
            say gol.idx
         end
     end

exit

AddName:
  I        = Name.0 + 1
  Name.0   = I
  Name.I   = Arg(1)
  ML       = Max(ML, Length(Name.I))
 return

sub_nextval:
  parse arg _data_
  _data_ = strip(_data_)
  if   _data_ = "" ,
  then _data_ = "(n/a)"
 return _data_

sub_init:
  parse value "" with _null_
  prolog.0 = 0
  epilog.0 = 0
  params.0 = 0
  gol.0    = 0
  global_vars = "_null_ prolog. epilog. params. gol."
 return 0

sub_prolog: procedure expose (global_vars)
  parse arg _data_
  if symbol("prolog.0") = "VAR" ,
  then nop
  else prolog.0 = 0
  prolog.0 = prolog.0 + 1
  idx = prolog.0
  prolog.idx = _data_
 return 0

sub_epilog: procedure expose (global_vars)
  parse arg _data_
  if symbol("epilog.0") = "VAR" ,
  then nop
  else epilog.0 = 0
  epilog.0 = epilog.0 + 1
  idx = epilog.0
  epilog.idx = _data_
 return 0

sub_params: procedure expose (global_vars)
  parse arg _data_
  if symbol("params.0") = "VAR" ,
  then nop
  else params.0 = 0
  params.0 = params.0 + 1
  idx = params.0
  params.idx = _data_
 return 0

sub_gol: procedure expose (global_vars)
  parse arg _data_
  if symbol("gol.0") = "VAR" ,
  then nop
  else gol.0 = 0
  gol.0 = gol.0 + 1
  idx = gol.0
  gol.idx = _data_
 return 0

/* checking must be done in subroutine */
sub_stemview: procedure expose (global_vars)
  select;
    when ( sysvar("sysispf") = "NOT ACTIVE" ) then return "NOK"
    when ( sysvar("sysenv")  = "BACK"       ) then return "NOK"
    otherwise nop
  end
  parse arg stemvar
  signal   on syntax Name sub_stemview_no
  TestVar  = "NO"
  _title_ = "XMITIPCU parm show"
  if zmsg000s""zmsg000l = _null_ ,
  then nop
  else do;
          address ispexec "setmsg msg(ispz000) cond"
       end;
  ispf_service = "browse"
  CALL STEMVIEW ispf_service,stemvar,,,_title_
  rcode = rc
  if rcode < 8 ,
  then TestVar  = "OK"
  else TestVar  = "ERR"
 sub_stemview_no:
  signal   off syntax
  if TestVar = "OK" ,
  then nop
 Return   TestVar

