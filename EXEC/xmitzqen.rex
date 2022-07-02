/* REXX                                                             */
/* Encode data to Quoted-Printable                                  */
/* changes by Hartmut Beckmann  / ATOS Origin / Germany             */
/* Written by Oliver Eichhorn   / ATOS Origin / Germany             */
/* Parts of the REXX are from ENBASE64 (File-IO) from James L. Dean */
/* modified from David Alcock                                       */
/*                                                                  */
/* Modification history:                                            */
/*                                                                  */
/*                                                                  */
/* Note: to use this REXX with other codepages                      */
/* just map the stem cp.0 to cp.255 to                              */
/* the values suitable to the ascii representation                  */
/*                                                                  */
/*                                                                  */
/* For mnotics and value assigned see Code Assignment in            */
/* IBM ESA/390 Reference Summary SA22-7209                          */
/*                                                                  */
/* ---------------------------------------------------------------- */
/* other sources (GOOGLE: HTML hex code char)                       */
/*   http://www.ascii.cl/htmlcodes.htm                              */
/* ---------------------------------------------------------------- */
/*                                                                  */
/* usage as a function in REXX                                      */
/*                                                                  */
/*     data = XMITZQEN("<HEADER>header parms</HEADER>"data"") ;     */
/*                                                                  */
/*     supported header parms:  <CP>   codepage      </CP>          */
/*                              <ENC>  _enc_         </ENC>         */
/*                              <TYPE> _type_        </TYPE>        */
/*                              <SPC>  special chars </SPC>         */
/*                              <DD>   ddname        </DD>          */
/*                              <MODE> TESTcu        </MODE>        */
/*                              <TOKEN>token         </TOKEN>       */
/*  DATA:                                                           */
/*    if token is provided it is used ...                           */
/*         ... to read  the unencoded data     with STEMPULL zqeni. */
/*         ... to write the   encoded data     with STEMPUSH zqeno. */
/*    if dd    is provided it is used ...                           */
/*         ... to read  the unencoded data     from the ddname      */
/*         ... to write the   encoded data     to   the ddname      */
/*    if neither token nor dd is provided                           */
/*         data must follow the XML header                          */
/* ---------------------------------------------------------------- */

        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITQENC                                        *
         *                                                            *
         * Function:  Customization definitions for XMITIP            *
         *                                                            *
         * Syntax:    Invoked as a rexx function                      *
         *                                                            *
         * ---------------------------------------------------------- *
         * History:                                                   *
         *                                                            *
         *          2009-11-17 - new parm cpcheck to generate a       *
         *                       message if encoding is not supported *
         *                     - add GLBID like in XMITZEX2           *
         *                     - TEST mode: info if nothing defined   *
         *          2009-06-25 - performance boost ...                *
         *                       support parms TOKEN and DD if used   *
         *                       (main EXEC XMITIP not yet ready)     *
         *          2009-04-30 - add new parm TOKEN                   *
         *          2009-02-10 - check _cp_ and _enc_ for TESTCU      *
         *                       (_cp_ requires _enc_ also)           *
         *          2008-06-24 - add parm <MODE>TEST</MODE> used by   *
         *                       TESTCU to check default settings for *
         *                       codepage and encoding                *
         *          2008-04-03 - add more HTML symbolics              *
         *                       other sources                        *
         *                       (GOOGLE: HTML hex code char)         *
         *                         http://www.ascii.cl/htmlcodes.htm  *
         *          2008-02-18 - new parm <DD>...</DD> for future use *
         *          2008-02-15 - add more HTML symbolics              *
         *          2007-11-12 - add new TYPE parameter to support    *
         *                       different encoding types             *
         *                       TXT (default)  HTML                  *
         *                       add HTML symbolics                   *
         *          2007-09-17 - still under construction             *
         *                       NLS testers are welcome              *
         *          2007-09-05 - revised                              *
         *          2007-05-05 - added function enc to support        *
         *                       different target encoding            *
         *                       ENC values like                      *
         *                                       "ISO-8859-1"         *
         *                                       "ISO-8859-15"        *
         *                                       "WINDOWS-1252"       *
         *                                                            *
         *          2007-05-01 - _initial_ start with codepage 1141   *
         * ---------------------------------------------------------- */

        /* --------------------  rexx procedure  -------------------- *
         * scheme                                                     *
         *                                                            *
         *   init                                                     *
         *   parms check                                              *
         *   set code points                                          *
         *   get / read  data / lines / stemin                        *
         *              loop thru all data lines                      *
         *                convert the chars of the data               *
         *   put / write data / lines / stemout                       *
         *                                                            *
         * ---------------------------------------------------------- */

  rcode = sub_init() ;

  parse arg all_parms
  select;
   when ( abbrev(all_parms,"<HEADER>") = 1 ) ,
    then do ;
              parse var all_parms "<HEADER>"header"</HEADER>"tmp_in
              header = translate(header) ;
              parse var header ,
                         1 . "<CP>"      _cp_      "</CP>"      . ,
                         1 . "<CPCHECK>" _cpcheck_ "</CPCHECK>" . ,
                         1 . "<ENC>"     _enc_     "</ENC>"     . ,
                         1 . "<SPC>"     _spc_     "</SPC>"     . ,
                         1 . "<TYPE>"    _type_    "</TYPE>"    . ,
                         1 . "<DD>"      _dd_      "</DD>"      . ,
                         1 . "<MODE>"    _mode_    "</MODE>"    . ,
                         1 . "<TOKEN>"   _token_   "</TOKEN>"   . ,
                         1 . "<GLBID>"   _glbid_   "</GLBID>"   . ,
                         1 .
              _cp_ = strip(_cp_) ;
         end;
   otherwise do;
              tmp_in = all_parms
         end;
  end;

  _cp_save_ = strip(_cp_)
  _cpcheck_ = strip(_cpcheck_)
  _enc_     = strip(_enc_)
  _spc_     = strip(_spc_)
  _type_    = strip(_type_)
  _dd_      = strip(_dd_)
  _mode_    = strip(_mode_)
  _token_   = strip(_token_)
  _glbid_   = strip(_glbid_)

  select ;
    when ( length(_cp_)   = 0      ) then nop ;
    when ( datatype(_cp_) = "NUM"  ) then _cp_ = _cp_ + 0 ;
    otherwise nop ;
  end ;

  select ;
    when ( left(_cp_,3)   = "GER"  ) then _sub_cp_ = "1141"    ;
    when (      _cp_      = 1141   ) then _sub_cp_ = "1141"    ;
    otherwise do;
                                          _sub_cp_ = ""        ;
                                              _cp_ = ""        ;
              end;
  end;

  if _glbid_ = _null_ ,
  then _glbid_ = left("XMITIP:",9)

  select ;
    when ( _cpcheck_ = _null_ ) then nop
    when ( _cpcheck_ = "YES"  ) then nop
    otherwise nop
  end ;

  select ;
    when ( abbrev(_mode_,"TEST") = 1 ) ,
      then do;
               _return_string_ = sub_test()
               return _return_string_
           end;
    when (      _sub_cp_  =  "1141"  ) then _junk_ = sub_cp1141() ;
    otherwise   _cp_      =  _null_ ;
  end ;

  select ;
    when ( _cp_           = _null_ ) then tmp_out = " " ;
    when ( length(tmp_in) = 0      ) then tmp_out = " " ;
    otherwise do ;
                  tmp_out = sub_encode_loop()
              end;
  end ;

 return tmp_out ;

 /* sub routines ------------------------------------------- */

 sub_test:
          _return_string_ = "0 OK"
          _combine_       = ""_cp_save_""_enc_""
          select;
            when ( _combine_ = _null_ ) ,
              then do;
                      _return_string_ = "2",
                                        "nothing defined:",
                                        "No encoding possible.",
                                        ""
                   end;
            when ( _cp_save_ = _null_ ) ,
              then do;
                      _return_string_ = "8",
                                        "encoding: "_enc_"",
                                        "- codepage: missing"
                   end;
            when ( _enc_     = _null_ ) ,
              then do;
                      _return_string_ = "8",
                                        "codepage: "_cp_save_"",
                                        "- encoding: missing"
                   end;
            when ( _cp_      = _null_ ) ,
              then do;
                      _return_string_ = "4",
                                        "Codepage "_cp_save_"",
                                        "is not supported (yet)."
                   end;
            otherwise do;
                      nop;
              end;
          end;
          return _return_string_

 sub_encode_loop:
