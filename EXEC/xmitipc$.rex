        /*%NOcomment ----------  rexx procedure  -------------------- */
       /* INFOZIP alias ZIP by XMITIP, other PKZIP                   */
       /* ISPF.ISPPROF(XMIT*) keep old definitions with ISPF panels  */
       /* Delete these members to have a fresh start if @ or Ö change*/
       /* Use SUBJECT with text: ZIN3: }{¦ $#@ !Å£Ö ja hipsu ' my¦s  */
       /* Avoid writing domain-part, let append_domain work if OK    */
       /* */
       /* http://www.tachyonsoft.com/cpindex.htm    iconv gives right value  */
       /* http://www.degraeve.com/reference/specialcharacters.php            */
/* http://tunes.org/wiki/html_20special_20characters_20and_20symbols.html */
       /* http://webdesign.about.com/library/bl_htmlcodes.htm                */
       /* http://www.htmlhelp.com/reference/html40/entities/latin1.html      */
       /* http://www.htmlhelp.com/reference/html40/entities/special.html     */
       /* */
       /* null equals no change in logic original XMIPIPCU logic     */
       /* Text within "...", numbers 0123456789 */
       /* */
       null = ""        /* fagu: XMITIP do parse later to "" */
       z_append_domain = "tieto.com"        /* change to "tieto.com" */
       z_smtp_domain = "tieto.com"          /* change to "tieto.com" */
       z_AtSign = "ÖÖ§ØÐ@à"              /* change first to your "Ö" */
       /*                ||||||+ France                                    */
       /*                |||||+-- USA, Spain, UK                           */
       /*                ||||+--- Iceland                                  */
       /*                |||+---- DENNOR                                   */
       /*                ||+----- AUSGER, Italy                            */
       /*                |+------ FINSWE                                   */
       /*                +------- Place here AtSign valid at your LPAR     */
       /*                ÖÖ§ØÐ@à                                           */
       /* hex            EEB8A74                                           */
       /* hex            CC50CC4                                           */
       z_batch_idval = null                 /* LDAP logic, (1),0...3 */
       z_center_ = "ESMVS1"                 /* NJE local(D) or remote*/
       z_smtp = "SMTP"                      /* SMTP or CP1047, CSSMTP*/
       z_writer = null                      /* local SMTP or CP1047  */
       z_sysout_class = "B"                 /* null to have "A"      */
       /* fagu: DEST=xxxx is NJENODE, SYSOUT=(B,xxxx) is writer      */
       /* fagu: writer is the SMTP started task at row 900++         */
       z_from_default = null                /* default is null       */
       z_check_send_from_use = "Y"          /* default is "N"        */
       /* if we have many JCL with From ...Ötieto.com >> ...Ökund.se */
       /* if only 1 DOMAIN need to be changed, update next           */
       z_addrdom_ = null                    /* null, _all_ is default*/
       /* TIETO.COM or IBM.COM or BMC.COM , with "NO" we exclude     */
       z_addrrew_ = null                    /* null, "YES" is default*/
       /* null or "YES", use "NO" to exclude one domain              */
       z_systcpd = "TCPTE.ZIN3.TCPZIN31.TCPPARM" /*ip.tcpip.data"    */
       z_systcpd_member = "TCPDATA"         /* PDS(TCPDATA)          */
       /* */
       /* eMail "Subject" has short form of coding:                  */
       /* =?charset?encoding?what-ever-text?=    , encoding= B or Q  */
       /* =?utf-8?B?77u/WklOMTogw6...?=                              */
       /* =?cp1252?Q?ZIN3: }{¦ $#@ !Å£Ö ja hipsu ' my¦s?=            */
       /* When CP1047 smtp relay is used, then                       */
       /*   =?utf-8?B?...?=  or =?cp1252?B?...?= or =?iso8859-       */
       /* When CP1143 smtp relay is used, then                       */
       /*   =?cp1252?Q?...?=                                         */
       /* When BASE64 is used for everything, then any CPxxxx        */
       /* eMail relay will work, and eMail client show OK            */
       /* Content-Type: text/html; charset=cp1252 or iso8859-1x      */
       /* Content-Transfer-Encoding: quoted-printable                */
       z_char = "cp1252"                    /* MIME CharSet "UTF-8"  */
       z_encoding_default = "WINDOWS-1252"
       /* MIME Con-Tr-Encoding  */
       /* "base64" with utf-8   */
       /* "quoted-printable"    */
       z_charuse = 1                        /* Character set use >=0 */
       /* EBCDIC(local_CodePage) to ASCII(cp1252) for attached       */
       /* files "z_charuse" most be 0. TXT, PDF, ZIP, BASE64 default */
       /* to IBM-1047, FINSWE is IBM-1143 incl !uro sign             */
       z_dateformat = "I"                   /* "U" "E" "I"           */
       z_cpdef = "01143"                    /* EBCDIC "01143" FINSWE */
       z_default_lang = "ENGLISH"           /* "ENGLISH", no FINSWE  */
       z_mailfmt = null                     /* PLAIN or HTML (def)   */
       z_env = null                         /* Disclamer logic       */
       z_disclm_dsn_p1 = null               /* "'HighLvl.lpar."      */
       z_disclm_dsn_p2 = null               /* ".disclaim'"          */
       z_empty_opt = 1                      /* Empty dsn option > 1  */
       z_faxcheck = "notes.faxgateway"      /* "some.faxgateway"     */
       z_feedback = "gustav.fagerholm@tieto.com"  /* only with ISPF  */
       z_From2Rep = null                    /* REPLYTO logic > 0 1   */
       z_metric = "c"                       /* Inches,Centim. > "c"  */
       z_size_limit = null                  /* eMail Size 9970000byte*/
       z_zip_available = "Y"                /* ZIP? Yes="Y"          */
       z_zip_type = "INFOZIP"               /* free=INFOZIP,ISV=PKZIP*/
       z_zip_load = null                    /* PKZIP, other STEP/LNK */
       /* ==> Should be found from LNKLST or STEPLIB                 */
       z_disable_antispoof = "Y"            /* AntiSpoof text in Mail*/
       /*                                                            */
       /* ---------------------------------------------------------- */
       /* Fagu: following rexx functions or programs need updates    */
       /* - XMITIPCU need changes that depend on LPAR and LEGACY     */
       /* - XMITZQEN CodePage for FIN, SWE, NOR, DEN, ICE,...        */
       /*            added to GER. Used in HTML, and sometimes XML.  */
       /*                                                            */
       /* ---------------------------------------------------------- */
       /* Fagu:                                                      */
       /* - XMITIPCU need changes that depend on LPAR and LEGACY     */
       /* - - XMITIP should be AS-IS, no local updates here|         */
       /*                                                            */
       /* - XMITZQEN cp1143 added, the cp1141 GER is default         */
       /* - - FIN = cp1143, SWE = cp1143 but cpXXXX my be used       */
       /* - - DEN = cp1142, NOR = cp1142 but cpXXXX my be used       */
       /* - - ICE = cp1149, ??? = cp1149 but cpXXXX my be used       */
       /* - - FRA = cp1147, ??? = cp1147 but cpXXXX my be used       */
       /*                                                            */
       /* SYSOUT=(B,CSSMTP),DEST=ESMVS1,RECFM=xx,LRECL=xx  ;TETL     */
       /* SYSOUT=(B,CP1047),DEST=ESMVS1,RECFM=xx,LRECL=xx  ;TETL     */
       /* SYSOUT=(B,SMTP),DEST=ESMVS1,RECFM=xx,LRECL=xx    ;TETL     */
       /*         |  |            |                                  */
       /*         |  |            +- LPAR sending to eMail server    */
       /*         |  +- Name the CSSMTP or SMTP listen to            */
       /*         + SYSOUT class for reader                          */
       /*                                                            */
       /* CodePage="IBM-1047" <> "ISO8859-1"  or "UTF-8" BASE64      */
       /* CodePage="IBM-1143" <> "IBM-1252"   or "UTF-8" FINSWE+!    */
       /*                                                            */
       /*                                                            */
       /*                                                            */
       /*                                                            */
       /*                                                            */
       /* ---------------------------------------------------------- */
       /* Name:      XMITIPCU                                        *
       *                                                            *
       * Function:  Customization definitions for XMITIP            *
       *                                                            *
       * Syntax:    Invoked as a rexx function                      *
       *                                                            *
       *            cu = xmitipcu()                                 *
       *                                                            *
       *            Must reside in the sysproc or sysexec           *
       *            concatenation.                                  *
       *                                                            *
       * Author:    Lionel B. Dyck                                  *
       *            Internet: lbdyck@gmail.com                      *
       *                                                            *
       * History:                                                   *
       *          2019-02-21 - NLS updates from fagu                *
       *          2018-01-25 - Update TZone_NM for Australia and    *
       *                       New Zealand (thanks to T. Liu)       *
       *          2017-07/26 - Add test for CSSMTP                  *
       *          2016-06/23 - Test lpar (sysname) for zip          *
       *          2016-08-05 - Dynamically get security product     *
       *                       thx to Peter Giles                   *
       *          2016-03-17 - Add default mail format (LBD)        *
       *                       to HTML                              *
       *          2016-02-23 - Update for new employer (lbd)        *
       *          2015-12-02 - Add TLS option at the request of     *
       *                       Hoi Keung Tong                       *
       * ******** 2014-03-17 - Update for PKZIP                     *
       * ******** 2013-06-18 - Updated for BMC.COM use              *
       *                                                            *
       *          2010-07-23 - Correction for the tcp/ip socket code*
       *                       to prevent closing all sockets       *
       *                       ** Thanks to Carol Samaras **        *
       *          2010-04-29 - add parm ADDRBYP to bypass rewriting *
       *                       of address: list of special email    *
       *                       addresses - separated by blank(s)    *
       *                       - generic supported (only 1 '*')     *
       *                         like NN*FAX.domain.com             *
       *          2010-01-18 - add code to support dynamic settings *
       *                       of antispoof and margins             *
       *          2009-12-11 - force_suf: set default to YES        *
       *                       ('IVP5 problem')                     *
       *                     - new sub routine sub_cp_setting to do *
       *                       all codepage dependent settings      *
       *          2009-11-19 - new var encoding_check               *
       *                       NO (default) / YES / WARN (overhead) *
       *          2009-11-11 - new var force_suf to force filenames *
       *                       with correct suffixes. Default value *
       *                       is force_suf = NO for compatibility  *
       *          2009-09-22 - fix defaults for center for kaiser   *
       *          2009-03-12 - enhance log: logdsn logtype logmsg   *
       *          2009-03-05 - fix setting for xmitipcu_msg         *
       *                     - add some codepages with description  *
       *                     - restricted hlqs: add racf and ca7    *
       *                     - highcc = 4 (warning) instead of 8 if *
       *                       check routine detects a problem      *
       *          2008-01-12 - add check_send_to_parms              *
       *                     - add check_send_from_parms            *
       *          2008-12-09 - add parm xmitipcu_infos to provide   *
       *                       infos: CURC and CUMSG                *
       *                     - change section default_hlq to be     *
       *                       more flexible                        *
       *                     - set always default_hlq (XMITIP like) *
       *                     - check ALIAS entry for the 1st qual.  *
       *                       of the default_hlq candidate(s)      *
       *                     - use quotes for x2c strings           *
       *          2008-09-28 - txt2pdf_parms in XML format like     *
       *                         <COMPRESS>n</COMPRESS>             *
       *                         <XLATE>exec</XLATE> i.e. TXT2PDFX  *
       *                     - tcp_stack (if not default)           *
       *          2008-09-24 - check_send_to EXIT                   *
       *          2008-09-22 - additional TCP/IP socket check       *
       *                       terminate:  2005 ESUBTASKNOTACTIVE ..*
       *                       initialize: 1004 EIBMIUCVERR ...     *
       *          2008-09-08 - check if from_default is already set *
       *          2008-09-02 - remove never executed "exit 8"       *
       *                     - XMITIPFV() replaced by XMITIP("VER") *
       *                     - XMITIPFV is now obsolete             *
       *                     - new variable check_send_from_exit to *
       *                       allow setting in "sub_site_settings:"*
       *          2008-06-18 - Add optional "VER" function          *
       *                     - Make INFOZIP default ZIP program     *
       *                       and call it via LINKLIST             *
       *                       (except for _center_ like *KAISER*)  *
       *          2008-05-23 - Make default for encoding_default    *
       *                       null                                 *
       *          2008-04-21 - smtp_array replaces smtp_fax         *
       *                       new variable smtp_array to support   *
       *                       different delivery tasks / methods   *
       *                       for special addresses (FROM ... TO)  *
       *                        typical values for each entry:      *
       *                        <SMTP>smtp</SMTP>                   *
       *                        <CLASS>class</CLASS>                *
       *                        <WRITER>writer</WRITER>             *
       *                        <OPTION>values</OPTION>             *
       *                          with values ...                   *
       *                          <PREFIX>$FAX $DUMMY</PREFIX>      *
       *                          <SUFFIX>@IBM.COM @KP.ORG</SUFFIX> *
       *          2008-02-20 - minor updates and cleanup            *
       *          2007-12-27 - use check_send_from_use to enable    *
       *                       checking of the from address         *
       *          2007-11-15 - find dyn. a possible separator for   *
       *                       the return string, default "/"       *
       *                       and begin the return string always   *
       *                       with the separator                   *
       *                     - add a little sub_init routine        *
       *                     - add parms for the xmitzex1 routine   *
       *                       These parms are passed thru xmitip   *
       *                       to the exit so that modifications    *
       *                       of the exit are not necessary.       *
       *                     - split values and their depending     *
       *                       settings and use a sub routine to do *
       *                       site specific changes.               *
       *                     - routine for checking TCPIP socket    *
       *          2007-11-08 - Change to use " instead of '         *
       *          2007-09-06 - Add new options for NLS              *
       *                       codepage_default   encoding_default  *
       *                     - Add new option check_send_from       *
       *                       check from address in an external    *
       *                       routine i.e. to bypass spam filter   *
       *                     - Add new option check_send_to (future)*
       *                     - Add new option smtp_fax to support   *
       *                       different smtp tasks                 *
       *          2007-05-02 - New jobinfo for internal xmitipcu    *
       *                       use and added to custsym (thx Hartmut*
       *          2007-04-30 - Correction in custsym routine thx    *
       *                       to Hartmut                           *
       *          2007-04-23 - Option for Mime8bit mime header      *
       *          2007-02-27 - Update custym to support MVSVARs thx *
       *                       to sample code from Hartmut Beckmann *
       *          2007-02-05 - Move the setting of the Custom       *
       *                       variables to the end of the routine  *
       *          2007-02-02 - Update for DST (minor typo)          *
       *          2007-01-19 - Correction to offset for start of DST*
       *                       thanks to greg shirly and ulrich     *
       *          2007-01-16 - Update zip_type for SLIKZIP          *
       *          2007-01-13 - Add new CustSym value for local      *
       *                       defined symbolics                    *
       *          2007-01-11 - Updated time zone routine with       *
       *                       corrections and commented samples    *
       *          2006-12-04 - Replaced Time zone routine with one  *
       *                       from Yvon Roy and updated for new    *
       *                       dates effective in US in 2007.       *
       *                     - Moved setting for ZIP type/libs      *
       *          2006-11-01 - Add commented code to tailor the     *
       *                       zip options by system                *
       *          2006-07-14 - Remove upper case for weekday in     *
       *                       antispoof block                      *
       *          2006-01-20 - Set Size_Limit to 9.97mb (9,970,000) *
       *          2006-01-18 - Update to description for DISCLAIM   *
       *                       value which may also be known as the *
       *                       Confidentiality Statement.           *
       *          2005-12-27 - Add missing 'end' in antispoof set   *
       *                       routine. (thx to Robert Phillips)    *
       *          2005-05-24 - get jobid and jobidl thru routine    *
       *                     - use always system variables to set   *
       *                       variables instead of using functions *
       *                     - strip trailing low values from       *
       *                       tcp_hostname (GetHostname)           *
       *                     - sample exit for default_hlq          *
       *          2005-01-28 - Change date(usa) to date("usa") in   *
       *                       the timezone routine.                *
       *          2004-07-28 - Update Special_Chars with text       *
       *          2004-07-26 - New approach to get jobid (hartmut)  *
       *                     - Allocate SYSTCPD DD (barry gilder)   *
       *                     - Add special characters for future    *
       *                       from hartmut                         *
       *                     - Add new SEND_FROM option             *
       *          2004-07-22 - More updates from hartmut and lionel *
       *                       place metric, paper size, margins    *
       *                             together based on metric       *
       *                     - Add Disable_Antispoof option         *
       *          2004-07-14 - Updates to Antispoof thx to Hartmut  *
       *          2004-06-22 - Allow multiple domains in            *
       *                       restrict_domain                      *
       *          2004-06-11 - Add default_lang option              *
       *                     - Fixup zip_hlq for infozip model      *
       *          2004-06-04 - Improve comments for default_hlq     *
       *                     - Add restrict_hlq variable            *
       *          2004-05-19 - Add symbolic for SYSTCPD dsname      *
       *                     - Improve the comments for pkzip load  *
       *          2004-05-17 - Move date for antispoof to xmitip    *
       *          2004-05-05 - Change vio value from sysda to work  *
       *          2004-04-16 - Comment change for Interlink         *
       *          2004-04-07 - Add warn and non-zero rc for         *
       *                       ValidFrom option                     *
       *          2004-04-05 - Add Log option                       *
       *          2004-03-30 - Add ValidFrom option                 *
       *          2004-03-22 - Move antispoof date from xmitip      *
       *                     - Add DateFormat option                *
       *          2004-03-21 - Add from2rep keyword                 *
       *          2004-03-16 - Document new value for from_default  *
       *          2004-03-15 - Change jobnumber to jobid and use    *
       *                       code from Hartmut Beckmann           *
       *          2004-03-11 - Move Jobname for AntiSpoof here      *
       *                       and add Job Number                   *
       *          2004-02-17 - Add TPAGEEND, TAPGELEND and          *
       *                       FAXCHECK options                     *
       *          2004-02-10 - Add comment about sysplex/sysracf    *
       *          2004-02-05 - Add User Exit capability             *
       *                       (find *exit* for details)            *
       *                     - Remove unused FONT setting           *
       *          2003-11-18 - Add Restrict_Domain                  *
       *          2003-09-29 - Minor change to antispoof            *
       *          2003-07-16 - Minor cleanup of RETURN              *
       *          2003-06-19 - Add ZIPCONT option                   *
       *          2003-06-09 - Add Tzone_NM from Kent Garrett       *
       *                       for use by sites that don't use GMT  *
       *          2003-06-03 - Minor update in node setup           *
       *          2003-05-06 - Allow 4th line in antispoof          *
       *          2003-04-29 - Add empty_opt of 2 for rc 0          *
       *          2003-04-22 - Code change per Alain Janssens       *
       *          2003-04-01 - Add RFC record length limit option   *
       *          2003-03-31 - Minor changes to clarify the coding  *
       *          2003-03-24 - remove references to b64_load        *
       *          2003-02-03 - Moved call to set_antispoof to end   *
       *                     - Moved set for security system        *
       *                       to the node setup routine            *
       *          2003-01-14 - Add FromReq keyword                  *
       *          2002-12-19 - Translate antispoof to change / to   *
       *                       x'01' (changed back when used)       *
       *            ...  snip                                       *
       *          1999-10-03 - creation from xmitip                 *
       *                                                            *
       * ---------------------------------------------------------- *
       * Timezone subroutine from Leland.Lucius@ecolab.com          *
       * Tzone_NM subroutine from Kent.Garrett@state.nm.us          *
       * Tzone_NM replacement from Yvon Roy                         *
       * ---------------------------------------------------------- */
       signal on novalue name sub_novalue

       /* ------------------------ */
       /* Process Options (if any) */
       /* ------------------------ */
       parse upper arg options

       if abbrev(options,"VER") = 1,
         then do ;
         /* ----------------------------- */
         /* Get Current Version of XMITIP */
         /* ----------------------------- */
         ver = xmitip("VER")
         return ver
       end;

       /* ------------------ */
       /* Setup our Defaults */
       /* ------------------ */
       parse value "" with null zone smtp vio _center_ ,
         smtp_secure smtp_address smtp_domain ,
         tcp_hostid tcp_hostname ,
         tcp_domain tcp_name ,
         tcp_stack ,
         text_enter sysout_class from_center ,
         from_default append_domain ,
         zip_type zip_load zip_unit zip_hlq ,
         writer mtop mbottom mleft mright ,
         interlink size_limit ,
         batch_idval create_dsn_lrecl ,
         receipt_type paper_size ,
         file_suf force_suf ,
         mail_relay AtSign ispffrom char ,
         charuse disclaim empty_opt ,
         font_size def_orient ,
         conf_msg metric site_disclaim ,
         descopt default_hlq ,
         smtp_method smtp_loadlib msg_summary ,
         smtp_server deflpi nullsysout ,
         feedback_addr fromreq rfc_maxreclen ,
         zipcont restrict_domain log ,
         tpagelen faxcheck from2rep validfrom ,
         systcpd restrict_hlq default_lang ,
         disable_antispoof send_from custsym ,
         Mime8bit ,
         codepage_default ,
         encoding_default encoding_check ,
         check_send_from ,
         check_send_to ,
         smtp_array ,
         txt2pdf_parms ,
         xmitsock_parms ,
         xmitipcu_infos ,
         starttls ,    /* TLS */
         antispoof  /* antispoof is always last */

       _junk_ = sub_init() ;

       /* ------------------------------------------------------ */
       /* all variables are moved out of the comment             */
       /* because they are used ...                              */
       /* ------------------------------------------------------ */
       jobname = mvsvar("symdef","jobname")
       custchar= mvsvar("symdef","custchar")
       sysplex = mvsvar("sysplex")
       sysname = mvsvar("sysname")
       lpar    = sysname
       sysenv  = sysvar("sysenv")
       sysnode = sysvar("sysnode")
       sysracf = sysvar("sysracf")
       sysuid  = sysvar("sysuid")
       call gen_jobid

       /* Setup a message ID */
       msgid = sysvar("sysicmd")":"
       if length(msgid) = 1 then
       msgid = sysvar("syspcmd")":"

       /* ------------------------------------------------------ *
       * Note that the setting of AntiSpoof occurs as the last  *
       * variable set as it uses other defined variables.       *
       * ------------------------------------------------------ */

       /* --------------------------------------------------------- *
       * Mime8bit: This setting determines if the mime header will *
       * be 7bit or 8bit. Normally 7bit works fine but 8bit may be *
       * needed for NLS. No problems have been reported with using *
       * 8bit as a default to date.                                *
       *                                                           *
       * 0 = 7bit                                                  *
       * 1 = 8bit                                                  *
       * --------------------------------------------------------- */
       Mime8bit = 1

       /* ----------------------------------------------------- *
       * append_domain                                         *
       *  if not null then used to append to e-mail addresses  *
       *  that are specified without a domain.                 *
       *  Note: do NOT code the @ symbol - it will be added    *
       *        by default.                                    *
       * ----------------------------------------------------- */
       append_domain = "VA.GOV"
       /* fagu: added logic */
       if    z_append_domain <> null then
       append_domain = z_append_domain

       /* ----------------------------------------------------- *
       * Set to ATSIGN VALUE from SMTPCONF (Default= "@")      *
       *  - multiple characters may be defined but only the    *
       *    first will be used in generated addresses.         *
       * ----------------------------------------------------- */
       AtSign = x2c("7C")   /* @ */
       /* fagu: added logic */
       if    z_AtSign <> null then
       AtSign = z_AtSign

       /* ----------------------------------------------------- *
       * Allow E-Mail address (ID) validation via LDAP         *
       * 0 = Allow in both Batch and ISPF (w/lookup)           *
       * 1 = Do Not Allow in Batch or ISPF                     *
       * 2 = Do Not Allow in Batch - Allow in ISPF (w/lookup)  *
       * 3 = Allow lookup only - no validation                 *
       * ----------------------------------------------------- */
       batch_idval = 1
       /* fagu: added logic */
       if    z_batch_idval <> null then
       batch_idval = z_batch_idval

       /* ------------------------------------------------------ *
       * Define the _center_, or NJE Node, where the SMTP       *
       * Server is running.                                     *
       *                                                        *
       * If the SMTP Server is running in the active Node then  *
       * no change is required as it is dynamically determined. *
       * ------------------------------------------------------ */
       _center_    = sysnode
       From_Center = _center_

       /* --------------------------------------------------------- *
       * Set the Mime Character Set                                *
       * --------------------------------------------------------- */
       char = "iso-8859-1"
       /* fagu: added logic */
       if    z_char <> null then
       char = z_char

       /* --------------------------------------------------------- *
       * Character set use option.                                 *
       *     0 = use everywhere                                    *
       *     1 = do not use for text or rtf                        *
       *     anything else acts like 0                             *
       *                                                           *
       * Note: some mail systems object to the charset for text    *
       *       and rtf (I don't know why)                          *
       * --------------------------------------------------------- */
       charuse = 1
       /* fagu: added logic */
       if    z_charuse <> null then
       charuse = z_charuse

       /* --------------------------------------------------------- *
       * conf_msg control defines if the private/confidential      *
       * message is generated in the message text.                 *
       *                                                           *
       * valid values are:                                         *
       *       null or off - no message                            *
       *       top         - message will be before message text   *
       *       bottom      - message at the end of message text    *
       * --------------------------------------------------------- */
       /* conf_msg = "bottom" */
       /* conf_msg = null  */
       conf_msg = "top"

       /* ----------------------------------------------------- *
       * Create_DSN_Lrecl default is 255                       *
       * used for FILE *CREATE*                                *
       * ----------------------------------------------------- */
       create_dsn_lrecl = 255

       /* ----------------------------------------------------- *
       * DateFormat: defines the format of the dates generated *
       *    U = U.S. format                                    *
       *    E = European format                                *
       *    I = ISO format                                     *
       *               CCYY-MM-DD (weekday) and time           *
       *    anything else will default to U                    *
       * ----------------------------------------------------- */
       dateformat = "U"
       /* fagu: added logic */
       if    z_dateformat <> null then
       dateformat = z_dateformat

       /* --------------------------------------- *
       * Default LPI (used only with Format PDF) *
       * --------------------------------------- */
       deflpi = 8

       /* ---------------------------------------------------- *
       * codepages traditional       (IBM Pers. Comm.)        *
       * 0037 - Belgium, Netherlands, Portugal,               *
       *        Brasil, Canada, USA                           *
       * 0273 - Germany, Austria                              *
       * 0280 - Italy                                         *
       * 0284 - Spain                                         *
       * 0285 - UK                                            *
       * 0297 - France                                        *
       * 0500 - International / Multinational                 *
       * 1047 - USA                                           *
       * ---------------------------------------------------- *
       * codepages with EURO support (IBM Pers. Comm.)        *
       * 1140 - Belgium, Netherlands, Portugal,               *
       *        Brasil, Canada, USA                           *
       * 1141 - Germany, Austria                              *
       * 1142 - Denmark, Norway                               *
       * 1143 - Finland, Sweden                               *
       * 1144 - Italy                                         *
       * 1145 - Spain                                         *
       * 1146 - UK                                            *
       * 1147 - France                                        *
       * 1148 - International / Multinational                 *
       * ---------------------------------------------------- *
       /* fagu: added logic */
       * CCSID Euro  Countries                                *
       *  037  1140  Australia, Brazil, Canada, New Zealand,  *
       *             Portugal, South Africa, USA              *
       *  273  1141  Austria, Germany                         *
       *  277  1142  Denmark, Norway                          *
       *  278  1143  Finland, Sweden                          *
       *  280  1144  Italy                                    *
       *  284  1145  Latin America, Spain                     *
       *  285  1146  Ireland, United Kingdom                  *
       *  297  1147  France                                   *
       *  500  1148  International                            *
       *  871  1149  Iceland                                  *
       *                                                      *
       *                                                      *
       *            +...................... - exclamation mark     *
       *            .  +................... - backslash            *
       *            .  .  +................ - diaresis             *
       *            .  .  .  +............. - bracket square left  *
       *            .  .  .  .  +.......... - bracket square right *
       *            .  .  .  .  .  +....... - bracket curly  left  *
       *            .  .  .  .  .  .  +.... - bracket curly  right *
       *            .  .  .  .  .  .  .  +. - hash / number sign   *
       *            .  .  .  .  .  .  .  .        description      */
       /* fagu: added logic */
       /* cp.? must be changed if adding CodePages, cp.0=12 */
       /* All CodePage conversion is from IBM-xxxx ==> IBM,WINDOWS-1252 */
       /* IBM-1143       |  É  ]  §  ¤  ä  å  Ä     fagu: eye catcher */
       cp.0=23
       cp.1="00037 "x2c("5A E0 72 AD BD C0 D0 7B")"    USA                 "
       /*  IBM-037       !  \  Ê  [  ]  {  }  #  */
       cp.2="00273 "x2c("4F EC BD 63 FC 43 DC 7B")"    Austria, Germany    "
       /*  IBM-273       |  Ö  ]  Ä  Ü  ä  ü  #  */
       cp.3="00277 "x2c("4F E0 BD 9E 9F 9C 47 4A")"    Denmark, Norway     "
       /*  IBM-277       |  \  ]  Æ  ¤  æ  å  ¢  */
       cp.4="00278 "x2c("4F 71 BD B5 9F 43 47 63")"    Finland, Sweden     "
       /*  IBM-278       |  É  ]  §  ¤  ä  å  Ä  */
       cp.5="00280 "x2c("4F 48 BD 90 51 44 54 B1")"    Italy               "
       /*  IBM-280       |  ç  ]  °  é  à  è  £  */
       cp.6="00284 "x2c("BB E0 A1 4A 5A C0 D0 69")"    Spain               "
       /*  IBM-284       ¨  \  ~  ¢  !  {  }  Ñ  */
       cp.7="00285 "x2c("5A E0 BD B1 BB C0 D0 7B")"    GB (UK)             "
       /*  IBM-285       !  \  ]  £  ¨  {  }  #  */
       cp.8="00297 "x2c("4F 48 A1 90 B5 51 54 B1")"    France              "
       /*   IBM-297       |  ç  ~  °  §  é  è  £  */
       cp.9="00500 "x2c("4F E0 BD 4A 5A C0 D0 7B")"    multinational       "
       /*   IBM-500       |  \  ]  ¢  !  {  }  #  */
       cp.10="00870 "x2c("4F E0 BD 4A 5A C0 D0 7B")"    Romania, Poland     "
       /*   IBM-870       |  \  ]  ¢  !  {  }  #  */
       cp.11="00871 "x2c("4F BE BD AE 9E 8E 9C 7B")"    Iceland             "
       /*   IBM-871       |  ´  ]  Þ  Æ  þ  æ  #  */
       cp.12="01047 "x2c("5A E0 72 AD BD C0 D0 7B")"    USA                 "
       /* IBM-1047       !  \  Ê  [  ]  {  }  #  */
       cp.13="01140 "x2c("5A E0 72 AD BD C0 D0 7B")"    B NL P BR CDN USA  E"
       /* IBM-1140       !  \  Ê  [  ]  {  }  #  */
       cp.14="01141 "x2c("4F EC BD 63 FC 43 DC 7B")"    Austria, Germany   E"
       /* IBM-1141       |  Ö  ]  Ä  Ü  ä  ü  #  */
       cp.15="01142 "x2c("4F E0 BD 9E 9F 9C 47 4A")"    Denmark, Norway    E"
       /* IBM-1142       |  \  ]  Æ  ¤  æ  å  ¢  */
       cp.16="01143 "x2c("4F 71 BD B5 9F 43 47 63")"    Finland, Sweden    E"
       /* IBM-1143       |  É  ]  §  ¤  ä  å  Ä  */
       cp.17="01144 "x2c("4F 48 BD 90 51 44 54 B1")"    Italy              E"
       /* IBM-1144       |  ç  ]  °  é  à  è  £  */
       cp.18="01145 "x2c("BB E0 A1 4A 5A C0 D0 69")"    Spain              E"
       /* IBM-1145       ¨  \  ~  ¢  !  {  }  Ñ  */
       cp.19="01146 "x2c("5A E0 BD B1 BB C0 D0 7B")"    GB (UK)            E"
       /* IBM-1146       !  \  ]  £  ¨  {  }  #  */
       cp.20="01147 "x2c("4F 48 A1 90 B5 51 54 B1")"    France             E"
       /*  IBM-1147       |  ç  ~  °  §  é  è  £  */
       cp.21="01148 "x2c("4F E0 BD 4A 5A C0 D0 7B")"    multinational      E"
       /*  IBM-1148       |  \  ]  ¢  !  {  }  #  */
       cp.22="01149 "x2c("4F BE BD AE 9E 8E 9C 7B")"    Iceland            E"
       /*  IBM-1149       |  ´  ]  Þ  Æ  þ  æ  #  */
       cp.23="01153 "x2c("4F E0 BD 4A 5A C0 D0 7B")"    Romania, Poland    E"
       /*  IBM-1153       |  \  ]  ¢  !  {  }  #  */

       /* using characters to make it easy     */
       cp = "..... !\.[]{}#"  /* ..... means no codepage value set    */

       cpdef= 99999 /* set default to a valid value - 99999 dummy entry */
       /* fagu: added logic */
       if    z_cpdef <> null then
       cpdef = z_cpdef

       /* -------------------------------------------------------- *
       * Be careful: Using ... quoted-printable ... requires      *
       *             a suitable encoding routine (see XMITZENQ).  *
       * -------------------------------------------------------- *
       *  ISO-8859-1                                              *
       *  ISO-8859-15                                             *
       *  WINDOWS-1252                                            *
       *  UTF-8                                                   *
       * -------------------------------------------------------- *
       * Content-Type: text/html; charset=ISO-8859-1              *
       * Content-Transfer-Encoding: quoted-printable              *
       * -------------------------------------------------------- */
       encoding_default = null
       /* fagu: added logic */
       if    z_encoding_default <> null then
       encoding_default = z_encoding_default

       /* -------------------------------------------------------- *
       * encoding_check                                           *
       * NO   - bypass encoding check (default)                   *
       * YES  - XMITIP will terminate if the check fails          *
       * WARN - XMITIP will continue and write out a warning msg  *
       *        Be careful to avoid overhead, because checking    *
       *        will be done for each encoding process (DEBUG)    *
       * ONCE - like WARN, but only once                          *
       * -------------------------------------------------------- */
       encoding_check   = "NO"

       /* ---------------------------------------------------- *
       * Default_Lang defines the default language to be used *
       * for the date translations or null.                   *
       * See XMITIPTR for the available languages             *
       * ---------------------------------------------------- */
       default_lang = null
       /* fagu: added logic */
       if    z_default_lang <> null then
       default_lang = z_default_lang

       /* --------------------------------------------------------- *
       * Default Page Orientation (Portrait or Landscape)          *
       * --------------------------------------------------------- */
       /* def_orient = "Landscape" */
       def_orient = "Portrait"

       /* --------------------------------------------------------- *
       * DESCOPT - if 0 then the dataset name or dd will be used   *
       * for FILEDESC otherwise (not 0) the filename will be used. *
       * --------------------------------------------------------- */
       descopt = 1

       /* -------------------------------------------------- *
       * Disable_Antispoof:   Security awareness option     *
       *        Y    = enabled (user can disable antispoof) *
       *        anything else = disabled                    *
       * -------------------------------------------------- */
       disable_antispoof = "N"
       /* fagu: added logic */
       if z_disable_antispoof <> null then
       disable_antispoof = z_disable_antispoof

       /* --------------------------------------------------------- *
       * Disclaimer specification. Defines a data set containing   *
       * a standard disclaimer or null. This is also known in      *
       * some shops as a Confidentiality Statement                 *
       * --------------------------------------------------------- */
       env = null   /* set by lbd for bmc */
       /* fagu: added logic */
       if    z_env <> null then
       env = z_env
       if env = null ,
         then do ;
         disclaim = null
       end;
       else do ;
         disclaim = null
         /* fagu: added logic */
         disclaim = z_disclm_dsn_p1||env||z_disclm_dsn_p2
       end;

       /* --------------------------------------------------------- *
       * Empty Data Set option:                                    *
       *      0 = warn message and continue with rc 4              *
       *      1 = error message and exit                           *
       *      2 = warn message and continue with rc 0              *
       * --------------------------------------------------------- */
       empty_opt = 0
       /* fagu: added logic */
       if    z_empty_opt <> null then
       empty_opt = z_empty_opt

       /* ------------------------------------------------------- *
       * FaxCheck: if not null then the character string to test *
       * for in the to e-mail address to determine if the e-mail *
       * is going out as a fax.  If so then the anti-spoof block *
       * will be bypassed. Case is ignored.                      *
       *                                                         *
       * e.g. FAXCHECK = "$FAX"                                  *
       * ------------------------------------------------------- */
       faxcheck = null
       /* fagu: added logic */
       if    z_faxcheck <> null then
       faxcheck = z_faxcheck

       /* ------------------------------------------------------- *
       * Feedback_Addr                                           *
       * This is an e-mail address to be used by the ISPF dialog *
       * if the user enters FEEDBACK on the command line.        *
       * This *SHOULD* be changed.                               *
       * ------------------------------------------------------- */
       feedback_addr = "lionel.dyck@va.gov"   /* 2/23/16 lbd */
       /* fagu: added logic */
       if    z_feedback <> null then
       feedback_addr = z_feedback

       /* --------------------------------------------------------- *
       * Define a default file suffix in case one is not defined   *
       * in FORMAT and a FILENAME is not defined.                  *
       * Note: a value of null is acceptable.                      *
       * --------------------------------------------------------- */
       file_suf = ".txt"

       /* --------------------------------------------------------- *
       * Set the default value for an automatic appended suffix    *
       * if an appropriate suffix is missed in FILENAME.           *
       * NO  - old behaviour for compatibility                     *
       * YES - an extension will be added if necessary             *
       *       (new default value because of user comments)        *
       * --------------------------------------------------------- */
       force_suf = "YES"

       /* --------------------------------------------------------- *
       * Default Font Size                                         *
       * --------------------------------------------------------- */
       font_size = 9

       /* ----------------------------------------------------------- *
       * FromReq used to require a FROM e-mail address in the XMITIP *
       * command.                                                    *
       *                                                             *
       * Values:   0 - not required                                  *
       *           1 - required                                      *
       *           "addr@host.com"    - code in quotes to avoid      *
       *                                translation to upper case    *
       *                                                             *
       * If an address then an e-mail is sent to that address for    *
       * logging purposes.                                           *
       * ----------------------------------------------------------- */
       FromReq = 0
       /* FromReq = "name@host.com" */

       /* ------------------------------------------------------ *
       * From2Rep - From to Reply                               *
       *   Set to 1 to cause the FROM to be used in the REPLYTO *
       *   if no REPLYTO is specified.                          *
       *                                                        *
       *   Set to 0 to generate a REPLY-TO only if a REPLYTO    *
       *   option is used.                                      *
       * ------------------------------------------------------ */
       From2Rep = 1
       /* fagu: added logic */
       if    z_From2Rep <> null then
       From2Rep = z_From2Rep

       /* ------------------------------- *
       * Define the default mail format: *
       *                                 *
       * mailfmt = plain or html         *
       *                                 *
       * plain is plain text             *
       * html is in html                 *
       * ------------------------------- */
       /* mailfmt = "Plain" */
       mailfmt = "HTML"
       /* fagu: added logic */
       if    z_mailfmt <> null then
       mailfmt = z_mailfmt

       /* ----------------------------------------------------- *
       * Set the interlink value to 1 if using the Interlink   *
       * tcp/ip stack for your SMTP server. This should be set *
       * based on where the SMTP server is running and not     *
       * where XMTIIP is running.                              *
       * ----------------------------------------------------- */
       interlink = 0

       /* --------------------------------------------------------- *
       * If ISPFFROM is null then the XMITIP Panel will not require*
       * a from address. If 1 then the Panel will require a from   *
       * address otherwise set to 0.                               *
       * --------------------------------------------------------- */
       ispffrom = 1

       /* create a new variable JOBINFO */
       idat = ,
         translate("1234-56-78",date("s"),"12345678")  /*iso date*/
       jobinfo  = ""left(jobname,8),
         ""left(jobidl,8),
         ""left(idat,10),
         ""left(TIME("N"),8)
       /* and a prefix of your choice */
       custplex = mvsvar("symdef","custplex")
       if custplex /= "" ,
         then jobinfo = ""left(custplex,4)" "jobinfo

       /* -------------------------------------------------- *
       * Log: determines if the LOGIT logging routine will  *
       *      be called.                                    *
       *                                                    *
       * Syntax:   LOG = option                             *
       *                                                    *
       *           option values                            *
       *                  null - no logging                 *
       *                  dsn  - dsname of the log data set *
       *                                                    *
       * -------------------------------------------------- */
       /* log = "'sysl.xmitip."sysnode".log'" */
       log     = null
       logmsg  = null
       logtype = null
       if log  = null ,
         then _logit_ = "N"
       else _logit_ = "Y"

       /* --------------------------------------------------------- *
       * Set mail relay address for those requiring it.            *
       * Will result in RCPT TO: relay:address                     *
       * --------------------------------------------------------- */
       mail_relay = null

       /* --------------------------------------------------------- *
       * Metric specification.                                     *
       *     I = Inches                                            *
       *     C = Centimeters                                       *
       * Used for margins and custom paper size.                   *
       * Does not affect the lpi specification.                    *
       * --------------------------------------------------------- */
       metric = "i"
       /* fagu: added logic */
       if    z_metric <> null then
       metric = z_metric

       /* ------------------------------------------------------ *
       * Msg_Summary defines if the message summary information *
       * will be appended to the end of every message.          *
       *                                                        *
       * msg_summary = 1 will generate the message              *
       * msg_summary = 0 will not                               *
       * ------------------------------------------------------ */
       msg_summary = 0

       /* ------------------------------------------------------- *
       * NullSysout defines a sysout class and goes to the bit   *
       * bucket. This is used with FORMAT XMIT or FORMAT ZIPXMIT *
       * to suppress the TSO Transmit messages.                  *
       * ------------------------------------------------------- */
       nullsysout = "0"

       /* ----------------------------------------------------- *
       * Receipt Type indicator                                *
       * 1 = Return-Receipt-To                                 *
       * 2 = Disposition-Notification-To (default)             *
       * ----------------------------------------------------- */
       receipt_type = 2

       /* ----------------------------------------------- *
       * Restrict_Domain                                 *
       *    If null then no action.                      *
       *    If set then all e-mails sent must end with   *
       *       one of the specified domains.             *
       * ----------------------------------------------- */
       restrict_domain = null
       /* restrict_domain = "host1.com host2.com" */

       /* --------------------------------------------------------- *
       * Restrict_Hlq: defines a list of high level quals that are *
       * not allowed to be used.                                   *
       *                                                           *
       * The first value is the action:  LOG or TERM               *
       * Following the action is the list of restricted hlqs       *
       * separated by blanks.                                      *
       *                                                           *
       * Both Log and Term will cause a log entry to be cut if     *
       * the log variable is set. In both cases a message is       *
       * issued to the user.                                       *
       *                                                           *
       * Action Term will cause XMITIP to end with return code 8   *
       *                                                           *
       * Set to null to not use                                    *
       *                                                           *
       * e.g. restrict_hlq = "Log hlq1 hlq2 hlq3"                  *
       * --------------------------------------------------------- */
       /* restrict_hlq = null */
       restrict_hlq = "Log defstc stctask" ,
         "racfca7 racf ca7 stcdeflt prodctl"

       /* ---------------------------------------------------------- *
       * RFC_MaxRecLen defines the option for how to handle records *
       * that exceed the RFC Maximum Record Limit of 998.           *
       *                                                            *
       *    0 - ignore and honor IBM SMTP limit of 1024             *
       *    1 - warn if exceeding the RFC limit and continue        *
       *    2 - honor the RFC limit and terminate if exceeded       *
       * ---------------------------------------------------------- */
       rfc_maxreclen = 1

       /* --------------------------------------------------------- *
       * Send_From is used to indicate (regardless of the fromreq) *
       * to set the SENDER SMTP Header tag to the user specified   *
       * FROM address if a FROM address is specified.              *
       * A value of 1 enables this option.                         *
       * --------------------------------------------------------- */
       send_from = 1

       /* --------------------------------------------------------- *
       * check_send_from = name of external routine                *
       * The routine is called from xmitip to check and rewrite    *
       * the from address.                                         *
       * If the domain of the from address differs from the domain *
       * of the environment the email could be filtered as spam.   *
       * The original from address should be copied to the reply   *
       * address - use option From2Rep = 1                         *
       * sample check_send_from = "xmitzex1"                       *
       * The parms in XML format a passed to the exit routine.     *
       *                                                           *
       * samples: xmitzex1 ...                                     *
       *          <ADDRPRE></ADDRPRE>                    default   *
       *          <ADDRSUF>-noreply</ADDRSUF>            default   *
       *          <ADDRDOM>ibm.com dummy.org</ADDRDOM>"  domains   *
       *          <ADDRREW>YES-YES-YES</ADDRREW>         Y/N       *
       *          <ADDRLAB>PART</ADDRLAB>                default P *
       *           if rewrite is done create a label               *
       *             N - create no label                           *
       *             F - original address: full                    *
       *             P - original address: part (domain stripped)  *
       *                 this is the default                       *
       *             T - T(chars) i.e. T(-.)                       *
       *                 like part with additonal translated chars *
       *                 to blank like Your.Name >>> Your Name     *
       *          <ADDRBYP>list of special addresses</ADDRBYP>     *
       * --------------------------------------------------------- */
       /* fagu: added logic */
       _addrsuf_ = ""
       _addrpre_ = ""
       _addrdom_ = "_all_"
       if    z_addrdom_ <> null then
       _addrdom_ = z_addrdom_
       _addrrew_ = "YES"
       if    z_addrrew_ <> null then
       _addrrew_ = z_addrrew_
       _addrlab_ = "PART"
       _addrbyp_ = ""
       check_send_from_exit   = "xmitzex1"  /* XMITIP sample exit */
       check_send_from_parms  = ""          /*  optional parms    */
       check_send_from_use    = "N"         /*  Y to activate     */
       /* fagu: added logic */
       if    z_check_send_from_use = "Y" then
       check_send_from_use = z_check_send_from_use

       /* -------------------------------------------------------- *
       * check_send_from = name of external routine               *
       * The routine is called from xmitip to check and rewrite   *
       * the from address.                                        *
       * -------------------------------------------------------- */

       check_send_to_exit     = "xmitzex2"  /* XMITIP sample exit */
       check_send_to_parms    = ""          /*  optional parms    */
       check_send_to_use      = "N"         /*  Y to activate     */

       /* ------------------------------------------------------- *
       * Site Disclaimer. This will be displayed in the SYSTSPRT *
       * when XMITIP is executed if not null.                    *
       * A # is used to separate lines.                          *
       * ------------------------------------------------------- */
       site_disclaim = "XMITIP is a free open source application" ,
         "which has no vendor support.# ",
         "It is supported on a best effort basis" ,
         "by the local systems staff."

       /* ----------------------------------------------------- *
       * Set size limit in bytes. 0 is unlimited (no commas)   *
       * ----------------------------------------------------- *
       *            . 10 million                               *
       *            .. 1 million                               *
       *            ... 100K                                   *
       *            .... 10K                                   *
       *            ..... 1k                                   */
       size_limit = 9970000  /* 9.97mb */
       /* fagu: added logic */
       if    z_size_limit <> null then
       size_limit = z_size_limit

       /* ----------------------------------------------------- *
       * Local NJE, Dasd and SMTP Server Setup                 *
       * ---------------------------------------------------- */

       /* ----------------------------------------------------- *
       * _center_ is the NJE node where the SMTP server runs   *
       *                                                       *
       * sec is the security system in use on the node         *
       *     values: RACF, ACF2, TOPSECRET                     *
       *                                                       *
       * smtp is the started task name for the SMTP server     *
       *   - used to generate the DEST for SYSOUT alloc on     *
       *     WORKDD alloc in XMITIP                            *
       *                                                       *
       * systcpd is the dsname for the default tcp/ip config   *
       *    data set. leave blank to use system default.       *
       *                                                       *
       *    e.g. systcpd = "tcpip.tcpip.data"                  *
       *                                                       *
       * writer is the name of the SMTP started task           *
       *   - null is acceptable                                *
       *   - setting to the smtp variable is probably normal   *
       *   - if specified will override DEST on SYSOUT for     *
       *     WORKDD alloc in XMITIP                            *
       *                                                       *
       * vio is the esoteric for the vio virtual dasd          *
       *                                                       *
       * zip_type:  PKZIP for PKZIP/MVS                        *
       *            ISPZIP for ASE's ISP/ZIP                   *
       *            SLIKZIP for ASE's SLIKZIP                  *
       *            ZIP390 for Data21's GZIP/ZIP               *
       *            INFOZIP                                    *
       *           if null then not supported by your shop     *
       *                                                       *
       * This allows this same code to run on multiple nodes   *
       *                                                       *
       * ---------------------------------------------------- *
       * If you do not require this level of flexibility then *
       * comment out from the Select to the End and then      *
       * uncomment the section after the End.                 *
       * ---------------------------------------------------- */
       zip_available = "N"
       if    z_zip_available <> null then
       zip_available = z_zip_available
       zip_type = "PKZIP"
       if    z_zip_type <> null then
       zip_type = z_zip_type
       if    z_zip_load <> null then
       zip_load = z_zip_load
       /*  *** commented by LBD for use at BMC
       Select
       When _center_ = "NKAISER2" then do
       sec      = "RACF"
       smtp     = "TCPSMTP"
       writer   = null
       vio      = "3390"
       systcpd  = null
       zip_type = "PKZIP"
       end
       When left(_center_,2) = "SK" then do
       if _center_ <> "SKAISERC" then
       _center_ = "SKAISERB"
       sec      = "RACF"
       smtp     = "TCPSMTP"
       writer   = null
       vio      = "3390"
       systcpd  = null
       zip_type = "PKZIP"
       end
       When pos("KAISER",_center_) > 0 then do
       _center_ = "NKAISERA"
       sec      = "RACF"
       smtp     = "SMTP"
       writer   = null
       vio      = "3390"
       systcpd  = null
       zip_type = "PKZIP"
       end
       Otherwise do
       _center_ = "NKAISERA"
       sec      = "RACF"
       smtp     = "SMTP"
       writer   = null
       vio      = "3390"
       systcpd  = null
       zip_type = "PKZIP"
       end
       End   ***** */

       /* ----------------------------------------------------- *
       * If you have commented out the Select/End above then   *
       * uncomment this section and set the variables for your *
       * installation.                                         *
       * ----------------------------------------------------- */
       _center_ = sysvar('sysnode')
       /* fagu: added logic */
       if    z_center_ <> null then
       _center_ = z_center_
       if    z_smtp <> null then smtp = z_smtp
       else smtp   = "SMTP"
       if    z_writer <> null then writer = z_writer
       else writer = null
       vio    = "3390"
       CVT    = C2D(STORAGE(10,4))
       CVTRAC = C2d(Storage(D2x(CVT + 992),4))   /* RACF CVT */
       RCVTID = Storage(D2x(CVTRAC),4) /* RCVT, ACF2 or RTSS */
       sec    = RCVTID                      /* RCVTID = ACF2 */
       If RCVTID = 'RCVT' then sec    = 'RACF'
       else
       If RCVTID = 'RTSS' then sec    = 'TOPSECRET'
       /* --------------- *
       | Test for CSSMTP |
       call outtrap 'xx.'
       'st cssmtp'
       call outtrap 'off'
       smtp = null
       do smtpi = 1 to xx.0
       if pos('EXECUTING',xx.smtpi) > 0
       then smtp = 'CSSMTP'
       end
       if smtp = null then smtp = 'SMTP'
       writer = null
       systcpd = null
       vio    = "VIO"
       * --------------- */

       /* ----------------------------------------------- *
       * Alloc DD SYSTCPD if not already allocated.      *
       * ----------------------------------------------- */
       /* fagu: added logic */
       if z_systcpd <> null then do
         if z_systcpd_member <> null then
         z_systcpd = z_systcpd"("z_systcpd_member")"
         /* fagu: prefer   systcpd   not   z_systcpd */
         if systcpd = null then systcpd = z_systcpd
       end
       if systcpd <> null then do
         LRC = listdsi("SYSTCPD" "file")
         if LRC = 16 & SYSREASON = 2 then ,
           "alloc dd(SYSTCPD) da('"SYSTCPD"') shr reuse"
       end

       /* -------------------------- *
       * domain name of smtp server *
       * -------------------------- */
       /* fagu: added logic */
       if smtp_domain = null then
       smtp_domain = z_smtp_domain

       /* --------------------------------------------------------- *
       * SMTP_Loadlib is the load library where the UDSMTP program *
       * is to be found.                                           *
       *                                                           *
       * Fully qualify without quotes.                             *
       *                                                           *
       * Only used if smtp_method is UDSMTP                        *
       * --------------------------------------------------------- */
       smtp_loadlib = null
       /* smtp_loadlib = "syslbd.lionel.load" */

       /* --------------------------------------------------------- *
       * SMTP_Method defines whether to use the active SMTP server *
       * or to use the free UDSMTP interface to send the e-mail.   *
       *                                                           *
       * If you don't have the z/OS SMTP Server then UDSMTP is     *
       * the suggested alternative                                 *
       *                                                           *
       * SMTP    = Use SYSOUT to SMTP Server                       *
       * UDSMTP  = Use the free UDSMTP interface                   *
       * SOCKETS = Use the XMITSOCK routine (REXX Sockets)         *
       * --------------------------------------------------------- */
       smtp_method = "SMTP"
       /* smtp_method = "UDSMTP"   */
       /* smtp_method = "SOCKETS"  */

       /* -------------------------- *
       * Secure SMTP option         *
       * set to 1 for secure        *
       * -------------------------- */
       /* smtp_secure = 1 */
       smtp_secure = null

       /* ----------------------------------------------------------- *
       * smtp_server defines the SMTP Server that the UDSMTP program *
       * is to route mail to.  It is best to use the dotted ip addr. *
       * ----------------------------------------------------------- */
       smtp_server = null

       /* ----------------------------------------------------------- *
       * STARTTLS: Enables the addition of the STARTTLS SMTP Keyword *
       *        On - enables for every e-mail                        *
       *        Off - disabled unless the user requests (default)    *
       * ----------------------------------------------------------- */
       starttls = "off"         /* off by default */

       /* ----------------------------------------------------- *
       * Set the sysout class to a external writer sysout      *
       * class                                                 *
       * ----------------------------------------------------- */
       if sysout_class = null then
       sysout_class = "A"
       /* fagu: added logic */
       if    z_sysout_class <> null then
       sysout_class = z_sysout_class

       /* ----------------------------------------------------- *
       * Set text_enter to null if you do not want the msgds * *
       * process to begin with the TE (Text Enter) command.    *
       * ----------------------------------------------------- */
       /* text_enter = null */
       text_enter = "Y"

       /* ------------------------------------------------------- *
       * TPAGEEND: defines whether to terminate an e-mail if the *
       * text exceeds the value in TPAGELEN or to just issue a   *
       * warning.                                                *
       *        0 = warning                                      *
       *        1 = abort                                        *
       * ------------------------------------------------------- */
       TPageEnd = 0

       /* ------------------------------------------------------ *
       * TPAGELEN: defines the text page size beyond which will *
       * result in a warning message or an aborted transmission *
       * based upon the TPAGEEND value.                         *
       *        0 = unlimited                                   *
       * ------------------------------------------------------ */
       tpagelen = 160

       /* --------------------------------------------------- *
       * VALIDFROM:  Validate the From and ReplyTo addresses *
       *       0 = do not validate                           *
       *       1 = validate and terminate                    *
       *       2 = validate and warn                         *
       *       3 = validate, warn and non-zero rc            *
       * Note: this requires that LDAP be enabled in         *
       *       the XMITLDAP REXX module.                     *
       * --------------------------------------------------- */
       validfrom = 0

       /* ----------------------------------------------------- *
       * Setup ZIP variables                                   *
       *   zip_type:  PKZIP for PKZIP/MVS                      *
       *              ISPZIP for ASE's ISP/ZIP                 *
       *              ZIP390 for Data21's GZIP/ZIP             *
       *              INFOZIP                                  *
       *   if null then not supported by your shop             *
       *   zip_type:  set previously in this routine           *
       *   zip_hlq:   hlq for work file for InfoZip (Only)     *
       *              used for the name-in-archive file name   *
       *   zip_load:  load.library(module)                     *
       *   zip_unit:  defines the dasd work device to use      *
       *              NOT an esoteric - try 3390               *
       *              Or * to use the system default           *
       * ----------------------------------------------------- */

       /* ---------------------------------------------------- *
       * specify antispoof options                            *
       * sys_info   -  generate system info                   *
       *               Null for none                          *
       *               Short for sysname and sysnode          *
       *               Long for sysname/sysplex/sysnode       *
       * mask_user  -  hide USERID                            *
       * mask_job   -  hide JOBNAME                           *
       *               Null to not hide                       *
       *               non-blank to hide only if based on uid *
       *               Force to always hide                   *
       * ---------------------------------------------------- */
       sys_info  = "SHORT"   /* null or Short or Long */
       mask_user = null      /* null or not-null */
       mask_job  = null      /* null or not-null or force */


       /* ----------------------------------------------------- *
       * Now all variables and values are set so now site      *
       * specific settings can be done.                        *
       * ----------------------------------------------------- */
       _junk_ = sub_site_settings() ;

       /* ------------------------------------------------------------- *
       *     Now set variables depending on previous settings ...      *
       * ------------------------------------------------------------- */
       _junk_ = sub_cp_setting(cpdef);

       /* -------------------------------------------------------- *
       * default_hlq is used for the temp datasets used in the    *
       * xmitip application. Set to null if existing defaults in  *
       * xmitip are acceptable.                                   *
       * Do *NOT* end the default_hlq with a period - it will be  *
       * added when needed.                                       *
       * -------------------------------------------------------- */
       /*  default_hlq = gen_default_hlq(); */
       if default_hlq = null then ,
         default_hlq = gen_default_hlq();

       codepage_default = strip(word(special_chars,1))
       select ;
         when ( datatype(codepage_default) /= "NUM" ) ,
           then codepage_default = "" ;
         when (          codepage_default   < 1     ) ,
           then codepage_default = "" ;
         otherwise ,
           do ;
           /* --------------------------------------------- *
           * 5 digits with leading zeroes                  *
           * Check that the codepage is supported in the   *
           * encoding routine                              *
           * --------------------------------------------- */
           codepage_default = right("00000"codepage_default,5);
         end;
       end;

       /* --------------------------------------------------------- *
       * Set the default paper size.  This allows sites to         *
       * set the size to something other than Letter (e.g. A4)     *
       * --------------------------------------------------------- *
       * Margin Defaults                                           *
       *    mtop, mbottom, mleft, mright (see metric variable)     *
       * --------------------------------------------------------- */
       if metric = "i" ,
         then do
         paper_size = "Letter"
         mtop    = word(mtop    "1.0",1)
         mbottom = word(mbottom "1.0",1)
         mleft   = word(mleft   "0.8",1)
         mright  = word(mright  "0.8",1)
       end
       else do
         paper_size = "A4"
         metric  = "c"    /* centimeters */
         mtop    = word(mtop    "2.50",1)
         mbottom = word(mbottom "2.00",1)
         mleft   = word(mleft   "2.50",1)
         mright  = word(mright  "2.50",1)
       end

       /* ----------------------------------------------- *
       * Define the NJE address of the SMTP Server if it *
       * is not running on the active NJE Node.          *
       *                                                 *
       * In most cases you can leave this code alone.    *
       * ----------------------------------------------- */
       if interlink = 0 then
       smtp_address = _center_"."smtp
       else
       smtp_address = smtp

       if zip_available = "N" ,
         then do
         zip_load = null
         zip_type = null
         zip_unit = null
         zip_hlq  = null
       end
       else do ;
         /* ------------------------------ *
         * Now set the zip load library   *
         * ------------------------------ */
         zip_unit = "*"

         select ;
           when ( zip_type = "PKZIP"   ) ,
             then do ;
             /* Now setup the load library for PKZIP */
             if zip_load = null ,
               then do ;
               zip_load = ,/* lbd 2-23-16 */
                 "'EXCUTL.SYS.PKZ150G.LOAD(pkzip)'"
             end;
           end;
           when ( zip_type = "ISPZIP"  ) ,
             then do ;
             /* zip_load = "'syslbd.ispzip.load(ispzip)'" */
           end;
           when ( zip_type = "INFOZIP" ) ,
             then do ;
             /* zip_load = "'syslbd.xmitip.load(zip)'"    */
             /* zip via dsname or * (LINKLIST / STEPLIB)  */
             if zip_load = null ,
               then zip_load = "*"
             if zip_hlq = "" ,
               then do ;
               select;
                 when (default_hlq /= "") ,
                   then z_hlq = default_hlq
                 when (length(sysvar("syspref")) = 0),
                   then z_hlq = sysvar("sysuid")
                 otherwise z_hlq = sysvar("syspref")
               end;
               zip_hlq = ,
                 z_hlq".z"right(sysvar("syssrv"),5,0)
             end;
           end;
           when ( zip_type = "SLIKZIP" ) ,
             then do ;
             /* zip_load = "'syslbd.slikzip.load(slikzip)'" */
           end;
           when ( zip_type = "ZIP390"  ) ,
             then do ;
             /* zip_load = "'syslbd.zip390.loadlib(zip390)'"*/
           end;
           otherwise nop ;
         end;
       end;

       /* ---------------------------------------------------- *
       * ZIPCONT                                              *
       * Defines the continuation prompt method for zipmethod *
       * and zippassword popup panel.                         *
       *                                                      *
       *    0 = use the Enter key to continue                 *
       *    1 = use the PF3 key to continue                   *
       *        ** 1 will function the same as before this    *
       *           option was made available.                 *
       * ---------------------------------------------------- */
       zipcont = 0

       /* -------------------------- *
       * Get current IP Domain      *
       * -------------------------- */
       if interlink = 0 ,
         then do;
         _anyname_ = Date("B")
         str    = Socket('initialize', _anyname_)
         Parse Var str sockrc _response_
         if sockrc = 0 ,
           then do;
           Parse Var str sockrc ,
             subtaskid _socks_ tcp_name
           str    = Socket('GetHostId')
           Parse Var str sockrc tcp_hostid    desc
           str    = Socket('GetHostname')
           Parse Var str sockrc tcp_hostname  desc
           /* strip low value in tcp_hostname       */
           parse var tcp_hostname tcp_hostname "00"x .
           str    = Socket('GetDomainName')
           Parse Var str sockrc tcp_domain    desc
           str    = Socket('Terminate',_anyname_)
         end;
       end;

       /* ----------------------------------------------------- *
       * Time-Zone Setup                                       *
       * set to your local time zone (e.g. PST)                *
       * or set to null to force call to timezone function     *
       * which sets the timezone based on cvt gmt offset       *
       * ----------------------------------------------------- */
       zone   = null
       /* or call timezone routine */
       if zone = null then
       zone = timezone()

       /* ------------------------------------------- *
       * If you don't use GMT then you might want to *
       * call the Tzone_NM routine instead after     *
       * you adjust the routine for your timezone.   *
       * ------------------------------------------- */
       /*   zone = tzone_NM() */

       /* ----------------------------------------------------- *
       * Setup the From Default                                *
       * This section should be customized for each shop       *
       * or at least reviewed.  Interlink users must customize *
       *                                                       *
       * Note: if fromreq is enabled (non-zero) then           *
       *       from_default can be * and will cause the        *
       *       user specified from to be used for the sender   *
       *                                                       *
       * NB: See Send_From if you don't set FromReq            *
       * ----------------------------------------------------- */
       /* fagu: added logic */
       if    z_from_default <> null then
       from_default = z_from_default
       uid = sysuid
       atsignc = left(atsign,1)
       if from_default = null ,
         then do;
         if from_center = _center_ ,
           then do ;
           from_default = ""
           from_default = from_default""uid""
           from_default = from_default""AtSignC""
           from_default = from_default""_center_""
           from_default = from_default"."tcp_domain
         end;
         else do ;
           from_default = ""
           from_default = from_default""uid""
           from_default = from_default"%"from_center""
           from_default = from_default""AtSignC""
           from_default = from_default""_center_""
           from_default = from_default"."smtp_domain
         end;
       end;

       /* ----------------------------------------------------- *
       * Reset check_send_from     to ""                       *
       *  if   check_send_from_use is not Y                    *
       *  else check_send_from     is built.                   *
       * ----------------------------------------------------- */
       _addrbyp_       = space(_addrbyp_,1)
       _data_          = ""
       _data_          = _data_" <ADDRSUF>"_addrsuf_"</ADDRSUF>"
       _data_          = _data_" <ADDRPRE>"_addrpre_"</ADDRPRE>"
       _data_          = _data_" <ADDRDOM>"_addrdom_"</ADDRDOM>"
       _data_          = _data_" <ADDRREW>"_addrrew_"</ADDRREW>"
       _data_          = _data_" <ADDRLAB>"_addrlab_"</ADDRLAB>"
       _data_          = _data_" <ADDRBYP>"_addrbyp_"</ADDRBYP>"

       if check_send_from = "" ,
         then do;
         if check_send_from_exit = "" ,
           then check_send_from = ""
         else check_send_from = check_send_from_exit"",
           check_send_from_parms"",
           strip(_data_)"",
           ""
       end;
       _data_ = ""
       if left(check_send_from_use,1) = "Y" ,
         then nop ;
       else check_send_from = ""

       /* ----------------------------------------------------- *
       * Reset check_send_to       to ""                       *
       *  if   check_send_to_use   is not Y                    *
       *  else check_send_to       is used as defined before.  *
       * ----------------------------------------------------- */
       if check_send_to   = "" ,
         then do;
         if check_send_to_exit = "" ,
           then check_send_to  = ""
         else check_send_to  = check_send_to_exit"",
           check_send_to_parms"",
           ""
       end;
       if left(check_send_to_use,1) = "Y" ,
         then nop ;
       else check_send_to   = ""

       /* ----------------------------------------------------- *
       * now build the variable log (used by %logit)           *
       * log = logdsn  (and additional sub parameter)          *
       * ----------------------------------------------------- */
       if abbrev(_logit_,"Y") = 1 ,
         then do;
         if log = "" ,
           then do;
           if logdsn = "" ,
             then nop
           else do;
             if sysdsn(logdsn) = "OK" ,
               then do;
               log = logdsn
             end;
           end;
         end;
         else nop;

         if logtype = null ,
           then nop
         else log = log" <LOGTYPE>"logtype"</LOGTYPE>"
         if logmsg  = null ,
           then nop
         else log = log" <LOGMSG>"logmsg"</LOGMSG>"
       end;

       /* --------------------------------------------------------- *
       * Antispoof setting: if this variable is set then the value *
       * will be inserted into the message text for all outgoing   *
       * e-mails after any signature.                              *
       *                                                           *
       * Note that if antispoof is set then when the PAGE option   *
       * is used only the current USERID will be appended to the   *
       * paging text (as the entire antispoof block is a tad large *
       * for a pager).                                             *
       *                                                           *
       * Comment this call out if you don't use it                 *
       * --------------------------------------------------------- */
       if antispoof = "DISABLE" ,
         then antispoof = null
       else call set_antispoof

       /* --------------------------------------------------- *
       * XMITIPCU User Exit:                      *exit*     *
       *                                                     *
       * To code comment out sample statements. See the      *
       * sample code in the distribution exec library.       *
       *                                                     *
       * A non-zero return code will result in a termination *
       * of the application.                                 *
       * --------------------------------------------------- */
       /* To use remove this line *****************
       exit_rc = xmitipex(msgid)
       if exit_rc > 0 then do
       say msgid "The application is being terminated due" ,
       "to a non-zero return code from the XMITIP" ,
       "user exit."
       exit 16
       end
       *******************  and remove this line */

       /* ------------------------------------------------------- *
       * CUSTSYM will contain installation specific symbolics in *
       * the format:                                             *
       *    custsym = "&sym1" value1 "&sym2" value2 ....         *
       * The delimiter between symbolics is the & and the value  *
       * can be anything either literal or generated.            *
       * NOTE: The use of the "/" is prohibited......            *
       * ------------------------------------------------------- */
       custsym = custsym ,
         "&jobinfo" jobinfo ;
       sysmvs = mvsvar("sysmvs")
       if sysmvs > "SP7.0.5" then do
         if sym_vars /= null then do
           custsymt = null
           do i = 1 to words(sym_vars)
             sym_var = word(sym_vars,i)
             sym_val = mvsvar("symdef",sym_var)
             if sym_val /= null ,
               then custsymt = custsymt"&"sym_var" "sym_val" "
           end
           if custsymt /= null then
           custsym = custsym custsymt
         end
         /*  if pos("/",custsym) > 0 then do                       *
         *     say msgid "ERROR: the custsym variable has been" , *
         *               "defined with a '/' character which" ,   *
         *               "is not allowed."                        *
         *     exit 16                                            *
         *     end                                                */
       end

       metric = translate(metric)

       /* ----------------------------------------------------- *
       * Now build the info variable with RC and MSG           *
       * ----------------------------------------------------- */
       xmitipcu_infos=xmitipcu_infos"<CU#RC>"xmitipcu_rc"</CU#RC>"
       xmitipcu_infos=xmitipcu_infos"<CU#MSG>"xmitipcu_msg"</CU#MSG>"

       /* ----------------------------------------------------- *
       * Now return to the caller with each value separated    *
       * by a separator (default: /).                          *
       * ----------------------------------------------------- */

       _s_    = ""
       _ret_  = sub_rstring("SEP="_s_) ;
       do _sidx_ = 1 to words(sep_vars)
         _s_ = word(sep_vars,_sidx_) ;
         _n_ = sub_needle(""_s_" "_ret_) ;
         if _n_ = 0 ,
           then do ;
           _ret_ = sub_rstring("SEP="_s_) ;
           leave
         end;
         else _s_ = "" ;
       end
       if _s_ = "" ,
         then do ;
         say "ERROR: no value or char found which can be",
           "used as a separator in the return string."
         say "..... exiting now"excl
         exit 16
       end;
       if _s_ = "/" ,
         then nop ;
       else _ret_ = "SEP="_s_" "_ret_ ;
       _s_val_d_ = c2d(_s_) ;  /* show value in dec format */
       _s_val_x_ = c2x(_s_) ;  /* show value in hex format */
       return _ret_ ;

       /* ---------------------------------------------------------- *
       * Set_AntiSpoof Routine: this routine will set the antispoof *
       * variable.                                                  *
       *                                                            *
       * You must define which security system you are using for    *
       * this to work.                                              *
       *                                                            *
       * ACF2 Note: You may need to change the parse if the         *
       *            user name is in a different position and        *
       *            if there is something after the name.           *
       * ---------------------------------------------------------- *
       * output formats:                                            *
       * RACF: USER=user NAME=user name OWNER=...  CREATED= ...     *
       * ---------------------------------------------------------- */
     Set_AntiSpoof: procedure expose antispoof sec dateformat ,
         default_lang null excl sysuid ,
         sysname sysplex sysnode sysenv ,
         jobidl jobname ,
         sys_info mask_user mask_job

       Select
         When sec = "RACF" then do
           call outtrap "s."
           "lu " sysuid
           call outtrap "off"
           parse value s.1 with . "NAME=" name "OWNER" .
         end
         When sec = "ACF2" then do
           call outtrap "s."
           "NewStack"
           queue "SET TERSE"
           queue "LIST " sysuid
           queue "END"
           queue
           "ACF"
           call outtrap "off"
           "Delstack"
           parse var s.1 a b name
         end
         When sec   = "TOPSECRET" then do
           cvt   = storage(10,4)
           ascb  = storage(d2x(c2d(cvt)+568),4)
           ascbx = storage(d2x(c2d(ascb)+108),4)
           acee  = storage(d2x(c2d(ascbx)+200),4)
           acex  = storage(d2x(c2d(acee)+152),4)
           name  = storage(d2x(c2d(acex)+261),32)
         end
         otherwise do
           if strip(sec) = "" ,
             then _secinfo_ = " (blank)"
           else _secinfo_ = ""
           say "ERROR: An Invalid Security system was defined."
           say "       valid: RACF  ACF2  TOPSECRET"
           say "       found: >>>"sec"<<<"_secinfo_
           say "       try again....."
           say "..... exiting now"excl
           exit 16
         end
       end
       name = strip(name)

       /* ------------------------------------------------- *
       * The antispoof variable has multiple sections with *
       * each separated by a special character defined as  *
       * as_sep                                            *
       * ------------------------------------------------- */
       as_sep = x2c("02")
       select ;
         when ( sysenv <> "FORE" ) then do_antispoof = "YES"
         when ( sysenv =  "FORE" ) then do_antispoof = "YES"
         otherwise                      do_antispoof = "YES"
       end;
       if do_antispoof = "YES" ,
         then do ;

         /* --- */
         antispoof  = null
         l1 = 15
         l2 = l1 + 15
         l3 = l2 +  5
         l4 = 15
         mask_info = 0

         if mask_user <> null then do
           jobuid    = copies("*",8)
           mask_info = mask_info + 1
         end
         else           jobuid    = sysuid
         jobnamx = jobname
         if mask_job  /= null then do
           if abbrev(jobname,sysuid) = 1  then do
             mask_job = "FORCE"
           end
           if translate(mask_job) = "FORCE" then do
             jobnamx   = copies("*",8)
             mask_info = mask_info + 2
           end
         end

         select
           when ( mask_info = 0 ) then ,
             mask_info = null
           when ( mask_info = 1 ) then ,
             mask_info = "Userid is masked."
           when ( mask_info = 2 ) then ,
             mask_info = "Jobname is masked."
           when ( mask_info = 3 ) then ,
             mask_info = "Jobname and Userid are masked."
           otherwise ,
             mask_info = " ... unknown ... "
         end

         x_string  = left("Jobname:   ",l1)""left(jobnamx,09)
         x_string  = left(x_string,l2)""left("JobID:",l4)""jobidl
         antispoof = antispoof "  " x_string

         x_string  = left("Userid:    ",l1)""left(jobuid,09)
         x_string  = left(x_string,l2)""left("User Name:",l4)""name
         antispoof = antispoof as_sep x_string

         if mask_info <> null then do
           mask_info = sub_xmitiptr(mask_info)
           x_string   = left("Note:    ",l1)""mask_info
           antispoof  = antispoof as_sep x_string
         end

         if sys_info  /= null ,
           then do ;
           select
             when (sys_info = "SHORT" ) then do
               x_string = ,
                 left("System:  ",l1)""left(sysname,09)
               x_string = ,
                 left(x_string,l2)""left("Node:",l4)""sysnode
               sys_info = x_string
             end
             when (sys_info = "LONG"  ) then do
               sys_info  = ,
                 ""left("System/Sysplex/Sysnode: ",24)   ,
                 ""sysname"/"sysplex"/"sysnode""
             end
             otherwise do
               sys_info = null
             end
           end /* end select */
           if sys_info  /= null ,
             then do ;
             antispoof = antispoof as_sep ,
               sys_info
           end;
         end; /* end sys_info   */
       end /* ANTISPOOF processing   */

       antispoof = strip(translate(antispoof,x2c("01"),"/"))
       return

       /* ----------------------------------------- *
       * Subroutines to translate or not           *
       * ----------------------------------------- */
     sub_xmitiptr:
       parse arg opt
       if default_lang = null then
       newopt = opt
       else
       newopt = xmitiptr("-L" default_lang opt)
       return newopt

       /* ----------------------------------------- *
       * Subroutines used to get data from storage *
       * ----------------------------------------- */
     ptr: return c2d(storage(d2x(arg(1)),4))
     stg: return storage(d2x(arg(1)),arg(2))

       /*
       * =============================================================
       * Function:      Timezone    : Calculates the offset from GMT
       * Arguments:     (none)      : nothing is required
       * Return:        offset      : offset in (-)HHMM format
       * Exposed vars:  (none)      : nothing is exposed
       *
       * Note:  Uses the CVTLDTO field in one of the CVT extensions.
       *        It looks like this field was added sometime in 1991,
       *        so this routine will not work on any OS version older
       *        than that.
       * =============================================================
       */
     Timezone:
       PROCEDURE

       /* ===========================================================
       * We're gonna have a big number
       */
       NUMERIC DIGITS 21

       /* ===========================================================
       * Get current CVTLDTO
       *   (Local Date Time Offset in STCK format))
       */
       cvt     = C2d( Storage( D2x( 16 ), 4 ) )
       cvttz   = C2d( Storage( D2x( cvt + 304 ), 4 ) )
       cvtext2 = C2d( Storage( D2x( cvt + 328 ), 4 ) )
       cvtldto = C2d( Storage( D2x( cvtext2 + 56 ), 8 ), 8 )

       /* ===========================================================
       * Calc the current offset in hours and minutes
       *    (work with absolute)
       */
       absldto = Abs( cvtldto )
       hours   = absldto % x2d("D693A400000" )
       minutes = ( absldto % x2d("3938700000") ) // 60

       /* ===========================================================
       * Correction to Round to nearest hour
       */
       If minutes <> "00"  Then Do
         If minutes > 30 Then
         hours = hours + 1
         /* minutes = 00 */
       End

       /* ===========================================================
       * Format to ANSI standard X3.51-1975
       */
       zone    = Right( hours, 2, "0" )Right( minutes, 2, "0" )
       IF cvtldto < 0 THEN DO
         zone      = "-"zone
       END
       ELSE DO
         zone = "+"zone
       END

       /* ===========================================================
       * Reset
       */
       NUMERIC DIGITS

       RETURN zone

       /*
       * =============================================================
       * Function:      TZone_NM    : Calculates the offset from GMT
       * Arguments:     (none)      : nothing is required
       * Return:        "xST"/"xDT" : time zone abbreviation
       * Exposed vars:  (none)      : nothing is exposed
       *
       * Note:  This is a good-enough-for-MVS routine for
       *        determining whether we are in standard time (MST)
       *        or daylight time (MDT).  The time change is set for
       *        2am.
       *        This routine determines the time zone abbreviation
       *        based upon the legal dates for switching between
       *        standard and daylight time.
       *
       * See this site for information on Daylight Savings Time:
       * http://en.wikipedia.org/wiki/Daylight_saving_time_around_the_the_worl
       *
       * Updated routine provided by Yvon Roy and modified by Lionel
       * Corrections by Ulrich D. Schmidt
       * =============================================================
       */
     TZone_NM:
       PROCEDURE

       /* the result returned will be one or the other of these */
       STANDARD_TIME = "PST"
       DAYLIGHT_TIME = "PDT"
       /* or if you prefer the offset to UTC/GMT */
       /* STANDARD_TIME = "+0001" */
       /* DAYLIGHT_TIME = "+0002" */

       /* Change SODST and EDOST according to your needs. The last
       sunday before this date will be propagated as Start or End
       of Daylight Saving Time
       Rules:
       USA:  DST starts at second sunday of march
       USA : DST ends at first sunday in november
       Europe: DST starts at last sunday in march
       Europe: DST ends at last sunday in october
       */

       /* fagu: added logic */
       /* for Australia and New Zealand
       SODST="1008"
       EODST="0408"
       */
       /* For USA:  */
       SODST="0315"
       EODST="1108"
       /* For Europe:
       SODST="0401"
       EODST="1101" */

       thisYear=SUBSTR(DATE("S"),1,4)

       /* find start of daylight saving time */
       /* DateOfLastSundayBeforeSODST = SODST - (SODST//7+1) */
       If SODST<EODST Then                                   /* #ANZ */
       StartOfDST=DATE("S",DATE("B",thisYear""SODST,"S"),
         -(DATE("B",thisYear""SODST,"S")//7+1),"B")
       Else                                                  /* #ANZ */
       StartOfDST=DATE("S",DATE("B",thisYear-1""SODST,"S"),  /* #ANZ */
         -(DATE("B",thisYear-1""SODST,"S")//7+1),"B") /* #ANZ */

       /* find end of daylight saving time */
       /* DateOfLastSundayBeforeEODST = EODST - (EODST//7+1) */
       EndOfDST=DATE("S",DATE("B",thisYear""EODST,"S"),
         -(DATE("B",thisYear""EODST,"S")//7+1),"B")

       /* determine daylight/standard time */
       today = DATE("S")
       zone = Standard_Time

       /* ---------------------------------------- *
       * Correctly handle the 2am start/end point *
       * ---------------------------------------- */
       if today = StartOfDST then
       if time("h") < 2 then NOP
       else zone = DayLight_Time
       if today = EndOfDST then
       if time("h") > 1 then NOP
       else zone = DayLight_Time
       if (today > StartOfDST & today < EndOfDST)
       then zone = DayLight_Time

       /* return the appropriate timezone offset */
       RETURN zone

       /**************************************************************
       * section to set some variables                              *
       **************************************************************/
     sub_init:
       parse value "" with custsym sym_vars zip_load z_hlq cu_add
       hex01  =  c2x("01") ;
       hex02  =  c2x("02") ;
       hex39  =  c2x("39") ;
       hex41  =  c2x("41") ;
       _vals_ = ""
       do i = 254 to 200 by -1
         _vals_ = ""_vals_""d2c(i)" " ;
       end
       sep_vars = "/ "hex41" "hex39" "hex02" "hex01;
       sep_vars = "/ "_vals_
       xmitipcu_rc  = 0
       xmitipcu_msg = ""
       global_vars = "null xmitipcu_rc xmitipcu_msg"
       return 0 ;

       /**************************************************************
       * function to count all occurences of needle in haystack     *
       **************************************************************/
     sub_needle: procedure expose (global_vars)
       parse arg needle haystack
       _n_  = ,
         length(space(translate(haystack,needle,needle""xrange('00'x,'FF'x)),0))
       /* 2 quotes between needle and xrange */
       return _n_ ;

     sub_rstring:
       parse arg _parms_
       parse var _parms_ 1 . "SEP="_s_ .
       _ret_  = ,
         _s_  _center_  _s_  zone  _s_  smtp ,
         _s_  vio  _s_  smtp_secure  _s_  smtp_address ,
         _s_  smtp_domain  _s_  text_enter ,
         _s_  sysout_class  _s_  from_center  _s_  writer ,
         _s_  mtop  _s_  mbottom  _s_  mleft  _s_  mright ,
         _s_  tcp_hostid _s_ tcp_hostname _s_ tcp_domain ,
         _s_  tcp_stack ,
         _s_  from_default ,
         _s_  append_domain  _s_  zip_type  _s_  zip_load ,
         _s_  zip_hlq  _s_  zip_unit ,
         _s_  interlink  _s_  size_limit ,
         _s_  batch_idval  _s_  create_dsn_lrecl ,
         _s_  receipt_type  _s_  paper_size ,
         _s_  file_suf _s_ force_suf ,
         _s_  mail_relay  _s_  AtSign ,
         _s_  ispffrom  _s_  fromreq ,
         _s_  char  _s_  charuse  _s_  disclaim  _s_  empty_opt ,
         _s_  font_size  _s_  def_orient ,
         _s_  conf_msg  _s_  metric ,
         _s_  descopt  _s_  smtp_method  _s_  smtp_loadlib ,
         _s_  smtp_server  _s_  deflpi  _s_  nullsysout ,
         _s_  default_hlq  _s_  msg_summary  _s_  site_disclaim ,
         _s_  zipcont  _s_  feedback_addr  _s_  rfc_maxreclen ,
         _s_  restrict_domain  _s_  log ,
         _s_  faxcheck  _s_  tpageend  _s_  tpagelen,
         _s_  from2rep  _s_  dateformat  _s_  validfrom ,
         _s_  systcpd  _s_  restrict_hlq  _s_  default_lang ,
         _s_  disable_antispoof  _s_  special_chars ,
         _s_  send_from  _s_  Mime8bit ,
         _s_  jobid  _s_  jobidl  _s_  custsym ,
         _s_  codepage_default ,
         _s_  encoding_default _s_  encoding_check ,
         _s_  check_send_from ,
         _s_  check_send_to ,
         _s_  smtp_array ,
         _s_  txt2pdf_parms ,
         _s_  xmitsock_parms ,
         _s_  xmitipcu_infos ,
         _s_ starttls _s_ mailfmt ,
         _s_  antispoof" " _s_""_s_""cu_add
       /* antispoof is always last    */
       /* finish with two separators  */

       return _ret_ ;

       /**************************************************************
       * Trap uninitialized variables                               *
       **************************************************************/
     sub_novalue:
       Say " "
       Say "Variable" ,
         condition("Description") "undefined in line" sigl":"
       Say sourceline(sigl)
       if sysenv           <> "FORE" then exit 8
       say "Report the error in this application along with the",
         "syntax used."
       exit 8

     sub_check:
       parse source ,
         rexxenv rexxinv rexxname rexxdd rexxdsn . rexxtype addrspc .
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
       ER.2 = 'An error has occurred in Rexx module:' rexxname
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
           txt.0 = 0  /* deactivate msg lines */
         end;
         otherwise nop ;
       end;
       do i = 1 to txt.0
         say txt.i
       end;
       return ret_str


       /* ------------------------------------------------ *
       * Subroutines to determine                         *
       *   jobid    i.e. J12345                           *
       *   jobidl   i.e. JOB12345 (full name)  5 digits   *
       *   jobidl   i.e. J0123456 (full name)  7 digits   *
       *   other TYPEs possible                           *
       *   TSUnnnnn                                       *
       *   STCnnnnn                                       *
       *   OMVSnnnn                                       *
       * ------------------------------------------------ *
       *   Use the first char of JOBIDL (8 chars) and all *
       *   chars beginning with the first numeric value   *
       * ------------------------------------------------ */
     gen_jobid: procedure expose (global_vars) ,
         _stepname_ _procstep_ _program_ ,
         jobid  jobidl
       tcb      = ptr(540)
       tiot     = ptr(tcb+12)
       jscb     = ptr(tcb+180)
       ssib     = ptr(jscb+316)
       jobidl   = stg(ssib+12,8)
       jobidl   = strip(jobidl)
       _jobidn_ = null
       do _idx_ = 1 to length(jobidl)
         _jobidc_ = substr(jobidl,_idx_,1)    /* only 1 char */
         if datatype(_jobidc_) = "NUM" ,
           then do;
           _jobtype = substr(jobidl,1,_idx_-1)
           _jobidn_ = substr(jobidl,_idx_)
           leave
         end;
       end;
       jobid    = substr(jobidl,1,1)""_jobidn_
       _stepname_ = strip(stg(tiot+8,8))
       _procstep_ = strip(stg(tiot+16,8))
       _program_  = strip(stg(jscb+360,8))
       return

       /* ------------------------------------------------ *
       * Subroutines to generate default hlq              *
       * i.e. for batch jobs if your schedule system      *
       *       needs special FLQs                         *
       * sample for                                       *
       *    USERID (scheduler): X#TWSZB                   *
       *    MODEL userid prefix X#TWS                     *
       *                                                  *
       *    sysplex = X00 (beginning with "X00")          *
       *    _gen_id: TWS userid of batch job  X#TWSZB     *
       *    xgenmid: model userid prefix      X#TWS       *
       *    xgenlen: amount of chars for substring (i.e.2)*
       *    --> HLQ: XZBPZ                                *
       * ------------------------------------------------ *
       * extended version with parms (very flexible)      *
       *   (This variation could be called via            *
       *    section sub_site_setting.)                    *
       *                                                  *
       * - userid                                         *
       * - model                                          *
       * - start                                          *
       * - length                                         *
       * - additional parms:                              *
       * -- <PRE>...</PRE>                                *
       * -- <MID>...</MID>                                *
       * -- <SUF>...</SUF>                                *
       * -- <REP>...</REP>                                *
       * --- with rep_char (start (lenght))               *
       *                                                  *
       * i.e.                                             *
       * custchar      = (any char)                       *
       * def_hlq_parms = sysuid"",                        *
       *                  custchar"#TWS",                 *
       *                  "1 1 <SUF>PZ</SUF>",            *
       *                  "<REP>"custchar</REP>",         *
       *                  ""                              *
       * default_hlq = gen_default_hlq(def_hlq_parms)     *
       *  I#TWSZB I#TWS 1 1 <SUF>PZ</SUF> <REP>X</REP>    *
       *    --> IZBPZ                                     *
       *    --> XZBPZ (after REPLACE)                     *
       * ------------------------------------------------ */
     gen_default_hlq: procedure expose (global_vars) ,
         custchar lpar ,
         sysuid sysname sysplex sysenv hash
       parse arg gen_parms
       default_hlq = null
       parse var gen_parms 1 . ,
         1 _gen_id xgenmid _start_ _length_  . ,
         1 . "<PRE>"    _pre_    "</PRE>"    . ,
         1 . "<MID>"    _mid_    "</MID>"    . ,
         1 . "<SUF>"    _suf_    "</SUF>"    . ,
         1 . "<REP>"    _rep_    "</REP>"    . ,
         1 . "<CHK>"    _chk_    "</CHK>"    . ,
         1 . "<HLQ#CC>" _hlq#cc_ "</HLQ#CC>" . ,
         1 .
       select ;
         when ( words(gen_parms) > 1 ) ,
           then nop
         when ( words(gen_parms) = 1 ) ,
           then   xgenmid = "NOT-SET"
         when ( words(gen_parms) = 0 ) ,
           then do;
           _gen_id = sysuid
           xgenmid = "NOT-SET"
         end;
         otherwise nop
       end
       if   _hlq#cc_ = null ,
         then _hlq#cc_ = 4

       /* generate check messages ... */
       select;
         when ( abbrev(_chk_,"N") = 1 )  then _chk_ = "NO"
         when ( abbrev(_chk_,"I") = 1 )  then _chk_ = "INFO"
         when ( abbrev(_chk_,"E") = 1 )  then _chk_ = "ERROR"
         when ( abbrev(_chk_,"W") = 1 )  then _chk_ = "WARNING"
         otherwise                            _chk_ = "ERROR"
       end
       if _gen_id  = "."  then _gen_id  = sysuid
       if datatype(_start_)  = "NUM" ,
         then nop;
       else _start_  = 1
       if datatype(_length_) = "NUM" ,
         then nop;
       else _length_ = 1

       select ;
         when ( "DUMMY" = "YMMUD"        ) then do
         end; /* DUMMY */
         when( left(sysplex,3) ) = "000" ,
           then do ;
           x_val = null
           xgenmid = "X"hash"TWS"
           xgenlid = length(xgenmid)
           xgenlen = 2
           if left(_gen_id,xgenlid) = xgenmid ,
             then do ;
             if length(_gen_id) >= xgenlid + xgenlen
             then do ;
               x_val = substr(_gen_id,xgenlid+1,xgenlen)
               default_hlq = substr(_gen_id,1,1)""x_val"PZ"
             end;
           end;
         end;
         otherwise ,
           do;
           _gen_id = _gen_id
           xgenmid = xgenmid
           select;
             when ( abbrev(_gen_id,xgenmid) = 1 ) ,
               then do;
               parse var _gen_id 1 (xgenmid) xgenlid
               xgenlid = strip(xgenlid)
               default_hlq = ,
                 ""_pre_"",
                 ""substr(xgenmid,_start_,_length_)"",
                 ""_mid_"",
                 ""xgenlid"",
                 ""_suf_"",
                 ""
               default_hlq = space(default_hlq,0)
               /* new default_hlq generated ...  *
               * anything to replace?           *
               * chars start length             */
               if _rep_ = null ,
                 then nop;
               else do;
                 parse var _rep_ _rchar_ _rs_ _rl_ .
                 if datatype(_rs_) = "NUM"  ,
                   then nop
                 else _rs_ = 1
                 if datatype(_rl_) = "NUM"  ,
                   then nop
                 else _rl_ = length(_rchar_)
                 _f_ = substr(default_hlq,1,_rs_-1)
                 _m_ = substr(default_hlq,_rs_,_rl_)
                 _l_ = substr(default_hlq,_rs_+_rl_)
                 default_hlq_new = _f_""_rchar_""_l_
                 default_hlq = ,
                   default_hlq_new" "default_hlq
               end;
             end;
             otherwise nop;
           end;
         end;
       end;

       /* now check if the generated hlq(s) is(are) valid    *
       *  otherwise reset to null                           */
       Select
         when ( sysvar("syspref") = null ) ,
           then do
           hlq  = sysvar("sysuid")
         end
         when ( sysvar("syspref") <> sysvar("sysuid") ) ,
           then do
           hlq  = sysvar("syspref")
           if sysvar("sysuid") = null ,
             then nop
           else hlq  = hlq"."sysvar("sysuid")
         end
         otherwise do
           hlq  = sysvar("syspref")
         end
       end
       default_hlq_standard = hlq
       if strip(default_hlq) = null ,
         then     default_hlq = strip(default_hlq_standard)
       else     default_hlq = strip(default_hlq)" ",
         strip(default_hlq_standard)

       if strip(default_hlq) = null ,
         then nop;
       else do;
         _hlq_msg_.0 = 0
         _hlqs_ = strip(default_hlq)
         default_hlq = ""
         do i = 1 to words(_hlqs_)
           _hlq_ = word(_hlqs_,i)
           parse var _hlq_ 1 _entry_ "." .
           x = outtrap("outline.",'*',"noconcat")
           "listc entry('"_entry_"')"
           rcode = rc
           x = outtrap("OFF")
           if rcode = 0 ,
             then do;
             default_hlq = _hlq_
             leave
           end;
           else do;
             _hlq_msg_.0   = _hlq_msg_.0 + 1
             idx           = _hlq_msg_.0
             _hlq_msg_.idx = ""outline.1""
           end;
         end
         if default_hlq = "" ,
           then do;
           msg_def_hlq = null
           if words(_hlqs_) = 1 ,
             then alias_text = "entry"
           else alias_text = "entries"
           _t_ = "ERROR - no default_hlq could be verified",
             "for USERID="userid()".",
             ""
           msg_def_hlq = msg_def_hlq"<MSG>"_t_"</MSG>"
           _t_ = "(checked the following ALIAS "alias_text")"
           msg_def_hlq = msg_def_hlq"<MSG>"_t_"</MSG>"
           do i = 1 to _hlq_msg_.0
             msg_def_hlq = ""msg_def_hlq"",
               "<MSG>"_hlq_msg_.i"</MSG>",
               ""
           end
           if _chk_ = "NO" ,
             then nop
           else do;
             msg_new = ,
               "<MSGDEFHLQ>"msg_def_hlq"</MSGDEFHLQ>"
             if xmitipcu_rc = 0 ,
               then xmitipcu_rc  = ,
               max(xmitipcu_rc,_hlq#cc_) ;
             if xmitipcu_rc > 0 ,
               then do;
               if xmitipcu_msg = msg_new ,
                 then nop;
               else do;
                 xmitipcu_msg = ,
                   xmitipcu_msg""msg_new
               end;
             end;
             xmitipcu_rc  = ,
               max(xmitipcu_rc,_hlq#cc_) ;
           end;
         end;
       end;

       select;
         when ( words(default_hlq) = 0 ) then nop;
         when ( words(default_hlq) = 1 ) ,
           then do;
           /* say "DEBUG default_hlq set to: "default_hlq  */
           nop;
         end;
         otherwise do;
           nop;
         end;
       end;
       return default_hlq

       /* --------------------------------------------------- */
       /* Subroutine to set codepage string and special chars */
       /* --------------------------------------------------- */
     sub_cp_setting:
       parse arg _data_
       cpdef = word(_data_,1)
       _cc_ = 0
       if datatype(cpdef) = "NUM" ,
         then do;
         cpdef = cpdef + 0
         do idx = 1 to cp.0
           cp_id = word(cp.idx,1) + 0
           if cp_id = cpdef ,
             then do;
             cp = cp.idx
             leave
           end;
         end;
         special_chars = cp
         excl      = substr(word(special_chars,2),1,1)
         hash      = substr(word(special_chars,2),8,1)
       end;
       else do;
         _cc_ = 8
       end;
       return _cc_

       /* --------------------------------------------------- */
       /* Subroutine for general site settings                */
       /* --------------------------------------------------- */
     sub_site_settings:
       site_settings = 0 ;
       if site_settings = 0 then return 0 ;

       _center_ = SYSNODE

       /* ------------------------------------------------------- *
       * sample for building logmsg                              *
       *   logmsg is added to the usage message                  *
       *   header version logmsg                                 *
       * ------------------------------------------------------- */
       _procstep_ = strip(word(_procstep_" N/A",1))
       _stepname_ = strip(word(_stepname_" N/A",1))
       _program_  = strip(word(_program_"  N/A",1))
       logtype = "U"  /* log usage message               */
       logmsg = ,
         left(_procstep_,8)"",
         left(_stepname_,8)"",
         left(_program_,8)""
       logmsg  = logmsg" '"left(custchar"I",1)"ZBP.XMITIP.EXEC'"
       logdsn  = "'"left(custchar"I",1)"ZBP.XMITIP.USAGE.LOGFILE'"

       /*                                                   */
       /*    custsym = custsym ,                            */
       /*              "&test Laurel & Hardy"               */
       /*    custsym = custsym ,                            */
       /*              "&cust1 XMITIP"   ,                  */
       /*              "&cust2 Rocks"    ,                  */
       /*              ""                                   */
       /*                                                   */
       sym_vars = "custplex custname custchar lpar "

       idat = ,
         translate("1234-56-78",date("s"),"12345678")  /*iso date*/
       custinfo  = ""left(jobname,8),
         ""left(jobidl,8),
         ""left(idat,10),
         ""left(TIME("N"),8)
       custinfo  = "&custinfo "custinfo
       custsym   = custsym" "custinfo
       custver   = "&custver" xmitip("VER")
       custsym   = custsym" "custver

       charuse = 0
       dateformat = "I"
       metric = "c"
       check_send_from_use  = "Y"
       /*  check_send_from_exit = "xmitzex1" */  /* default */
       faxcheck = "$FAX"
       TPageEnd = 1
       tpagelen = 140
       size_limit = 12582912  /* 12mb, ie. 12 * 1,048,576 */
       encoding_default = "WINDOWS-1252"    /* new default */
       mask_user = "Y"       /* null or not-null */
       mask_job  = "Y"       /* null or not-null or force */

       zip_type = "INFOZIP"

       tcp_stack      = ""
       txt2pdf_parms  = "",
         "<COMPRESS>9</COMPRESS>",
         "<XLATE>TXT2PDFX</XLATE>",
         ""
       txt2pdf_parms  = "",
         "<COMPRESS>9</COMPRESS>",
         ""

       _junk_ = sub_cp_setting(1141); /* set default 1141 GERMAN E */

       if zip_available = "N" ,
         then do ;
         zip_load = ""
       end;
       else do ;
         zip_load = ""
         if zip_type = "PKZIP" ,
           then do ;
           custchar = MVSVAR("SYMDEF","CUSTCHAR")
           flq.1    = ""left(custchar"I",1)"ZBP"
           flq.2    = "IZBP"
           flq.0    = 2
           if flq.1 = flq.2 then flq.0 = 1
           do zidx = 1 to flq.0
             zipl = "'"flq.zidx".PKZIP.LOAD(pkzip)'"
             if SYSDSN(zipl) = "OK" ,
               then do ;
               zip_load = zipl
               leave
             end;
           end;
         end;
       end;

       /* sample additional parm for backup HLQ */
       xmitsock_parms = "",
         "B(TEMP.XMITSOCK.)",
         ""

       /* additional settings for the EDIT macro XMIT#IVP */

       _cmds_    = ""
       _cmds.0   = 0
       if nlschars = null ,
         then nop
       else do;
         _cmds.0 = _cmds.0 + 1
         _cmdidx = _cmds.0
         _cmds._cmdidx = "nlschars='"nlschars"';"
       end;
       _cmds.0 = _cmds.0 + 1
       _cmdidx = _cmds.0
       _cmds._cmdidx = "_msgsamp_='Hello world.';"
       if _cmds.0 > 0 ,
         then do ;
         _cmds_ = _cmds_"<CMD>"
         do cidx = 1 to _cmds.0
           _cmds_ = _cmds_""_cmds.cidx
         end;
         _cmds_ = _cmds_"</CMD>"
         _cmds_ = strip(_cmds_)
       end;
       cu_add    = ""_cmds_""

       /* ------------------------------------------------------- *
       * sample definitions for check_send_to EXIT               *
       * check_send_to_exit  = "XMITZEX2"                        *
       * check_send_to_parms = "<OTHER>whatever</OTHER>"         *
       * ------------------------------------------------------- */
       return 0 ;
