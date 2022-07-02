/* --------------------  rexx procedure  -------------------- */
ver = "3.6"
/* Name:      TXT2HTML                                        *
 *                                                            *
 * Function:  Copy input text dataset to output dataset       *
 *            converting to HTML during the copy              *
 *                                                            *
 *            Can also convert a comma or semicolon separated *
 *            file to a html table.                           *
 *            *** Thanks to Alain Janssens ***                *
 *                                                            *
 * Syntax:    %txt2html IN  input-ds   (or DD:input-ddname)   *
 *                      OUT output-ds  (or DD:output-ddname)  *
 *                      CODEPAGE cp    - see below            *
 *                      COLOR color    - see below            *
 *                      CONFIG config-ds or dd:configdd       *
 *                      FONT  font-size (from 1 to 7)         *
 *                      CC    Yes or No                       *
 *                      NOCONFIRM      (suppress messages)    *
 *                      BROWSE         (will browse report)   *
 *                      BANNER Yes or No                      *
 *                      NOADV                                 *
 *                      TITLE title                           *
 *                      TABLE    (to convert csv to table)    *
 *                      NOHEADER (if no header row desired    *
 *                                in the Table)               *
 *                      WRAP     (columns are wrapped to      *
 *                                length of the largest word) *
 *                      SEMICOLON (use semicolon instead of   *
 *                                 comma)                     *
 *                                                            *
 *             If no parameters and under ISPF then the ISPF  *
 *             dialog will be invoked.                        *
 *                                                            *
 *             Where:                                         *
 *                                                            *
 *             input_ds is a sequential dataset or member of  *
 *                         a partitioned dataset              *
 *                                                            *
 *                       or dd:ddname                         *
 *                                                            *
 *             output_ds is a sequential dataset or member of *
 *                         a partitioned dataset              *
 *                                                            *
 *                       or dd:ddname                         *
 *                                                            *
 *            Color definitions for HTML attachments          *
 *                   If color is just color then it is the    *
 *                   text color with a white background.      *
 *                   If color is color-color then the first   *
 *                   color is the background color and the    *
 *                   second color is the text color           *
 *                                                            *
 *                   Color      Abbrev   Color     Abbrev     *
 *                   Aqua       A        Navy   N          *
 *                   Black      Bla      Olive     O          *
 *                   Blue       Blu      Purple    P          *
 *                   Fuchsia    F        Red       R          *
 *                   Gray       Gra      Silver    S          *
 *                   Green      Gre      Teal      T          *
 *                   Lime       L        White     W          *
 *                   Maroon     M        Yellow    Y          *
 *                                                            *
 *             CONFIG file or DD:ddname                       *
 *                    where file or DD:ddname references      *
 *                    a configuration file which contains     *
 *                    TXT2HTML keywords and values with no    *
 *                    continuation coded (be careful of       *
 *                    sequence numbers).                      *
 *                    An * in column 1 is a comment           *
 *                                                            *
 *                    NOTE: TITLE is NOT ALLOWED in the       *
 *                          Configuration File.               *
 *                                                            *
 *             FONT-Size (default is null for browser)        *
 *                       values from 1 (very small)           *
 *                              to 7 (very large)             *
 *                                                            *
 *             CC indicates if carriage control is            *
 *                included in the input data.                 *
 *                                                            *
 *                Valid options are:                          *
 *                No   no carriage control                    *
 *                Yes  carriage control                       *
 *                                                            *
 *             NOCONFIRM      all messages will be            *
 *                            suppressed                      *
 *                                                            *
 *             BANNER         Display TITLE as a Banner       *
 *                            yes - display title as banner   *
 *                            no  - don't display as banner   *
 *                                                            *
 *             BROWSE         (will browse report)            *
 *                            used under ISPF for use by      *
 *                            the ISPF interface              *
 *                                                            *
 *             NOADV          will not generate blank lines   *
 *                            for double/triple space         *
 *                                                            *
 *             TABLE          convert a csv to a table        *
 *                            ** if specified the defaults    *
 *                            ** are Header and NoWrap        *
 *                                                            *
 *             NOHEADER       do not generate a header row    *
 *                                                            *
 *             WRAP           wrap cell entries               *
 *                                                            *
 *             SEMICOLON      if CSV uses semicolons instead  *
 *                            of commas                       *
 *                                                            *
 *                                                            *
 *             TITLE is anything you want to use as the       *
 *                   title for the html document              *
 *                                                            *
 *             ** Title must be the LAST keyword specified    *
 *                                                            *
 * Author:    Lionel B. Dyck                                  *
 *            Internet: lbdyck@gmail.com                      *
 *                                                            *
 *            Alain Janssens (CSV to HTML code)               *
 *                                                            *
 * History:                                                   *
 *          2008-12-01 - Version 3.6                          *
 *                     - use quotes for x2c strings           *
 *          2008-09-01 - Version 3.5                          *
 *                     - Remove "exit 8" after "return ver"   *
 *                     - insert missing "otherwise"           *
 *                     - compiled exec - fix msgid problem    *
 *                     - uniform msgid                        *
 *          2008-06-27 - Version 3.4 add options support ver  *          /*wls*/
 *          2008-04-03 - Version 3.3                          *
 *                     - Correct output lrecl calculation     *
 *          2007-12-06 - Version 3.2                          *
 *                     - use xmitipcu to set default values:  *
 *                       codepage, special_values, charset    *
 *                     - new options: Encode, JavaScrCheck    *
 *                     - JavaScript code added                *
 *                     - added a BOTTOM button (like TOP)     *
 *                     - added encode routine                 *
 *          2007-11-13 - Version 3.1                          *
 *                     - NLS support                          *
 *          2005-12-27 - Version 3.0                          *
 *                     - Minor update to move comments around *
 *                       the inline panels to before >START   *
 *                       and after the last record.           *
 *          2004-10-08 - Version 2.9                          *
 *                     - Correct no space asa cc processing   *
 *          2004-06-04 - Version 2.8                          *
 *                     - Minor perf improvement for panel load*
 *          2004-06-01 - Version 2.7                          *
 *                     - Improve column detection in tables   *
 *                       *** from Alain Janssens ***          *
 *          2004-05-03 - Version 2.6                          *
 *                     - CSV to HTML support                  *
 *                       *** from Alain Janssens ***          *
 *          2004-01-30 - Version 2.5                          *
 *                     - Correction for text font size        *
 *                     - Correction for NOADV default         *
 *          2003-09-30 - Version 2.4                          *
 *                     - rewrite option parse routine         *
 *                     - Support CONFIG option                *
 *          2003-03-27 - Version 2.3                          *
 *                     - correct font usage with css thanks   *
 *                       to Mike Plowinske                    *
 *          2003-01-22 - Version 2.2                          *
 *                     - add css style and page breaks        *
 *                       thanks to Barry Nichols              *
 *          2002-09-11 - Version 2.1                          *
 *                     - page counter correction              *
 *          2002-08-06 - Version 2.0                          *
 *                     - Move panel inline and use loadispf   *
 *                     - Save panel variables in ispf profile *
 *                       using new t2h variable names.        *
 *                     - No longer able to be Compiled.       *
 *          2002-02-18 - Version 1.9                          *
 *                     - Fix banner code and add comments     *
 *          2002-02-12 - Version 1.8                          *
 *                     - Banner option from Scott Doherty     *
 *                     - fix short lrecl input file           *
 *          2002-02-09 - Version 1.7                          *
 *                     - Clean up html for netscape issue     *
 *                     - New NOADV option                     *
 *                     - Add page count to report             *
 *          2002-01-29 - Version 1.6                          *
 *                     - support browse if noprefix used      *
 *          2002-01-23 - Version 1.5                          *
 *                     - dynamically calculate work space     *
 *          2001-12-17 - Version 1.4                          *
 *                     - added a TOP button per the suggestion*
 *                       of Gunter Fischbach                  *
 *          2001-12-09 - Version 1.3                          *
 *                     - if not under ISPF turn off Browse    *
 *                     - change parse value to parse var      *
 *          2001-12-06 - Version 1.2                          *
 *                     - add noconfirm                        *
 *                     - add browse and ISPF interface        *
 *                     - clean up messages                    *
 *          2001-12-06 - Version 1.1                          *
 *                     - fix cc processing and report it      *
 *          2001-12-06 - Version 1.0                          *
 *                     - fix alloc for existing output pds    *
 *          2001-12-04 - add support for ddname               *
 *                     - add cc support                       *
 *                     - additional valiation                 *
 *                     - convert to keyword driven            *
 *          2001-12-03 - Creation (by copying do_html routine *
 *                       from XMITIP                          *
 * ---------------------------------------------------------- */
 parse arg options

         if abbrev(options,"VER") = 1,
         then do ;
                    /* ----------------------------- *
                     * Get Current Version           *
                     * ----------------------------- */
                     return ver
              end;
 _x_ = sub_init();

/* --------------------------------------------------------- *
 * If no options provided and ISPF is active then call the   *
 * ISPF interface.                                           *
 * --------------------------------------------------------- */
 if length(options) = 0 then do
    if sysvar('sysispf') = "ACTIVE" then do
       ret = 1
       cc = ""
       call load_stuff
       do forever
          cmd = ""
          Address ISPExec
          "CONTROL ERRORS CANCEL"
          "Display Panel(txt2html)"
          if rc > 4 then call exit_here
          "Vput (t2hip t2hop t2htit t2hban t2hfont" ,
                "t2hcolor t2hcc t2hnav" ,
                "t2htbl t2hwrap t2hhdr t2hsemi" ,
                ") Profile"
          Address TSO
          options = cmd
          call do_it
          end
       end
    else do
         say "Error: "myname" requires a minimum of IN and",
             "OUT keywords and values."
         say " "
         say ""myname" Syntax:"
         say " "
         say "%"myname" IN input-ds"
         say "          OUT output-ds"
         say "          CC  Yes/No"
         say "          FONT font-size"
         say "          COLOR color"
         say "          NOCONFIRM"
         say "          BROWSE"
         say "          BANNER Yes/No"
         say "          NOADV"
         /* default is header and nowrap */
         say "          TABLE"
         Say "          WRAP"
         Say "          NOHEADER"
         Say "          SEMICOLON"
         say "          TITLE title"
         say "          NOJAVACHECK"
         say " "
         say "Try again.........."
         exit 8
         end
    end

 Do_It:
/* --------------------------------------------------------- *
 * Setup the default variables                               *
 * --------------------------------------------------------- */
 parse value "" with null indd outdd top color font_size banner ,
                     do_cc title browse config configs ,
                     rpt. ,
                     _opt_enc_ _opt_cp_ _opt_cs_ ,
                     encoding_default codepage_num codepage_chars

 _x_ = sub_codepage_set() ;

 dd    = "HTML"random(999)
 out.0 = 0
 r     = 0
 save_lrecl = 80
 page_count = 0
 confirm    = 1
 noadv      = 0

 table = "NO"
 WRAP = "nowrap"
 NOHEADER = "HEADER"
 NOJAVACHECK = "NOJAVACHECK"
 SEPA = ","    /* depends on regional settings
                  English UK : sepa = ','
                  Belgium - Dutch : sepa = ';'*/
 sepa = sep_default /* depends on XMITIPCU - first approach codepage*/
 if   _opt_cs_  = null ,
 then _charset_ = encoding_default ;
 else _charset_ = _opt_cs_         ;
 _charset_      = strip(_charset_)

/* ----------------------------- *
 * Now process the other options *
 * ----------------------------- */
 do while length(options) > 0
    uopt = translate(options)
    Select
      When word(uopt,1) = "IN" then do
           input   = word(uopt,2)
           options = delword(options,1,2)
           end
      When word(uopt,1) = "OUT" then do
           output  = word(uopt,2)
           options = delword(options,1,2)
           end
      When word(uopt,1) = "CC" then do
           do_cc   = word(uopt,2)
           options = delword(options,1,2)
           end
      When word(uopt,1) = "COLOR" then do
           color   = word(uopt,2)
           options = delword(options,1,2)
           end
      When word(uopt,1) = "FONT" then do
           font_size = word(uopt,2)
           options = delword(options,1,2)
           end
      When word(uopt,1) = "BANNER" then do
           banner  = word(uopt,2)
           options = delword(options,1,2)
           end
      When word(uopt,1) = "BROWSE" then do
           options = delword(options,1,1)
           if sysvar('sysispf') = "ACTIVE"
              then browse = 1
           end
      When word(uopt,1) = "ENCODE" then do
           _opt_enc_  = word(uopt,2)
           options = delword(options,1,2)
           end
      When word(uopt,1) = "CODEPAGE" then do
           _opt_cp_   = word(uopt,2)
           options = delword(options,1,2)
           end
      When word(uopt,1) = "CHARSET" then do
           _opt_cs_  = strip(word(uopt,2))
           options = delword(options,1,2)
           end
      When word(uopt,1) = "TITLE" then do
           title   = subword(options,2)
           options = null
           end
      When word(uopt,1) = "NOADV" then do
           noadv   = 1
           options = delword(options,1,1)
           end
      When word(uopt,1) = "NOCONFIRM" then do
           confirm = null
           options = delword(options,1,1)
           end
      When word(uopt,1) = "CONFIG" then do
           config  = word(uopt,2)
           if wordpos(config,configs) = 0 then
              configs = configs config
           else do
              say msgid "Error: Recursive CONFIG files"
              say msgid "       Config" config "already specified."
              say msgid "Exiting...."
              exit 8
              end
           options = delword(options,1,2)
           drop cfg.
           if left(config,3) = "DD:" then do
              parse value config with "DD:"cdd
              "Execio * diskr" cdd "(finis stem cfg."
              end
           else do
                "Alloc f("dd") shr reuse ds("config")"
                "Execio * diskr" dd "(finis stem cfg."
                "Free  f("dd")"
                end
           do ic = 1 to cfg.0
              if left(cfg.ic,1) = "*" then iterate
              if translate(word(cfg.ic,1)) = "TITLE" then do
                 call domsg "Ignore TITLE from configuration file" ,
                      config
                 end
              else options = strip(cfg.ic)  options
              end
           uopt = translate(options)
           end
      When word(uopt,1) = "TABLE" then do
           options = delword(options,1,1)
           TABLE="YES"
           end
      When word(uopt,1) = "WRAP" then do
           options = delword(options,1,1)
           WRAP="Wrap"
           end
      When word(uopt,1) = "NOHEADER" then do
           options = delword(options,1,1)
           NOHEADER= "NOHEADER"
           end
      When word(uopt,1) = "SEMICOLON" then do
           options = delword(options,1,1)
           SEPA= ";"
           end
      When word(uopt,1) = "NOJAVACHECK" then do
           options = delword(options,1,1)
           NOJAVACHECK = "NOJAVACHECK"
           end
      Otherwise do
                call domsg "Error: Unknown option:" ,
                    word(options,1)
                call domsg "Exiting...."
                if ret = 1 then return
                           else exit 8
                end
    end
 end

 if _x_ /= 0 ,
 then do ;
                call domsg "Exiting...."
                exit 8
      end;

 if confirm = 1 then do
   call domsg "Text to HTML Conversion Utility. Version:" ver
   call domsg " "
   end

/* --------------------------------------------------------- *
 * Test that the input dataset already exists                *
 *      or that the input dd is allocated                    *
 * --------------------------------------------------------- */
 if translate(left(input,3)) = "DD:" then do
    parse value input with "DD:"indd
    x = listdsi(indd "file")
    if x  > 0 then do
             call domsg "Error encountered."
             call domsg "The input ddname" indd,
                       "can not be found."
             signal done
       end
    end
 else  if "OK" <> sysdsn(input) then do
          call domsg "Error encountered."
          call domsg "The input dataset" input
          call domsg sysdsn(input)
          signal done
          end

/* --------------------------------------------------------- *
 * Test for a specified output dataset                       *
 *      or that the output dd is allocated                   *
 * --------------------------------------------------------- */
 if output = null then do
    call domsg "Error encountered."
    call domsg "The output dataset was not specified."
    signal done
    end
 if translate(left(output,3)) = "DD:" then do
    parse value output with "DD:" outdd
    x = listdsi(outdd "file")
    if x > 0 then do
             call domsg "Error encountered."
             call domsg "The output ddname" outdd,
                       "can not be found."
             signal done
       end
    end
 else  if "OK" = sysdsn(output) then do
          call domsg "Error encountered."
          call domsg "The output dataset currently exists."
          call domsg "Please specify a dataset name" ,
                    "to be created."
          signal done
          end

/* --------------------------------------------------------- *
 * validate font size                                        *
 * --------------------------------------------------------- */
 If font_size <> null then do
    if datatype(font_size) <> "NUM" then do
       call domsg "The specified font_size is not a valid",
                 "number. It must be between 1 and 7."
       signal done
       end
    if font_size < 1 then do
       call domsg "The specified font_size is not a valid",
                 "number. It is less than 1 and must be"
       call domsg "a valid number between 1 and 7."
       signal done
       end
    if font_size > 7 then do
       call domsg "The specified font_size is not a valid",
                 "number. It is more than 7 and must be"
       call domsg "a valid number between 1 and 7."
       signal done
       end
    end

/* --------------------------------------------------------- *
 * Validate CC                                               *
 * --------------------------------------------------------- */
 if do_cc <> null then
    if pos(do_cc,"YES NO") = 0 then do
       call domsg "Invalid CC specified. Must be Yes or No."
       signal done
       end
    else if do_cc = "YES" then do_cc = 1

/* --------------------------------------------------------- *
 * Validate BANNER                                           *
 * --------------------------------------------------------- */
 if banner <> null then
    if pos(banner,"YES NO") = 0 then do
   call domsg "Invalid BANNER specified. Must be Yes or No."
       signal done
       end
  else if banner = "YES" then nop
  else if banner = "NO" then banner = ""
  if title = null then banner = null

/* --------------------------------------------------------- *
 * Read the input dataset into in.                           *
 * --------------------------------------------------------- */
 if indd = null then do
    "Alloc f("dd") shr ds("input") reuse"
    "Execio * diskr" dd "(finis stem in."
    "Free  f("dd")"
    call listdsi input
    end
 else "Execio * diskr" indd "(finis stem in."

/* --------------------------------------------------------- *
 * Now call the Do_HTML Conversion Routine                   *
 * --------------------------------------------------------- */
 call do_html

/* --------------------------------------------------------- *
 * Now Report What We Did                                    *
 * --------------------------------------------------------- */
 if confirm = 1 then do
    if font_size = null then font_size = "Default"
    if indd = null then
       call domsg "Input File: " input
       else
       call domsg "Input DD:   " indd
    if outdd = null then
       call domsg "Output File:" output
       else
       call domsg "Output DD:  " outdd
    call domsg "Records:    " in.0
    if title <> null then
       call domsg "Title:      " title
    if banner <> null then
       call domsg "Banner:     " banner
    call domsg "Text:       " fore
    call domsg "Background: " background
    call domsg "Font Size:  " font_size
    call domsg "Encode:     " _opt_enc_
    call domsg "Charset:    " _charset_
    call domsg "Codepage:   " codepage_num
    call domsg "SpecialChars" codepage_chars
    call domsg "JavaScrCheck" NOJAVACHECK
    if do_cc = 1 then
       call domsg "CC:          Yes"
    if page_count > 0 then
       call domsg "Pages:      " page_count
    if configs <> null then
       do i = 1 to words(configs)
          call domsg "Config:     " word(configs,i)
          end
 /* added by isysaja */
    if table = "YES" then
       call domsg "Table:" translate(wrap) noheader "Separator =" sepa
 /* end added by isysaja */
    call domsg " "
    end

/* --------------------------------------------------------- *
 * Write out the converted data                              *
 * --------------------------------------------------------- */

 if table = "YES" then Call Design_table

 if _opt_enc_    = "YES" ,
 then do ;
        do_encode = "YES" ;
        if codepage_num /= "" ,
        then do ;
                do _idx_ = 1 to out.0
                   out_upper = translate(out._idx_)
                   do_encode_save = ""
                   select ;
                     when ( pos("=",out_upper)                > 0 ) ,
                       then do ;
                               do_encode_save = do_encode
                               do_encode = "YES";
                            end;
                     when ( abbrev(out_upper,"<"cc_excl"--")  = 1 ) ,
                       then do ;
                               do_encode = "NO" ;
                            end;
                     when ( abbrev(out_upper,"<SCRIPT")       = 1 ) ,
                       then do ;
                               do_encode = "YES";
                            end;
                     when ( abbrev(out_upper,"</STYLE>")      = 1 ) ,
                       then do ;
                               do_encode = "YES";
                               iterate;
                            end;
                     when ( abbrev(out_upper,"</SCRIPT>")     = 1 ) ,
                       then do ;
                               do_encode = "YES";
                               iterate;
                            end;
                     otherwise nop ;
                   end;
                   if do_encode = "YES" ,
                   then do ;
                           _enctype_ = "HTML"
                           out._idx_ = sub_encode_data(out._idx_)
                        end;
                   if do_encode_save /= "" ,
                   then do ;
                           do_encode = do_encode_save
                           do_encode_save = ""
                        end;
                end;
             end;
      end;

 if outdd = null then do
    do i = 1 to out.0
       save_lrecl = max(save_lrecl,length(out.i))
    end
    space = (out.0 * save_lrecl)%34000
    space = space + 30
    space = space","space
    if pos("(",output) = 0 then
       "Alloc f("dd") new ds("output") reuse tr" ,
             "recfm(v b) lrecl("save_lrecl+4")" ,
             "blksize(0) spa("space") release"
    else do
         if "MEMBER NOT FOUND" = sysdsn(output) then
            "Alloc f("dd") shr ds("output") reuse"
         else
       "Alloc f("dd") new ds("output") reuse tr" ,
             "recfm(v b) lrecl("save_lrecl+4")" ,
             "dir(27)" ,
             "blksize(0) spa("space") release"
         end
    "Execio * diskw" dd "(finis stem out."
    "Free  f("dd")"
    end
 else "Execio * diskw" outdd "(finis stem out."

/* --------------------------------------------------------- *
 * Done so report out and leave                              *
 * --------------------------------------------------------- */
 Done:
 if browse = 1 then
    if r > 0 then do
       call msg 'off'
       if sysvar("syspref") = null then
          hlq  = sysvar("sysuid")"."
       else hlq = null
       browse_dsn = hlq"txt2html.report"
       call msg "off"
       "Delete" browse_dsn
       "Alloc f("dd") ds("browse_dsn") new spa(1,1) tr",
       "recfm(v b) lrecl(80) blksize(0)"
       "Execio * diskw" dd "(Finis stem rpt."
       Address ISPExec "Browse Dataset("browse_dsn")"
       "Free f("dd")"
       "Delete" browse_dsn
       end

 if ret = 1 then return
 Exit 0


sub_init:
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
  msgid = left(myname": ",9)
 return 0

 /* -------------------------------------------------------------- *
  * encode the input data                                          *
  * -------------------------------------------------------------- */

  sub_encode_data: procedure expose ,
             msgid null codepage_num _charset_ _enctype_
    parse arg _data_
    if _data_ = null ,
    then nop ;
    else do ;
            enc_header = "<HEADER>"
            enc_header = enc_header"<CP>"codepage_num"</CP>"
            enc_header = enc_header"<ENC>"_charset_"</ENC>"
            if _enctype_ = null ,
            then nop;
            else do ;
                    enc_header = enc_header"<TYPE>"_enctype_"</TYPE>"
                 end;
            _enctype_  = null
            enc_header = enc_header"</HEADER>"
            _data_     = xmitzqen(""enc_header""_data_"") ;
         end;
   return _data_ ;

 /* -------------------------------------------------------------- *
  * set the codepage                                               *
  * -------------------------------------------------------------- */

 sub_codepage_set: procedure expose ,
   codepage_num codepage_chars ,
   excl basl diar brsl brsr brcl brcr hash ,
   cc_excl cc_brcl cc_brcr ,
   codepage_default encoding_default sep_default

   cc_excl          = x2c("5A")
   cc_brcl          = x2c("C0")
   cc_brcr          = x2c("D0")
      excl          = x2c("5A")
      brcl          = x2c("C0")
      brcr          = x2c("D0")
   SpecialChars     = x2c("5A E0 72 AD BD C0 D0 7B")
   codepage_num     = "00037"
   codepage_chars   = ""SpecialChars
   codepage_default = ""codepage_num" "codepage_chars
   codepage_default = ""
   encoding_default = "WINDOWS-1252"
        sep_default = ","
 /* return 0 */ /* remove the comment to deactivate xmitipcu */

 /* check xmitipcu existence and get data                */
 /*   use a sub routine to continue processing if error  */
 cu = sub_check_xmitipcu() ;

 if datatype(cu) = "NUM" ,
 then do ;
           nop ;
      end;
 else do ;
        /* ----------------------------------------------------- *
         * Invoke XMITIPCU for local customization values        *
         * ----------------------------------------------------- */
        if datatype(cu) = "NUM" then exit cu

        /* ----------------------------------------------------- *
         * parse the customization defaults to use them here     *
         * ----------------------------------------------------- *
         * parse the string depending on the used separator      *
         * ----------------------------------------------------- */
        if left(cu,4) = "SEP=" ,
        then do ;
                 parse var cu "SEP=" _s_ cu
                 _s_val_d_ = c2d(_s_)
                 _s_val_x_ = c2x(_s_)
             end;
        else     _s_ = left(strip(cu),1)

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

        /* ------------------------------------------------------ *
         * Now remove any leading/trailing blanks from the values *
         * ------------------------------------------------------ */
         codepage_default = strip(codepage_default)
         encoding_default = strip(encoding_default)
         codepage_num   = strip(word(special_chars,1))
         codepage_chars = strip(word(special_chars,2))
         excl           = substr(codepage_chars,1,1)
         basl           = substr(codepage_chars,2,1)
         diar           = substr(codepage_chars,3,1)
         brsl           = substr(codepage_chars,4,1)
         brsr           = substr(codepage_chars,5,1)
         brcl           = substr(codepage_chars,6,1)
         brcr           = substr(codepage_chars,7,1)
         hash           = substr(codepage_chars,8,1)
         select ;
           when ( codepage_default = "01141" ) then sep_default = ";"
           otherwise                                sep_default = ","
         end;
      end;
   return 0

 sub_check_xmitipcu:
   cu = 8
   signal on  syntax name sub_check
   cu = xmitipcu() ;
   signal off syntax
   return cu

 sub_check:
  signal off novalue        /* Ignore no-value variables within trap */
  trap_errortext = 'Not Present'/* Error text available only with RC */
  trap_condition = Condition('C')              /* Which trap sprung? */
  trap_description = Condition('D')               /* What caused it? */
  trap_rc = rc                          /* What was the return code? */
  if datatype(trap_rc) = 'NUM' then     /* Did we get a return code? */
     trap_errortext = Errortext(trap_rc)    /* What was the message? */
  trap_linenumber = sigl                     /* Where did it happen? */
  trap_line = sourceline(trap_linenumber)  /* What is the code line? */
  trap_line = strip(space(trap_line,1," "))

  msgid = ""left(rexxname,8)" "
  _code_ = 999
  rcode = sub_specials(_code_)
  if rcode < _code_ ,
  then do ;
           return rcode
       end;

  if value(contact) = "CONTACT" ,
  then contact = "your contact"
  ER. = ''                           /* Initialize error output stem */
  ER.1 = ' '
  ER.2 = 'An error has occurred in Rexx module:' myname
  ER.3 = '   Error Type        :' trap_condition
  ER.4 = '   Error Line Number :' trap_linenumber
  ER.5 = '   Instruction       :' trap_line
  ER.6 = '   Return Code       :' trap_rc
  ER.7 = '   Error Message text:' trap_errortext
  ER.8 = '   Error Description :' trap_description
  ER.9 = ' '
  ER.10= 'Please look for corresponding messages '
  ER.11= '  and report the problem to 'contact'.'
  ER.12= ' '
  ER.0 = 12

  do i = 1 to ER.0                   /* Print error report to screen */
     say ER.i
  end /*do i = 1 to ER.0*/

  Exit 8

  /* ------------------------------------------------------------ *
   * special checks:                                              *
   *    get the failing command                                   *
   *    check whether processing can / should continue ...        *
   * here: check existence of xmitipcu                            *
   *       continue processing without messages                   *
   *       use hardcoded values or xmitipcu values                *
   * ------------------------------------------------------------ */
 sub_specials:
  parse arg ret_str
  _cmd_ = trap_line
  parse var _cmd_ 1 . "=" _cmd_ "/*" .
  parse var _cmd_ 1       _cmd_ ";"  .
  _cmd_ = space(translate(_cmd_,"",'"'),0)
  _cmd_upper_ = translate(_cmd_)
  txt.0 = 0
  select
    when ( _cmd_upper_ = translate("XMITIPCU()") ) ,
      then do ;
               ret_str = 4
               txt.1 = " "
               txt.2 = ""msgid"... "_cmd_
               txt.3 = ""msgid"... "trap_rc" - "trap_errortext
               txt.4 = ""msgid"... processing continues ..."
               txt.5 = " "
               txt.0 = 5
               txt.0 = 0  /* deactivate msg lines */
           end;
    when ( _cmd_upper_ = translate("SOCKET('terminate')") ) ,
      then do ;
               ret_str = 4
               txt.1 = " "
               txt.2 = ""msgid"... "_cmd_
               txt.3 = ""msgid"... "trap_rc" - "trap_errortext
               txt.4 = ""msgid"... processing continues ..."
               txt.5 = " "
               txt.0 = 5
           end;
    otherwise nop ;
  end;
           do i = 1 to txt.0
              say txt.i
           end
  return ret_str

/* ---------------------- *
 * Call Load ISPF Routine *
 * ---------------------- */
 Load_Stuff:
 save_load = loadispf()
 return

/* ---------------------- *
 * Exit Routine           *
 * ---------------------- */
 Exit_Here:
 Address ISPExec
 do until length(save_load) = 0
    parse value save_load with dd libd save_load
    if left(libd,6) = "ALTLIB" then do
       if libd = "ALTLIBC" then lib = "CLIST"
                           else lib = "EXEC"
       Address TSO,
         "Altlib Deact Application("lib")"
       end
    else do
         "libdef" libd
         end
    address tso,
       "free f("dd")"
    end
 exit 0

/* ----------------------------------------------------- *
 * Do_HTML      Routine (base on idea/code from          *
 *                  Leland Lucius)                       *
 * Add basic html page header.                           *
 * If Do_CC  = 1 then do:                                *
 * Convert 1 in column 1 to horizontal line              *
 * Convert 0 in column 1 to a blank line then data line  *
 * Convert - in column 1 to 2 blank lines then data line *
 * Convert non-blank col 1 to a blank line then data line*
 * if + then merge data into previous line               *
 * Shifts data left 1 column to remove cc                *
 * ----------------------------------------------------- */
 Do_HTML:
 background = "white"
 if color = null then do
    text       = "black"
    end
 if pos("-",color) > 0 then
    parse value color with background "-" text
 else text = color
 if   _opt_cp_  = null ,
 then codepage_num  = word(codepage_default,1) ;
 else do ;
          parse var _opt_cp_ codepage_num "-" codepage_chars
          if codepage_chars /= "" ,
          then special_chars = codepage_chars
      end;

 /* --------------------------------------------------- *
  * Now fixup the color in case abbreviations were used */
 text       = fix_color(text)
 background = fix_color(background)
 if background = null then background = "White"
 if text       = null then text       = "Black"
 fore = text
 n = out.0 + 1
 out.n = '<HTML>'
 n = n + 1
 out.n = '<HEAD>'
 if title <> null then do
    n = n + 1
    out.n = "<title>"title"</title>"
    end
 n = n + 1
 out.n = '<STYLE type="text/css">'
 n = n + 1
 out.n = "<"cc_excl"--"   /* separate line                 */
 n = n + 1
 out.n = " p.button"
 n = n + 1
 out.n = " "cc_brcl" "
 n = n + 1
 out.n = "   font-size: 9pt ;"
 n = n + 1
 out.n = "   font-style: italic ;"
 n = n + 1
 out.n = "   font-family: verdana, arial, helvetica, sans-serif ; "
 n = n + 1
 out.n = "   color: red ;"
 n = n + 1
 out.n = " "cc_brcr" "
 n = n + 1
 out.n = " body"
 n = n + 1
 out.n = " "cc_brcl" "
 n = n + 1
 out.n = "   Background-color:" background ";"

/* ------------------------------------------------------------ *
 * Font Size determined                                         *
 * ------------------------------------------------------------ */
 font_sizes = "xx-small x-small small medium large x-large xx-large"
 if font_size <> null then do
    fontsize = word(font_sizes,font_size)
    n = n + 1
    out.n = "   Font-Size:" fontsize" ;"
    end

 n = n + 1
 out.n = "   Color: "text" ;"
 n = n + 1
 out.n = " "cc_brcr" "
 n = n + 1
 out.n = "-->"
 n = n + 1
 out.n = "</STYLE>"    /* separate line and uppercase   */
 n = n + 1
 out.n = "</HEAD>"
 n = n + 1
 out.n = "<BODY>"
 n = n + 1
 out.n = "<PRE>"
 n = n + 1
 out.n = ""
 out.n = out.n'<A NAME="TOP" HREF="#BOTTOM">'
 out.n = out.n'<p class="button">Bottom</p>'
 out.n = out.n'</A>'
 top = 1
 if banner <> null then do
    n = n + 1
    out.n = '<center><b><FONT color="'text'" size="6">'
    n = n + 1
    out.n = title
    n = n + 1
    out.n = "</b></center></Font>"
    end
 cc = " "
 /*
 n = n + 1
 if font_size <> null then
    text = text "Size="font_size
 save_font = "<FONT color="text">"
 out.n = save_font
 */
 new_page = '</pre><p STYLE="page-break-before: always"></p><pre>'
 /* added by aja */
 first_out = n + 1
 /* end added by aja */

/* ------------------------------------------------------------ *
 * Now process all the input records                            *
 * ------------------------------------------------------------ */
 do i = 1 to in.0
    /* save_lrecl = max(save_lrecl,length(out.n)) */
    if do_cc = 1 then do
       cc = left(in.i,1)
       if length(in.i) > 1 then
          in.i = substr(in.i,2)
       else in.i = " "
       end

   /* ----------------------------------------------------- *
    * Translate <>"& characters to &lt, &gt, &quot, &amp    *
    * ----------------------------------------------------- */
    tranlen = length(in.i)
    tranfrom = '&<>"'
    tranto   = "&amp; &lt; &gt; &quot;"
    do tranc = 1 to length(tranfrom)
       transt = 1
       tranchar = substr(tranfrom,tranc,1)
       do forever
          if pos(tranchar,in.i,transt) = 0 then iterate tranc
          tranpos =  pos(tranchar,in.i,transt)
          transt = tranpos + 2
          tranleft = left(in.i,tranpos-1)
          tranright = substr(in.i,tranpos+1)
          in.i = tranleft""word(tranto,tranc)""tranright
          end
       end

    Select
      When cc = "1" then do
           page_count = page_count + 1
           if page_count > 1 then do
              n = n + 1
              out.n = new_page
              n = n + 1
              out.n = '<hr>'
              end
           n = n + 1
           out.n = in.i
           end
      When cc = "0" then do
          if noadv = 0 then do
              n = n + 1
              out.n = "   "
              end
           n = n + 1
           out.n = in.i
           end
      When cc = "-" then do
          if noadv = 0 then do
              n = n + 1
              out.n = "   "
              n = n + 1
              out.n = "   "
              end
           n = n + 1
           out.n = in.i
           end
      When cc = " " then do
           n = n + 1
           out.n = in.i
           end
      When cc = "+" then do
           if i -1 > 0 then do
              maxl = length(out.n)
              i1   = length(out.n)
              i2   = in.i
              maxl = max(maxl,length(i2))
              if i1 <> i2 then
                 i1 = left(i1,maxl,' ')
              do c  = 1 to maxl
                 c1 = substr(i2,c,1)
                 if substr(out.n,c,1) = " " then
                    out.n = overlay(c1,out.n,c)
                 end
              end
          end
/* --------------------------------------------------------- *
 * Process Machine Carriage Control - revised & corrected    *
 * --------------------------------------------------------- */
      When cc = '89'x then do         /* Before Top of page */
           page_count = page_count + 1
           if page_count > 1 then do
              n = n + 1
              out.n = '</pre><p STYLE="page-break-before: always"></p><pre>'
              n = n + 1
              out.n = '<hr>'
              end
           n = n + 1
           out.n = in.i
           if noadv = 0 then do
              n = n + 1
              out.n = ' '
              end
           end
      When cc = '8B'x then do         /* After Top of page */
           page_count = page_count + 1
           if noadv = 0 then do
              n = n + 1
              out.n = ' '
              end
           if page_count > 1 then do
              n = n + 1
              out.n = '</pre><p STYLE="page-break-before: always"></p><pre>'
              n = n + 1
              out.n = '<hr>'
              end
           n = n + 1
           out.n = in.i
           end
      When cc = '11'x then do         /* Before 2           */
           n = n + 1
           out.n = in.i
           if noadv = 0 then do
              n = n + 1
              out.n = ' '
              end
           end
      When cc = '13'x then do         /* After 2           */
           if noadv = 0 then do
              n = n + 1
              out.n = ' '
              end
           n = n + 1
           out.n = in.i
           end
      When cc = '19'x then do         /* Before 3           */
           n = n + 1
           out.n = in.i
           if noadv = 0 then do
              n = n + 1
              out.n = ' '
              n = n + 1
              out.n = ' '
              end
           end
      When cc = '1B'x then do         /* After 3            */
           if noadv = 0 then do
              n = n + 1
              out.n = ' '
              n = n + 1
              out.n = ' '
              end
           n = n + 1
           out.n = in.i
           end
      When cc = '09'x then do         /* Before 1           */
           n = n + 1
           out.n = in.i
           end
      When cc = '0B'x then do         /* After 1           */
           n = n + 1
           out.n = in.i
           end
      When cc = '01'x then do         /* Before 0           */
           l1 = length(out.n)
           l2 = length(in.i)
           if l1 < l2 then out.n = left(out.n,l2,' ')
           if in.i <> out.n then
              do c = 1 to l2
                 c1 =  substr(in.i,c,1)
                 if substr(in.i,c,1) <> " " then
                    out.n = overlay(c1,out.n,c)
                 end
           end
      When cc = '03'x then do         /* Before 0           */
           l1 = length(out.n)
           l2 = length(in.i)
           if l1 < l2 then out.n = left(out.n,l2,' ')
           if in.i <> out.n then
              do c = 1 to l2
                 c1 =  substr(in.i,c,1)
                 if substr(out.n,c,1) <> " " then
                    out.n = overlay(c1,out.n,c)
                 end
           end
      Otherwise do
           if noadv = 0 then do
              n = n + 1
              out.n = "   "
              end
           n = n + 1
           out.n = in.i
           end
      end
    end
 n = n + 1
 out.n = "  "
 /* added by aja */
 last_out = n
 /* end added by aja */
 n = n + 1
 out.n = ""
 out.n = out.n'<A NAME="BOTTOM" HREF="#TOP">'
 out.n = out.n'<p class="button">Top</p>'
 out.n = out.n'</A>'
 n = n + 1
 out.n = "</PRE>"
 if NOJAVACHECK = "JAVACHECK" ,
 then do;
         n = n + 1
         out.n = '<script language="JavaScript">'
         n = n + 1
         out.n = '<'cc_excl'--'
         n = n + 1
         out.n = ' alert("Hello, JavaScript is active.");'
         n = n + 1
         out.n = '//-->'
         n = n + 1
         out.n = '</script>'
         n = n + 1
         out.n = '<noscript>'
         n = n + 1
         out.n = '<center>'
         n = n + 1
         out.n = '<p> </p> <p> </p> <p> </p>'
         n = n + 1
         out.n = '<font size="2">JavaScript is not',
                 'supported or deactivated.',
                 '</font>'
         n = n + 1
         out.n = '</center>'
         n = n + 1
         out.n = '</noscript>'
      end;
 n = n + 1
 out.n = "</BODY>"
 n = n + 1
 out.n = "</HTML>"
 out.0 = n

 return

/* --------------------------------------------------------- *
 * Issue Messages                                            *
 * --------------------------------------------------------- */
 DoMsg:
   parse arg msg
   if confirm = null then return
   if browse  = null then say msgid msg
   if browse = 1 then do
      r = r + 1
      rpt.r = msg
      end
   return

/* ----------------------------------------------------- *
 * Fix up the color specified.......                     *
 * ----------------------------------------------------- */
 Fix_Color: Procedure Expose msgid null
 arg color
 Select
      When abbrev("AQUA",color,1)    then newcolor = "Aqua"
      When abbrev("BLACK",color,3)   then newcolor = "Black"
      When abbrev("BLUE",color,3)    then newcolor = "Blue"
      When abbrev("FUCHSIA",color,1) then newcolor = "Fuchsia"
      When abbrev("GRAY",color,3)    then newcolor = "Gray"
      When abbrev("GREEN",color,3)   then newcolor = "Green"
      When abbrev("LIME",color,1)    then newcolor = "Lime"
      When abbrev("MAROON",color,1)  then newcolor = "Maroon"
      When abbrev("NAVY",color,1)    then newcolor = "Navy"
      When abbrev("OLIVE",color,1)   then newcolor = "Olive"
      When abbrev("PURPLE",color,1)  then newcolor = "Purple"
      When abbrev("RED",color,1)     then newcolor = "Red"
      When abbrev("SILVER",color,1)  then newcolor = "Silver"
      When abbrev("TEAL",color,1)    then newcolor = "Teal"
      When abbrev("WHITE",color,1)   then newcolor = "White"
      When abbrev("YELLOW",color,1)  then newcolor = "Yellow"
      When color = null then newcolor = null
      otherwise do
                newcolor = null
                call domsg "Color specified:" color ,
                          "is not a valid color. -",
                          "Will use default colors."
                call domsg "Valid colors are:"
                call domsg "Color     Abbrev   Color     Abbrev"
                call domsg "Aqua      A        Navy      N     "
                call domsg "Black     Bla      Olive     O     "
                call domsg "Blue      Blu      Purple    P     "
                call domsg "Fuchsia   F        Red       R     "
                call domsg "Gray     Gra       Silver    S     "
                call domsg "Green    Gre       Teal      T     "
                call domsg "Lime     L         White     W     "
                call domsg "Maroon   M         Yellow    Y     "
                end
      end
    return newcolor

/* --------------------  rexx procedure  -------------------- *
 * Name:      LoadISPF                                        *
 *                                                            *
 * Function:  Load ISPF elements that are inline in the       *
 *            REXX source code.                               *
 *                                                            *
 * Syntax:    rc = loadispf()                                 *
 *                                                            *
 *            The inline ISPF resources are limited to        *
 *            ISPF Messages, Panels, and Skeletons,           *
 *                 CLISTs and EXECs are also supported.       *
 *            The inline resources must start in column 1     *
 *            and use the following syntax:                   *
 *            >START  - used to indicate the start of the     *
 *                      inline data                           *
 *            >END    - used to indicate the end of the       *
 *                      inline data                           *
 *            Each resource is begins with a type record:     *
 *            >type name                                      *
 *               where type is CLIST, EXEC, MSG, PANEL, SKEL  *
 *                     name is the name of the element        *
 *                                                            *
 * Sample usage:                                              *
 *          -* rexx *-                                        *
 *          x = loadispf()                                    *
 *          ... magic code happens here (your code) ...       *
 *          Address ISPEXEC                                   *
 *          do until length(x) = 0                            *
 *             parse value x with dd libd x                   *
 *             if left(libd,6) = "ALTLIB" then do             *
 *                if libd = "ALTLIBC" then lib = "CLIST"      *
 *                                    else lib = "EXEC"       *
 *                Address TSO,                                *
 *                  "Altlib Deact Application("lib")"         *
 *                end                                         *
 *             else do                                        *
 *                  "libdef" libd                             *
 *                  end                                       *
 *             address tso,                                   *
 *                "free f("dd")"                              *
 *             end                                            *
 *          exit                                              *
 *                                                            *
 * Returns:   the list of ddnames allocated for use along     *
 *            with the libdef's performed or altlib           *
 *                                                            *
 *            format is ddname libdef ddname libdef ...       *
 *                   libdef may be altlibc or altlibe         *
 *                   for altlib clist or altlib exec          *
 *                                                            *
 * Notes:     Entire routine must be included with REXX       *
 *            exec - inline with the code.                    *
 *                                                            *
 * Comments:  The entire rexx program is processed from the   *
 *            first record to the >END statement or the end   *
 *            of the program, which ever comes first. There   *
 *            are techniques to identify the start of the     *
 *            inline code quicker but that technique would    *
 *            require more coding on the part of the user of  *
 *            this code. Ease compared to speed was chosen.   *
 *                                                            *
 *            Inline ISPTLIB or ISPLLIB were not supported    *
 *            because the values for these would have to be   *
 *            in hex.                                         *
 *                                                            *
 * Author:    Lionel B. Dyck                                  *
 *            Kaiser Permanente Information Technology        *
 *            Walnut Creek, CA 94598                          *
 *            (925) 926-5332                                  *
 *            Internet: lbdyck@gmail.com                      *
 *                                                            *
 * History:                                                   *
 *            08/05/02 - Creation                             *
 *                                                            *
 * ---------------------------------------------------------- */
 LoadISPF: Procedure

 parse value "" with null kmsg kpanel kskel first returns ,
                     kclist kexec
/* ------------------------------------------------------- *
 * Find the InLine ISPF Elements and load them into a stem *
 * variable.                                               *
 *                                                         *
 * Elements keyword syntax:                                *
 * >START - start of inline data                           *
 * >CLIST name                                             *
 * >EXEC name                                              *
 * >MSG name                                               *
 * >PANEL name                                             *
 * >SKEL name                                              *
 * >END   - end of all inline data (optional if last)      *
 * ------------------------------------------------------- */
 last_line = sourceline()
 do i = last_line to 1 by -1
    line = sourceline(i)
    if translate(left(line,6)) = ">START " then leave
    end
 rec = 0
/* --------------------------------------------------- *
 * Flag types of ISPF resources by testing each record *
 * then add each record to the data. stem variable.    *
 * --------------------------------------------------- */
 do j = i+1 to last_line
    line = sourceline(j)
    if translate(left(line,5)) = ">END "   then leave
    if translate(left(line,7)) = ">CLIST " then kclist = 1
    if translate(left(line,6)) = ">EXEC "  then kexec  = 1
    if translate(left(line,5)) = ">MSG "   then kmsg   = 1
    if translate(left(line,7)) = ">PANEL " then kpanel = 1
    if translate(left(line,6)) = ">SKEL "  then kskel  = 1
    rec  = rec + 1
    data.rec = line
    end

/* ----------------------------------------------------- *
 * Now create the Library and Load the Member(s)         *
 * ----------------------------------------------------- */
 Address ISPExec
/* ----------------------------- *
 * Assign dynamic random ddnames *
 * ----------------------------- */
 clistdd = "lc"random(999)
 execdd  = "le"random(999)
 msgdd   = "lm"random(999)
 paneldd = "lp"random(999)
 skeldd  = "ls"random(999)

/* ---------------------------------------- *
 *  LmInit and LmOpen each resource library *
 * ---------------------------------------- */
 if kclist <> null then do
    call alloc_dd clistdd
    "Lminit dataid(clist) ddname("msgdd")"
    "LmOpen dataid("clist") Option(Output)"
    returns = strip(returns clistdd ALTLIBC)
    end
 if kexec <> null then do
    call alloc_dd execdd
    "Lminit dataid(exec) ddname("msgdd")"
    "LmOpen dataid("exec") Option(Output)"
    returns = strip(returns execdd ALTLIBE)
    end
 if kmsg <> null then do
    call alloc_dd msgdd
    "Lminit dataid(msg) ddname("msgdd")"
    "LmOpen dataid("msg") Option(Output)"
    returns = strip(returns msgdd ISPMLIB)
    end
 if kpanel <> null then do
    call alloc_dd paneldd
    "Lminit dataid(panel) ddname("paneldd")"
    "LmOpen dataid("panel") Option(Output)"
    returns = strip(returns paneldd ISPPLIB)
    end
 if kskel <> null then do
    call alloc_dd skeldd
    "Lminit dataid(skel) ddname("skeldd")"
    "LmOpen dataid("skel") Option(Output)"
    returns = strip(returns skeldd ISPSLIB)
    end

/* ----------------------------------------------- *
 * Process all records in the data. stem variable. *
 * ----------------------------------------------- */
 do i = 1 to rec
    record = data.i
    recordu = translate(record)
    if left(recordu,5) = ">END " then leave
    if left(recordu,7) = ">CLIST " then do
       if first = 1 then call add_it
       type = "Clist"
       first = 1
       parse value record with x name
       iterate
       end
    if left(recordu,6) = ">EXEC " then do
       if first = 1 then call add_it
       type = "Exec"
       first = 1
       parse value record with x name
       iterate
       end
    if left(recordu,5) = ">MSG " then do
       if first = 1 then call add_it
       type = "Msg"
       first = 1
       parse value record with x name
       iterate
       end
    if left(recordu,7) = ">PANEL " then do
       if first = 1 then call add_it
       type = "Panel"
       first = 1
       parse value record with x name
       iterate
       end
    if left(recordu,6) = ">SKEL " then do
       if first = 1 then call add_it
       type = "Skel"
       first = 1
       parse value record with x name
       iterate
       end
   /* --------------------------------------------*
    * Put the record into the appropriate library *
    * based on the record type.                   *
    * ------------------------------------------- */
    Select
      When type = "Clist" then
           "LmPut dataid("clist") MODE(INVAR)" ,
                 "DataLoc(record) DataLen(255)"
      When type = "Exec" then
           "LmPut dataid("exec") MODE(INVAR)" ,
                 "DataLoc(record) DataLen(255)"
      When type = "Msg" then
           "LmPut dataid("msg") MODE(INVAR)" ,
                 "DataLoc(record) DataLen(80)"
      When type = "Panel" then
           "LmPut dataid("panel") MODE(INVAR)" ,
                 "DataLoc(record) DataLen(80)"
      When type = "Skel" then
           "LmPut dataid("skel") MODE(INVAR)" ,
                 "DataLoc(record) DataLen(80)"
      otherwise nop ;
      end
    end
 if type <> null then call add_it
/* ---------------------------------------------------- *
 * Processing completed - now lmfree the allocation and *
 * Libdef the library.                                  *
 * ---------------------------------------------------- */
 if kclist <> null then do
    Address TSO,
    "Altlib Act Application(Clist) File("clistdd")"
    "LmFree dataid("clist")"
    end
 if kexec <> null then do
    Address TSO,
    "Altlib Act Application(Exec) File("execdd")"
    "LmFree dataid("exec")"
    end
 if kmsg <> null then do
    "LmFree dataid("msg")"
    "Libdef ISPMlib Library ID("msgdd") Stack"
    end
 if kpanel <> null then do
    "Libdef ISPPlib Library ID("paneldd") Stack"
    "LmFree dataid("panel")"
    end
 if kskel <> null then do
    "Libdef ISPSlib Library ID("skeldd") Stack"
    "LmFree dataid("skel")"
    end
 return returns

/* --------------------------- *
 * Add the Member using LmmAdd *
 * based upon type of resource *
 * --------------------------- */
 Add_It:
 if type = "Clist" then
    "LmmAdd dataid("clist") Member("name")"
 if type = "Exec" then
    "LmmAdd dataid("exec") Member("name")"
 if type = "Msg" then
    "LmmAdd dataid("msg") Member("name")"
 if type = "Panel" then
    "LmmAdd dataid("panel") Member("name")"
 if type = "Skel" then
    "LmmAdd dataid("skel") Member("name")"
 type = null
 return

/* ------------------------------ *
 * ALlocate the temp ispf library *
 * ------------------------------ */
 Alloc_DD:
 arg dd
 Address TSO
 if pos(left(dd,2),"lc le") > 0 then
 "Alloc f("dd") unit(sysda) spa(5,5) dir(1)",
    "recfm(v b) lrecl(255) blksize(32760)"
 else
 "Alloc f("dd") unit(sysda) spa(5,5) dir(1)",
    "recfm(f b) lrecl(80) blksize(0)"
 return

/*---------------------------------------------
  Procedure Design_table  (written by ISYSAJA)
---------------------------------------------*/
design_table:
/* count number of columns */
to_value = length(strip(out.first_out))
col.0 = 1
do t_i = first_out to last_out - 1
   temp = out.t_i

/*temp = out.first_out */
   Do i_t = 1 to to_value UNTIL temp = ''
      temp = strip(temp)
      pos_Qu = pos('&quot;',temp)
      pos_Se = pos(sepa,temp)
      if (pos_Se > 0 & ,
         pos_qu > 0 & ,
         pos_qu < pos_Se) | ,
         (pos_Se = 0 & ,     /*last column isn't terminated by sepa*/
         pos_qu > pos_Se) then
      do
         Parse var temp '&quot;' col.i_t '&quot;' (sepa) temp
      end
      else
      do
         Parse var temp col.i_t (sepa) temp
      end
   end
   col.0 = max(i_t,col.0) /* col.0 contains number of Cols */
end

/* Build table */
/* Prepare the table definition tags to use */
IF NOHEADER = "HEADER" THEN
DO
   tab.1 = '<div id="HeadDiv" style="height:30px;width:900px;'
   tab.1 = tab.1'overflow:hidden">'
   tab.2 = '<table border="1" width=500>'
   tab.0 = 2
END
ELSE DO
   tab.1 = '<table border="1">'
   tab.1 = '<table border="1" CELLSPACING="3" CELLPADDING="3">'
   tab.0 = 1
END
restart_tab = tab.0

do t_i = first_out to last_out - 1
   tab.0 = tab.0 + 1
   next_l = tab.0
   tab.next_l = '<tr>'  /* new table row */
   tab.0 = tab.0 + 1
   next_l = tab.0
/* add table header */
   if t_i = first_out & ,  /* first_line */
      NOHEADER = 'HEADER' Then
   do
      tab.next_l = "<thead>"
      tag1 = "<th "wrap">"
      tagl = "</th>"
      eol_tag = "</thead><tbody>"
   end
   else do /* No table header desired */
      tab.next_l = ""
      tag1 = "<td "wrap">"
      tagl = "</td>"
      eol_tag = ""
   end
   /* Split inputdata into columns */
   temp = out.t_i
   Do t_j = 1 to Col.0 /*UNTIL temp = ''*/
      temp = strip(temp)
      pos_Qu = pos('&quot;',temp)
      pos_Se = pos(sepa,temp)
      if pos_Se > 0 & ,
         pos_qu > 0 & ,
         pos_qu < pos_Se | ,
         (pos_Se = 0 & ,     /*last column isn't terminated by sepa*/
         pos_qu > pos_Se) then
      do
         Parse var temp '&quot;' col.t_j '&quot;' (sepa) temp
      end
      else
      do
         Parse var temp col.t_j (sepa) temp
      end
      if col.t_j = '' then col.t_j = '&nbsp'
   end
   /* end split inputdata into columns */
   /* Construct string */
   Do td = 1 to Col.0
      tab.next_l = strip(tab.next_l)""tag1""strip(col.td)""tagl
   End
   tab.next_l = strip(tab.next_l)""eol_tag
 /*save_lrecl = max(save_lrecl,length(tab.next_l))*/
   /* end construct string */
   tab.0 = tab.0 + 1
   next_l = tab.0
   tab.next_l = '</tr>'
end
IF NOHEADER = "HEADER" THEN
DO
   /* close first non scrollable table */
   numtab = tab.0    /* = last tab line */
   tab.0 = tab.0 + 1
   next_l = tab.0
   tab.next_l = '</table></div>'
   /* repeat table for second scrollable table */
   tab.0 = tab.0 + 1
   next_l = tab.0
   tab.next_l = '<div id="datadiv" style="height:450px;'||,
                'width:920px;overflow:scroll" onScroll="scrollit()">'
   do numt = restart_tab to numtab  /* recopy table */
      tab.0 = tab.0 + 1
      next_l = tab.0
      tab.next_l = tab.numt
      If numt = restart_tab + 2 then /* make header not visible*/
      do   /* replace tag <THEAD> */
         tab.next_l = '<thead style="VISIBILITY: hidden">'||,
                      substr(strip(tab.numt),8)
       /*save_lrecl = max(save_lrecl,length(tab.next_l))*/
      end
   end
END
/* close HTML for second table */
tab.0 = tab.0 + 1
next_l = tab.0
IF NOHEADER = "HEADER" THEN
DO
   tab.next_l = '</tbody></table></div>'
END
ELSE DO
   tab.next_l = '</tbody></table>'
END
/* add script to scroll the second table*/
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = '<script language="JavaScript">'
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = "<"cc_excl"--"
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = "  function scrollit() "cc_brcl""
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = '    datapart=document.getElementById("datadiv");'
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = '    headerpart=document.getElementById("HeadDiv");'
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = '    x=datapart.scrollLeft;'
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = '    headerpart.scrollLeft=datapart.scrollLeft;'
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = " "cc_brcr""
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = "//-->"
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = '</script>'
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = '<noscript>'
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = "JavaScript is deactivated or not supported."
tab.0 = tab.0 + 1
next_l = tab.0
tab.next_l = '</noscript>'

/* append last_out to end of file */
do t_i = last_out + 1 to out.0
   tab.0 = tab.0 + 1
   next_l = tab.0
   tab.next_l = out.t_i
end
/* write new lines to out. */

oud = first_out - 1
do i_t = 1 to tab.0
   oud = oud + 1
   out.oud = tab.i_t
end
out.0 = oud
drop tab.
return

/*
>Start
>Panel txt2html
)Attr Default(%+_)
   _ type( input) intens(high) caps(off) just(left )
   $ type( input) intens(high) caps(on ) just(left )
   % type(text) intens(high)
   ^ type(text) intens(high) color(blue) hilite(reverse)
   @ type(output) intens(high) color(blue) just(right)
)Body Expand(²²)
%-²-²- ^Text-to-HTML @ver% -²-²-
%Command ===>_Zcmd
+
+ Input Dataset    %===>$t2hip
+ Output Dataset   %===>$t2hop
+                       must be new dataset or new member
+
^Optional information+
+ Page Title       %===>_t2htit                                               +
+ Banner Title     %===>_t2hban+     + Table            %===>_t2htbl+
+ Font Size        %===>_t2hfont+    + Header           %===>_t2hhdr+
+ Colors           %===>_t2hcolor    + Wrap             %===>_t2hwrap+
+ Carriage Control %===>_t2hcc +     + SemiColon        %===>_t2hsemi+
+ No Advance       %===>_t2hnav+     + Codepage         %===>_t2cp +
+
+ Valid Color specifications are:
 ^Color+ ^Abv^Color+ ^Abv+^Color+^Abv+^Color+^Abv+^Color+ ^Abv+^Color+ ^Abv+
+ Aqua   ^A+ +Fuchsia^F+  +Lime  ^L+  +Olive ^O+  +Silver ^S+  +Yellow ^Y+
+ Black  ^Bla+Gray   ^Gra++Maroon^M+  +Purple^P+  +Teal   ^T+
+ Blue   ^Blu+Green  ^Gre++Navy  ^N+  +Red   ^R+  +White  ^W+
+
+ PF1 for Help Panel
)Init
 .cursor  = t2hip
 .help    = t2hhelp
  &t2hcc  = &z
  &t2hnav = &z
  &t2hban = &z
)Proc
ver (&t2hip,nb,dsname)
ver (&t2hop,nb,dsname)
 ver (&t2hfont,range,1,7)
 &more = &z
 &t2hcc = trans(trunc(&t2hcc,1) y,Yes n,No Y,Yes N,No *,*)
 ver (&t2hcc,list,Yes,No)
 &t2hban = trans(trunc(&t2hban,1) y,Yes n,No Y,Yes N,No *,*)
 ver (&t2hban,list,Yes,No)
 &t2hnav = trans(trunc(&t2hnav,1) y,Yes n,No Y,Yes N,No *,*)
 ver (&t2hnav,list,Yes,No)
 &t2htbl = trans(trunc(&t2htbl,1) y,Yes n,No Y,Yes N,No *,*)
 ver (&t2htbl,list,Yes,No)
 &t2hhdr = trans(trunc(&t2hhdr,1) y,Yes n,No Y,Yes N,No *,*)
 ver (&t2hhdr,list,Yes,No)
 &t2hwrap = trans(trunc(&t2hwrap,1) y,Yes n,No Y,Yes N,No *,*)
 ver (&t2hwrap,list,Yes,No)
 &t2hsemi = trans(trunc(&t2hsemi,1) y,Yes n,No Y,Yes N,No *,*)
 ver (&t2hsemi,list,Yes,No)
 &cmd = 'IN &t2hip OUT &t2hop BROWSE'
 if (&t2hcc NE &z)
    &cmd = '&cmd CC &t2hcc'
 if (&t2hban NE &z)
    &cmd = '&cmd BANNER &t2hban'
 if (&t2hfont NE &z)
    &cmd = '&cmd FONT &t2hfont'
 if (&t2hcolor NE &z)
    &cmd = '&cmd COLOR &t2hcolor'
 if (&t2hnav EQ Yes)
    &cmd = '&cmd NOADV'
 if (&t2htbl EQ Yes)
    &cmd = '&cmd TABLE'
 if (&t2hhdr EQ No)
    &cmd = '&cmd NOHEADER'
 if (&t2hwrap EQ Yes)
    &cmd = '&cmd WRAP'
 if (&t2hsemi EQ Yes)
    &cmd = '&cmd SEMICOLON'
 if (&t2htit NE &z)
    &cmd = '&cmd TITLE &t2htit'
)End
>Panel t2hhelp
)Attr Default(%+_)
   _ type( input) intens(high) caps(off) just(left )
   $ type( text) intens(high) caps(off) just(left ) color(yellow)
   # type( text) intens(high) caps(off) just(left ) color(turq)
   % type(text) intens(high)
   ^ type(text) intens(high) color(blue) hilite(reverse)
   @ type(output) intens(high) color(blue) just(right)
)Body Expand(²²)
%-²-²- ^Text-to-HTML Help @ver% -²-²-
%Command ===>_Zcmd
+
# The$Input Dataset#must be a sequential data set or pds member.
# The$Output Dataset#must not already exist.
+
 ^The Optional information:+
$ Page Title      #Text for a page title
$ Banner Title    #Yes or No to generate a banner (default no)
$ Font Size       #font size (1=very small 7=very large)
$ Colors          #text or background-text color (see color list on panel)
$ Carriage Control#Yes or No
$ No Advance      #Yes or No for double/triple spacing
 ^The Optional information to convert a CSV to an HTML Table:+
$ Table           #Yes or No to convert CSV to HTML Table (default No)
$ Header          #Yes or No to create a Header row if Table is Yes
$ Wrap            #Yes or No to wrap cells in HTML Table if Table is Yes
$ SemiColon       #Use a semicolon in Table conversion instead of comma
)Init
)Proc
)End
*/