_junk_ = trace("N")
   _return_string_ = _null_
   select;
     when ( _token_ /= _null_ ) ,
       then do;
                _token_ = _token_
                _rcode_ = stempull(_token_)
                if _rcode_ = 0 ,
                then nop
                else return 12
            end;
     when ( tmp_in  /= _null_ ) ,
       then do;
                zqeni.0 = 1
                zqeni.1 = tmp_in
            end;
     otherwise  zqeni.0 = 0
   end
   zbeno.0 = zqeni.0 = 0
   do idx = 1 to zqeni.0
       zqeno.idx = sub_encode(zqeni.idx);
   end
   select;
     when ( _token_ /= _null_ ) ,
       then do;
                _token_ = STEMPUSH("zqeno.")
                if length(_token_) = 16 ,
                then _return_string_ = _token_
                else _return_string_ = 8
            end;
     when ( tmp_in  /= _null_ ) ,
       then do;
                _return_string_ = zqeno.1
            end;
     otherwise  _return_string_ = _null_
   end
   return _return_string_

 sub_encode: procedure expose _null_ _enc_ _type_ cp.
   tmp_out = _null_ ;
   parse arg tmp_in ;
   char_in = length(tmp_in)

  /*------------------------------------------------------------- *
   * now we will loop over the tmp_in and transfer the chars      *
   * ------------------------------------------------------------ */
  do pos_in_count = 1 to char_in
     p_char        = substr(tmp_in,pos_in_count,1)
     index_char    = c2d(p_char)
       hex_char    = c2x(p_char)
     select;
       when ( _type_ = "HTML" ) ,
         then do ;
                   /* ---------------------------------------------- *
                    * samples if it is necessary to encode HTML text *
                    * The amp char & should not be translated to     *
                    * words (see below).                             *
                    * ---------------------------------------------- */
                   p_char_word=translate(substr(tmp_in,pos_in_count,8))
                   select ;
                     when ( abbrev(p_char_word,"&AMP;"  ) = 1 ) ,
                        then do ;
                                  _chars_ = cp.index_char
                             end;
                     when ( abbrev(p_char_word,"&NBSP;" ) = 1 ) ,
                        then do ;
                                  _chars_ = p_char
                             end;
                     when ( abbrev(p_char_word,"&AUML;" ) = 1 ) ,
                        then do ;
                                  _chars_ = p_char
                             end;
                     when ( abbrev(p_char_word,"&OUML;" ) = 1 ) ,
                        then do ;
                                  _chars_ = p_char
                             end;
                     when ( abbrev(p_char_word,"&UUML;" ) = 1 ) ,
                        then do ;
                                  _chars_ = p_char
                             end;
                     when ( abbrev(p_char_word,"&SZLIG;") = 1 ) ,
                        then do ;
                                  _chars_ = p_char
                             end;
                     when ( cp.index_char.2 = _null_ ) ,
                        then do ;
                                  _chars_ = p_char  /* unchanged */
                             end;
                     otherwise do ;
                                  _chars_ = cp.index_char.2
                             end;
                   end;
              end;
       otherwise ,
              do ;
                        _chars_ = cp.index_char
              end;
     end;
     tmp_out = tmp_out""_chars_
     pos_out_count = length(tmp_out)
  end /* do pos_in_count */

  return tmp_out

 sub_init:
     parse value "" with _null_    ,
                         _cp_      ,
                         _cpcheck  ,
                         _enc_     ,
                         _spc_     ,
                         _type_    ,
                         _dd_      ,
                         _mode_    ,
                         _token_   ,
                         _glbid_   ,
                         .
     cp.0    = 0
     zqeni.0 = 0
     zqeno.0 = 0

     global_vars = "_null_ _cp_ _cpcheck_   " ,
                   "_enc_ _spc_ _type_ _dd_ " ,
                   "_mode_ _token_ _glbid_  " ,
                   "cp. zqeni. zqeno.       "
   return 0

