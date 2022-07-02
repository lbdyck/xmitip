        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITZEX1 User Exit to rewrite the from address  *
         *                                                            *
         * Function:  XMITIP User Exit                                *
         *                                                            *
         * Syntax:    x = xmitzex1()                                  *
         *                                                            *
         *            parameters may be passed within the parens      *
         *            and must be processed by this code              *
         *                                                            *
         *            The first parm if any should be the msgid       *
         *                                                            *
         *                                                            *
         *      check_send_from                                       *
         *      Use the XMITIPCU variable 'check_send_from' to        *
         *      define the name exit routine you want to use,         *
         *      i. e. XMITZEX1.                                       *
         *                                                            *
         *                                                            *
         *      coding in xmitip to call the routine                  *
         *      interpret "from = "check_send_from"('"checkparm"')"   *
         *      checkparm for this sample:                            *
         *          msgid" FUNCTION=CHECKFROM AtSign="AtSign" " ...   *
         *          "smtp_domain="smtp_domain" from="from" "          *
         *       additional parms can be set in XMITIPCU              *
         *          "<ADDRPRE>value</ADDRPRE>"                        *
         *          "<ADDRSUF>value</ADDRSUF>"  i.e. -noreply         *
         *          "<ADDRREW>value</ADDRREW>"  i.e. NO YES (default) *
         *          "<ADDRDOM>value</ADDRDOM>"  i.e. "IBM.COM XY.COM" *
         *          "<ADDRLAB>value</ADDRLAB>"  i.e. "IBM.COM XY.COM" *
         *                                                            *
         *      This routine was written to bypass a customer spam    *
         *      filter which checks whether the domain of the target  *
         *      environment (spam filter) and the domain of the from  *
         *      address belong to the same environment.               *
         *      sample:                                               *
         *      to:              part1.part2@ibm.com                  *
         *      from:            part1.part2@ibm.com                  *
         *      from rewritten:  part1.part2-noreply@kp.org           *
         *      replyto:         part1.part2@ibm.com                  *
         *                                                            *
         * History:                                                   *
         *          2010-05-10 - support generic addresses for addrbyp*
         *                       (only left part, not domain names)   *
         *                       - generic supported (only 1 '*')     *
         *                         like NN*FAX.domain.com             *
         *          2010-04-29 - add <ADDRBYP>: bypass full named     *
         *                       addresses (e.g. prod@special.com)    *
         *          2009-06-08 - use only the 1st char of AtSign      *
         *          2008-09-01 - remove never executed "exit 8"       *
         *                     - use new var "glbid" (global msgid)   *
         *          2008-08-28 - uniform msgid                        *
         *          2008-02-13 - new parm addrlab to preserve the     *
         *                       original "from address" as a label   *
         *                       N-no  F-full  P-part  T-trans        *
         *                       "old_address"<rewrite_addr@domain.xy>*
         *          2007-12-27 - avoid _prefix_/_suffix_              *
         *                       insertion if it already exists       *
         *                     - from address converted to lowercase  *
         *          2007-11-15 - additional parms set in XMITIPCU     *
         *                       no changes are necessary in this exec*
         *                                                            *
         *          2007-07-04 - Creation (Hartmut)                   *
         *                                                            *
         * ---------------------------------------------------------- */
         _junk_ = sub_init()
         parse arg glbid parms
         glbid = left(glbid,9)
         /* Process the parms here */
         if parms = "" ,
         then do;
                  /* Set the return code */
                  exitrc = 0
                  return exitrc
              end ;
         else return sub_exits(parms) ;

 /* ---------------------------------------------------------- */
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
  msg.0   = 0

 return 0

/* ------------------------------------------------ */
/* Subroutine for other processing                  */
/* ------------------------------------------------ */
 sub_exits:
   /* FUNCTION=CHECKFROM parms */
   parse arg all_parms
   parse var all_parms 1 _todo_ _parms_
   parse var _todo_    1 _todo_type_ "=" _todo_value_
   _junk_ = sub_parm_decode(_parms_) ;
   select ;
     when ( _todo_value_ = "CHECKFROM" ) ,
       then do  ;
                 r_string = sub_check_from() ;
            end ;
       otherwise do  ;
                 end ;
   end ;
   do idx = 1 to msg.0 ;
      say ""msg.idx" "
   end;
   return r_string

