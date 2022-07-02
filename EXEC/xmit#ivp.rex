/*****************************   REXX   ******************************/
/*                                                                   */
/*  member name:    XMIT#IVP                       (C) Atos Origin   */
/*                                                                   */
/*  member type:                                                     */
/*                                                                   */
/*  Author:         Hartmut  BECKMANN              DATE: 2007-11-18  */
/*                                                                   */
/*  Description:    edit macro to do all changes in Lionel's IVPJOB  */
/*                  use xmitipcu to get dynamically several settings */
/*                  use the dataset name of the actual edited member */
/*                  set some changes fix like email address          */
/*                                                                   */
/*                  find 'STATIC_VALUES' and do your changes         */
/*                                                                   */
/*  History:                                                         */
/*  __date__    who comment                                          */
/*  2007-12-01  HB  add init routine                                 */
/*  2007-11-18  HB  _initial_                                        */
/*********************************************************************/
  _x_ = TRACE("N")
 _junk_ = sub_init();

ADDRESS ISREDIT
"MACRO"
IF RC <> 0 THEN EXIT
"ISREDIT (MEM)     = MEMBER"    /* MEM - NAME of member             */
"ISREDIT (DSN)     = DATASET"   /* DSN - name of dataset            */
mem = mem
dataset = STRIP(TRANSLATE(dsn,"","'"))
dataset = dataset
_tmp_   = translate(dataset," ",".")
_llq_   = word(_tmp_,words(_tmp_))
v1      = "."_llq_
parse var dataset 1 _pre_xmit_ (v1) .
_pre_xmit_   = _pre_xmit_"."
_x_ = sub_call_xmitipcu();
" RESET "
" RESET LABEL"
" CURSOR = 1 1 "
"EXCLUDE ALL 1 3 '//*' "
_x_ = sub_changes_first() ;
do i = 1 to c.0
   "change first nx '"c.i.1"' '"c.i.2"'"
   rcode = RC
end

_str_ = "//EXEC  SET" ;
_len_ = length(_str_)
"find first '"_str_"' 1 "_len_""
if rc <> 0 ,
then do ;
     end;
"(ROW1 COL1)=CURSOR"
"LABEL "row1"=.A 0"

_str_ = "    and using the /"
"find first nx '"_str_"'"
if rc =  0 ,
then do ;
          "(ROW1 COL1)=CURSOR"
          "(dataline) = LINE " row1
          parse var dataline 1 (_str_) _newline_char_ .
     end;
else do ;
          _newline_char_ = ""
     end;
_x_ = sub_changes_dynamic() ;
do i = 1 to c.0
   "change all nx .a .zlast '"c.i.1"' '"c.i.2"'"
   rcode = RC
end
_x_ = sub_changes_static() ;
do i = 1 to c.0
   "change all nx .a .zlast '"c.i.1"' '"c.i.2"'"
   rcode = RC
end
/* "SAVE"  */
" CURSOR = 1 1 "
exit

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
           myname  = word(sysicmd" "syspcmd" XMIT#IVP",1)
       end;
  msgid = left(myname": ",10)
  if rexxdd = "?" ,
  then _modtyp_ = "LMOD"
  else _modtyp_ = "EXEC"
 return 0