/*   CP1141 - german  with euro                                     */
 sub_cp1141: procedure expose (global_vars)
drop cp.
do i = 1 to 255 ;
     parse value "" with cp.i cp.i.2
end
cp.0   = ' '                      /* NUL                            */
cp.1   = '=01'                    /* SOH                            */
cp.2   = '=02'                    /* STX                            */
cp.3   = '=03'                    /* ETX                            */
cp.4   = '=DC'                    /* SEL                            */
cp.5   = '=09'                    /* HT                             */
cp.6   = '=C3'                    /* RNL                            */
cp.7   = '=7F'                    /* DEL                            */
cp.8   = '=CA'                    /* GE                             */
cp.9   = '=B2'                    /* SPS                            */
cp.10  = '=D5'                    /* RPT                            */
cp.11  = '=0B'                    /* VT                             */
cp.12  = '=0C'                    /* FF                             */
cp.13  = '=0D'                    /* CR                             */
cp.14  = '=0E'                    /* SO                             */
cp.15  = '=0F'                    /* SI                             */
cp.16  = '=10'                    /* DLE                            */
cp.17  = '=11'                    /* DC1                            */
cp.18  = '=12'                    /* DC2                            */
cp.19  = '=13'                    /* DC3                            */
cp.20  = '=DB'                    /* RES/ENP                        */
cp.21  = '=DA'                    /* NL                             */
cp.22  = '=08'                    /* BS                             */
cp.23  = '=C1'                    /* POC                            */
cp.24  = '=18'                    /* CAN                            */
cp.25  = '=19'                    /* EM                             */
cp.26  = '=C8'                    /* UBS                            */
cp.27  = '=F2'                    /* CU1                            */
cp.28  = '=1C'                    /* IFS                            */
cp.29  = '=1D'                    /* IGS                            */
cp.30  = '=1E'                    /* IRS                            */
cp.31  = '=1F'                    /* ITB/IUS                        */
cp.32  = '=C4'                    /* DS                             */
cp.33  = '=B3'                    /* SOS                            */
cp.34  = '=C0'                    /* FS                             */
cp.35  = '=D9'                    /* WUS                            */
cp.36  = '=BF'                    /* BYP/INP                        */
cp.37  = '=0A'                    /* LF                             */
cp.38  = '=17'                    /* ETB                            */
cp.39  = '=1B'                    /* ESC                            */
cp.40  = '=B4'                    /* SA                             */
cp.41  = '=C2'                    /* SFE                            */
cp.42  = '=C5'                    /* SM/SW                          */
cp.43  = '=B0'                    /* CSP                            */
cp.44  = '=B1'                    /* MFA                            */
cp.45  = '=05'                    /* ENQ                            */
cp.46  = '=06'                    /* ACK                            */
cp.47  = '=07'                    /* BEL                            */
cp.48  = '=CD'                    /* **NONE**                       */
cp.49  = '=BA'                    /* **NONE**                       */
cp.50  = '=16'                    /* SYN                            */
cp.51  = '=BC'                    /* IR                             */
cp.52  = '=BB'                    /* PP                             */
cp.53  = '=C9'                    /* TRN                            */
cp.54  = '=CC'                    /* NBS                            */
cp.55  = '=04'                    /* EOT                            */
cp.56  = '=B9'                    /* SBS                            */
cp.57  = '=CB'                    /* IT                             */
cp.58  = '=CE'                    /* RFF                            */
cp.59  = '=DF'                    /* CU3                            */
cp.60  = '=14'                    /* DC4                            */
cp.61  = '=15'                    /* NAK                            */
cp.62  = '=FE'                    /* **NONE**                       */
cp.63  = '=1A'                    /* SUB                            */
cp.64  = ' '                      /* SP                             */
cp.65  = '=FF';cp.65.2 ="&nbsp;"  /* RSP   required space           */
cp.66  = '=E2';cp.66.2 ="&acirc;";/* A CIRCUMFLEX SMALL             */
cp.67  = '=7B';cp.67.2 ="ä";      /* LEFT BRACE                     */
cp.67  = '=7B';cp.67.2 ="&#123;"; /* LEFT BRACE                     */
cp.68  = '=E0';cp.68.2 ="&agrave;"/* A GRAVE SMALL                  */
cp.69  = '=E1';cp.69.2 ="&aacute;"/* A ACUTE SMALL                  */
cp.70  = '=E3';cp.70.2 ="&atilde;"/* A TILDE SMALL                  */
cp.71  = '=E5';cp.71.2 ="&aring;" /* A OVERCIRCLE SMALL             */
cp.72  = '=E7';cp.72.2 ="&ccedil;"/* C CEDILLA SMALL                */
cp.73  = '=F1';cp.73.2 ="&ntilde;"/* N TILDE SMALL                  */
cp.74  = '=C4';cp.74.2 ="&Auml;"; /* A DIAERESIS CAPITAL            */
cp.75  = '.'                      /* PERIOD                         */
cp.76  = '<'                      /* LESS THAN                      */
cp.77  = '('                      /* LEFT PARENTHESIS               */
cp.78  = '+'                      /* PLUS SIGN                      */
cp.79  = '=21';cp.79.2 ="&#33;";  /* EXCLAMATION POINT              */
cp.80  = '=26';/*cp.80.2 ="&amp;"; char supports HTML    AMPERSAND  */
cp.81  = '=E9';cp.81.2 ="&eacute;"/* E ACUTE SMALL                  */
cp.82  = '=EA';cp.82.2 ="&ecirc;";/* E CIRCUMFLEX SMALL             */
cp.83  = '=EB';cp.83.2 ="&euml;"; /* E DIAERESIS SMALL              */
cp.84  = '=E8';cp.84.2 ="&egrave;"/* E GRAVE SMALL                  */
cp.85  = '=ED';cp.85.2 ="&iacute;"/* I ACUTE SMALL                  */
cp.86  = '=EE';cp.86.2 ="&icirc;";/* I CIRCUMFLEX SMALL             */
cp.87  = '=EF';cp.87.2 ="&iuml;"; /* I DIAERESIS SMALL              */
cp.88  = '=EC';cp.88.2 ="&igrave;"/* I GRAVE SMALL                  */
cp.89  = '=7E';cp.89.2 ="&tilde;" /* TILDE ACCENT                   */
cp.90  = '=DC';cp.90.2 ="&Uuml;"; /* U DIAERESIS CAPITAL            */
cp.91  = '=24'                    /* DOLLAR SIGN                    */
cp.92  = '=2A'                    /* ASTERIX                        */
cp.93  = ')'                      /* RIGHT PARENTHESIS              */
cp.94  = '=3B'                    /* SEMICOLON                      */
cp.95  = '=5E';cp.95.2 ="&circ;"  /* CIRCUMFLEX ACCENT              */
cp.96  = '-'                      /* HYPHEN                         */
cp.97  = '/'                      /* SLASH                          */
cp.98  = '=C2';cp.98.2 ="&Acirc;" /* A CIRCUMFLEX CAPITAL           */
cp.99  = '=5B';cp.99.2 ="&#91;";  /* LEFT BRACKET                   */
cp.100 = '=C0';cp.100.2="&Agrave;"/* A GRAVE CAPITAL                */
cp.101 = '=C1';cp.101.2="&Aacute;"/* A ACUTE CAPITAL                */
cp.102 = '=C3';cp.102.2="&Atilde;"/* A TILDE CAPITAL                */
cp.103 = '=C5';cp.103.2="&Aring;" /* A OVERCIRCLE CAPITAL           */
cp.104 = '=C7';cp.104.2="&Ccedil;"/* C CEDILLA CAPITAL              */
cp.105 = '=D1';cp.105.2="&Ntilde;"/* N TILDE CAPITAL                */
cp.106 = '=F6';cp.106.2="&ouml;"; /* O DIAERESIS SMALL              */
cp.107 = ','                      /* COMMA                          */
cp.108 = '%'                      /* PERCENT                        */
cp.109 = '_'                      /* UNDERLINE                      */
cp.110 = '>'                      /* GREATER THAN                   */
cp.111 = '?'                      /* QUESTION MARK                  */
cp.112 = '=F8';cp.112.2="&oslash;"/* O SLASH SMALL                  */
cp.113 = '=C9';cp.113.2="&Eacute;"/* E ACUTE CAPITAL                */
cp.114 = '=CA';cp.114.2 ="&Ecirc;"/* E CIRCUMFLEX CAPITAL           */
cp.115 = '=CB';cp.115.2="&Euml;"; /* E DIAERESIS CAPITAL            */
cp.116 = '=C8';cp.116.2="&Egrave;"/* E GRAVE CAPITAL                */
cp.117 = '=CD';cp.117.2="&Iacute;"/* I ACUTE CAPITAL                */
cp.118 = '=CE';cp.118.2 ="&Icirc;"/* I CIRCUMFLEX CAPITAL           */
cp.119 = '=CF';cp.119.2="&Iuml;"; /* I DIAERESIS CAPITAL            */
cp.120 = '=CC';cp.120.2="&Igrave;"/* I GRAVE CAPITAL                */
cp.121 = '=60'                    /* GRAVE                          */
cp.122 = ':'                      /* COLON                          */
cp.123 = '#';/*cp.123.2="&#35;";       NUMBER SIGN (HASH)           */
cp.124 = '=A7';cp.124.2="&sect;"  /* SECTION SYMBOL                 */
cp.125 = "'"                      /* SINGLE QUOTE                   */
cp.126 = '=3D';cp.126.2="=3D";    /* EQUAL SIGN                     */
cp.127 = '"'                      /* DOUBLE QUOTE       &quot;      */
cp.128 = '=D8';cp.128.2="&Oslash;"/* O SLASH CAPITAL                */
cp.129 = 'a'                      /*                                */
cp.130 = 'b'                      /*                                */
cp.131 = 'c'                      /*                                */
cp.132 = 'd'                      /*                                */
cp.133 = 'e'                      /*                                */
cp.134 = 'f'                      /*                                */
cp.135 = 'g'                      /*                                */
cp.136 = 'h'                      /*                                */
cp.137 = 'i'                      /*                                */
cp.138 = '=AB';cp.138.2="&laquo;";/* LEFT ANGLE QUOTES              */
cp.139 = '=BB';cp.139.2="&raquo;" /* RIGHT ANGLE QUOTES             */
cp.140 = '=F0';cp.140.2="&eth;"   /* ETH ICELANDIC SMALL            */
cp.141 = '=FD';cp.141.2="&yacute;"/* Y ACUTE SMALL                  */
cp.142 = '=FE';cp.142.2="&thorn;" /* THORN ICELANDIC SMALL          */
cp.143 = '=B1';cp.143.2="&plusmn;"/* PLUS OR MINUS SIGN             */
cp.144 = '=B0';cp.144.2="&deg;";  /* DEGREE                         */
cp.145 = 'j'                      /*                                */
cp.146 = 'k'                      /*                                */
cp.147 = 'l'                      /*                                */
cp.148 = 'm'                      /*                                */
cp.149 = 'n'                      /*                                */
cp.150 = 'o'                      /*                                */
cp.151 = 'p'                      /*                                */
cp.152 = 'q'                      /*                                */
cp.153 = 'r'                      /*                                */
cp.154 = '=AA';cp.154.2="&ordf;"; /* ORDINAL INDICATOR FEMININE     */
cp.155 = '=BA';cp.155.2="&ordm;"; /* ORDINAL INDICATOR MASCULINE    */
cp.156 = '=E6';cp.156.2="&aelig;";/* AE DIPTHONG SMALL              */
cp.157 = '=B8';cp.157.2="&cedil;";/* CEDILLA                        */
cp.158 = '=C6';cp.158.2="&AElig;";/* AE DIPTHONG CAPITAL            */
if _enc_ = "WINDOWS-1252" ,
then do ;
cp.159 = '=80';cp.159.2="&euro;"; /* INTERNATIONAL CURRENCY SYMBOL  */
     end;
