        /* ---------------------  rexx procedure  ------------------- */
        ver = xmitip("VER")
        /* Name:      XMITIPI                                         *
         *                                                            *
         * Function:  To drive the ISPF Interface to the XMITIP       *
         *            application.                                    *
         *                                                            *
         * Notes:     Normally invoked by the XMITIP command if no    *
         *            parameters are specified and ISPF is active.    *
         *                                                            *
         * Syntax:    %xmitipi parm                                   *
         *                                                            *
         *            Valid parms:
         *                  DEBUG   - turn on tracing                 *
         *                  NOATTR  - only display file att settings  *
         *                            if user asks on XMITIP panel    *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * License:   This EXEC and related components are released   *
         *            under terms of the GPLV3 License. Please        *
         *            refer to the LICENSE file for more information. *
         *            Or for the latest license text go to:           *
         *                                                            *
         *              http://www.gnu.org/licenses/                  *
         *                                                            *
         * History:                                                   *
         *          2020-08-26 - 20.08                                *
         *                     - Add () around replyto                *
         *          2016-09/21 - 16.09                                *
         *                     - add SizeLim support                  *
         *          2016-03/17 - 16.03                                *
         *                     - add MailFMT support                  *
         *          2015-12/02 - 15.12                                *
         *                     - add StartTLS support                 *
         *          2010-07/07 - 10.07                                *
         *                     - add sysname to xmitjcl               *
         *          2008-12-01 - 08.12                                *
         *                     - use quotes for x2c strings           *
         *          2008-09-01 - 08.09                                *
         *                       remove second label disp:            *
         *          2008-08-29 - 08.08                                *
         *                     - use xmitip("VER") function           *
         *          2008-06-16 - 08.07                                *
         *                     - Allow DD:ddname for MSGDS            *
         *                     - Allow Attachment of DD:ddname        *
         *                     - Correct OK to OR for no file selected*
         *                       msg                                  *
         *          2008-04-03 - 08.04                                *
         *                     - Change in versioning to year.month   *
         *          2008-02-13 - 08.02                                *
         *                     - Change in versioning to year.month   *
         *          2008-01-02 - 08.01                                *
         *                     - Change in versioning to year.month   *
         *          2007-10-18 - 5.70                                 *
         *                     - Version change only                  *
         *          2007-06-29 - 5.68                                 *
         *                     - Version change only                  *
         *          2007-06-08 - 5.66                                 *
         *                     - Version change only                  *
         *          2007-05-04 - 5.64                                 *
         *                     - Update for new XMITIPCU return       *
         *          2007-04-19 - 5.62                                 *
         *                     - Version change only                  *
         *          2007-02-02 - 5.60                                 *
         *                     - Version change only                  *
         *          2007-01-13 - 5.58                                 *
         *                     - Add custsym to parse from xmitipcu   *
         *          2006-11-01 - 5.56                                 *
         *                     - version change only to match xmitip  *
         *          2006-10-26 - 5.54                                 *
         *                     - version change only to match xmitip  *
         *          2006-09-26 - 5.52                                 *
         *                     - version change only to match xmitip  *
         *          2006-09-12 - 5.50                                 *
         *                     - version change only to match xmitip  *
         *          2006-07-12 - 5.48                                 *
         *                     - Add SORT option for Address Table.   *
         *                       and save the option as new default   *
         *          2006-04-06 - 5.46                                 *
         *                     - version change only to match xmitip  *
         *          2006-01-18 - 5.44                                 *
         *                     - version change only to match xmitip  *
         *          2005-12-30 - 5.42                                 *
         *                     - version change only to match xmitip  *
         *          2005-11-10 - 5.40                                 *
         *                     - version change only to match xmitip  *
         *          2005-11-07 - 5.38                                 *
         *                     - version change only to match xmitip  *
         *          2005-05-24 - 5.36                                 *
         *                     - change to return from xmitipcu       *
         *          2005-05-17 - 5.34                                 *
         *                     - version change only to match xmitip  *
         *          2005-04-19 - 5.30                                 *
         *                     - version change only to match xmitip  *
         *          2005-01-24 - 5.28                                 *
         *                     - version change only to match xmitip  *
         *          2004-10-08 - 5.26                                 *
         *                     - version change only to match xmitip  *
         *          2004-07-26 - 5.24                                 *
         *                     - Support updates to XMITIPCU          *
         *          2004-06-07 - 5.20                                 *
         *                     - Handle dsnames in XMITIP panel as    *
         *                       ver dsnameq would handle them        *
         *                     - Correct hlq for batch jcl            *
         *                     - Update for new xmitipcu variable     *
         *                       restrict_hlq (not used in this exec) *
         *                     - Update for new xmitipcu variable     *
         *                       default_lang (not used in this exec) *
         *          2004-05-19 - 5.18                                 *
         *                     - Correct bug with batch steplib dsns  *
         *                       * thx to hartmut beckmann            *
         *                     - Use new XMITIPCU variable SYSTCPD    *
         *          2004-05-11 - 5.16                                 *
         *                     - Support csv to html table            *
         *          2004-05-04 - 5.14                                 *
         *                     - Change .ics time format              *
         *          2004-04-30 - 5.14                                 *
         *                     - Change usage of "" to null           *
         *          2004-04-19 - 5.12                                 *
         *                     - Enable Default Setting of QUIET for  *
         *                       the ISPF dialog to only display the  *
         *                       XMITIP Log if the return code from   *
         *                       XMITIP is greater than zero.         *
         *          2004-04-13 - 5.10                                 *
         *                     - Support new XMITIPCU VALIDFROM option*
         *                       if >0 then validate FROM and REPLYTO *
         *                       addresses.                           *
         *          2004-03-21 - 5.08                                 *
         *                     - Better diag if gdg on tape           *
         *                     - XMITIPCU from2rep                    *
         *          2004-03-11 - 5.06                                 *
         *                     - Add return code display on ispf      *
         *                       execution.                           *
         *                     - Add RESPOND to Mail Delivery panel   *
         *                     - Clean up calls to XMITIPID           *
         *                     - Change Batch option to allow Edit    *
         *                       of the command and foreground exec   *
         *                     - Correct call to test_pdfidx          *
         *          2004-02-09 - 5.04                                 *
         *                     - Add return code test from XMITIPCU   *
         *                     - Update to allow comma separated      *
         *                       addresses                            *
         *          2004-01-27 - 5.02                                 *
         *                     - Update to generate only a single     *
         *                       margin value if FORMAT *xxx is used  *
         *                       (uses only 1st specified margin      *
         *          2003-12-30 - 5.00                                 *
         *                     - Reset level to match XMITIP          *
         *          2003-12-05 - 4.98                                 *
         *                     - Reset level to match XMITIP          *
         *          2003-11-10 - 4.96                                 *
         *                     - Reset level to match XMITIP          *
         *          2003-10-22 - 4.94                                 *
         *                     - Reset level to match XMITIP          *
         *          2003-10-09 - 4.92                                 *
         *                     - Fix if ?RTF entered                  *
         *                     - Save profile variables for margins   *
         *          2003-09-30 - 4.90                                 *
         *                     - Correct file attribute settings      *
         *                     - Support CONFIG on Format HTML/ZIPHTML*
         *          2003-09-26 - 4.88a                                *
         *                     - Correct test and setting for         *
         *                       ignoresuffix and ignorecc            *
         *                       and pass to xmitip command           *
         *          2003-09-25 - 4.88                                 *
         *                     - If multiple formats are found test   *
         *                       and if all the same use FORMAT *xxx  *
         *                     - Support RTF Configuration file       *
         *                     - Support IGNORESUFFIX option          *
         *                     - Change panel xmitipif to use ENTER to*
         *                       continue                             *
         *                     - If using ? for Format from table     *
         *                       save updated margins in table        *
         *                     - Fix repeat if using dsn then hfs file*
         *                     - Remove Deliver Setting Set message   *
         *                     - Support Read Only option for RTF     *
         *                     - Support iCalendar format of ICAL     *
         *                     - Support FollowUp option              *
         *                     - Support blanks in file attachment    *
         *                       name                                 *
         *                     - Change xmitipip display to continue  *
         *                       on entry instead of pf3              *
         *          2003-08-01 - 4.86                                 *
         *                     - Level change only                    *
         *          2003-07-30 - 4.84                                 *
         *                     - Add review comment to configds       *
         *                     - Clean up margins prompting           *
         *                     - Better support Format ?xxx           *
         *                     - Change process flow for format       *
         *                       and general settings to continue     *
         *                       instead of returning to the main     *
         *                       panel.                               *
         *          2003-07-10 - 4.82                                 *
         *                     - Add otherwise to select/when routine *
         *          2003-07-01 - 4.80                                 *
         *                     - Allow USS files for MSGDS            *
         *                     - Correct atsrc not initialized        *
         *                     - Correction to remove bogus text      *
         *                     - Support new zipcont option           *
         *          2003-05-27 - 4.78                                 *
         *                     - Dynamically acquire STEPLIB for JCL  *
         *                       if ISPLLIB is used (look for T2PINIT *
         *                     - ensure fileo file is in quotes       *
         *          2003-04-11 - 4.76                                 *
         *                     - If Subject is Page then use MSGDS    *
         *                       text for page text                   *
         *                     - Correct Murphy and Sig with Page     *
         *          2003-04-07 - 4.74                                 *
         *                     - Support Page as option in Subject    *
         *                       and display popup for page text      *
         *          2003-03-28 - 4.72                                 *
         *                     - remove references to b64_load        *
         *          2003-03-11 - 4.70                                 *
         *                     - change batch jcl dsname              *
         *          2003-02-14 - 4.68                                 *
         *                     - version change only for xmitip       *
         *          2003-01-15 - 4.66                                 *
         *                     - support for CONFIG keyword           *
         *                     - add new Execution mode of Config     *
         *                     - add prompt to replace/overlay config *
         *                       file                                 *
         *          2002-12-19 - 4.64                                 *
         *                     - add debug to xmitip command report   *
         *          2002-11-14 - 4.64                                 *
         *                     - minor fix for test for txt2pdf config*
         *                       file in pdf format                   *
         *          2002-10-29 - 4.64                                 *
         *                     - version change only                  *
         *          2002-10-25 - 4.62                                 *
         *                     - new feedback command option          *
         *                       using new GENRFDBK interface         *
         *                     - allow new format *type               *
         *                     - support format pdf/ds: or pdf/dd:    *
         *          2002-09-20 - 4.60                                 *
         *                     - support PDF security                 *
         *                     - fix prompting for zipxmit            *
         *                     - add NOSTRIP option                   *
         *          2002-08-05 - 4.58                                 *
         *                     - rollup 4.57 beta                     *
         *                     - support quoted addresses with blanks *
         *                       e.g. "group one"@host.com            *
         *                     - add default_hlq to xmitipcu          *
         *          2002-07-25 - 4.56                                 *
         *                     - include 4.55 beta level              *
         *                     - fix font test for pdf for bold       *
         *                     - new xmitipcu variable zip_hlq        *
         *                     - Only display xmitipif if format      *
         *                       changes or requested.                *
         *          2002-05-17 - 4.54                                 *
         *                     - Add PDF Index                        *
         *                       - validate pdf index values          *
         *                     - option of Never added to ZIPSET      *
         *                     - support sending all members of a pds *
         *                       or masked (with a single *)          *
         *                     - fix address file cc/bcc and panel    *
         *                       cc/bcc                               *
         *          2002-02-07 - 4.52                                 *
         *                     - Several minor fixes                  *
         *          2002-02-06 - 4.51 GA                              *
         *                     - Support quotes within Subject        *
         *                     - Fix broken msgds                     *
         *          2002-02-04 - 4.50 GA                              *
         *                     - Change to version 4.50 because of the*
         *                       extensive changes to the dialog      *
         *                     - new option on call - noattr          *
         *                     - popup file attachment settings if    *
         *                       attachment file name changes         *
         *                       or if the format changes             *
         *                     - Several changes to generated cmd:    *
         *                       - each file, filename, format, and   *
         *                         margin on separate line.           *
         *                     - new xmitipcu option to use filename  *
         *                       as filedesc if no filedesc given     *
         *                     - remove support for cc/bcc + as the   *
         *                       ? uses the address list better       *
         *                     - add option to edit message dsn (copy)*
         *                     - add execmode of prompt to confirm    *
         *                       or cancel sending of the e-mail      *
         *                     - add personal option on panel and do  *
         *                       panel redesign                       *
         *                     - add mset for import,prior, sens      *
         *                     - add attset option for attachment     *
         *                       settings                             *
         *                       if file is a dataset then attset     *
         *                       will be automatically set            *
         *                     - compare format with filename suffix  *
         *                       and issue warning                    *
         *                     - remove filename, filedesc, format    *
         *                       if no files                          *
         *                     - set popups for settings              *
         *                     - validate colors and prompt           *
         *                     - validate importance                  *
         *                     - validate priority                    *
         *                     - validate sensitivity                 *
         *                     - validate msgds dsn                   *
         *                     - Use new XMIT001 ISPF Message         *
         *          2001-11-17 - 4.46 change to match xmitip level    *
         *                     - add format validation code           *
         *                     - if format ? then return to panel     *
         *                       after format defined                 *
         *                     - change ldap lookup to popup panels   *
         *                     - change fix_format to popup panels    *
         *                     - change to support ldap lookup only   *
         *                     - update for xmitipcu antispoof        *
         *                     - update for xmitipcu font_size and    *
         *                       def_orient                           *
         *          2001-10-01 - 4.45 change to match xmitip level    *
         *          2001-09-20 - 4.44 support debug option on panel   *
         *                     - fix format of generated cc           *
         *                     - fix copy of jcl if member new        *
         *                       and if pds member add ispf stats     *
         *          2001-08-22 - 4.43 add blank line to report        *
         *                            after the generated command     *
         *                       - add empty_opt to xmitipcu          *
         *          2001-08-01 - 4.42 fix if left margin not defined  *
         *                            was ignoring all margins        *
         *          2001-07-27 - 4.41 add batch option                *
         *                       - change smcopy to execio 4 copy     *
         *                       - Add disclaim (xmitipcu)            *
         *          2001-06-22 - 4.40 fix for ldap lookup             *
         *                            fix for dist list in table      *
         *          2001-06-14 - 4.39 change level to match xmitip    *
         *          2001-06-06 - 4.38 change level to match xmitip    *
         *          2001-05-29 - 4.37                                 *
         *                       - Add char (xmitipcu)                *
         *          2001-05-21 - 4.36                                 *
         *                       - Add Addressfile panel option.      *
         *                         - Saveaf to save selected addrs    *
         *                         - Loadaf to load from addrfile     *
         *                       - Save addressfile in address table  *
         *                       - Add support for GDG attachments    *
         *                       - Move Format prompt and change to   *
         *                         not return to the display          *
         *                       - add support for AtSign (FEC)       *
         *                       - add support for ISPFFROM flag      *
         *                       - Support new L (loadaf) on address  *
         *                       - Support B to Browse the AddressFile*
         *                       - Support E to Edit the AddressFile  *
         *                       - Support S on address to select     *
         *                         addressfile                        *
         *                       - change address sort order          *
         *                       - when adding addresses cap first let*
         *                       - allow attachment dsn of * instead  *
         *                         of *create*                        *
         *          20xx-xx-xx - 4.35 beta level                      *
         *          2001-03-23 - 4.34 Level change to XMITIP only.    *
         *          2001-03-09 - 4.33 Add test for hfs file exist.    *
         *                       - Enable HFS File attachments        *
         *          2001-02-20 - 4.32a set return code if pf3         *
         *          2001-02-07 - 4.32 fix insert lookup invalid msg   *
         *          2001-01-23 - 4.31 change level to match XMITIP    *
         *                     - clean up history                     *
         *          2001-01-16 - 4.30 add test on reinvoke for error  *
         *                     -  report on sigdsn if defined         *
         *          2000-12-21 - 4.29 add test for sigdsn             *
         *          2000-12-13 - 4.28 change to match xmitip level    *
         *                     - fix report to add + for cc           *
         *          2000-12-01 - 4.27 Fix serialization of XMITIPI    *
         *          2000-11-28 - 4.26 Prevent duplicate addresses     *
         *                     - fix pfz -> fpz (bug)                 *
         *          2000-11-22 - 4.25 Invoke XMITIPCU for ldap info   *
         *          2000-11-21 - 4.25 fix to fit cols 1-72            *
         *                       - also for dsn table fix null sel    *
         *                         dsn validation.                    *
         *          2000-11-13 - 4.25 Add support for XMITIPID to     *
         *                            validate local addresses        *
         *                     - plus support XMITIPML to look up     *
         *                       addresses via ldap                   *
         *          2000-11-04 - 4.22 change level to match xmitip    *
         *            ..                                              *
         *          1999-06-15 - created                              *
         *                                                            *
         * the version reflects the current version of XMITIP while   *
         * the letter suffix is an indication of updates to this code.*
         * ---------------------------------------------------------- */
         arg options

         Signal on NoValue

        /* ---------------------------------------------------------- *
         * Set several default values                                 *
         * ---------------------------------------------------------- */
         parse value "" with zippass null ldap check_addrs ,
                             attset_done import prior sens noattr ,
                             personal ignorecc emsg nostrip ,
                             pg1 pg2 fupdate ignoresf respond stls ,
                             slim hsizelim smtpdest
         msgid = "XMITIP"

        /* ----------------------------------------------------- *
         * If options non-null then trace                        *
         * ----------------------------------------------------- */
         if options <> null then do
            options = translate(options)
            select
               when options = "DEBUG" then trace "?i"
               when options = "TEST"  then nop
               when options = "NOATTR" then do
                    noattr = 1
                    options = null
                    end
               otherwise nop
               end
            end

        /* --------------------------------------------------------- *
         * Setup ISPF Addressing                                     *
         * --------------------------------------------------------- */
        Address ISPEXEC

        /* --------------------------------------------------------- *
         * Set ISPF Message Alarm and other defaults                 *
         * --------------------------------------------------------- */
         zerralrm = "YES"
         "Vput (Zerralrm) Shared"
         parse value "" with zerrtype zerrlm

        /* ----------------------------------------------------- *
         * Test for ISPF Applid of XMIT and if not then recurse  *
         * with that Applid.                                     *
         * ----------------------------------------------------- */
        "Control Errors Return"
        "VGET ZAPPLID"
          if zapplid <> "XMIT" then do
             "TBCreate xmitcmds names(zctverb zcttrunc zctact" ,
                       "zctdesc) replace share nowrite"
             zctverb = "RFIND"
             zcttrunc = 0
             zctact = "&XMTRFIND"
             zctdesc = "RFIND for XMITIP"
             "TBAdd xmitcmds"
             "Select CMD(%"sysvar('sysicmd') options ") Newappl(XMIT)" ,
                 "passlib scrname(XMITIP)"
             x_rc = rc
             "TBClose xmitcmds"
             if x_rc > 4 then do
                smsg = zerrtype
                lmsg = zerrlm
               "Setmsg Msg(xmit001)"
                end
             Exit 0
             end

        /* ----------------------------------------------------- *
         * Invoke XMITIPCU for local customization values        *
         * ----------------------------------------------------- */

        cu = xmitipcu()
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
             (_s_) starttls (_s_) mailfmt ,
             (_s_) antispoof (_s_)(_s_) cu_add
                   /*   antispoof is always last         */
                   /*   finish CU with double separator  */
                   /*   cu_add for specials ...          */

         AtSign   = strip(AtSign)
         dfsize   = font_size     /* used in ispf panels */
         ispffrom = strip(ispffrom)
         systcpd  = strip(systcpd)
         default_hlq = strip(default_hlq)
         feedback_addr = strip(feedback_addr)
         if ispffrom <> 1 then ispffrom = 0
         if zipcont <> 1 then zipcont = 0
                         else zipcont = 1

        /* ---------------------------------------------------------- *
         * Set default value for LDAP Access                          *
         * ---------------------------------------------------------- */
         x=xmitldap()
         parse value x with server .
         if server = 0 then ldap = 1
                       else ldap = 0

        /* ---------------------------------------------------------- *
         * Test ldap value and compare with batch id validation       *
         * ---------------------------------------------------------- */
         if ldap = 0 then
            if batch_idval = 1
               then ldap = 1
            if batch_idval = 3
               then ldap = 1

        /* ----------------------------------------------------- *
         * Display ISPF Panel XMITIP                             *
         * ----------------------------------------------------- */
         Display:
         Address ISPExec
         "Control Errors Return"
         "Vget (left right top bottom paper) Profile"
         if datatype(left)   <> "NUM" then left   = mleft
         if datatype(right)  <> "NUM" then right  = mright
         if datatype(top)    <> "NUM" then top    = mtop
         if datatype(bottom) <> "NUM" then bottom = mbottom

        /* --------------------------------------------------------- *
         * Reset AddressFile to blank                                *
         * --------------------------------------------------------- */
         addrfile = null

        /* --------------------------------------------------------- *
         * Get variables from the profile                            *
         * --------------------------------------------------------- */
        "Vget (from replyto sigdsn mur receipt configds mset pageleno" ,
              "file format zippass zipmeth filename addrfile execmode" ,
              "left right top bottom filedesc pindex filename zipset" ,
              "quiet xsizelim)" ,
              "Profile"

        /* ---------------- *
         * Check for NoAttr *
         * ---------------- */
         if noattr = 1 then do
            filesave = file
            formsave = format
            "Vput (filesave formsave) Profile"
            end

        /* ---------------------------------------------------------- *
         * Display the ISPF Panel until PF3 or user Exits             *
         * ---------------------------------------------------------- */
         do forever
            parse value "" with c_format c_margin c_to ,
                       c_cc c_bcc zcmd addr_table att c_mur,
                       tb_open c_filedesc c_filename c_zippass ,
                       c_fileo c_file filedd c_slim ,
                       c_zipmethod c_pindex pagetxt c_subject ,
                       c_sigds c_msgds tbl_mode msgdd c_msgdd
            "Display Panel(xmitip)"
            rcode = rc
            if rcode > 7 ,
            then leave ;
            else do;
                     call do_it
                 end;
         end;
         exit

         Do_it:
        /* ---------------------------------------------------------- *
         * Do_IT is where we process all the user specified           *
         * information on the Panel.                                  *
         * ---------------------------------------------------------- */

        /* ---------------------------------------------------- *
         * Process command of Feedback to e-mail the designated *
         * support person.                                      *
         * ---------------------------------------------------- */
         if abbrev("FEEDBACK",translate(zcmd),3) then do
            if length(feedback_addr) = 0 then do
               smsg = "Not Supported"
               lmsg = "Feedback is not supported at this location."
               "Setmsg Msg(xmit001)"
               end
            else
               Address TSO ,
                   "%genrfdbk XMITIP" ver feedback_addr
            return
            end

        /* -------------------------------------------------------- *
         * Fixup File and MSGDS quotes the same as ver dsnameq does *
         * in the panel if it were used.                            *
         * -------------------------------------------------------- */
         if translate(left(file,3)) = "DD:" then do
            file = translate(file)
            parse value file with "DD:"filedd
            end
         if filedd /= null then
            if left(file,1) = "'" then
               if right(file,1) <> "'" then
                  file = file"'"
         Select
           When ( left(translate(msgds),3) = "DD:" ) ,
             then do;
                      msgdd = substr(msgds,4)
                  end;
           When ( words(msgds) = 1 ) ,
             then do;
                      if left(msgds,1) = "'" then
                         if right(msgds,1) <> "'" then
                            msgds = msgds"'"
                  end;
           otherwise nop;
         end

        /* --------------------------------------------------------- *
         * Save variables in the Profile                             *
         * --------------------------------------------------------- */
         "Vput (attset configds file format filename addrfile" ,
               "execmode) Profile"

        /* --------------------------------------------------------- *
         * Test the personal option and display personalization panel *
         * --------------------------------------------------------- */
         if ispffrom = 1 then
            if from = null then
               personal = "Yes"
         if personal = "Yes" then do
            save_from    = from
            save_replyto = replyto
            if xsizelim = null then do
               hsizelim = size_limit
               xsizelim = size_limit
               end
            do forever
               "Addpop"
               "Display Panel(xmitipia)"
               xrc = rc
               'vput (xsizelim) profile'
               if xsizelim = null then do
                  size_limit = hsizelim
                  slim = null
                  c_slim = null
                  end
               "Rempop"
               if sigdsn <> null then
                  if "OK" <> sysdsn(sigdsn) then do
                     smsg = "Error"
                     lmsg = "Error: the specified signature file is:" ,
                            sysdsn(sigdsn)
                     "Setmsg Msg(xmit001)"
                     xrc = 0
                     end
               if validfrom > 0 then do
                  smsg = null
                  if save_from <> from then do
                  save_from = from
                  if pos("<",from) > 0 then
                     parse value from with ."<"xfrom">".
                  else xfrom = from
                  vfrc = xmitipid(xfrom)
                  if vfrc > 0 then do
                     xrc = 0
                     save_from = null
                     smsg = "Error: From"
                     lmsg = "Error: the specified FROM address:" from ,
                            "is invalid. Try again."
                     "Setmsg Msg(xmit001)"
                     end
                     end
                  if smsg = null then
                  if replyto <> null then
                     if save_replyto <> replyto then do
                     save_replyto = replyto
                     if pos("<",replyto) > 0 then
                        parse value replyto with ."<"xreplyto">".
                     else xreplyto = replyto
                     vfrc = xmitipid(xreplyto)
                     if vfrc > 0 then do
                        xrc = 0
                        save_replyto = null
                        smsg = "Error: REPLY-TO"
                        lmsg = "Error: the specified REPLY-TO address:" ,
                               replyto "is invalid. Try again."
                        "Setmsg Msg(xmit001)"
                        end
                     end
                  end
               if xrc > 4 then leave
               end
            replyto = '('replyto')'
            "vput (from replyto receipt sigdsn mur pageleno quiet)" ,
                  "Profile"
            smsg = null
            lmsg = "Personalization Settings Saved.",
                   "Verify/Update the other panel options",
                   "then",
                   "press Enter to continue or PF3 to",
                   "cancel this e-mail session."
            "Setmsg Msg(xmit001)"
            personal = null
            signal display
            end

        /* --------------------------- *
         * Process Subject and/or Page *
         * --------------------------- */
        if length(subject) > 0 then do
           if abbrev("PAGE",translate(strip(subject)),1) = 1 then do
              if msgds = "?" then do
                "Display (Panel(xmitippg)"
                if rc > 0 then return
                pg1 = strip(pg1)
                if right(pg1,1) = "+" then
                   pagetxt = left(pg1,length(pg1)-1)strip(pg2)
                else pagetxt = strip(pg1) strip(pg2)
                end
              else pagetxt = msgds

                Select
                  When pos("'",pagetxt) > 0 then
                     c_subject = 'Page "'pagetxt'"'
                  When pos('"',pagetxt) > 0 then
                     c_subject = "Page '"pagetxt"'"
                  Otherwise
                     c_subject = "Page '"pagetxt"'"
                  end
                end
           else do
                Select
                  When pos("'",subject) > 0 then
                     c_subject = 'Subject "'subject'"'
                  When pos('"',subject) > 0 then
                     c_subject = "Subject '"subject"'"
                  Otherwise
                     c_subject = "Subject '"subject"'"
                  end
                end
           end

        /* --------------------------------------------------------- *
         * Test for Execution mode of Batch and EMSG (Edit Message)  *
         * if Message DSN is a dataset.                              *
         *                                                           *
         * If so then tell the user.                                 *
         * --------------------------------------------------------- */
         if translate(emsg) = "YES" then
            if execmode = "Batch" then
               if msgds <> null then
                  if msgds <> "*" then do
                     smsg = "Error"
                     lmsg = "Edit Message DSN is not allowed with",
                            "Execution Mode of Batch. Change Edit",
                            "Message DSN to No (or blank) or change",
                            "the Execution Mode to ISPF."
                     "Setmsg msg(xmit001)"
                     return
                     end

        /* --------------------------------------------------------- *
         * Test for mset and display mail settings options.          *
         * --------------------------------------------------------- */
         if mset = "Yes" then do
            do forever
               "AddPop"
               "Display Panel(xmitipim)"
               xrc = rc
               "RemPop"
               if xrc = 0 then leave
               if xrc > 4 then return
               end
            end

        /* --------------------------------- *
         * Test for Execution Mode of CONFIG *
         * --------------------------------- */
         if execmode = "Config" then do
            tconfig = 0
            if "DATASET NOT FOUND" = sysdsn(configds) then do
               if pos("(",configds) > 0 then dir = "dir(5)"
                                        else dir = null
               Address TSO,
                 "Alloc ds("configds") new spa(1,1) tr",
                   "Recfm(f b) lrecl(80) blksize(0)" dir
               Address TSO "Free ds("configds")"
               tconfig = 1
               end
            if tconfig = 0 then
               if "OK" = sysdsn(configds) then do
                 "Display Panel(xmitipcr)"
                 if rc > 0 then do
                     smsg = "Cancelled"
                     lmsg = "The allocation of the Configuration",
                            "file has been cancelled."
                     "Setmsg msg(xmit001)"
                    return
                    end
                 end
            end

        /* --------------------------------------------------------- *
         * Test the Format option for ?                              *
         * --------------------------------------------------------- */
         if pagetxt = null then
         if left(format,1) = "?" then do
            call fix_format format
            if new_format <> null then do
               format = new_format
               "Vput (format)"
              end
             if pos("HTM",translate(format)) > 0 then call test_color
            "Vput (format)"
            end
         else do
              if pos("HTM",translate(format)) > 0 then call test_color
              "Vput (format)"
              end

        /* --------------------------------------------------------- *
         * Test for attset and if file and it are set then display   *
         * file attachment settings panel.                           *
         * --------------------------------------------------------- */
         if pagetxt = null then
         if attset <> "No" then
         if file <> "?" then
            if file <> null then do
               "Vget (filesave formsave) Profile"
               attset_done = null
               if file <> filesave then attset_done = 0
                                   else attset_done = 1
               if attset_done = 1 then do
                   if format <> formsave then attset_done = 0
                                         else attset_done = 1
                   if pos(translate(left(format,3)),"PDF RTF ZIP") = 0
                      then attset_done = 1
                   end
               if attset_done <> 1 then
                  attset = "Yes"
               if zipset <> "Never" then
                  if zipset <> "Yes" then
                     if pos("ZIP",translate(format)) > 0
                        then if format <> formsave
                           then zipset = "Yes"
                           else zipset = "No"
                     end
         filesave = file
         formsave = format
         "Vput (filesave formsave zipset) Profile"
         if attset = "Yes" then
            if file <> null then
               if file <> "?" then do
            if format <> null then
               if filename <> null then do
                  tn = translate(filename," ",".")
                  tw = words(tn)
                  ts = translate(word(tn,tw))
                  if pos(ts,translate(format)) = 0 then do
                     smsg = " "
                     lmsg = "Warning: Filename of:" filename".",
                            "And format of '"format"'" ,
                            "may be in conflict."
                     "Setmsg msg(xmit001)"
                     end
                  end
            if metric = "I" then measure = "Inches"
                            else measure = "Centimeters"
            "AddPop"
            "Display Panel(xmitipif)"
            xrc = rc
            "RemPop"
            if filedesc <> null then
               if words(filedesc) > 1 then do
                  smsg = "Error"
                  lmsg = "Error: The File Description" ,
                         "can not contain blanks."
                  "Setmsg Msg(xmit001)"
                  rc = 0
                  end
            attset_done = 1
            attset = null
            if translate(ignorecc) <> "YES" then ignorecc = null
            if translate(ignoresf) <> "YES" then ignoresf = null
            if translate(nostrip)  <> "YES" then nostrip  = null
            "Vput (filedesc filename ignoresf" ,
                  "left right top bottom" ,
                   "zipset ignorecc nostrip) Profile"
            end

        /* ----------------------------------------------------- *
         * If AddressFile specified then validate it             *
         * ----------------------------------------------------- */
         if length(addrfile) > 0 then
            if "OK" <> sysdsn(addrfile) then do
               smsg = null
               lmsg = "Address File DSN Error:" addrfile sysdsn(addrfile) ,
                         "Correct and retry."
               "Setmsg Msg(xmit001)"
               return
               end

        /* ----------------------------------------------------- *
         * If Signature DSN specified then validate it           *
         * ----------------------------------------------------- */
         if length(sigdsn) > 0 then
            if "OK" <> sysdsn(sigdsn) then do
               smsg = null
               lmsg = "Signature DSN Error:" sigdsn sysdsn(sigdsn) ,
                         "Correct it in the Personalization Settings"
               "Setmsg Msg(xmit001)"
               return
               end

        /* ----------------------------------------------------- *
         * If Configuration File DSN specified then validate it  *
         * ----------------------------------------------------- */
         if pagetxt = null then
         if execmode <> "Config" then
         if length(configds) > 0 then
            if "OK" <> sysdsn(configds) then do
               smsg = null
               lmsg = "Configuration File DSN Error:" configds ,
                      sysdsn(configds) ,
                      "Correct it in the Personalization Settings"
              "Setmsg Msg(xmit001)"
               return
               end

        /* ---------------------------- *
         * Validate pindex if specified *
         * ---------------------------- */
         if pagetxt = null then
         if length(pindex) > 0 then do
            call test_pdfidx pindex
            if erc > 0 then do
               attset = "Yes"
               return
               end
            end

        /* ----------------------------------------------------- *
         * Save values to ISPF Profile for future use.           *
         * ----------------------------------------------------- */
        "Vput (to msgds bcc cc from subject file font paper style",
               "left right top bottom pindex sigdsn" ,
               "mur filedesc configds mset" ,
               ") profile"

        /* ----------------------------------------------------- *
         * Retrieve saved profile values.                        *
         * ----------------------------------------------------- */
           "Vget (b1 b2 b3 b4 b5 b6 b7 b8 b9 ba bb bc)"
           "Vget (c1 c2 c3 c4 c5 c6 c7 c8 c9 ca cb ccx)"
           "Vget (f1 f2 f3 f4 f5 f6 f7 f8 f9 fa fb fc)"
           "Vget (ss1 ss2 ss3 ss4 ss5 ss6 ss7 ss8",
                              "ss9 ssa ssb ssc)"
           "Vget (ssf1 ssf2 ssf3 ssf4 ssf5 ssf6 ssf7 ssf8",
                              "ssf9 ssfa ssfb ssfc)"
           "Vget (ssp1 ssp2 ssp3 ssp4 ssp5 ssp6 ssp7 ssp8",
                              "ssp9 sspa sspb sspc)"
           "Vget (sl1 sl2 sl3 sl4 sl5 sl6 sl7 sl8",
                              "sl9 sla slb slc)"
           "Vget (sr1 sr2 sr3 sr4 sr5 sr6 sr7 sr8",
                              "sr9 sra srb src)"
           "Vget (st1 st2 st3 st4 st5 st6 st7 st8",
                              "st9 sta stb stc)"
           "Vget (sb1 sb2 sb3 sb4 sb5 sb6 sb7 sb8",
                              "sb9 sba sbb sbc)"

        /* ----------------------------------------------------- *
         * If To is ? then display selection list of To address  *
         * ----------------------------------------------------- */
         inv = 0
         if to <> "?" then do
            call process_address to
            if parens = 1 then signal display
            if tb_open <> 1 then
               call build_address_table
            to   = translate(to," ",",")
            c_to = to
            ename = null
            do i = 1 to words(t_addrs)
               eaddr = word(t_addrs,i)
               ename = t_names.i
               if ename = null then call fix_name eaddr
               if left(eaddr,1) = "*" then iterate
               trc = 0
               do c = 1 to length(atsign)
                  atsigntc = substr(atsign,c,1)
                  if pos(atsigntc,eaddr) > 0 then trc = 1
                  if trc = 1 then leave
                  end
               if trc = 1 then do
                  pat = pos(AtSigntc,eaddr)
                  if pos(AtSigntc,eaddr,pat+1) > 0 then inv = 1
                  if pos(":",eaddr,pat+1) > 0 then inv = 0
                  end
               if inv = 1 then iterate
               x_rc = test_address(eaddr)
               eaddru = translate(eaddr)
               atype = null
               if x_rc = 0 then
                  "TBAdd" tblname "Order"
               else do
                    smsg = "Error"
                    lmsg = "Invalid address:" eaddr
                   "Setmsg Msg(xmit001)"
                    return
                    end
               end
            end
         else do
              if tb_open <> 1 then
                 call build_address_table
              call do_address_table
              addr_table = 1
              end
          call save_addr_table
          if inv = 1 then parse value "" with c_to c_cc c_bcc
          if length(c_to) + length(c_cc) + length(c_bcc) > 0 then do
                  if length(c_to) = 0
                       then c_to = "*"
                  end
          else do
             if inv = 0 then do
                smsg = "No Selections"
                lmsg = "No addresses were selected."
                end
             else do
                smsg = "Error"
                lmsg = "Invalid Address - too many "AtSign"'s."
                end
             "Setmsg Msg(xmit001)"
             return
             end

        /* ----------------------------------------------------- *
         * Test for a To address - if not error message          *
         * ----------------------------------------------------- */
         if length(c_to) = 0 then do
            smsg = null
            lmsg = "Error: A To address must be specified."
            "Setmsg Msg(xmit001)"
            return
            end

        /* ----------------------------------------------------- *
         * For bcc, cc, file, plus paper, style, and margins     *
         * get additional information if coded as a + or ?       *
         * ----------------------------------------------------- */
         if c_bcc <> null then
            c_bcc = c_bcc bcc
         if c_bcc = null then
            if bcc <> "+" then
               if bcc = "?" then call do_address_table2
               else
               if c_bcc = null then do
                  bcc = translate(bcc," ",",")
                  c_bcc = bcc
                  end

         if c_cc <> null then
            c_cc = c_cc cc
         if c_cc = null then
            if cc <> "+" then
               if cc = "?" then call do_address_table2
               else do
                    cc = translate(cc," ",",")
                    if c_cc = null then c_cc = cc
                    end

         if c_to = "*" then tl = 0
                       else tl = 1
         if tl+length(c_cc)+length(c_bcc) = 0 then do
            smsg = "No Selections"
            lmsg = "No addresses were selected."
            "Setmsg Msg(xmit001)"
            return
            end

         form_over = 0

         if pagetxt = null then do
        /* ----------------------------------------------------- *
         * Process File - call do_attachment_table if ?          *
         * ----------------------------------------------------- */
         if file <> "?" then do
            d_rc = 1
            if file <> null then do
               if filedd = null then do
                  rc = test_gdg(file)
                  if rc > 0 then do
                     smsg = "GDG DSN Error"
                     lmsg = "GDG DSN Error:" file_dsn
                    "Setmsg msg(xmit001)"
                    return
                   end
                  if file_dsn <> file
                     then file = file_dsn
                  call test_file file
                  end
               if d_rc = 0 then return
               if pos("/",file) > 0 then do
                  if left(file,1) <> "'" then
                     file = "'"file"'"
                  c_fileo = file
                  end
               else c_file = file
               end
            form_over = 0
            end
         else do
              call do_attachment_table
              style = null
              font  = null
              parse value "" with c_file c_margin c_filename c_format,
                                  c_fileo c_pindex
              call get_attachments 1
              call get_attachments 2
              if words(c_file) > 1 then
                  c_file = "("strip(c_file)")"
              else
                  c_file = strip(c_file)
              if words(c_fileo) > 1 then
                  c_fileo = "("strip(c_fileo)")"
              else
                  c_fileo = strip(c_fileo)
              if c_filedesc <> null then do
                 ok = 0
                 do cf = 1 to words(c_filedesc)
                    if translate(word(c_filedesc,cf)) <> "X"
                       then ok = 1
                    end
                 if ok = 0 then c_filedesc = null
                 if words(c_filedesc) > 1 then
                    c_filedesc = "Filedesc ("strip(c_filedesc)")"
                 else do
                    if length(c_filedesc) > 0 then
                       c_filedesc = "Filedesc "strip(c_filedesc)
                    end
                 end
              if c_format <> null then do
                 ok = 0
                 do cf = 1 to words(c_format)
                    if translate(word(c_format,cf)) <> "X"
                       then ok = 1
                    end
                 if ok = 0 then c_format = null
                 if words(c_format) > 1 then do
                    tcfmt = null
                    do icfw = 1 to words(c_format)
                       cfw = word(c_format,icfw)
                       if wordpos(cfw,tcfmt) = 0 then
                          tcfmt = strip(tcfmt cfw)
                       end
                    if words(tcfmt) > 1 then
                       c_format = "Format ("c_format")"
                    else c_format = "Format *"strip(tcfmt)
                    end
                 else do
                    if length(c_format) > 0 then
                       c_format = "Format "strip(c_format)
                    end
                 end
              if c_filename <> null then do
                 ok = 0
                 do cf = 1 to words(c_filename)
                    if translate(word(c_filename,cf)) <> "X"
                       then ok = 1
                    end
                 if ok = 0 then c_filename = null
                 if words(c_filename) > 1 then do
                    c_filename = "Filename ("strip(c_filename)")"
                    end
                 else do
                    if pos(x2c("01"),c_filename) > 0 then
                       c_filename = "("c_filename")"
                    if length(strip(c_filename)) > 0 then
                       c_filename = "Filename "strip(c_filename)
                    end
                 end
              if pos("PDF",translate(c_format)) > 0 then
                 if c_pindex <> null then do
                    if words(c_pindex) > 1 then
                       c_pindex = "PDFIDX ("strip(c_pindex)")"
                    else
                       c_pindex = "PDFIDX "strip(c_pindex)
                    end
              if c_margin <> null then do
                 w_margin = space(c_margin,0)
                 t_margin = left("/",length(w_margin),"/")
                 if w_margin <> t_margin
                    then c_margin = "Margin ("strip(c_margin)")"
                    else c_margin = null
                 end
              "TBClose" tblname "Library(ISPPRof)"
          end

        /* ----------------------------------------------------- *
         * Test for FORMAT Prompt                                *
         * ----------------------------------------------------- */
         if c_format = null then
          if format <> null then do
            call test_format format
            if erc > 0 then signal display
                       else c_format = "Format "format
            end
            end

        /* ----------------------------------------------------- *
         * Test Importance                                       */
         test = translate(import)
         if test <> null then
         select
           when abbrev("HIGH",test,1)   then import = "High"
           when abbrev("LOW",test,1)    then import = "Low"
           when abbrev("NORMAL",test,1) then import = "Normal"
           otherwise do
             smsg  = "Error"
             lmsg  = "Invalid Importance specified:" import ,
                     "Press PF1 on that field for more info."
             "Setmsg msg(xmit001)"
             return
             end
           end

        /* ----------------------------------------------------- *
         * Test prior                                            */
         test = translate(prior)
         if test <> null then
         select
           when abbrev("URGENT",test,1) then prior = "Urgent"
           when abbrev("HIGH",test,1)   then prior = "Urgent"
           when abbrev("NON-URGENT",test,3) then
                prior = "Non-Urgent"
           when abbrev("LOW",test,1) then
                prior = "Non-Urgent"
           when abbrev("NORMAL",test,3) then prior = "Normal"
           otherwise do
             smsg  = "Error"
             lmsg  = "Invalid Priority specified:" prior ,
                     "Press PF1 on that field for more info."
             "Setmsg msg(xmit001)"
             return
             end
           end

        /* ----------------------------------------------------- *
         * Test sens                                             */
         test = translate(sens)
         if test <> null then
           select
             when abbrev("CONFIDENTIAL",test,3) then
                  sens = "Confidential"
             when abbrev("COMPANY-CONFIDENTIAL",test,3) then
                  sens = "Company-Confidential"
             when abbrev("PRIVATE",test,2) then
                  sens = "Private"
             when abbrev("PERSONAL",test,2) then
                  sens = "Personal"
             otherwise do
                smsg  = "Error"
                lmsg  = "Invalid Sensitivity specified:" import ,
                        "Press PF1 on that field for more info."
                "Setmsg msg(xmit001)"
                return
                end
             end

        /* -------------------------------------- *
         | test for an override to the size_limit |
         * -------------------------------------- */
         if strip(xsizelim) /= null then
            if xsizelim /= size_limit then
               slim = 'SIZELIM' xsizelim

        /* ----------------------------------------------------- *
         * Save updated values                                   *
         * ----------------------------------------------------- */
         "Vput (import prior sens stls) Profile"

        /* ----------------------------------------------------- *
         * Test each of the keywords and set to null if not      *
         * specified.                                            *
         * ----------------------------------------------------- */
         if pagetxt = null then

         Select
           When msgdd /= null then
                c_msgdd = "MSGDD" msgdd
           When length(msgds) = 0 then
                c_msgds = "Nomsg"
           When translate(msgds) = "HTML" then
                c_msgds = "MSGDS * HTML"
           When translate(msgds) = "NOMSG" then
                c_msgds = "Nomsg"
           When msgds = "*" then
                c_msgds = "Msgds *"
           When msgds = "?" then do
                smsg = "Error"
                lmsg = "Message Dataset:" msgds ,
                        "is invalid unless the Subject is PAGE."
                "Setmsg msg(xmit001)"
                return
                end
           When words(msgds) > 1 then
                Select
                when left(msgds,1) = "'" then
                   c_msgds = "MSGT" msgds
                when left(msgds,1) = '"' then
                   c_msgds = "MSGT" msgds
                when pos('"',msgds) > 0 then
                   c_msgds = "MSGT '"msgds"'"
                when pos("'",msgds) > 0 then
                   c_msgds = 'MSGT "'msgds'"'
                otherwise
                   c_msgds = "MSGT '"msgds"'"
                end
           Otherwise do
                     c_msgds = "Msgds" msgds
                     Select
                     When left(msgds,2) = "'/" then do
                          call test_omvs
                          if omvs_stat > 0 then return
                          end
                     When left(msgds,1) = "/" then do
                          call test_omvs
                          if omvs_stat > 0 then return
                          end
                     When sysdsn(msgds) <> "OK" then do
                        smsg = "Error"
                        lmsg = "Message Dataset:" msgds ,
                                sysdsn(msgds)
                        "Setmsg msg(xmit001)"
                        return
                        end
                      otherwise   nop
                      end
                     if translate(emsg) = "YES" then
                        c_msgds = c_msgds "emsg"
                     end
                end

        if length(addrfile) > 0
           then c_addrfile = "Addressfile" addrfile
           else c_addrfile = null
        if length(configds) > 0 then c_configds = "Config" configds
                               else c_configds = null
        if execmode = "Config" then c_configds = null

        if pagetxt = null then
        if length(sigdsn)  > 0 then c_sigds = "Sig" sigdsn
                               else c_sigds = null

        if length(import)  > 0 then c_import = "Importance" import
                               else c_import = null
        if filedd /= null then do
           file     = null
           filename = null
           end
        if file <> "?" then
        if length(filedesc) > 0
           then do
                if words(filedesc) > 1 then
                   filedesc = translate(filedesc,"-"," ")
                c_filedesc = "Filedesc" filedesc
                end
        if file <> "?" then
        if length(filename) > 0
           then do
                x_filename = filename
                x_filename = translate(x_filename,x2c("01"),' ')
                if words(x_filename) > 1 then
                   x_filename = "('"x_filename"')"
                c_filename = "Filename" x_filename
                end
        if form_over = 0 then do
           if length(format) > 0
              then do
                   if words(format) > 1 then
                      format = translate(format,"-"," ")
                   c_format = "Format" format
                   end
           end
        if length(pindex)  > 0 then c_pindex = "PDFIDX" pindex
                               else c_pindex = null
        laf = translate(left(format,3))
        if pos(laf,"PDF ZIPPDF") = 0 then c_pindex = null
        if length(sens)    > 0 then c_sens   = "Sensitivity" sens
                               else c_sens   = null
        if length(stls)    > 0 then c_stls = "TLS" stls
                               else c_stls = null
        if length(prior)   > 0 then c_prior  = "Priority" prior
                               else c_prior  = null
        if translate(ignorecc) = "YES"
                                then c_ignorecc = "IGNORECC"
                                else c_ignorecc = null
        if translate(ignoresf) = "YES"
                                then c_ignoresf = "IGNORESUFFIX"
                                else c_ignoresf = null
        if length(nostrip)  > 0 then c_nostrip = "NoStrip"
                                else c_nostrip = null
        if length(fupdate)  > 0 then c_follow = "FollowUp" fupdate
                                else c_follow = null
        if length(smtpdest) > 0 then c_smtpd  = "SmtpDest" smtpdest
                                else c_smtpd  = null
        if length(respond)  > 0 then do
                                     if words(respond) > 0 then
                                        if left(respond,1) <> "(" then
                                           respond = "("respond")"
                                     c_respond= "Respond" respond
                                     if pos("HTML",c_msgds) = 0 then
                                        c_respond = c_respond "HTML"
                                     end
                                else c_respond= null
        if pagetxt = null then
        if length(mur)     > 0 then
                               if left(mur,1) = "Y" then
                                  c_mur = "Murphy"
                               else c_mur = null
        if slim /= null then do
                             c_slim = slim
                             end
        if length(c_bcc)   > 0 then do
                               c_bcc = strip(c_bcc)
                               if words(c_bcc) > 1 then
                                  c_bcc = "Bcc ("c_bcc")"
                                  else c_bcc = "bcc" c_bcc
                               end
                               else c_bcc = null
        if length(c_cc)    > 0 then do
                               c_cc = strip(c_cc)
                               if words(c_cc) > 1 then
                                  c_cc = "Cc ("c_cc")"
                                  else c_cc = "cc" c_cc
                               end
                               else c_cc = null
        if length(from)    > 0 then c_from = "From" from
                               else c_from = null
        if length(replyto) > 0 then c_replyto = "Replyto" replyto
                               else c_replyto = null
        if length(receipt) > 0 then c_receipt = "Receipt" receipt
                               else c_receipt = null
        c_tpagelen = null
        if translate(left(c_subject,5)) = "PAGE " then do
           if length(pageleno)> 0 then c_tpagelen = "TPageLen" pageleno
           end
        if length(c_file)  > 0
           then do
                if filedd /= null
                   then c_file = "FileDD" filedd
                   else c_file = "File" c_file
                end
           else c_file = null
        if length(c_fileo) > 0 then c_fileo = "FileO" c_fileo
                               else c_fileo = null
        cf = length(c_file) + length(c_fileo)
        if cf = 0 then do
           c_filename = null
           c_format   = null
           c_filedesc = null
           end
        if cf > 0 then
           if length(c_format) > 0 then do
              if c_margin = null then
                 if file <> "?" then do
                 if strip(length(left""right""top""bottom))    > 0
                    then c_margin = "Margin" left"/"right"/"top"/"bottom
                    else c_margin = null
                 end
              end
        if pos(left(c_format,1),"X x") > 0 then c_margin = null
        if length(c_format) = 0 then c_margin = null
        if pos("RTF",translate(c_format)) = 0 then
           if pos("PDF",translate(c_format)) = 0 then
              c_margin = null

        if pos("ZIP",translate(c_format)) > 0 then
        if zipset = "Yes" then do
           do forever
              "Addpop"
              "Display Panel(xmitipiz)"
              xrc = rc
              "RemPop"
              if zipcont = 0 then leave
              else if xrc > 4 then leave
              end
           "Vput (zipmeth zippass) Profile"
           if length(zipmeth) > 0 then
                                  c_zipmethod = "ZipMethod" zipmeth
           if length(zippass) > 0 then
                                  c_zippass = "ZipPass" zippass
           end

        if length(c_file) + length(c_fileo) = 0 then do
           c_zipmethod = null
           c_zippass   = null
           c_format    = null
           end

        /* ----------------------------------------------------- *
         * Make sure the cc and bcc are in the e-mail table      *
         * ----------------------------------------------------- */
         "TBOpen xmitaddr Write Library(ISPPROF)"
         if pos("(",c_to) > 0 then parse value c_to with "(" t_to ")"
                            else t_to = c_to
         if pos("(",c_cc) > 0 then parse value c_cc with . "(" t_cc ")"
                            else parse value c_cc with x t_cc
         if pos("(",c_bcc) > 0 then parse value c_bcc with . "("t_bcc")"
                            else parse value c_bcc with x t_bcc
         call process_address t_to
         if parens = 1 then signal display
         do i = 1 to words(t_addrs)
            ename = t_names.i
            eaddr = word(t_addrs,i)
            if ename = null then call fix_name eaddr
            if left(eaddr,1) = "*" then iterate
             x_rc = test_address(eaddr)
             if x_rc = 0 then
               "TBAdd xmitaddr"
               else do
                    smsg = "Error"
                    lmsg = "Invalid To address:" eaddr
                   "Setmsg Msg(xmit001)"
                    call close_addr
                    signal display
                    end
            end
         call process_address t_cc
         if parens = 1 then signal display
         do i = 1 to words(t_addrs)
            ename = t_names.i
            eaddr = word(t_addrs,i)
            if ename = null then call fix_name eaddr
             x_rc = test_address(eaddr)
             if x_rc = 0 then
               "TBAdd xmitaddr"
               else do
                    smsg = "Error"
                    lmsg = "Invalid CC address:" eaddr
                   "Setmsg Msg(xmit001)"
                    call close_addr
                    signal display
                    end
            end
         call process_address t_bcc
         if parens = 1 then signal display
         do i = 1 to words(t_addrs)
            ename = t_names.i
            eaddr = word(t_addrs,i)
            if ename = null then call fix_name eaddr
             x_rc = test_address(eaddr)
             if x_rc = 0 then
               "TBAdd xmitaddr"
               else do
                    smsg = "Error"
                    lmsg = "Invalid BCC address:" eaddr
                   "Setmsg Msg(xmit001)"
                    call close_addr
                    signal display
                    end
            "TBAdd xmitaddr"
            end
         call close_addr

        /* ----------------------------------------------------- *
         * Test validity of from, receipt, reply-to addrs        *
         * ----------------------------------------------------- */
         if length(from) > 0 then do
            x_rc = test_address(from)
            if x_rc > 0 then do
               smsg = "Error"
               lmsg = "Invalid From address:" from
              "Setmsg Msg(xmit001)"
               signal display
               end
           end
         if length(receipt) > 0 then do
            x_rc = test_address(receipt)
            if x_rc > 0 then do
               smsg = "Error"
               lmsg = "Invalid Receipt address:" receipt
              "Setmsg Msg(xmit001)"
               signal display
               end
           end
         if length(replyto) > 0 then do
            x_rc = test_address(replyto)
            if x_rc > 0 then do
                smsg = "Error"
                lmsg = "Invalid ReplyTo address:" replyto
               "Setmsg Msg(xmit001)"
                signal display
                end
           end

        /* ----------------------------------------------------- *
         * Now invoke the XMITIP application based on our input  *
         * while trapping the output to view after execution.    *
         * ----------------------------------------------------- */
        Address TSO
        cmd.  = null
        xmit. = null
        if execmode = "Debug" then c_debug = "Debug"
                              else c_debug = null
        if options = null then
           call outtrap "xmit."

        /* -------------------------- *
         * Log the command            *
         * -------------------------- */
        n = 1
        cmd.n = "Generated Command:"
        n = n + 1
        if words(c_to) > 1 then do
           call process_address c_to
           if parens = 1 then signal display
           c_to = "("c_to")"
           if t_names.1 <> null then
              addr = '"'t_names.1'"' "<"word(t_addrs,1)">"
           else
              addr = word(t_addrs,1)
           if pos(x2c("01"),addr) > 0 then
              addr = translate(addr,' ',x2c("01"))
           if words(t_addrs) > 1 then
              cmd.n = "%xmitip ("addr "+"
           else
              cmd.n = "%xmitip ("addr") +"
           n = n + 1
           do co = 2 to words(t_addrs)
              if t_names.co <> null then
                 addr = '"'t_names.co'"' "<"word(t_addrs,co)">"
              else
                 addr = word(t_addrs,co)
              if co = words(t_addrs)
                 then addr = addr ")"
              cmd.n = "        " addr "+"
              n = n + 1
              end
              end
           else do
                cmd.n = "%xmitip" c_to "+"
                n = n + 1
                end

        if pagetxt = null then do
           cmd.n = "       " c_msgds "+"
           config_start = n
           n = n + 1
           end
        else config_start = n

        if c_slim /= null then do
           cmd.n = "       " c_slim "+"
           n = n + 1
           end

        if words(c_cc) > 2 then do
           parse value c_cc with x taddr
           call process_address taddr
           if parens = 1 then signal display
           if t_names.1 <> null then
                 addr = '"'t_names.1'"' "<"word(t_addrs,1)">"
              else
                 addr = word(t_addrs,1)
           cmd.n = "        Cc (" addr "+"
           n = n + 1
           do co = 2 to words(t_addrs)
              if t_names.co <> null then
                 addr = '"'t_names.co'"' "<"word(t_addrs,co)">"
              else
                 addr = word(t_addrs,co)
              if co = words(t_addrs)
                 then addr = addr ")"
              cmd.n = "           " addr "+"
              n = n + 1
              end
              end
           else do
               cmd.n = "       " c_cc "+"
               n = n + 1
               end
        if length(c_cc) = 0
           then n = n - 1
        else do
             nm1 = n - 1
             if pos("(",cmd.nm1) > 0 then
                if pos(")",cmd.nm1) = 0 then do
                   parse value cmd.nm1 with tad "+"
                   cmd.nm1 = tad ") +"
                   end
             end
        if words(c_bcc) > 2 then do
           cmd.n = "        Bcc" word(c_bcc,2) "+"
           n = n + 1
           do co = 3 to words(c_bcc)
              cmd.n = "            " word(c_bcc,co) "+"
              n = n + 1
              end
              end
           else do
               cmd.n = "       " c_bcc "+"
               n = n + 1
               end
        if length(c_bcc) = 0 then n = n - 1
        cmd.n = c_from
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_replyto
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_addrfile
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_subject
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_receipt
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_tpagelen
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_import
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_sens
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_stls
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_msgdd
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1

        n = n + 1
        cmd.n = c_prior
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1

        n = n + 1
        cmd.n = c_follow
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1

        n = n + 1
        cmd.n = c_smtpd
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1

        n = n + 1
        cmd.n = c_respond
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1

        if pagetxt = null then do
        n = n + 1
        cmd.n = c_configds
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_sigds
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_mur
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_ignorecc
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_ignoresf
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_nostrip
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_zipmethod
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1
        n = n + 1
        cmd.n = c_zippass
          if strip(cmd.n) <> null then cmd.n = "       " cmd.n "+"
                             else n = n - 1

        n = n + 1
        if length(c_file) > 0 then
           if words(c_file) = 2 then
           cmd.n = "       " c_file "+"
           else do
                cmd.n = "       " subword(c_file,1,2) "+"
                n = n + 1
                do ct = 3 to words(c_file)
                   cmd.n = left(" ",13) word(c_file,ct) "+"
                   n = n + 1
                   end
               end
        if strip(cmd.n) = null then n = n - 1

        n = n + 1
        if length(c_fileo) > 0 then
           if words(c_fileo) = 2 then
           cmd.n = "       " c_fileo "+"
           else do
                cmd.n = "       " subword(c_fileo,1,2) "+"
                n = n + 1
                do ct = 3 to words(c_fileo)
                   cmd.n = left(" ",14) word(c_fileo,ct) "+"
                   n = n + 1
                   end
               end
        if strip(cmd.n) = null then n = n - 1

        n = n + 1
        if length(c_filename) > 0 then
           if words(c_filename) = 2 then do
              cmd.n = "       " c_filename "+"
              cmd.n = translate(cmd.n,' ',x2c("01"))
              end
           else do
                cmd.n = "       " subword(c_filename,1,2) "+"
                cmd.n = translate(cmd.n,' ',x2c("01"))
                n = n + 1
                do ct = 3 to words(c_filename)
                   cmd.n = left(" ",17) word(c_filename,ct) "+"
                   cmd.n = translate(cmd.n,' ',x2c("01"))
                   n = n + 1
                   end
               end
        if strip(cmd.n) = null then n = n - 1

        n = n + 1
        if length(c_filedesc) > 0 then
           if words(c_filedesc) = 2 then
           cmd.n = "       " c_filedesc "+"
           else do
                cmd.n = "       " subword(c_filedesc,1,2) "+"
                n = n + 1
                do ct = 3 to words(c_filedesc)
                   cmd.n = left(" ",17) word(c_filedesc,ct) "+"
                   n = n + 1
                   end
               end
        if strip(cmd.n) = null then n = n - 1

        n = n + 1
        if length(c_format) > 0 then
           if words(c_format) = 2 then
           cmd.n = "       " c_format "+"
           else do
                cmd.n = "       " subword(c_format,1,2) "+"
                n = n + 1
                do ct = 3 to words(c_format)
                   cmd.n = left(" ",15) word(c_format,ct) "+"
                   n = n + 1
                   end
               end
        if strip(cmd.n) = null then n = n - 1

        if pos("*",c_format) > 0 then
           if length(c_margin) > 0 then do
              parse value c_margin with cm1 "("cm2")"
              c_margin = cm1 word(cm2,1)
           end

        n = n + 1
        if length(c_margin) > 0 then
           if words(c_margin) = 2 then
           cmd.n = "       " c_margin "+"
           else do
                cmd.n = "       " subword(c_margin,1,2) "+"
                n = n + 1
                do ct = 3 to words(c_margin)
                   cmd.n = left(" ",15) word(c_margin,ct) "+"
                   n = n + 1
                   end
               end
        if strip(cmd.n) = null then n = n - 1

        n = n + 1
        if length(c_pindex) > 0 then
           if words(c_pindex) = 2 then
           cmd.n = "       " c_pindex "+"
           else do
                cmd.n = "       " subword(c_pindex,1,2) "+"
                n = n + 1
                do ct = 3 to words(c_pindex)
                   cmd.n = left(" ",15) word(c_pindex,ct) "+"
                   n = n + 1
                   end
               end
        if strip(cmd.n) = null then n = n - 1
        end      /* if pagetxt is null */

        n = n + 1
        if length(c_debug) > 0 then
           cmd.n = "       " c_debug "+"
        if strip(cmd.n) = null then n = n - 1

        /* now blank the last + */
        cmd.n = left(cmd.n,length(cmd.n)-1)
        n = n + 1
        cmd.n = " "
        cmd.0 = n

        /* --------------------------------------------------------- *
         * Turn off attachment attribute set flag                    *
         * --------------------------------------------------------- */
        attset_done = null
        if filedd /= null then file = "DD:"filedd

        /* --------------------------------------------------------- *
         * If Execution Mode Prompt then Prompt to Send              *
         * --------------------------------------------------------- */
         if execmode = "Prompt" then do
            Address ISPExec
            "TBCreate prompt names(row) NoWrite"
            do i = 1 to cmd.0
               row = cmd.i
               if length(row) = 0 then iterate
               "TBAdd prompt"
               end
            "TBTop prompt"
            "TBDispl prompt Panel(xmitipic)"
            p_rc = rc
            if p_rc > 4 then do
               smsg = "Cancelled"
               lmsg = "Sending of your e-mail has",
                      "been cancelled per your request."
               "Setmsg msg(xmit001)"
               "TBEnd Prompt"
               return
               end
            "TBEnd Prompt"
            Address TSO
            end

        /* ----------------------------------------------------- *
         * Now issue the command based upon the Execution option *
         * ----------------------------------------------------- */
        cmd = ,
        "%xmitip" c_to c_msgds c_msgdd c_cc c_bcc c_from ,
                  c_subject c_file,
                  c_fileo c_addrfile c_debug c_configds,
                  c_ignorecc c_ignoresf ,
                  c_format c_margin c_sigds c_import c_sens c_mur,
                  c_prior c_filedesc c_replyto c_receipt c_zippass ,
                  c_filename c_zipmethod c_pindex c_nostrip c_follow ,
                  c_tpagelen c_respond c_stls
        cmd_rc = 0

        Select
          When options = "TEST" then do
               say cmd
               call outtrap "off"
               end
          When execmode = "Batch" then do
               call outtrap "off"
               batch_mode = 0
               call do_batch
               if batch_mode = 1 then do
                  smsg = "Complete"
                  lmsg = "Batch Process ended."
                  Address ISPExec ,
                       "Setmsg Msg(xmit001)"
                  return
                  end
               else do
                    call outtrap "xmit."
                    cmd
                    call outtrap "off"
                    end
               end
          When execmode = "Config" then do
               call do_config
               smsg = "Complete"
               lmsg = "Configuration file" configds ,
                      "created."
               Address ISPExec ,
                    "Setmsg Msg(xmit001)"
               return
               end
          Otherwise do
                    cmd
                    cmd_rc = rc
                    call outtrap "off"
                    end
          end

        smsg = "RC:" cmd_rc
        lmsg = "XMITIP completed with return code of" cmd_rc
        Address ISPExec "Setmsg msg(xmit001)"

        if quiet = "Yes" then
           if cmd_rc = 0 then return
        xmit_dd = "C"random()
        "ALLOCATE FILE("xmit_dd") REUSE UNIT(SYSDA) SPACE(1 1) CYL",
                 "DSORG(PS) RECFM(V B) LRECL(255)"
        "EXECIO * DISKW" xmit_dd "(STEM cmd. )"
        "EXECIO * DISKW" xmit_dd "(STEM xmit. FINIS)"
        Address ISPEXEC "LMINIT DATAID(DATAID) DDNAME("xmit_dd")"
        Address ISPEXEC "BROWSE DATAID("dataid")"
        Address ISPEXEC "LMFREE DATAID("dataid")"
        "FREE FILE("xmit_dd")"
        Return

        /* ----------------------------------------------------- *
         * Build address table                                   *
         * ----------------------------------------------------- */
         Build_address_table:
         tb_open = 1
         tblname = "xmit"random(9999)
         "TBCreate" tblname "keys(eaddru)" ,
                  "names(zsel lact eaddr ename atype) Write"
         "Vget (addrsort) profile"
         if "MAIL" = addrsort
            then "TBSORT" tblname "Fields(ename)"
            else "TBSORT" tblname "Fields(eaddr)"
         "TBOpen xmitaddr Write Library(ISPPROF)"
          if rc = 8 then do
             call Create_Table
             end
          if rc = 12 then do
             "TBClose xmitaddr Library(ISPPROF)"
             "TBOpen xmitaddr Write Library(ISPPROF)"
             end
          "TBTop xmitaddr"
           lact = null
          "TBQuery xmitaddr rownum(rows)"
          add_row = "Mult("rows")"
          do rw = 1 to rows
             "TBSkip xmitaddr"
             "TBGet  xmitaddr"
             if ename = null then call fix_name eaddr
             eaddru = translate(eaddr)
             "TBAdd" tblname "Order" add_row
             add_row = null
             end
          "TBTop" tblname
          return

        /* ----------------------------------------------------- *
         * Create the permanent address table                    *
         * ----------------------------------------------------- */
         Create_Table:
          "TBCreate xmitaddr keys(eaddru)",
              "Names(ename eaddr atype) Library(ISPPROF) Replace"
           return

        /* ----------------------------------------------------- *
         * Save the address table                                *
         * ----------------------------------------------------- */
         Save_Addr_Table:
         call Create_Table
          "TBTop" tblname
          "TBQuery" tblname "rownum(rows)"
          add_row = "Mult("rows")"
          do rw = 1 to rows
            "TBSkip" tblname
            "TBGet" tblname
            "TBAdd xmitaddr" add_row
            add_row = null
            end
          "TBSave  xmitaddr Library(ISPPROF)"
          "TBClose xmitaddr Library(ISPPROF)"
          "TBEnd" tblname
          return

        /* ----------------------------------------------------- *
         * Find sub-routine                                      *
         * ----------------------------------------------------- */
        Do_Find:
              parse value zcmd with o1 argument
              upper argument
              argument = strip(argument)
              hit  = 1
              crp  = ztdtop
              find_loop = ''
              search    = ''
              rowid     = crp
              if o1     = "RFIND" then do
                 last_find = last_find + 1
                 "TBTOP " tblname
                 "TBSKIP" tblname "Position(ROWID) Number("Last_find")"
                 end
                 else do
                      "TBSKIP" tblname "Position(ROWID)"
                      end
              if rc = 8 then do
                             "TBTop" tblname
                             "TBSKIP" tblname "Position(ROWID)"
                             smsg = "Wrapped"
                             end
                        else smsg = "Found"

              /* perform search */

              do forever
                 if att = 1 then
                    search = translate(adsn afile aformat adesc)
                 else
                     search = translate(ename eaddr)
                 if pos(argument,search) > 0 then do
                    crp = rowid + 0
                    rowcrp = crp
                    last_find = crp
                    lmsg = argument "found during search in row:" crp
                    "Setmsg msg(xmit001)"
                    leave
                    end
                 "TBSKIP" tblname "POSITION(Rowid)"
                 if rc = 8 then do
                       "TBTOP" tblname
                        smsg = "Wrapped"
                    if find_loop = "on" then do
                        smsg = "Not Found"
                        lmsg = argument "Not found during search"
                        rowid = crp
                        "Setmsg msg(xmit001)"
                        leave
                        end
                        else find_loop = "on"
                    end
                 end
         return

        /* ----------------------------------------------------- *
         * Insert Address routine                                *
         * ----------------------------------------------------- */
         Do_Insert:
             iexit = 0
             "control display save"
             parse value "" with ename eaddr lact zcmd zsel ,
                            zerrlm
             do forever
                "Display panel(xmitipau)"
                if rc > 3 then leave
                if rc < 4 then do
                   do c = 1 to length(atsign)
                      atsigntc = substr(atsign,c,1)
                      if pos(atsigntc,eaddr) > 0 then atsrc = 1
                                                 else atsrc = 0
                      if atsrc = 1 then leave
                      end
                   Select
                      when pos("(",ename) > 0 then
                           lmsg = "Invalid Name - no parenthesis",
                                     "allowed."
                      when atsrc <> 1 then
                           lmsg = "Invalid Address - no "AtSigntc" found."
                      when atsrc = 1 then do
                         pat = pos(AtSigntc,eaddr)
                         if pos(AtSigntc,eaddr,pat+1) > 0 then do
                            lmsg = "Too many "AtSigntc" in address"
                            iexit = 2
                            end
                         if iexit = 0 then do
                            if ename = null then call fix_name eaddr
                            x_rc = test_address(eaddr)
                            eaddru = translate(eaddr)
                            if x_rc = 0 then do
                               "TBAdd" tblname "Order"
                                if rc = 8 then call dup_eaddr eaddr
                                end
                             else lmsg = "Invalid address:" eaddr
                            iexit = 0
                            end
                         end
                      otherwise nop
                      end
                if length(zerrlm) > 0 then do
                   smsg = "Error"
                   lmsg = zerrlm
                   "Setmsg msg(xmit001)"
                   end
                if iexit = 1 then leave
                end
             end
             "control display restore"
             return

        /* ----------------------------------------------------- *
         * Fixup the Name from the address                       */
          Fix_Name: Procedure expose ename atsign null
          parse arg waddr
          trc = 0
          atsigntc = null
          do c = 1 to length(atsign)
             atsigntc = substr(atsign,c,1)
             if pos(atsigntc,waddr) > 0 then trc = 1
             if trc = 1 then leave
             end
          if atsigntc = null then atsigntc = left(atsign,1)
          parse value waddr with wname (AtSigntc) .
          wname = translate(wname," ",".")
          do i = 1 to words(wname)
             tname = word(wname,i)
             if length(tname) = 1 then
                ename = ename translate(tname)
             else do
                  parse value tname with first 2 rest
                  ename = ename translate(first)""rest
                  end
             end
          ename = strip(ename)
          return

        /* ----------------------------------------------------- *
         * Issue duplicate address message                       *
         * ----------------------------------------------------- */
         dup_eaddr:
         parse arg addr
         smsg = "Duplicate"
         lmsg = "Address:" addr "already exists in the table",
                   "- not added.  Use Revise if you need to change",
                   "the address or name information."
         "Setmsg msg(xmit001)"
         return

        /* --------------------------------------------------------- *
         * Test for GDG                                              *
         * --------------------------------------------------------- */
         test_gdg:
         parse arg file_dsn
         if pos("(",file_dsn) > 0 then do
            parse value file_dsn with dsnx "("gdg")"
            if datatype(gdg) <> "NUM" then return 0
            gdg_dsn  = allocgdg("*" file_dsn)
            if datatype(gdg_dsn) <> "NUM" then do
               file_dsn = gdg_dsn
               return 0
               end
               else return 4
            end
            return 0

        /* ----------------------------------------------------- *
         * Test file for existence                               *
         * ----------------------------------------------------- */
         test_file:
         parse arg file_dsn
         smsg = null
         tfhit = 0
         if left(file_dsn,1) = "*" then return
         if pos("/",file_dsn) > 0 then do
            Address TSO ,
              "BPXBATCH SH ls -l" file_dsn
               bpxrc = rc / 256
            if bpxrc = 0 then return
            d_rc = 0
            smsg = "DSN Error"
            lmsg = "Attachment DSN:" file_dsn "not found"
            "Setmsg msg(xmit001)"
            return
            end
         if pos("(",file_dsn) > 0 then do
            parse var file_dsn tfile_dsn"("tfmem")" .
            if left(tfile_dsn,1) = "'" then tfile_dsn = tfile_dsn"'"
            if pos("*",tfmem) > 0 then do
               file_dsn = tfile_dsn
               tfhit = 1
               end
            end
         if sysdsn(file_dsn) <> "OK" then do
            d_rc = 0
            smsg = "DSN Error"
            lmsg = "Attachment DSN:" file_dsn sysdsn(file_dsn)
           "Setmsg msg(xmit001)"
           return
           end
         else do
              call listdsi file_dsn
              if sysdsorg = "PS" then return
              if sysdsorg <> "PO" then do
                 d_rc = 0
                 smsg = "DSN Error"
                 lmsg = "Attachment DSN:" file_dsn "is an invalid dataset" ,
                          "organization. DSORG="sysdsorg
                "Setmsg msg(xmit001)"
                return
                end
              if pos("(",file_dsn) > 0 then return
              if tfhit = 1 then return
              d_rc = 0
              smsg = "DSN Error"
              lmsg = "Attachment DSN:"file_dsn ,
                      "is partitioned and requires" ,
                      "member name."
              "Setmsg msg(xmit001)"
              end
        return

        /* ----------------------------------------------------- *
         * Do the e-mail address table cc / bcc                  *
         * ----------------------------------------------------- */
         do_address_table2:
         if addr_table = 1 then return
         addr_table = 1
         call build_address_table
         call do_address_table
         call save_addr_table
         return

        /* ----------------------------------------------------- *
         * Do the e-mail address table                           *
         * ----------------------------------------------------- */
         do_address_table:
            mult_sels = 0
            crp = 1
            rowcrp = 0
            src    = 0
            disp:
            do forever
               xmtrfind = "PASSTHRU"
               "Vput xmtrfind"
               zcmd = null
               if mult_sels = 0 then do
                 "TBTop" tblname
                 "TBSkip" tblname "Number("crp")"
                    "TBDispl" tblname "Panel(xmitipat)" ,
                            "Csrrow("rowcrp") AutoSel(No)"
                 end
               else
                 "TBDispl" tblname
               t_rc = rc
               mult_sels = ztdsels
               xmtrfind = ''
               "vput xmtrfind"
               if t_rc > 7 then leave
               up_ok = 0
               Select
               When abbrev("SORT",word(zcmd,1),3) = 1 then do
                    parse value zcmd with zcmd addrsort
                    if "MAIL" = addrsort
                       then "TBSORT" tblname "Fields(ename)"
                       else "TBSORT" tblname "Fields(eaddr)"
                    "Vput (addrsort) profile"
                    end
               When abbrev("CANCEL",zcmd,3) = 1 then do
                    call save_addr_table
                    signal display
                    end
               When zcmd = "LOADAF" then do
                    "AddPop"
                    "Display Panel(xmitipla)"
                    s_rc = rc
                    "Rempop"
                    if s_rc > 0 then leave
                    save_af = addrfile
                    Call load_address_file
                    ename = "Distribution List"
                    eaddr = save_af
                    eaddru = translate(eaddr)
                    atype = "D"
                    lact  = "Load"
                    "TBAdd" tblname "Order"
                    if rc = 8 then
                       "TBMod" tblname "Order"
                    end
               When zcmd = "SAVEAF" then do
                    "AddPop"
                    "Display Panel(xmitipas)"
                    s_rc = rc
                    "Rempop"
                    if s_rc > 0 then leave
                    addrfile = adfdsn
                    call listdsi addrfile
                    if sysreason+0 = 0 then
                       if addrdisp = "NEW" then do
                          smsg = "Error"
                          lmsg = addrfile "already exists",
                                    "Disposition of New invalid."
                          "Setmsg msg(xmit001)"
                          signal do_address_table
                          end
                    if sysreason+0 > 0 then do
                       if addrdisp = "NEW" then do
                          Address TSO
                          if pos("(",addrfile) > 0 then
                             "Alloc f(addralx) ds("addrfile")",
                             "New spa(15,15) tr dir(12)",
                             "Recfm(v b) lrecl(132) blksize(26400)"
                          else
                             "Alloc f(addralx) ds("addrfile")",
                             "New spa(15,15) tr ",
                             "Recfm(v b) lrecl(132) blksize(26400)"
                          "Free f(addralx)"
                          Address ISPExec
                          end
                       else do
                            smsg = "Invalid DSN"
                            lmsg = addrfile SYSMSGLVL1,
                                      SYSMSGLVL2
                            "Setmsg msg(xmit001)"
                            end
                       end
                   save_crp = ztdtop
                   "TBTop" tblname
                   sc = 2
                   saddr.1 = "* AddressFile created on",
                             date() "at" time() "by" sysvar("sysuid")
                   saddr.2 = "* "
                   do forever
                      "TBSkip" tblname
                      if rc > 0 then leave
                      "TBGet" tblname
                      if lact = null then iterate
                      if lact = "Load" then iterate
                      if lact = "Save" then iterate
                      sc = sc + 1
                      lact = strip(lact)
                      saddr.sc = left(lact,5) '"'ename'" <'eaddr'>'
                      lact = null
                      "TBMod" tblname
                      end
                   if sc = 0 then do
                      smsg = "Error"
                      lmsg = "No addresses selected so",
                                "there is nothing to save."
                      "Setmsg msg(xmit001)"
                      end
                   else do
                     Address TSO
                     "Alloc F(sc"sc") shr Ds("addrfile")"
                     "Execio * diskw sc"sc "(finis stem saddr."
                     "Free  F(sc"sc")"
                     Address ISPExec
                     ename = adfdesc
                     if ename = null then
                        ename = "Distribution List"
                     eaddr = adfdsn
                     eaddru = translate(eaddr)
                     atype = "D"
                     lact  = "Save"
                     "TBAdd" tblname "Order"
                     if rc = 8 then
                        "TBMod" tblname "Order"
                     "Vput (addrfile) Profile"
                     if to = "?" then c_to = "*"
                     smsg = "Completed"
                     lmsg = "AddressFile created in" ,
                               addrfile "and defined for this",
                               "e-mail."
                     "Setmsg msg(xmit001)"
                    end
                    end
               When words(zcmd) > 1 then do
                    parse value zcmd with o1 o2
                    zsel = null
                    if abbrev("FIND",o1,1) = 1 then call do_find
                    end
               When zcmd = "LOOKUP" then
                    if batch_idval <> 1 then do
                       "AddPop"
                       Address TSO,
                           "%xmitipml  /"tblname
                       "RemPop"
                       end
               When zcmd = "RFIND" then do
                    zcmd = "RFIND" o2
                    zsel = null
                    call  do_find
                    end
               When abbrev("INSERT",zcmd,1) = 1 then call do_insert
               When zsel = "L" then do
                    if atype <> "D" then do
                       lmsg = "The requested entry is not an",
                                 "address list."
                       smsg = "Error"
                       "Setmsg msg(xmit001)"
                       end
                    else do
                         addrfile = eaddr
                         save_af = addrfile
                         save_ad = ename
                         Call load_address_file
                         ename = save_ad
                         eaddr = save_af
                         eaddru = translate(eaddr)
                         lact = "Load"
                         atype = "D"
                         zsel = null
                         "TBMod" tblname "Order"
                         end
                    end
               When zsel = "S" then
                    if atype = "D" then do
                       addrfile = eaddr
                       lact = "Select"
                       zsel = null
                       "TBPut" tblname
                       if to = "?" then c_to = "*"
                       end
                    else
                    if lact <> "To" then do
                       call clean_addr
                       if ename <> null then
                          c_to = strip(c_to '"'ename'" <'eaddr'>')
                       else
                          c_to = strip(c_to eaddr)
                       lact = "To"
                       zsel = null
                       "TBPut" tblname
                       end
               When zsel = "B" then do
                    call test_atype
                    if at = 1 then do
                       "Control Display Save"
                       "Browse Dataset("eaddr")"
                       "Control Display Restore"
                       lact = "Browse"
                       zsel = null
                       "TBPut" tblname
                       end
                    else
                       if lact <> "Bcc" then do
                          call clean_addr
                          c_bcc = strip(c_bcc eaddr)
                          lact = "Bcc"
                          zsel = null
                          "TBPut" tblname
                          end
                       end
               When zsel = "E" then do
                    call test_atype
                    if at = 1 then do
                       "Control Display Save"
                       "Edit Dataset("eaddr")"
                       e_rc = rc
                       "Control Display Restore"
                       if e_rc = 0 then do
                          lmsg = "AddressFile" eaddr "Edited",
                                    "suggest you do a Load to update",
                                    "this table."
                          smsg = null
                          "Setmsg msg(xmit001)"
                       end
                       lact = "Edit"
                       zsel = null
                       "TBPut" tblname
                       end
                       end
               When zsel = "U" then
                    if atype = null then do
                    call clean_addr
                    lact = null
                    zsel = null
                    "TBPut" tblname
                    end
               When zsel = "C" then
                    if atype = null then
                    if lact <> "Cc" then do
                       call clean_addr
                       if ename <> null then
                          c_cc = strip(c_cc '"'ename'" <'eaddr'>')
                       else
                          c_cc = strip(c_cc eaddr)
                       lact = "Cc"
                       zsel = null
                       "TBPut" tblname
                       end
               When zsel = "D" then do
                     call clean_addr
                    "TBDelete" tblname
                    end
               When zsel = "R" then do
                    call test_atype
                    if at = 1 then do
                       "control display save"
                       zsel = null
                       lact = "Revise"
                       "TBGet" tblname "Position(rcrp)"
                       adfdsn  = eaddr
                       adfdesc = ename
                       "Display panel(xmitipar)"
                       up_ok = rc
                       "control display restore"
                       eaddr  = adfdsn
                       eaddru = translate(eaddr)
                       ename   = adfdesc
                       lact    = "Revise"
                       atype   = "D"
                       if rc = 0 then
                         "TBMod" tblname "Order"
                       end
                    if at = 0 then do
                       call clean_addr
                       "control display save"
                       zsel = null
                       lact = "Revise"
                       "TBGet" tblname "Position(rcrp)"
                       s_addr = eaddr
                       "Display panel(xmitipau)"
                       if rc < 4 then do
                          if s_addr <> eaddr then do
                             n_eaddr = eaddr
                             n_ename = ename
                             "TBTop" tblname
                             "TBSkip" tblname "Number("rcrp")"
                             "TBDelete" tblname
                             eaddr = n_eaddr
                             ename = n_ename
                             end
                       trc = 0
                       do c = 1 to length(atsign)
                          atsigntc = substr(atsign,c,1)
                          if pos(atsigntc,eaddr) > 0 then trc = 1
                          if trc = 1 then leave
                          end
                        if trc <> 1 then do
                          up_ok = 1
                          lmsg = "Invalid address - no" ,
                                  left(AtSign,1)
                          smsg = "Error"
                          end
                        if pos("(",ename) > 0 then do
                           up_ok = 1
                           lmsg = "Invalid name - ( found"
                           smsg = "Error"
                           end
                        if pos(")",ename) > 0 then do
                           up_ok = 1
                           lmsg = "Invalid name - ) found"
                           smsg = "Error"
                           end
                        end
                       "control display restore"
                       eaddru = translate(eaddr)
                       if up_ok = 0 then
                          "TBMod" tblname "Order"
                       else
                          "Setmsg msg(xmit001)"
                       end
                    end
               When zsel = "I" then
                    if atype = null then
                       call do_insert
               Otherwise do
                         m_type = null
                         if zsel <> null then
                            m_type = "Invalid Selection" zsel
                         if zcmd <> null then
                            m_type =  "Invalid Command" zcmd
                         smsg = "Error"
                         lmsg = "An" m_type "was entered."
                         if m_type <> null then
                            "Setmsg Msg(xmit001)"
                         end
             end
            end
            return

        /* ----------------------------------------------------- *
         * Clean up possible duplicate address                   *
         * ----------------------------------------------------- */
         Clean_Addr:
         if lact = null then return
         Select
           When lact = "To" then do
                call clean_addr_string c_to
                c_to = string
                end
           When lact = "Cc" then do
                call clean_addr_string c_cc
                c_cc = string
                end
           When lact = "Bcc" then do
                call clean_addr_string c_bcc
                c_bcc = string
                end
           otherwise nop
           end
           return

        /* ----------------------------------------------------- *
         * Eliminate duplicate address                           *
         * ----------------------------------------------------- */
         Clean_Addr_String:
         parse arg string
         if length(string) = 0 then return
         if ename = null then do
            p1 = wordpos(eaddr,string)
            string = delword(string,p1,1)
            end
         else do
              saddr = "<"eaddr">"
              p1 = wordpos(saddr,string)
              if p1 > 0 then do
                 string = delword(string,p1,1)
                 pw = words(ename)
                 p1 = p1 - pw
                 string = delword(string,p1,pw)
                 end
              end
         return

        /* ----------------------------------------------------- *
         * Do the Attachment Table                               *
         * ----------------------------------------------------- */
         do_attachment_table:
         att = 1
         tbl_mode = 1
         if zipset <> "Never" then
            zipset = "Yes"
         att_sel = 0
         tblname = "XMITFILE"
         "TBOpen" tblname "Write Library(ISPProf)"
         if rc = 0 then do
            "TBQuery" tblname "Names(names) Rownum(rows)"
            parse value names with "(" names ")"
            if wordpos("AFORMAT",names) = 0 then do
               oldtbl = tblname
               tblname = "XMITFNEW"
               call build_attachment_table
               "TBTop" oldtbl
               "TBDelete" tblname
               do i = 1 to rows
                  "TBSkip" oldtbl
                  if pos("/",adesc) > 0 then
                     parse value adesc with afile "/" adesc
                  "TBadd" tblname
                  end
               "TBend" oldtbl
               "TBSave" tblname "Library(ISPProf) Name(XMITFILE)"
               "TBEND" tblname
               tblname = "XMITFILE"
               "TBOpen" tblname "Write Library(ISPProf)"
               smsg = null
               lmsg = "Info: Your File attachment table ",
                         "has been converted to the new format.",
                         "Some old information may have been lost",
                         "in the conversion."
               "setmsg msg(xmit001)"
            end
            if wordpos("ACT",names) = 0 then do
               oldtbl = tblname
               tblname = "XMITFNEW"
               call build_attachment_table
               "TBTop" oldtbl
               do i = 1 to rows
                  "TBSkip" oldtbl
                  "TBadd" tblname
                  end
               "TBend" oldtbl
               "TBSave" tblname "Library(ISPProf) Name(XMITFILE)"
               "TBEND" tblname
               tblname = "XMITFILE"
               "TBOpen" tblname "Write Library(ISPProf)"
               smsg = null
               lmsg = "Info: Your File attachment table ",
                         "has been converted to the new format.",
                         "Some old information may have been lost",
                         "in the conversion."
               "setmsg msg(xmit001)"
            end
         end
         if rc = 8 then call build_attachment_table
            mult_sels = 0
            crp = 1
            rowcrp = 1
            src    = 0
            adsn   = null
            if metric = "I" then measure = "Inches"
                            else measure = "Centimeters"
            do forever
               xmtrfind = "PASSTHRU"
               zsel = null
               "Vput xmtrfind"
               if mult_sels = 0 then do
                 "TBTop" tblname
                 "TBSkip" tblname "Number("crp")"
                 if adsn <> null then csr = "zsel"
                                 else csr = "adsn"
                 if rowcrp = 0 then
                    "TBDispl" tblname "Panel(xmitipfi)",
                       "Position(rowcrp)"
                 else
                    "TBDispl" tblname "Panel(xmitipfi)" ,
                            "Cursor("csr") AutoSel(No)" ,
                            "Position(rowcrp)"
                 end
               else
                 "TBDispl" tblname "csrrow("rowcrp")" ,
                           "Position(rowcrp) cursor(adsn)"
               t_rc = rc
               mult_sels = ztdsels
               xmtrfind = ''
               "vput xmtrfind"
               if t_rc > 7 & att_sel > 0 then leave
               if t_rc > 7 then
                  if att_sel = 0 then do
                     smsg = null
                     lmsg = "Error: No files were selected for ",
                               "attachment.  Select at least one file",
                               "or use the Cancel command."
                     "setmsg msg(xmit001)"
                     zcmd = null
                     end
               select
               when abbrev("CANCEL",zcmd,3) = 1 then do
                    "TBEnd" tblname
                    tbl_mode = null
                    signal display
                    end
               when zcmd = "CLEAR" then do
                    "TBEnd" tblname
                    "TBErase" tblname "Library(ISPProf)"
                    call build_attachment_table
                    zcmd = null
                    mult_sels = 0
                    crp = 1
                    rowcrp = 1
                    src    = 0
                    end
               When words(zcmd) > 1 then do
                    parse value zcmd with o1 o2
                    if abbrev("FIND",o1,1) = 1 then call do_find
                    end
               When abbrev("INSERT",zcmd,1) = 1 then do
                    "TBbottom" tblname
                    "TBVClear" tblname
                    "TBadd" tblname
                    "TBQuery" tblname "rownum(rowcrp)"
                    crp = rowcrp
                    end
               When zcmd = "RFIND" then do
                    zcmd = "RFIND" o2
                    call  do_find
                    end
               When zsel = "I" then do
                    zsel = null
                    act  = null
                    "TBadd" tblname
                    rowcrp = rowcrp + 1
                    crp    = rowcrp
                    end
               When zsel = "S" then do
                    zsel = null
                    call test_gdg  adsn
                    if file_dsn = adsn then
                       call test_file adsn
                    act  = "Y"
                    att_sel = att_sel + 1
                    if left(aformat,1) = "?" then do
                       "Control Display Save"
                       call fix_format aformat
                       "Control Display Restore"
                       if new_format <> null then do
                          aformat = new_format
                          aleft   = left
                          aright  = right
                          atop    = top
                          abottom = bottom
                          end
                       end
                    if words(adesc) > 1 then do
                       act = null
                       att_sel = att_sel - 1
                       smsg = "Error"
                       lmsg = "Error: File Description may not" ,
                              "contain blanks."
                       "Setmsg msg(xmit001)"
                       end
                    if length(apindex) > 0 then do
                       call test_pdfidx apindex
                       if erc > 0 then
                          act  = null
                       end
                    if aformat <> null then do
                       call test_format aformat
                       if erc > 0 then do
                          act = null
                          att_sel = att_sel - 1
                          end
                       end
                    "TBPut" tblname
                    end
               When zsel = "U" then do
                    zsel = null
                    act  = null
                    att_sel = att_sel - 1
                    "TBPut" tblname
                    end
               When zsel = "D" then do
                    zsel = null
                    if act <> null then
                       att_sel = att_sel - 1
                    "TBDelete" tblname
                    end
               When zsel = null then do
                    if left(aformat,1) = "?" then do
                       "Control Display Save"
                       call fix_format aformat
                       "Control Display Restore"
                       if new_format <> null then do
                          aformat = new_format
                          aleft   = left
                          aright  = right
                          atop    = top
                          abottom = bottom
                          end
                       end
                    if words(adesc) > 1 then do
                       smsg = "Information"
                       lmsg = "Description contains more than" ,
                                 "1 word. Dashes (-) inserted."
                       "Setmsg msg(xmit001)"
                       adesc = translate(adesc,"-"," ")
                       end
                     if aformat <> null then do
                        call test_format aformat
                        if erc > 0 then do
                           act = null
                           att_sel = att_sel - 1
                           end
                        end
                     if length(apindex) > 0 then
                         call test_pdfidx apindex
                     "TBPut" tblname
                    end
               Otherwise do
                         if zsel <> null then
                            m_type = "Invalid Selection" zsel
                         if zcmd <> null then
                            m_type =  "Invalid Command" zcmd
                         smsg = "Error"
                         lmsg = "An" m_type "was entered."
                         "Setmsg Msg(xmit001)"
                         end
               end
            end
            att = 0
            return

          /* ----------------------------------------------------- *
           * Build the file attachment table                       *
           * ----------------------------------------------------- */
           build_attachment_table:
            "TBCreate" tblname ,
                      "names(act adsn afile aformat aleft aright",
                            "atop abottom adesc apindex) replace"
            "TBSort"   tblname "Fields(adsn)"
            "TBVClear" tblname
            "TBadd"    tblname
            return

        /* ----------------------------------------------------- *
         * Process Address                                       *
         * ----------------------------------------------------- */
        Process_Address: Procedure Expose t_names. t_addrs parens ,
                                   atsign zerralrm null
        parse arg address
        /* ----------------------------------------------------- *
         * Remove any wrapping parens                            */
         if left(address,1) = "(" then do
            parse value address with "(" address
            if right(address,1) = ")" then
               parse value address with address ")"
            end
         address = strip(address)
         address = translate(address,' ',',')

        /* ----------------------------------------------------- *
         * Test for parenthesis                                  */
          parens = 0
          if pos("(",address) > 1 then parens = 1
          if pos(")",address) > 1 then parens = 1
          if parens = 1 then do
             smsg = "Error"
             lmsg = "Invalid Address - includes '(' or ')' :" ,
                        address
             Address ISPExec,
                     "Setmsg msg(xmit001)"
             return
             end

        /* ----------------------------------------------------- *
         * set up our variables                                  */
         t_addrs   = null
         t_names.  = null
         t_names.0 = 0
         tn = 0

        /* ----------------------------------------------------- *
         * Now process thru the provided address                 *
         * ----------------------------------------------------- */
        do until length(address) = 0
              Select
                /* -------------------------------------------------- *
                 * No name just an address in <>                      *
                 * e.g. <first.last@address>                          */
                when left(address,1) = '<' then do
                     tn = tn + 1
                     parse value address with "<" addr ">" address
                     t_addrs = t_addrs addr
                     address = strip(address)
                     end
                /* -------------------------------------------------- *
                 * quoted address                                     *
                 * e.g. "first last"@address                          *
                 * note: replace blanks with x'01' for now            */
                when pos('"'atsign,address) > 0 then do
                     parse value address with '"'addr'"'addrh address
                     addr = translate(addr,x2c("01"),' ')
                     t_addrs = t_addrs '"'addr'"'addrh
                     address = strip(address)
                     end
                /* -------------------------------------------------- *
                 * double quotes                                      *
                 * e.g. "first last" <first.last@address>             */
                when left(address,1) = '"' then do
                     right = pos(">",address)
                     if right = 0 then
                        if pos("<",address) > 1
                          then do
                               address = address">"
                               right = pos(">",address)
                               end
                          else right = length(address)
                     data = left(address,right)
                     x = length(address)
                     address = substr(address,right+1)
                     address = strip(address)
                     tn = tn + 1
                     parse value data with '"' t_names.tn '"' .
                     parse value data with . "<" addr ">" .
                     t_addrs = t_addrs addr
                     end
                /* -------------------------------------------------- *
                 * single quotes                                      *
                 * e.g. 'first last' <first.last@address>             */
                when left(address,1) = "'" then do
                     right = pos(">",address)
                     if right = 0 then
                        if pos("<",address) > 1
                          then do
                               address = address">"
                               right = pos(">",address)
                               end
                          else right = length(address)
                     data = left(address,right)
                     address = substr(address,right+1)
                     address = strip(address)
                     tn = tn + 1
                     parse value data with "'" t_names.tn "'" .
                     parse value data with . "<" addr ">" .
                     t_addrs = t_addrs addr
                     end
                /* -------------------------------------------------- *
                 * Only 1 word so must be an address                  */
                when words(address) = 1 then do
                     tn = tn + 1
                     t_addrs = t_addrs address
                     address = null
                     end
                /* -------------------------------------------------- *
                 * Only 1 word so must be an address                  */
                when pos(">",address) = 0 then do
                     tn = tn + 1
                     t_addrs = t_addrs address
                     address = null
                     end
                /* -------------------------------------------------- *
                 * otherwise assume name with no quotes               *
                 * e.g. first last <first.last@address>               */
                otherwise do
                     right = pos(">",address)
                     data = left(address,right)
                     address = substr(address,right+1)
                     address = strip(address)
                     tn = tn + 1
                     parse value data with t_names.tn "<" .
                     parse value data with . "<" addr ">" .
                     t_addrs = t_addrs addr
                     end
                end
              end
              t_names.0 = tn
              return

        /* --------------------------------------------------------- *
         * Process Selected Attachments                              *
         * Option 1: normal     Option 2: hfs files                  *
         * --------------------------------------------------------- */
        Get_Attachments:
         arg gaopt
         "TBTop" tblname
         do forever
          skip = 0
           "TBskip" tblname
           if rc > 7 then leave
           if act = null then iterate
           if adsn = null then do
              skip = 1
              "TBDelete" tblname
              end
           if skip = 1 then iterate
           if gaopt = 1 then if pos("/",adsn) > 0 then iterate
           if gaopt = 2 then if pos("/",adsn) = 0 then iterate
           if pos("/",adsn) > 0 then
              c_fileo = c_fileo adsn
           else c_file = c_file adsn
           act = null
           "TBPUT" tblname
           form_over = 1
           if afile <> null then do
              if pos(" ",afile) > 0 then do
                 x_afile = translate(afile,x2c("01"),' ')
                 x_afile = "'"x_afile"'"
                 end
              else x_afile = afile
              c_filename = strip(c_filename x_afile)
              end
           else c_filename = strip(c_filename) "x"
           if adesc <> null
              then c_filedesc = strip(c_filedesc) adesc
              else c_filedesc = strip(c_filedesc) "x"
           if aformat <> null
              then c_format = strip(c_format) aformat
              else c_format = strip(c_format) "x"
           if apindex <> null then do
              laf = translate(left(aformat,3))
              if pos(laf,"PDF ZIPPDF") = 0
                 then apindex = null
              end
           if apindex <> null
              then c_pindex = strip(c_pindex) apindex
              else c_pindex = strip(c_pindex) "x"
           if strip(aleft""aright""atop""abottom) <> null
              then c_margin = strip(c_margin) ,
                   aleft"/"aright"/"atop"/"abottom
              else c_margin = strip(c_margin) "/"
         end
         return

        /* ----------------------------------------------------- *
         * FORMAT statement Prompt Routine                       *
         * ----------------------------------------------------- */
         Fix_Format:
         parse arg fixfmt
         Parse value "" with ft tsuf fb bsuf fh hcolor hsuf,
                             fr rlayout rfont rpaper rsuf rop ,
                             fz znia fbz bznia fhz hznia  ,
                             frz rznia zlayout zfont zpaper zrop ,
                             fp playout pfont plpi ppaper psec ,
                             fpz pznia pzlayout pzfont pzlpi pzpaper ,
                             fzz t2pconf t2rconf ,
                             new_format hfsize hban pzsec ,
                             fc fg fx fcz fgz fxz fic ,
                             fmt1 fmt2 fmt3 fmt4 fmt5 fmt6 fmt7 fmt8 fmt9 ,
                             aleft aright atop abottom ,
                             htbl hhead hwrap hsemi
         fixfmt = substr(fixfmt,2)
         "AddPop"
         if fixfmt <> null then do
            parse value fixfmt with fmt1 "/" fmt2 "/" fmt3 "/" ,
                                    fmt4 "/" fmt5 "/" fmt6 "/" ,
                                    fmt7 "/" fmt8 "/" fmt9
             fmt1l = strip(fmt1)
             fmt1 = Translate(fmt1l)
             fmt2 = strip(fmt2)
             fmt3 = strip(fmt3)
             fmt4 = strip(fmt4)
             fmt5 = strip(fmt5)
             fmt6 = strip(fmt6)
             fmt7 = strip(fmt7)
             fmt8 = strip(fmt8)
             fmt9 = strip(fmt9)
             Select
               When fmt1 = "BIN" then do
                    bznia = fmt2
                    fb    = 1
                    end
               When left(fmt1,3) = "HTM" then do
                    hcolor = fmt2
                    if hcolor <> null then
                       parse value hcolor with bcolor"-"tcolor
                    hsuf   = fmt3
                    hfsize = fmt4
                    hban   = fmt5
                    if translate(left(fmt6,1)) = "Y"
                       then htbl   = fmt6
                    if translate(left(fmt7,1)) = "N"
                       then hhead  = fmt7
                    if translate(left(fmt8,1)) = "Y"
                       then hwrap  = fmt8
                    if translate(left(fmt9,1)) = "Y"
                       then hsemi  = fmt9
                    fh     = 1
                    end
               When fmt1 = "PDF" then do
                    playout = fmt2
                    pfont   = fmt3
                    ppaper  = fmt4
                    plpi    = fmt5
                    psec    = fmt6
                    fp      = 1
                    end
               When fmt1 = "RTF" then do
                    rlayout = fmt2
                    rfont   = fmt3
                    rpaper  = fmt4
                    rsuf    = fmt5
                    rop     = fmt6
                    fr      = 1
                    left    = aleft
                    right   = aright
                    top     = atop
                    bottom  = abottom
                    end
               When fmt1 = "ZIP" then do
                    znia = fmt2
                    fz   = 1
                    end
               When fmt1 = "ZIPBIN" then do
                    bznia = fmt2
                    fbz   = 1
                    end
               When fmt1 = "ZIPHTML" then do
                    hznia   = fmt2
                    hcolor  = fmt3
                    if hcolor <> null then
                       parse value hcolor with bcolor"-"tcolor
                    hfsize  = fmt4
                    hban    = fmt5
                    if translate(left(fmt6,1)) = "Y"
                       then htbl   = fmt6
                    if translate(left(fmt7,1)) = "N"
                       then hhead  = fmt7
                    if translate(left(fmt8,1)) = "Y"
                       then hwrap  = fmt8
                    if translate(left(fmt9,1)) = "Y"
                       then hsemi  = fmt9
                    fhz     = 1
                    end
               When fmt1 = "ZIPPDF" then do
                    pznia    = fmt2
                    pzlayout = fmt3
                    pzfont   = fmt4
                    pzpaper  = fmt5
                    pzlpi    = fmt6
                    pzsec    = fmt7
                    fpz      = 1
                    end
               When fmt1 = "ZIPRTF" then do
                    rznia  = fmt2
                    zlayout = fmt3
                    zfont   = fmt4
                    zpaper  = fmt5
                    zrop    = fmt6
                    frz     = 1
                    left    = aleft
                    right   = aright
                    top     = atop
                    bottom  = abottom
                    end
               Otherwise do
                         tsuf = fmt1l
                         fmt1 = null
                         end
               End
            End

          do forever
             if fmt1 = null then
             "Display Panel(xmitipfp)"
             if rc > 3 then leave

             if metric = "I" then measure = "Inches"
                             else measure = "Centimeters"

             if length(fh) > 0 then do
                "Display Panel(xmitipf1)"
                p_rc = rc
                if bcolor <> null then
                   bcolor = fix_color(bcolor)
                   if bcolor = null then bcolor = "White"
                if tcolor <> null then
                   tcolor = fix_color(tcolor)
                   if tcolor = null then tcolor = "Black"
                hcolor = bcolor"-"tcolor
                if t2hconf <> null then do
                   if sysdsn(t2hconf) <> "OK" then do
                      smsg = null
                      lmsg = "Invalid TXt2HTML Configuration"
                             "data set name specified" ,
                             sysdsn(t2hconf)
                      "Setmsg msg(xmit001)"
                     fp = null
                     end
                     end
                if p_rc > 3 then leave
                end

             if length(fp) > 0 then do
                "Display Panel(xmitipf2)"
                if rc > 3 then leave
                if pfont = null then pfont = 9
                if translate(right(pfont,1)) = "B" then
                   t_font = left(pfont,length(pfont)-1)
                else t_font = pfont
                if datatype(t_font) <> "NUM" then do
                   smsg = null
                   lmsg = "Invalid Font Size Specified."
                   "Setmsg msg(xmit001)"
                   fp = null
                   end
                if t2pconf <> null then do
                   if sysdsn(t2pconf) <> "OK" then do
                      smsg = null
                      lmsg = "Invalid TXT2PDF Configuration"
                             "data set name specified" ,
                             sysdsn(t2pconf)
                      "Setmsg msg(xmit001)"
                     fp = null
                     end
                     end
                end

             if length(fr) > 0 then do
                "Display Panel(xmitipf3)"
                if rc > 3 then leave
                "Vput (left right top bottom t2rconf) Profile"
                if rfont = null then rfont = 9
                if datatype(rfont) <> "NUM" then do
                   smsg = null
                   lmsg = "Invalid Font Size Specified."
                   "Setmsg msg(xmit001)"
                   fr = null
                   end
                if t2rconf <> null then do
                   if sysdsn(t2rconf) <> "OK" then do
                      smsg = null
                      lmsg = "Invalid TXT2RTF Configuration"
                             "data set name specified" ,
                             sysdsn(t2rconf)
                      "Setmsg msg(xmit001)"
                     fr = null
                     end
                     end
                end

             if length(fz) > 0 then do
                "Display Panel(xmitipf4)"
                if rc > 3 then leave
                end

             if length(fbz) > 0 then do
                "Display Panel(xmitipf5)"
                if rc > 3 then leave
                end

             if length(fhz) > 0 then do
                "Display Panel(xmitipf6)"
                if rc > 3 then leave
                if t2hconf <> null then
                   if sysdsn(t2hconf) <> "OK" then do
                      smsg = null
                      lmsg = "Invalid TXt2HTML Configuration" ,
                             "data set name specified" ,
                             sysdsn(t2hconf)
                      "Setmsg msg(xmit001)"
                     fpz = null
                     end
                end

             if length(fpz) > 0 then do
                "Display Panel(xmitipf7)"
                if rc > 3 then leave
                if pzfont = null then pzfont = 9
                if translate(right(pzfont,1)) = "B" then
                   t_font = left(pzfont,length(pzfont)-1)
                else t_font = pzfont
                if datatype(t_font) <> "NUM" then do
                   smsg = null
                   lmsg = "Invalid Font Size Specified."
                   "Setmsg msg(xmit001)"
                   fpz = null
                   end
                if t2pconf <> null then
                   if sysdsn(t2pconf) <> "OK" then do
                      smsg = null
                      lmsg = "Invalid TXT2PDF Configuration" ,
                             "data set name specified" ,
                             sysdsn(t2pconf)
                      "Setmsg msg(xmit001)"
                     fpz = null
                     end
                end

             if length(frz) > 0 then do
                "Display Panel(xmitipf8)"
                if rc > 3 then leave
                if zfont = null then zfont = 9
                if datatype(zfont) <> "NUM" then do
                   smsg = null
                   lmsg = "Invalid Font Size Specified."
                   "Setmsg msg(xmit001)"
                   frz = null
                   end
                if t2rconf <> null then
                   if sysdsn(t2rconf) <> "OK" then do
                      smsg = null
                      lmsg = "Invalid TXT2RTF Configuration" ,
                             "data set name specified" ,
                             sysdsn(t2rconf)
                      "Setmsg msg(xmit001)"
                     frz = null
                     end
                end

             if length(fzz) > 0 then do
                "Display Panel(xmitipf9)"
                if rc > 3 then leave
                end

             if length(fic) > 0 then do
                fich = 0
                if tbl_mode = null
                   then if file = "*" then fich = 1
                if tbl_mode <> null
                   then if adsn = "*" then fich = 1
                if fich = 1 then do
                "RemPop"
                "Display Panel(xmitipcc)"
                "AddPop"
                e_rc = rc
                if e_rc > 3 then leave
                "Display Panel(xmitipcp)"
                if tbl_mode = null then do
                   file     = icalds
                   filename = icalfile
                   end
                else do
                     adsn  = icalds
                     afile = icalfile
                     end
                "Vput (icalds icalfile) Profile"
                call do_calendar
                end
                end

             t = strip(ft""fb""fh""fr""fz""fbz""fhz""frz""fp""fpz)
             t = strip(t""fc""fg""fx""fcz""fgz""fxz""fzz""fic)
             if length(t) > 0
                then leave
             end

          Select
            When fc <> null then
                 nfmt = "CSV"
            When fg <> null then
                 nfmt = "GIF"
            When ft <> null then
                 nfmt = "TXT"
            When fb <> null then
                 nfmt = "BIN"
            When fh <> null then
                 if t2hconf = null then
                 nfmt = "HTML/"hcolor"/html/"hfsize"/"hban ,
                        || "/"htbl"/"hhead"/"hwrap"/"hsemi
                 else
                 nfmt = "HTML/ds:"t2hconf
            When fic <> null then
                 nfmt = "ICAL"
            When fp <> null then
                 if t2pconf = null then
                 nfmt = "PDF/"playout"/"pfont"/"ppaper"/"plpi"/"psec
                 else
                 nfmt = "PDF/ds:"t2pconf
            When fr <> null then
                 if t2rconf = null then
                 nfmt = "RTF/"rlayout"/"rfont"/"rpaper"/"rsuf"/"rop
                 else
                 nfmt = "RTF/ds:"t2rconf
            When fx <> null then
                 nfmt = "XMIT"
            When fz <> null then
                 nfmt = "ZIP/"znia
            When fbz <> null then
                 nfmt = "ZIPBIN/"bznia
            When fcz <> null then
                 nfmt = "ZIPCSV"
            When fgz <> null then
                 nfmt = "ZIPGIF"
            When fxz <> null then
                 nfmt = "ZIPXMIT"
            When fhz <> null then do
                 if t2hconf = null then
                 nfmt = "ZIPHTML/"hznia"/"hcolor"/"hfsize"/"hban ,
                        || "/"htbl"/"hhead"/"hwrap"/"hsemi
                 else
                 nfmt = "ZIPHTML/"hznia"/ds:"t2hconf
                 end
            When fpz <> null then do
                 if t2pconf = null then do
                    nfmt = "ZIPPDF/"pznia
                    nfmt = nfmt"/"pzlayout"/"pzfont"/"pzpaper"/"pzlpi
                    if pzsec <> null then
                       nfmt = nfmt"/"pzsec
                    end
                 else
                    nfmt = "ZIPPDF/"pznia"/ds:"t2pconf
                 end
            When frz <> null then
                 if t2rconf = null then
                 nfmt = "ZIPRTF/"rznia"/"zlayout"/"zfont"/"zpaper"/"zrop
                 else
                    nfmt = "ZIPRTF/"rznia"/ds:"t2rconf
            When fzz <> null then
                 nfmt = "ZIPXMIT/"rznia
            otherwise nfmt = null
            end
            new_format = nfmt
            "RemPop"
          return

        /* ---------------------------------------------------------- *
         * Test Address routine.                                      *
         * If ldap is not 1 or 3 then perform a test of the e-mail    *
         * address against the provided ldap server using the xmitipid*
         * routine.                                                   *
         *                                                            *
         * If the routine returns 0 the address is ok                 *
         *                        4 the address is no good            *
         *                        8 the ldap server is not there      *
         * ---------------------------------------------------------- */
         Test_Address: Procedure Expose ldap check_addrs batch_idval null
         if ldap = 1 then return 0
         if ldap = 3 then return 0
         if batch_idval = 1 then return
         arg address
         if pos("<",address) > 0 then
            parse value address with . "<" address ">" .
         if pos(address,check_addrs) > 0 then return 0
           else check_addrs = strip(check_addrs address)
         x_rc = xmitipid(address)
         if x_rc = 0 then return 0
         if x_rc = 4 then return 4
         if x_rc = 8 then ldap = 1
         return 8

        /* --------------------------------------------------------- *
         * Process Load AddressFile Request                          *
         * --------------------------------------------------------- */
         Load_Address_File:
          call listdsi addrfile
          if sysreason+0 > 0 then do
             smsg = "Invalid DSN"
             lmsg = addrfile SYSMSGLVL1,
                       SYSMSGLVL2
             "Setmsg msg(xmit001)"
             end
          else do
               Address TSO
               "Alloc F(addralx) shr Ds("addrfile")"
               "Execio * diskr addralx (finis stem saddr."
               "Free  F(addralx)"
               Address ISPExec
               added = 0
               ltot  = 0
               do sc = 1 to saddr.0
                  if left(saddr.sc,1) = "*" then iterate
                  ename = null
                  if pos("<",saddr.sc) > 0 then do
                     if pos('"',saddr.sc) > 0 then
                        parse value saddr.sc with ,
                           lact '"'ename'"' "<"eaddr">" .
                     if pos("'",saddr.sc) > 0 then
                        parse value saddr.sc with ,
                           lact "'"ename"'" "<"eaddr">" .
                     end
                  else parse value saddr.sc with ,
                       lact eaddr .
                  eaddru = translate(eaddr)
                  if ename = null then call fix_name eaddr
                  ltot = ltot + 1
                  "TBAdd" tblname "Order"
                  if rc = 0 then added = added + 1
                  else do
                       slact = lact
                       "TBGet" tblname
                       lact = slact
                       "TBMod" tblname "Order"
                       end
                  if length(c_to) > 0 then do
                     call clean_addr_string c_to
                     c_to = string
                     end
                  if length(c_cc) > 0 then do
                     call clean_addr_string c_cc
                     c_cc = string
                     end
                  if length(c_bcc) > 0 then do
                     call clean_addr_string c_bcc
                     c_bcc = string
                     end
                  Select
                  When translate(lact) = "TO" then do
                       if ename <> null then
                          c_to = strip(c_to '"'ename'" <'eaddr'>')
                       else
                          c_to = strip(c_to eaddr)
                       end
                  When translate(lact) = "CC" then do
                       if ename <> null then
                          c_cc = strip(c_cc '"'ename'" <'eaddr'>')
                       else
                          c_cc = strip(c_cc eaddr)
                       end
                  When translate(lact) = "BCC" then do
                       c_bcc = strip(c_bcc eaddr)
                       end
                  otherwise nop
                  end
                  end
               smsg = added "of" ltot "added.",
                        ltot "flagged."
               lmsg = "AddressFile" addrfile ,
                         "added to Address Table." ,
                         added "entries added out of",
                         ltot"." ltot "entries flagged."
                         "And the AddressFile",
                         "variable has been cleared."
               "Setmsg msg(xmit001)"
               addrfile = null
               "Vput (addrfile) Profile"
               end
          return

        /* --------------------------------------------------------- *
         * Test for AddressFile type                                 *
         * --------------------------------------------------------- */
         Test_Atype:
           if atype <> null then at = 1
                            else at = 0
           return

        /* ----------------------------------------------------- *
         * Save and close the address table                      *
         * ----------------------------------------------------- */
         Close_Addr:
          "TBSave  xmitaddr Library(ISPPROF)"
          "TBClose xmitaddr Library(ISPPROF)"
          return

        /* ------------------------------- *
         * Generate the Configuration File *
         * ------------------------------- */
         Do_Config:
           drop cmdo.
           cmdc = 1
           cmdo.cmdc = "* Configuration file created on" date() ,
                       "at" time()
           cmdc = cmdc + 1
           cmdo.cmdc = "* You should review and tailor before use"
           do i = config_start to cmd.0-1
              cmdc = cmdc + 1
              cmdo.cmdc = cmd.i
              end
           cmdo.0 = cmdc
           wdd = "cf"random(9999)
           "Alloc f("wdd") ds("configds") shr"
           "Execio * diskw" wdd "(finis stem cmdo."
           "Free  f("wdd")"
           drop cmdo. cmdc
           Address ISPExec "Browse Dataset("configds")"
           return

        /* --------------------------------------------------------- *
         * Generate Batch JCL and Control statements                 *
         * Then prompt the user to Browse, Edit, Copy, or Submit     *
         * --------------------------------------------------------- */
         Do_Batch: Procedure expose cmd cmd. null zerralrm ver ,
                                    batch_mode systcpd default_hlq

         parse source x y xcmd dd .
         call get_dsn dd xcmd
         xdsn = return_dsn

         jcupdate = null

         Address ISPExec "QLibdef ISPLLIB Type(type) Id(id)"
         if rc > 0 then do
            call get_dsn "ISPLLIB" "T2PINIT"
            ldsn = return_dsn
            end
         else do
              if type = "DATASET" then
                 ldsn = translate(id," ","',")
                 else do
                      call get_dsn id "T2PINIT"
                      ldsn = return_dsn
                      end
              end

            Address ISPExec
            call do_jobcard

            head  = "XMITIP E-Mail JCL generated:" ,
                     date()
            trail = "XMITIP Version" ver
            batch_cmd = null

            jcl.1 = xjc1
            jcl.2 = xjc2
            jcl.3 = xjc3
            jcl.4 = xjc4
            jcl.5 = "//*----------------------------------------------*"
            jcl.6 = "//*" left(head,44) "*"
            jcl.7 = "//* Statements 1-4 are reserved for the JOB Card *"
            jcl.8 = "//* Verify all dsnames in the command if not     *"
            jcl.9 = "//* running under the generating userid.         *"
            jcl.10 = "//*                                              *"
            jcl.11 = "//*" left(trail,44) "*"
            jcl.12 = "//*----------------------------------------------*"
            jcl.13 = "//XMITIP  EXEC PGM=IKJEFT1B,DYNAMNBR=50"
            jc = 13
            if ldsn <> null then do
               do li = 1 to words(ldsn)
                  jc = jc + 1
                  ldsnx = word(ldsn,li)
                  if li = 1
                     then jcl.jc = "//STEPLIB  DD DISP=SHR,DSN="ldsnx
                     else jcl.jc = "//         DD DISP=SHR,DSN="ldsnx
                  end
               end
            if systcpd <> null then do
               jc = jc + 1
               jcl.jc = "//SYSTCPD  DD DISP=SHR,DSN="systcpd
               end
            jc = jc + 1
            jcl.jc = "//SYSEXEC  DD DISP=SHR,DSN="xdsn
            jc = jc + 1
            jcl.jc = "//SYSPRINT DD  SYSOUT=*"
            jc = jc + 1
            jcl.jc = "//SYSTSPRT DD  SYSOUT=*"
            jc = jc + 1
            jcl.jc = "//SYSTSIN DD   *"
            jcnt = jc

            do i = 2 to cmd.0 -1
               jcnt = jcnt + 1
               jcl.jcnt = cmd.i
               parse value cmd.i with exc "+"
               batch_cmd = strip(batch_cmd) exc
               end

            jcnt = jcnt + 1
            jcl.jcnt = "/*"

            Select
               When default_hlq <> null
                  then hlq = default_hlq"."
               When sysvar("syspref") = null
                  then hlq = sysvar("sysuid")"."
               When sysvar("syspref") <> sysvar("sysuid")
                  then hlq = sysvar("syspref")"."sysvar("sysuid")"."
               Otherwise hlq = sysvar("sysuid")"."
               end

            jcldd = "xmitjc"random(99)

            sysname = mvsvar("sysname")
            if sysname = null then sysname = 'zos'
            if datatype(left(sysname,1)) = "NUM" ,
               then sysqual = strip("S"left(sysname,7))"."
               else sysqual = sysname"."
            xmitjcl = "'"hlq""sysqual"xmitip.jcl'"

            call build_jcl xmitjcl

            batch_mode = 1

            do forever
               zcmd = null
               "Display Panel(xmitipgs)"
               if rc > 3 then leave
               Select
                 When left(zcmd,1) = "B" then do
                      "Control Display Save"
                      "Browse Dataset("xmitjcl")"
                      "Control Display Restore"
                      smsg = "Browse Complete"
                      lmsg = "Browse of the Job and XMITIP" ,
                             "complete."
                      "Setmsg msg(xmit001)"
                      end
                 When left(zcmd,1) = "E" then do
                      "Control Display Save"
                      "Edit Dataset("xmitjcl")"
                      "Control Display Restore"
                      Address TSO
                      wdd = "cf"random(9999)
                      "Alloc f("wdd") shr ds("xmitjcl")"
                      "Execio * diskr" wdd "(finis stem jcl."
                      "Free  f("wdd")"
                      xjc1 = jcl.1
                      xjc2 = jcl.2
                      xjc3 = jcl.3
                      xjc4 = jcl.4
                      hitx = 0
                      batch_cmd = null
                      do ex = 1 to jcl.0
                         if word(jcl.ex,1) = "//SYSTSIN" then hitx = 1
                         if word(jcl.ex,1) = "//SYSTSIN" then iterate
                         if word(jcl.ex,1) = "/*" then hitx = 0
                         if hitx = 0 then iterate
                         parse value jcl.ex with exc "+"
                         batch_cmd = strip(batch_cmd) exc
                         end
                      Address ISPExec
                      "Vput (xjc1 xjc2 xjc3 xjc4) Profile"
                      smsg = "Edit Complete"
                      lmsg = "Edit complete and job card variables" ,
                                "updated if changed."
                      "Setmsg msg(xmit001)"
                      end
                 When left(zcmd,1) = "C" then do
                      call copy_jcl
                      smsg = "Complete"
                      lmsg = "Copy Operation Completed."
                      "Setmsg msg(xmit001)"
                      end
                 When left(zcmd,1) = "J" then do
                      call do_jobcard2
                      call build_jcl xmitjcl
                      smsg = "Complete"
                      lmsg = "Job Statement Updated or Reviewed."
                      "Setmsg msg(xmit001)"
                      end
                 When left(zcmd,1) = "S" then do
                      Address TSO "Submit" xmitjcl
                      smsg = "Job Submitted"
                      parse value xjc1 with "//"jobname .
                      lmsg = "Job" jobname "has been submitted for execution."
                      "Setmsg msg(xmit001)"
                      end
                 When left(zcmd,1) = "X" then do
                      cmd = batch_cmd
                      batch_mode = 0
                      return
                      end
                 Otherwise nop
                 end
               end

            Address TSO
            call msg "off"
            "Delete" xmitjcl
            return

        /* --------------------------------------------------------- *
         * Copy the Generated JCL to a target Data Set               *
         *      - test for target d/s exist                          *
         * --------------------------------------------------------- */
         Copy_JCL: Procedure expose xmitjcl jcl. null zerralrm
           do forever
              "Display Panel(xmitipgc)"
              if rc > 3 then return
              Address TSO
              indd  = "xmiti"random(99)
              outdd = "xmito"random(99)
              dsn_rc = 1
              mem    = null
              if pos("(",xmit2jcl) > 0 then do
                 if sysdsn(xmit2jcl) = "OK"
                    then dsn_rc = 0
                 if sysdsn(xmit2jcl) = "MEMBER NOT FOUND"
                    then dsn_rc = 0
                 parse value xmit2jcl with xmit2ds"("mem")" q
                 if q = "'" then xmit2ds = xmit2ds"'"
                 end
              else do
                   if sysdsn(xmit2jcl) = "OK"
                      then dsn_rc = 0
                   xmit2ds = xmit2jcl
                   end
              if dsn_rc = 1 then do
                 outdd = "xmitc"random(99)
                 "Alloc f("outdd") new spa(1,1) tr recfm(f b) lrecl(80)" ,
                    "blksize(6160) ds("xmit2jcl")"
                 end
              else do
                   "Alloc f("outdd") ds("xmit2jcl") shr reuse"
                   end
              "Alloc f("indd") ds("xmitjcl") shr reuse"
              "Execio * diskw" outdd "(finis stem jcl."
              "Free  f("outdd indd")"
              Address ISPExec
              smsg = "Copied"
              lmsg = xmitjcl "copied to" xmit2jcl
              "Setmsg msg(xmit001)"
              if mem <> null then do
                 "lminit dataid(memid) dataset("xmit2ds")"
                 "lmopen dataid("memid")"
                 uid = sysvar("sysuid")
                 "lmmstats dataid("memid") member("mem") user("uid")"
                 "lmclose dataid("memid")"
                 "lmfree  dataid("memid")"
                 end
              end
           return

        /* --------------------------------------------------------- *
         * Build the JCL Data Set                                    *
         * --------------------------------------------------------- */
        Build_JCL:
           Address TSO
           call msg "off"
           "Delete" xmitjcl
           "Alloc f("jcldd") ds("xmitjcl") new spa(5,5) Tr",
              "recfm(f b) lrecl(80) blksize(6160)"
           "Execio * diskw" jcldd "(finis stem jcl."
           "Free f("jcldd")"
           Address ISPExec
           return

        /* --------------------------------------------------------- *
         * Ask for and update job statements                         *
         * --------------------------------------------------------- */
         do_jobcard2:
            jcupdate = 1
         do_jobcard:
            "Vget (xjc1 xjc2 xjc3 xjc4) Profile"
           if length(xjc1) = 0 then xjc1 = "//*"
           parse value xjc1 with "//"jname jrest
           sjname = left(jname,length(jname)-1)
           if sjname = sysvar("sysuid") then do
              call get_jobid
              jname = sjname""jobsuf
              xjc1 = "//"jname jrest
              end
            if strip(xjc1) = "//*" then do
               call get_jobid
               xjc1 = "//"sysvar("sysuid")""jobsuf "....."
               jcupdate = 1
               end
            if jcupdate = 1 then do
               zxjc1 = xjc1
               zxjc2 = xjc2
               zxjc3 = xjc3
               zxjc4 = xjc4
               xrc = 0
               do until xrc = 1
                  zcmd = null
                  "Display Panel(xmitipgj)"
                  if abbrev("CANCEL",zcmd,3) = 1 then return
                  if rc > 3 then do
                     xjc1 = strip(zxjc1)
                     xjc2 = strip(zxjc2)
                     xjc3 = strip(zxjc3)
                     xjc4 = strip(zxjc4)
                     if xjc1 = null then xjc1 = "//* "
                     if xjc2 = null then xjc2 = "//* "
                     if xjc3 = null then xjc3 = "//* "
                     if xjc4 = null then xjc4 = "//* "
                     "Vput (xjc1 xjc2 xjc3 xjc4) Profile"
                     jcl.1 = xjc1
                     jcl.2 = xjc2
                     jcl.3 = xjc3
                     jcl.4 = xjc4
                     xrc = 1
                     end
                  end
               end
               return

        /* -------------------------- *
         * Get a unique jobid by      *
         * bumping the last char      *
         * -------------------------- */
         Get_JobID:
         Address ISPExec ,
             "VGET (JOBSUF) PROFILE"
         if length(jobsuf) = 0 then jobsuf = "A"
            else
            jobsuf = translate(jobsuf, ,
                      'BCDEFGHIJKLMNOPQRSTUVWXYZ0123456789A', ,
                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')
         Address ISPExec ,
            "VPUT (JOBSUF) PROFILE"
         return

        /* --------------------------------------------------------- *
         * Test for a Valid Format                                   *
         * --------------------------------------------------------- */
         Test_Format: procedure expose erc null
           parse arg format
           parse value format with fmt "/" .
           tfmt = translate(strip(fmt))
           if left(tfmt,1) = "*" then
              tfmt = substr(tfmt,2)
           list = "TXT RTF HTML PDF BIN ZIP ZIPBIN ZIPRTF" ,
                  "ZIPPDF ZIPHTML CSV GIF XMIT ZIPCSV ZIPGIF",
                  "ZIPXMIT ICAL XLS XLSX"
           if wordpos(tfmt,list) = 0 then
              call bad_format
           else erc = 0
           return

        /* --------------------------------------------------------- *
         * Test for Format HTML and fixup color (if any)             *
         * --------------------------------------------------------- */
         Test_Color:
         if pos("ZIPHTM",translate(format)) > 0 then do
            parse var format a "/" b "/" color "/" c
            if translate(left(color,3)) = "DS:" then return
            if translate(left(color,3)) = "DD:" then return
            color = translate(color)
            if pos("-",color) > 0 then do
               parse var color colorl"-"colorr
               colorl = fix_color(colorl)
               if colorl = null then colorl = "White"
               colorr = fix_color(colorr)
               if colorr = null then colorr = "Black"
               color = colorl"-"colorr
               end
            else color = fix_color(color)
            format = strip(a)"/"strip(b)"/"strip(color)"/"strip(c)
            end
         else if pos("HTM",translate(format)) > 0 then do
            parse var format a "/" color "/" c
            if translate(left(color,3)) = "DS:" then return
            if translate(left(color,3)) = "DD:" then return
            color = translate(color)
            if pos("-",color) > 0 then do
               parse var color colorl"-"colorr
               colorl = fix_color(colorl)
               if colorl = null then colorl = "White"
               colorr = fix_color(colorr)
               if colorr = null then colorr = "Black"
               color = colorl"-"colorr
               end
            else color = fix_color(color)
            format = strip(a)"/"strip(color)"/"strip(c)
            end
          return

        /* ----------------------------- *
         * Validate the PDF Index value. *
         * ----------------------------- */
         Test_PDFIDX: Procedure Expose erc null
         arg idx
         erc = 0
         parse var idx row"/"col"/"len
         if datatype(row) <> "NUM" then erc = 4
         if datatype(col) <> "NUM" then erc = 4
         if datatype(len) <> "NUM" then erc = 4
         if erc = 4 then do
            smsg = "Error"
            lmsg = "The PDF Index of" idx ,
                   "contains a non-numeric value in",
                   "a numeric field. The correct syntax",
                   "is: row/column/length"
              "Setmsg msg(xmit001)"
            end
         return

        /* --------------------------------------------------------- *
         * Fixup the specified Color(s)                              *
         * --------------------------------------------------------- */
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
                        "AddPop"
                        "Display Panel(xmitipph)"
                        newcolor = fix_color(newcolor)
                        "RemPop"
                        end
              end
            return newcolor

        /* --------------------------------------------------------- *
         * Bad Format Error Message                                  *
         * --------------------------------------------------------- */
         Bad_Format:
            smsg = "Format Error"
            lmsg = "Specified format of '"fmt"' is invalid as",
                      "it is not one of the valid formats:" list
            "Setmsg Msg(xmit001)"
            erc = 4
            return

        /* -------------------------------------------- *
         * Get Data Set Name for supplied DD and Member *
         * -------------------------------------------- */
         Get_DSN: Procedure Expose return_dsn null
         arg dd cmd
         return_dsn = null

         call outtrap 'trap.'
         "lista sta"
         call outtrap 'off'

         hit = 0
         cnt = 0
         tdd = null

         do i = 1 to trap.0
            if tdd = dd then hit = 1
            if hit = 1 then
               if tdd <> dd then leave
            if left(trap.i,2) = "--" then iterate
            if left(trap.i,1) <> " " then do
               dsn = word(trap.i,1)
               end
            else do
                 if left(trap.i,3) = "   " then do
                 if tdd <> dd then iterate
                 cnt = cnt + 1
                 dsn.cnt = tdd dsn
                 end
               else do
                    tdd = word(trap.i,1)
                    if tdd <> dd then iterate
                    cnt = cnt + 1
                    dsn.cnt = tdd dsn
                    end
               end
            end

         do i = 1 to cnt
            if "OK" = sysdsn("'"word(dsn.i,2)"("cmd")'") then do
               return_dsn = word(dsn.i,2)
               leave
               end
            end
         return

        /* ---------------------------- *
         * Process the iCalendar Prompt *
         * ---------------------------- */
         Do_Calendar:
         if icdur = 0 then ictype = "VTODO"
                      else ictype = "VEVENT"
         ical.1 = "BEGIN:VCALENDAR"
         ical.2 = "METHOD:Text"
         ical.3 = "VERSION:2.0"
         ical.4 = "PRODID:-//XMITIP" ver"//NONSGML zOS E-Mail//EN"
         ical.5 = "BEGIN:"ictype
         stamp_time = time('n')
         parse value stamp_time with hh":"mm":"ss
         stamp_time = right(hh+100,2)right(mm+100,2)"00"
         ical.6 = "DTSTAMP:"date('s')"T"stamp_time
         ical.7 = "SEQUENCE:0"
         icfrom = from
         if pos('"',icfrom) = 0 then do
            icfpos = pos(atsign,icfrom)
            icfrom = left(icfrom,icfpos-1)
            icfrom = translate(icfrom," ",".")
            end
         else do
              parse value icfrom with '"'icfrom'"'.
              end
         icfn = null
         do icx = 1 to words(icfrom)
            icw = word(icfrom,icx)
            if length(icw) > 1 then do
               parse value icw with icc 2 icr
               icfn = strip(icfn  translate(icc)""icr)
               end
            else icfn = strip(icfn  translate(icw)".")
            end
         ical.8 = "ORGANIZER;ROLE=CHAIR:"icfn
         if left(icdate,1) = "+" then do
             sicdate = substr(icdate,2)
             d      = date('b') + sicdate
             sicdate = date("s",d,"b")
            end
         else do
              parse value icdate with mm"/"dd"/"yy
              sicdate = "20"yy""right(mm+100,2)""right(dd+100,2)
              end
         ictm   = right(ictm+10000,4)"00"
         ical.9 = "DTSTART:"sicdate"T"ictm
         if datatype(right(icdur,1)) = "NUM" then
            icdur = icdur"M"
         ical.10 = "SUMMARY:"ictitle
         icalc = 10
         if ictype = "VEVENT" then do
            icalc = icalc + 1
            ical.icalc = "DURATION:PT"icdur
            end
         icalc = icalc + 1
         ical.icalc = "DESCRIPTION:"ictext1
         if ictext2 <> null then call add_ical ictext2
         if ictext3 <> null then call add_ical ictext3
         if ictext4 <> null then call add_ical ictext4
         if ictext5 <> null then call add_ical ictext5
         if ictext6 <> null then call add_ical ictext6
         if ictext7 <> null then call add_ical ictext7
         if ictext8 <> null then call add_ical ictext8
         if ictext9 <> null then call add_ical ictext9
         if ictexta <> null then call add_ical ictexta
         if ictextb <> null then call add_ical ictextb
         if icloc <> null then do
            icalc = icalc + 1
            ical.icalc = "LOCATION:"icloc
            end
         icalc = icalc + 1
         ical.icalc = "END:"ictype
         icalc = icalc + 1
         ical.icalc = "END:VCALENDAR"
         icalc = icalc + 1
         ical.icalc = " "
         Address TSO
         wtime  = right(time('s') + 10,2)
         eddd   = "XM"wtime""right(time('l'),4)
         "Alloc ds("icalds") new spa(1,1) tr",
            "Recfm(v b) lrecl(80)" ,
            "blksize(9004)",
            "Unit(sysallda) f("eddd")"
         "Execio * diskw" eddd "(finis stem ical."
         "Free f("eddd")"
         drop ical. eddd
         return

        /* ------------------------------------- *
         * Add the iCalendar Description records *
         * ------------------------------------- */
         Add_iCal: procedure expose icalc ical. null
           parse arg data
           icalc = icalc + 1
           ical.icalc = " "data
           return

        /* --------------------------------------- *
         * Test the existence of the OMVS data set *
         * --------------------------------------- */
         Test_OMVS: Procedure Expose msgds omvs_stat null
         path = msgds
         path = STRIP(path,,"'")
         omvs_stat = 0
         x = syscalls('ON')
         address syscall
         "lstat (path) st."
         x = syscalls('OFF')
         Address ISPExec
         if st.0 = 0 then do
            smsg = "Message DSN Error"
            lmsg = "OMVS File" path ,
                   "Invalid Path or file not found"
           "Setmsg Msg(xmit001)"
            omvs_stat = 4
            end
         Return

        /***************************************************************
        * Trap uninitialized variables                                 *
        ***************************************************************/
        Novalue:

        Say "Variable" condition("Description") "undefined in line" ,
             sigl":"
        Say sourceline(sigl)
        Say "Contact systems support about this error."
        Exit 16