sub_call_xmitipcu:
  /* make a temp copy of the actual member XMITIPCU           *
   * to be sure to get the correct version                    */

 address ispexec "control errors return"
 address tso
  _elib_ = "'"_pre_xmit_"EXEC'"
  tmpexec = "$tmpx"right("000"random(3),3)
  xmiexec = "$xmix"right("000"random(3),3)
  "Alloc fi("tmpexec") unit(sysda) spa(5,5) dir(1)",
     "recfm(f b) lrecl(80) blksize(27920)"
  "Alloc fi("xmiexec") dataset("_elib_") shr reuse"
  Address ISPEXEC "LMINIT DATAID(cui) DDNAME("xmiexec")"
  Address ISPEXEC "LMINIT DATAID(cuo) DDNAME("tmpexec")"
  Address ISPEXEC "LMCOPY FROMID("cui") frommem(XMITIPCU)" ,
                       "TODATAID("cuo")   tomem($$$$$$ZZ)"
  Address ISPEXEC "LMFREE DATAID("cui")"
  Address ISPEXEC "LMFREE DATAID("cuo")"
  "altlib   act application(exec) ddname("tmpexec")"
  rcode = rc
  xmitvers = $$$$$$ZZ("VER") ;
  cu  = $$$$$$ZZ() ;
  "altlib deact application(exec) "
  "free fi("tmpexec xmiexec")"

        if datatype(cu) = "NUM" then exit cu

        /* ----------------------------------------------------- *
         * parse the customization defaults to use them here     *
         * ----------------------------------------------------- *
         * parse the string depending on the used separator      *
         * ----------------------------------------------------- */
        cu = strip(cu)
        select ;
          when ( left(cu,4) = "SEP=" ) ,
            then do ;
                    parse var cu "SEP=" _s_ cu
                    _s_val_d_ = c2d(_s_)
                   _s_val_x_ = c2x(_s_)
                 end;
          when ( substr(cu,2,1) = " " ) ,
            then do ;
                    _s_ = left(strip(cu),1)
                 end;
          otherwise do;
                    _s_ = "/"
                    cu  = _s_" "cu
                 end;
        end;

        parse value cu with ,
             (_s_) _center_ (_s_) zone (_s_) smtp ,
             (_s_) vio (_s_) smtp_secure (_s_) smtp_address ,
             (_s_) smtp_domain (_s_) text_enter ,
             (_s_) sysout_class (_s_) from_center (_s_) writer ,
             (_s_) mtop (_s_) mbottom (_s_) mleft (_s_) mright ,
             (_s_) tcp_hostid (_s_) tcp_name (_s_) tcp_domain ,
             (_s_) tcp_stack  ,
             (_s_) from_default ,
             (_s_) append_domain (_s_) zip_type (_s_) zip_load ,
             (_s_) zip_hlq (_s_) zip_unit ,
             (_s_) interlink (_s_) size_limit ,
             (_s_) batch_idval (_s_) create_dsn_lrecl ,
             (_s_) receipt_type (_s_) paper_size ,
             (_s_) file_suf (_s_) force_suf ,
             (_s_) mail_relay (_s_) AtSign ,
             (_s_) ispffrom (_s_) fromreq ,
             (_s_) char (_s_) charuse (_s_) disclaim (_s_) empty_opt ,
             (_s_) font_size (_s_) def_orient ,
             (_s_) conf_msg (_s_) metric ,
             (_s_) descopt (_s_) smtp_method (_s_) smtp_loadlib ,
             (_s_) smtp_server (_s_) deflpi (_s_) nullsysout ,
             (_s_) default_hlq (_s_) msg_summary (_s_) site_disclaim ,
             (_s_) zipcont (_s_) feedback_addr (_s_) rfc_maxreclen ,
             (_s_) restrict_domain (_s_) log ,
             (_s_) faxcheck (_s_) tpageend (_s_) tpagelen,
             (_s_) from2rep (_s_) dateformat (_s_) validfrom ,
             (_s_) systcpd (_s_) restrict_hlq (_s_) default_lang ,
             (_s_) disable_antispoof (_s_) special_chars ,
             (_s_) send_from (_s_) Mime8bit ,
             (_s_) jobid (_s_) jobidl (_s_) custsym ,
             (_s_) codepage_default ,
             (_s_) encoding_default (_s_) encoding_check ,
             (_s_) check_send_from ,
             (_s_) check_send_to ,
             (_s_) smtp_array ,
             (_s_) txt2pdf_parms ,
             (_s_) xmitsock_parms ,
             (_s_) xmitipcu_infos ,
             (_s_) antispoof (_s_)(_s_) cu_add
                   /*   antispoof is always last         */
                   /*   finish CU with double separator  */
                   /*   cu_add for specials ...          */

     _center_      = strip(_center_)
     atsign        = strip(atsign)
     metric        = strip(metric)
     paper_size    = strip(paper_size)
     special_chars = strip(special_chars)
     sp_chars      = left(strip(word(special_chars,2)),10)
     sp_codepage   = word(special_chars,1)
     excl          = substr(sp_chars,1,1)
     basl          = substr(sp_chars,2,1)
     diar          = substr(sp_chars,3,1)
     brsl          = substr(sp_chars,4,1)
     brsr          = substr(sp_chars,5,1)
     brcl          = substr(sp_chars,6,1)
     brcr          = substr(sp_chars,7,1)
     hash          = substr(sp_chars,8,1)
     parse var cu_add 1 . "<CMD>"_cmds_"</CMD>" .
     if _cmds_ /= "" ,
     then do ;
               interpret _cmds_
          end;
 return 0 ;