else do ;
cp.159 = '=A4';cp.159.2="&euro;"; /* INTERNATIONAL CURRENCY SYMBOL  */
     end;
cp.160 = '=B5';cp.160.2="&micro;";/* MICRO SYMBOL                   */
cp.161 = '=DF';cp.161.2="&szlig;";/* SZ LIGATUR OR SHARP S SMALL    */
cp.162 = 's'                      /*                                */
cp.163 = 't'                      /*                                */
cp.164 = 'u'                      /*                                */
cp.165 = 'v'                      /*                                */
cp.166 = 'w'                      /*                                */
cp.167 = 'x'                      /*                                */
cp.168 = 'y'                      /*                                */
cp.169 = 'z'                      /*                                */
cp.170 = '=A1';cp.170.2="&iexcl;";/* EXCLAMATION POINT INVERTED     */
cp.171 = '=BF';cp.171.2="&iquest;"/* QUESTIOM MARK INVERTED         */
cp.172 = '=D0';cp.172.2="&ETH;"   /* ETH ICELANDIC CAPITAL          */
cp.173 = '=DD';cp.173.2="&Yacute;"/* Y ACUTE CAPITAL                */
cp.174 = '=DE';cp.174.2="&THORN;" /* THORN ICELANDIC CAPITAL        */
cp.175 = '=AE';cp.175.2="&reg;";  /* REGISTERED TRADEMARK SYMBOL (R)*/
cp.176 = '=A2';cp.176.2="&cent;"; /* CENT SIGN                      */
cp.177 = '=A3';cp.177.2="&pound;";/* POUND SIGN                     */
cp.178 = '=A5';cp.178.2="&yen;";  /* YEN SIGN                       */
cp.179 = '=B7';cp.179.2="&middot;"/* MIDDLE DOT ACCENT              */
cp.180 = '=A9';cp.180.2="&copy;"; /* COPYRIGHT SYMBOL               */
cp.181 = '=40';cp.181.2="&#64;"   /* AT SIGN                        */
cp.182 = '=B6';cp.182.2="&para;"; /* PARAGRAPH SYMBOL               */
cp.183 = '=BC';cp.183.2="&frac14;"/* ONE QUARTER SIGN               */
cp.184 = '=BD';cp.184.2="&frac12;"/* ONE HALF SIGN                  */
cp.185 = '=BE';cp.185.2="&frac34;"/* THREE QUARTERS SIGN            */
cp.186 = '=AC';cp.186.2="&not;"   /* LOGICAL NOT SYMBOL             */
cp.187 = '=7C';cp.187.2="&#124;"; /* VERTICAL BAR                   */
cp.188 = '=AF';cp.188.2="&macr;"; /* OVERLINE                       */
cp.189 = '=A8';cp.189.2="&uml;" ; /* DIAERESIS                      */
cp.190 = '=B4';cp.190.2="&acute;" /* ACUTE ACCENT                   */
cp.191 = '=D7';cp.191.2="&times;";/* MULTIPLICATION SIGN            */
cp.192 = '=E4';cp.192.2="&auml;"; /* A DIAERESIS SMALL              */
cp.193 = 'A'                      /*                                */
cp.194 = 'B'                      /*                                */
cp.195 = 'C'                      /*                                */
cp.196 = 'D'                      /*                                */
cp.197 = 'E'                      /*                                */
cp.198 = 'F'                      /*                                */
cp.199 = 'G'                      /*                                */
cp.200 = 'H'                      /*                                */
cp.201 = 'I'                      /*                                */
cp.202 = '=AD';cp.202.2="&shy;"   /* SYLLABLE HYPHEN                */
cp.202 = '=AD';cp.202.2="-"       /* SYLLABLE HYPHEN                */
cp.203 = '=F4';cp.203.2 ="&ocirc;"/* O CIRCUMFLEX SMALL             */
cp.204 = '=A6';cp.204.2="&brvbar;"/* VERTICAL BAR BROKEN            */
cp.205 = '=F2';cp.205.2="&ograve;"/* O GRAVE SMALL                  */
cp.206 = '=F3';cp.206.2="&oacute;"/* O ACUTE SMALL                  */
cp.207 = '=F5';cp.207.2="&otilde;"/* O TILDE SMALL                  */
cp.208 = '=FC';cp.208.2="&uuml;"; /* U DIAERESIS SMALL              */
cp.209 = 'J'                      /*                                */
cp.210 = 'K'                      /*                                */
cp.211 = 'L'                      /*                                */
cp.212 = 'M'                      /*                                */
cp.213 = 'N'                      /*                                */
cp.214 = 'O'                      /*                                */
cp.215 = 'P'                      /*                                */
cp.216 = 'Q'                      /*                                */
cp.217 = 'R'                      /*                                */
cp.218 = '=B9';cp.218.2="&sup1;"; /* ONE SUPERSCRIPT                */
cp.219 = '=FB';cp.219.2="&ucirc;" /* U CIRCUMFLEX SMALL             */
cp.220 = '=7D';cp.220.2="ü";      /* RIGHT BRACE                    */
cp.220 = '=7D';cp.220.2="&#125;"; /* RIGHT BRACE                    */
cp.221 = '=F9';cp.221.2="&ugrave;"/* U GRAVE SMALL                  */
cp.222 = '=FA';cp.222.2="&uacute;"/* U ACUTE SMALL                  */
cp.223 = '=FF';cp.223.2="&yuml;"; /* Y DIAERESIS SMALL              */
cp.224 = '=D6';cp.224.2="&Ouml;"; /* O DIAERESIS CAPITAL            */
cp.225 = '=F7';cp.225.2="&divide;"/* DIVIDE SIGN                    */
cp.226 = 'S'                      /*                                */
cp.227 = 'T'                      /*                                */
cp.228 = 'U'                      /*                                */
cp.229 = 'V'                      /*                                */
cp.230 = 'W'                      /*                                */
cp.231 = 'X'                      /*                                */
cp.232 = 'Y'                      /*                                */
cp.233 = 'Z'                      /*                                */
cp.234 = '=B2';cp.234.2 ="&sup2;";/* TWO SUPERSCRIPT                */
cp.235 = '=D4';cp.235.2 ="&Ocirc;"/* O CIRCUMFLEX CAPITAL           */
cp.236 = '=5C';cp.236.2="&#92;";  /* BACKSLASH                      */
cp.237 = '=D2';cp.237.2="&Ograve;"/* O GRAVE CAPITAL                */
cp.238 = '=D3';cp.238.2="&Oacute;"/* O ACUTE CAPITAL                */
cp.239 = '=D5';cp.239.2="&Otilde;"/* O TILDE CAPITAL                */
cp.240 = '0'                      /*                                */
cp.241 = '1'                      /*                                */
cp.242 = '2'                      /*                                */
cp.243 = '3'                      /*                                */
cp.244 = '4'                      /*                                */
cp.245 = '5'                      /*                                */
cp.246 = '6'                      /*                                */
cp.247 = '7'                      /*                                */
cp.248 = '8'                      /*                                */
cp.249 = '9'                      /*                                */
cp.250 = '=B3';cp.250.2 ="&sup3;";/* THREE SUPERSCRIPT              */
cp.251 = '=DB';cp.251.2 ="&Ucirc;"/* U CIRCUMFLEX CAPITAL           */
cp.252 = '=5D';cp.252.2="&#93;";  /* RIGHT BRACKET                  */
cp.253 = '=D9';cp.253.2="&Ugrave;"/* U GRAVE CAPITAL                */
cp.254 = '=DA';cp.254.2="&Uacute;"/* U ACUTE CAPITAL                */
cp.255 = '=9F';cp.255.2="&nbsp;"  /*                                */
   return 0