/* ------------------------------------------------ */
/* Subroutine for decoding parms                    */
/* ------------------------------------------------ */
 sub_parm_decode:
   parse arg parms_to_decode
   parms.0  = 0
   do forever
       parms_to_decode = strip(parms_to_decode)
       if parms_to_decode = _null_ then leave
       parms.0 = parms.0 + 1
       pidx    = parms.0
       parse var parms_to_decode parm_key "=" parm_more
       parse var parm_more       parm_val parm_key_next"="parm_rest
       if parm_rest = _null_ ,
       then do
               parm_val = strip(parm_val)" "parm_key_next
               parms_to_decode = _null_
            end
       else do
               parms_to_decode = ""strip(parm_key_next)"="parm_rest
            end
       parms.pidx.1 = strip(parm_key)
       parms.pidx.2 = strip(parm_val)
   end
   do i = 1 to parms.0
       if strip(parms.i.1) = "" ,
       then do ;
            end
       else do ;
                intervar = translate(parms.i.1)
                interpret   value(INTERVAR) "= '"parms.i.2"'"
            end
   end
   return 0

/* ------------------------------------------------------ */
/* Subroutine for special processing of from addr.        */
/*   check if the from address is to be rewritten         */
/*   sample    rewrite email_prefix@kp.org  to new        */
/*    value    email_prefix-noreply@local_domain_name     */
/* ------------------------------------------------------ */
sub_check_from:

 if value("addrrew")  = "ADDRREW"
 then addrrew = ""
 if value("addrdom")  = "ADDRDOM"
 then addrdom = ""
 if value("addrpre")  = "ADDRPRE"
 then addrpre = ""
 if value("addrsuf")  = "ADDRSUF"
 then addrsuf = ""
 if value("addrlab")  = "ADDRLAB"
 then addrlab = ""
 if value("addrbyp")  = "ADDRBYP"
 then addrbyp = ""
 parm_from_rewrite  = translate(strip(addrrew))
 parm_from_domains  =           strip(addrdom)
 parm_from_suffix   =           strip(addrsuf)
 parm_from_prefix   =           strip(addrpre)
 parm_from_label    = translate(strip(addrlab))
 parm_from_bypass   = translate(strip(addrbyp))

 dflt_from_rewrite  = "YES"
 dflt_from_domains  = "_ALL_"
 dflt_from_suffix   = "-noreply"
 dflt_from_prefix   = _null_
 dflt_from_label    = "PART"
 dflt_from_bypass   = ""

 select ;
   when ( left(parm_from_rewrite,1) = "Y" ) then _rewrite_ = "Y" ;
   when ( left(parm_from_rewrite,1) = "N" ) then _rewrite_ = "N" ;
   otherwise _rewrite_ = left(dflt_from_rewrite,1) ;
 end;

 if   parm_from_domains  = "" ,
 then from_domains_check = dflt_from_domains
 else from_domains_check = parm_from_domains

 if   parm_from_suffix   = "" ,
 then from_suffix        = dflt_from_suffix
 else from_suffix        = parm_from_suffix

 if   parm_from_prefix   = "" ,
 then from_prefix        = dflt_from_prefix
 else from_prefix        = parm_from_prefix

 if   parm_from_label    = "" ,
 then from_label         = dflt_from_label
 else from_label         = parm_from_label

 if   parm_from_bypass   = "" ,
 then from_bypass        = dflt_from_bypass
 else from_bypass        = parm_from_bypass

 _from_ = from ;
 _from_domain_ = smtp_domain ;
 if _rewrite_ = "N" then ,
           return _from_ ;

 if pos("<",_from_) > 0 ,
 then do ;
         parse value _from_ with ."<" _fromx_ ">" .
         from_format = 1 ;
      end;
 else do
         _fromx_ = _from_
         from_format = 2 ;
      end
 AtSign = left(AtSign,1)
 parse var _fromx_ _from_name_ (AtSign) _from_domain_
 from_prefix        = sub_lc(from_prefix) ;
 from_suffix        = sub_lc(from_suffix) ;
 _from_name_        = sub_lc(_from_name_) ;
 _from_upper_       = translate(_from_) ;
 _from_domain_      = sub_lc(_from_domain_) ;
 from_domains_check = sub_lc(from_domains_check) ;

 bypass_address_rewrite = "NO"

 do idx = 1 to words(from_bypass)
    bypass_address = translate(word(from_bypass,idx))
    parse var bypass_address 1 addrleft (AtSign) addrright
    parse var _from_upper_   1 frupleft (AtSign) frupright
    addrleft  = strip(addrleft)
    addrright = strip(addrright)
    frupleft  = strip(frupleft)
    frupright = strip(frupright)
    select;
      when ( addrright /= frupright ) then iterate
      when ( addrleft   = frupleft  ) ,
        then bypass_address_rewrite = "YES"
      otherwise do;
          check_cc = sub_generic_address(addrleft" "frupleft)
          if check_cc = 0 ,
             then bypass_address_rewrite = "YES"
        end;
    end;

    if bypass_address_rewrite = "YES" ,
    then do;
             leave
         end;
 end

 select ;
    when ( bypass_address_rewrite = "YES" ) ,
       then      _from_change_ = "" ;
    when ( translate(_from_domain_) = translate(smtp_domain) ) ,
       then      _from_change_ = "rewrite preferred" ;
    when ( wordpos(_from_domain_,from_domains_check) > 0 ) ,
       then      _from_change_ = "rewrite matched" ;
    when ( from_domains_check = "_all_"  ) ,
       then      _from_change_ = "rewrite forced"   ;
    otherwise    _from_change_ = "" ;
 end ;
 _r_from_label = ""
 if _from_change_ = "" ,
 then nop ;
 else do ;
        _from_save_ = _from_ ;
        if abbrev(from_prefix,_from_name_) = 1 then ,
        parse var _from_name_ 1 (from_prefix) _from_name_ ,
                              1 .
        parse var _from_name_ 1 _from_name_   (from_suffix) . ,
                              1 .
        _fromx_ = from_prefix""_from_name_""from_suffix""AtSign
        _fromx_ = _fromx_""smtp_domain
        if from_format = 1 ,
        then _from_ = "<"_fromx_">"
        else _from_ =  ""_fromx_""
        txt.1 = left(glbid" "copies("-",80),78)
        txt.2 = glbid""left(" EXIT "myname":",25)"rewrite from address"
        txt.3 = glbid""left("      ---> old address:",25)""_from_save_""
        txt.4 = glbid""left("      ---> new address:",25)""_fromx_""
        txt.5 = glbid""left("      ---> reason: ",25)""_from_change_
        txt.6 = left(glbid" "copies("-",80),78)
        txt.7 = glbid" "
        txt.0 = 7
        do i = 1 to txt.0;
             _junk_ = msg_gen(""txt.i"") ;
        end;
        drop txt.
        select;
          when ( abbrev(from_label,"N") = 1  ) then nop ;
          when ( abbrev(from_label,"F") = 1  ) ,
            then   parse var _from_save_ 1 _r_from_label
          when ( abbrev(from_label,"P") = 1  ) ,
            then   parse var _from_save_ 1 _r_from_label (AtSign) .
          when ( abbrev(from_label,"T") = 1  ) ,
            then do ;
                   parse var _from_save_ 1 _r_from_label (AtSign) .
                   parse var from_label 1 . "T" "(" t_chars ")" .
                   do idx = 1 to length(t_chars)
                      t_char = substr(t_chars,idx,1)
                      _r_from_label = ,
                          strip(translate(_r_from_label," ",t_char))
                   end
                 end;
          otherwise                                 nop ;
        end;
        _r_from_label = "<LABEL>"_r_from_label"</LABEL>"
      end;
 return _from_" "_r_from_label