sub_changes_dynamic:
  c.0   = 0
  idx   = c.0 + 1 ; c.0 = idx
  c.idx.1 = "hlq.XMITIP."
  c.idx.2 = _pre_xmit_

  /* special variable must be set */
  if abbrev(translate(metric),"C") = 1 ,
  then do ;
          idx   = c.0 + 1 ; c.0 = idx
          c.idx.1 = "install.pds(test$csv)"
          c.idx.2 = "install.pds(test$csw)"
       end;

  idx   = c.0 + 1 ; c.0 = idx
  c.idx.1 = "DSN=install.pds"
  c.idx.2 = "DSN="_pre_xmit_"PDS"

  idx   = c.0 + 1 ; c.0 = idx
  c.idx.1 = "'install.pds"
  c.idx.2 = "'"_pre_xmit_"pds"

  if abbrev(translate(paper_size),"LET") = 1 ,
  then nop ;
  else do ;
           idx   = c.0 + 1 ; c.0 = idx
           c.idx.1 = "/let"
           c.idx.2 = "/"paper_size
       end;

  idx   = c.0 + 1 ; c.0 = idx
  c.idx.1 = "(special_chars)"
  if words(special_chars) > 1 ,
  then do ;
           c.idx.2    = "("word(special_chars,1)" - "
           spec_chars = word(special_chars,2)
       end;
  else do ;
           c.idx.2 = "("
           spec_chars = word(special_chars,1)
       end;
  do i = 1 to length(spec_chars)
      c.idx.2 = c.idx.2""substr(spec_chars,i,1)" "
  end
  c.idx.2 = strip(c.idx.2)")"

  if _newline_char_ /= "" ,
  then do ;
          if basl /= "" ,
          then do ;
                   if _newline_char_ = basl ,
                   then nop;
                   else do ;
                            idx = c.0 + 1 ; c.0 = idx
                            c.idx.1 = _newline_char_
                            c.idx.2 = basl
                        end;
               end;
       end;
 return 0

  /* ------------------------------------------------------------ *
   * STATIC_VALUES                                                *
   * ------------------------------------------------------------ */
sub_changes_static:
  c.0   = 0

  idx   = c.0 + 1 ; c.0 = idx
  c.idx.1 = "your.email@address"
  c.idx.2 = "hartmut.beckmann@atosorigin.com"

  idx   = c.0 + 1 ; c.0 = idx
  c.idx.1 = "xmitip lbdyck@gmail.com +"
  c.idx.2 = "xmitip "c.1.2" +"

  idx   = c.0 + 1 ; c.0 = idx
  c.idx.1 = "hlq.TXT2PDF."
  c.idx.2 = "AZBP.TXT2PDF."

  idx   = c.0 + 1 ; c.0 = idx
  c.idx.1 = "(insert your company name)"
  c.idx.2 = "ATOS Origin, Germany"

  idx   = c.0 + 1 ; c.0 = idx
  c.idx.1 = "(insert your name)"
  c.idx.2 = "Hartmut BECKMANN"

  if value("nlschars")  = "NLSCHARS" ,
  then nlschars = "¢\!{¦}~"
  idx   = c.0 + 1 ; c.0 = idx
  c.idx.1 = "(nls_chars)"
  c.idx.2 = "("

  do i = 1 to length(nlschars)
      c.idx.2 = c.idx.2""substr(nlschars,i,1)" "
  end
  c.idx.2 = strip(c.idx.2)")"

  idx   = c.0 + 1 ; c.0 = idx
  c.idx.1 = "'hlq.temp.changes.pdf'"
  c.idx.2 = "temp.changes.pdf"
 return 0

sub_changes_first:

  ADDRESS ISPEXEC "VGET (ZACCTNUM)"
  c.0   = 0
  idx   = c.0 + 1 ; c.0 = idx
  c.idx.1 = "account"
  c.idx.2 = ""zacctnum""
 return 0
 /* -------- end of member ------------------------------- */