sub_lc: procedure expose _null_
  parse arg _string_
  chars_lower = "abcdefghijklmnopqrstuvwxyz"
  chars_upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  _string_ = translate(_string_,chars_lower,chars_upper) ;
  return _string_ ;

msg_gen: procedure expose msg.
  parse arg _msg_line_ ;
  msg.0 = msg.0 + 1 ;
  idx   = msg.0
  msg.idx = _msg_line_
 return 0

sub_generic_address: procedure
  rcode = 4
  parse arg _genstack_ _needle_
  if pos("*",_genstack_) + pos("%",_genstack_) = 0 ,
  then return 4
  /* generic sign found */
  select;
    when ( pos("*",_genstack_) * pos("%",_genstack_) > 0 ) ,
      then do;
               /* both wildcards together are not supported */
           end;
    when ( pos("*",_genstack_) > 0 ) ,
      then do;
               parse var _genstack_ gleft_ "*" gright_
               gleft_  = strip(gleft_)
               gright_ = strip(gright_)
               nleft_  = left(_needle_,length(gleft_))
               nright_ = right(_needle_,length(gright_))
               select;
                 when ( gleft_  /= nleft_  ) then nop
                 when ( gright_ /= nright_ ) then nop
                 otherwise do;
                       rcode = 0
                   end;
               end;
           end;
    when ( pos("%",_genstack_) > 0 ) ,
      then do;
           end;
    otherwise nop
  end;
 return rcode
