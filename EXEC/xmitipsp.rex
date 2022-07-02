/* ------------------------  rexx procedure  ------------------------ */
 ver = "1.15"
/* Name: XMITIPSP                                                     *
 *                                                                    *
 * Function: To read an input file and separate it at the indicated   *
 *           breakpoints and then mail the separated section to the   *
 *           specified address(s) using XMITIP.                       *
 *                                                                    *
 * Syntax: %xmitipsp input-file control-file options                  *
 *                                                                    *
 * Where   input-file is a sequential data set that is to be          *
 *         processed and mailed using XMITIP                          *
 *                                                                    *
 *         input_file may also be specified as DD:ddname where        *
 *         the ddname refers to the input data set.                   *
 *                                                                    *
 *         control-file is a sequential data set containing           *
 *         the control information to manage the separation           *
 *         of the reports.                                            *
 *                                                                    *
 *         control-file may also be specified as DD:ddname where      *
 *         the ddname refers to the control data set.                 *
 *                                                                    *
 *         options may only be DEBUG at this time. If specified       *
 *                 the exec will execute but will only echo the       *
 *                 XMITIP command instead of calling XMITIP.          *
 *                                                                    *
 * The control statements supported in the Control File are:          *
 *                                                                    *
 * * in column 1 is a comment                                         *
 *                                                                    *
 * COMBINE        Combines all separated reports into single file     *
 *                and single e-mail based on KEYMAIL address.         *
 *                                                                    *
 *                The net result is that each KEYMAIL address         *
 *                will receive individual e-mails with a combined     *
 *                report of all KEYV values that match for them.      *
 *                                                                    *
 *                To keep each report in a unique file use the        *
 *                MERGEMAIL option instead of COMBINE.                *
 *                                                                    *
 * FILENAME=xxx   Where xxx is the filename to be generated in the    *
 *                e-mail that will be seen by the mail recipient      *
 *                                                                    *
 *                The filename may contain any of the symbolics       *
 *                supported by XMITIP for filename in addition to     *
 *                &sepval which is the value from the SEPLOC.         *
 *                                                                    *
 *                When using SEPLINES or SEPPAGES the symbolic of     *
 *                &sepnum can be used to be replaced by the number    *
 *                of the current split.                               *
 *                                                                    *
 *                ** This is required as the generated filename       *
 *                   from XMITIP would not be user friendly           *
 *                   based on the temporary separated report          *
 *                   data set that is passed to XMITIP.               *
 *                                                                    *
 * GMAIL=address  Is the same as KEYMAIL but is used with SEPLOC      *
 *                to eliminate the need to code redundant KEYMAIL     *
 *                addresses for multiple KEYV statements.             *
 *                                                                    *
 *                Each GMAIL address will be used with every          *
 *                KEYV statement.                                     *
 *                                                                    *
 *                Individual KEYMAIL statements may still be used     *
 *                with a KEYV if desired to send the separated        *
 *                reports to just that address for that KEYV.         *
 *                                                                    *
 * KEYMAIL=address Is the e-mail address to be used to e-mail the     *
 *                 separated report. Multiple KEYMAIL statements may  *
 *                 be coded and will be used with the immediately     *
 *                 prior KEYV.                                        *
 *                                                                    *
 *                 See GMAIL if the same address is in every KEYV     *
 *                                                                    *
 * KEYPREF=value   Defines a prefix string that must be found in the  *
 *                 Key Value (KEYV) to be considered a valid key.     *
 *                                                                    *
 * KEYV=sepvalue   A separation value that will be matched            *
 *       with the KEYMAIL address to identify where the mail          *
 *       is to be sent. There must be one KEYV keyword                *
 *       for every possible value to be found in the                  *
 *       input data and each KEYV must have an associated             *
 *       KEYMAIL keyword which must immediately follow its            *
 *       owning KEYV keyword in the control file.                     *
 *                                                                    *
 *       Embedded blanks are allowed but trailing blanks will         *
 *       be ignored.                                                  *
 *                                                                    *
 *       Masking is:   ? masks any single character                   *
 *                     * masks current and all subsequent characters  *
 *                                                                    *
 *       Note: May not use ? and * in the same mask.                  *
 *                                                                    *
 *       Note 2:  GMAIL may be used in place of, or in addition to,   *
 *                KEYMAIL.                                            *
 *                                                                    *
 * KEYSUBJ=xx     A Subject that will be used for the associated      *
 *                KEYV value                                          *
 *                                                                    *
 *                Will override any SUBJECT for the KEYV mail.        *
 *                                                                    *
 *                All of the supported subject symbolics allowed by   *
 *                XMITIP may be used in this subject.                 *
 *                                                                    *
 *                *** Not supported with COMBINE or MERGEMAIL         *
 *                                                                    *
 * MERGEMAIL      Indicates that all separations based on KEYV values *
 *                will be consolidated with other separations in the  *
 *                e-mail but will remain separate files.              *
 *                                                                    *
 *                This is different from COMBINE.                     *
 *                                                                    *
 *                When this option is used then the FILENAME *should* *
 *                use &SEPVAL so that the recipient can easily        *
 *                differentiate the file attachments.                 *
 *                                                                    *
 *                Note that is the SEPVAL contains blanks, ( or )     *
 *                characters they will be translated to _ in the      *
 *                resulting FileName.                                 *
 *                                                                    *
 *                If using XMITIPCONFIG to include a FORMAT you       *
 *                should use the form of FORMAT of FORMAT *xxx/....   *
 *                to apply the format to all file attachments         *
 *                                                                    *
 * MSGDD=ddname   is the DDname where the Message Text is to be       *
 *                found that will be included with each e-mail        *
 *                                                                    *
 * MSGDS=dsname   is the Data Set name where the Message Text is      *
 *                to be found that will be included with each e-mail  *
 *                                                                    *
 * MSGSTART   Indicates that the records that follow are to be        *
 *            used as the message text.                               *
 *                                                                    *
 * MSGEND      Indicates the end of the message text.                 *
 *                                                                    *
 * SEPLOC=col/len/row                                                 *
 *       Is the column, length and row (separated by a /) where       *
 *       the separation value is to be found. If row is not           *
 *       specified then the SEP value will be checked in              *
 *       the indicated column in every row. When the value            *
 *       changes an e-mail will be generated.                         *
 *                                                                    *
 *       Note that row is the physical input record and               *
 *       not the printed row.                                         *
 *      * mutually exclusive of SEPLINES and SEPPAGES                 *
 *                                                                    *
 * SEPLINES=nnnn defines the number of lines per e-mail               *
 *               * mutually exclusive of SEPLOC and SEPPAGES          *
 *                                                                    *
 * SEPPAGES=nnnn defines the number of pages per e-mail               *
 *               * mutually exclusive of SEPLOC and SEPLINES          *
 *                                                                    *
 * SUBJECT=xxx   is the subject for the generated e-mail              *
 *                                                                    *
 *               All of the supported subject symbolics allowed by    *
 *               XMITIP may be used in this subject.                  *
 *                                                                    *
 *               A special symbolic of &sepval can be used which will *
 *               be replaced by the text found in the separation value*
 *               location for the specified length (see SEPV)         *
 *                                                                    *
 *               When using SEPLINES or SEPPAGES the symbolic of      *
 *               &sepnum can be used to be replaced by the number     *
 *               of the current split.                                *
 *                                                                    *
 *               ** Will be over-ridden by KEYSUBJ                    *
 *                                                                    *
 * TO=xxx        Specifies the recipient e-mail address for the       *
 *               separated reports. This option is only valid         *
 *               if SEPLINES or SEPPAGES are used.                    *
 *                                                                    *
 *               Multiple TO statements may be coded to allow         *
 *               additional addresses to receive the reports.         *
 *                                                                    *
 * XMITIPCONFIG=xxx is the configuration data set name or ddname      *
 *                  of the XMITIP Configuration information.          *
 *                                                                    *
 *              where xxx is a data set name                          *
 *                        or DD:ddname                                *
 *                                                                    *
 *              ** This is required to provide the XMITIP options     *
 *                 to be used.                                        *
 *                                                                    *
 * The REQUIRED keywords are:                                         *
 *                                                                    *
 *    FILENAME                                                        *
 *    KEYV with KEYMAIL (if SEPLOC is coded)                          *
 *    SEPLOC, SEPLINES, or SEPPAGES                                   *
 *    TO (if SEPLINES or SEPPAGES are coded)                          *
 *    XMITIPCONFIG                                                    *
 *                                                                    *
 * Notes:                                                             *
 *         KEYPREF may not be coded with SEPLINES or SEPPAGES         *
 *         MSGDD, MSGDS, and MSGSTART/MSGEND are mutually exclusive.  *
 *         SEPLINES, SEPLOC, and SEPPAGES are mutually exclusive      *
 *         SEPLOC and TO                                              *
 *                                                                    *
 * Sample Execution JCL:                                              *
 *                                                                    *
 *         //TSOB     EXEC PGM=IKJEFT1B,DYNAMNBR=200                  *
 *         //SYSEXEC  DD  DISP=SHR,DSN=system.rexx.library            *
 *         //SYSPRINT DD  SYSOUT=*                                    *
 *         //SYSTSPRT DD  SYSOUT=*                                    *
 *         //REPORT   DD  SYSOUT=*                                    *
 *         //SYSTSIN  DD  *                                           *
 *         %xmitipsp input control                                    *
 *         //                                                         *
 *                                                                    *
 *        NOTE: The REPORT DD is optional - this is where the         *
 *              XMITIPSP processing information will be reported      *
 *              and if not defined the report will go to the          *
 *              SYSTSPRT DD.                                          *
 *                                                                    *
 *              The DYNAMNBR=200 on the EXEC statement defines how    *
 *              many dynamically allocated data sets are allowed in   *
 *              this Batch TSO step. If there are a lot of KEYMAIL    *
 *              addresses this value may need to be increased.        *
 *                                                                    *
 *                                                                    *
 * Author:    Lionel B. Dyck                                          *
 *            Internet: lbdyck@gmail.com                              *
 *                                                                    *
 * History:                                                           *
 *          2018-06-29 - 01.15 Correction to support blank records    *
 *                       in MSGSTART/MSGEND                           *
 *          2010-07-06 - 01.14 Data-Tronics (JC Ewing), reset linec   *
 *                       in New_Split to avoid spurious lines when    *
 *                       seploc on row 1. Keep linec always as lines  *
 *                       in page array.                               *
 *          2009-10-19 - 01.13                                        *
 *                     - Kaiser Modification (thx Mitchel Dehler)     *
 *                       Changing logic used to reset LINEC back to   *
 *                       01.11 version                                *
 *          2008-12-01 - 01.12                                        *
 *                     - use quotes for x2c strings                   *
 *          2007-11-14 - v1.11                                        *
 *                     - Corrections from Jean Quintal for work space *
 *          2005-01-24 - v1.10                                        *
 *                     - Correct Report in Batch                      *
 *          2004-04-09 - v1.09                                        *
 *                     - Generate REPORT on the fly instead of waiting*
 *                       and if no REPORT then report to SYSTSPRT     *
 *          2004-03-16 - v1.08 (jbs)                                  *
 *                     - Exit only if SEPLOC ROW specified and no CC  *
 *                       in the input DCB RECFM (modifies v0.09 mods) *
 *                     - Remove requirement for control statements    *
 *                       (except * for comment) to begin in column 1. *
 *          2004-02-05 - v1.07                                        *
 *                     - Add KEYSUBJ keyword                          *
 *          2003-12-12 - v1.06                                        *
 *                     - Corrections for MERGEMAIL usage on last page *
 *                       thanks to David G. Clark.                    *
 *          2003-12-03 - v1.05                                        *
 *                     - Add MERGEMAIL option and associated function.*
 *                     - Add space in column 1 for REPORT records     *
 *          2003-11-10 - v1.04                                        *
 *                     - Add GMAIL keyword and associated function.   *
 *          2003-10-28 - v1.03                                        *
 *                     - Correct to not try e-mail if no separation   *
 *                       with combine for an address                  *
 *                     - Correct if seploc and 1st page is not        *
 *                       included in any key                          *
 *          2003-10-22 - v1.02                                        *
 *                     - Correct reporting for Separation KEYV        *
 *                     - Minor tweak in report                        *
 *          2003-10-21 - v1.01                                        *
 *                     - Add support for masking the KEYV value       *
 *          2003-10-15 - v1.00                                        *
 *                     - Change to version 1.00 as this  seems very   *
 *                       stable                                       *
 *          2003-10-15 - v0.91                                        *
 *                     - Minor cleanup and correction for MSGDD       *
 *          2003-10-14 - v0.90                                        *
 *                     - Correction for Combine multiple e-mails      *
 *                     - Correction for freeing work files            *
 *          2003-10-13 - v0.10                                        *
 *                     - Add COMBINE option                           *
 *          2003-10-09 - v0.09                                        *
 *                     - Exit if SEPLOC specified and no CC in the    *
 *                       input DCB RECFM                              *
 *                     - Exit if SEPPAGES specified and no CC in the  *
 *                       input DCB RECFM                              *
 *          2003-10-08 - v0.08                                        *
 *                     - Report duplicate SUBJECT keyword usage       *
 *                     - Report duplicate FILENAME keyword usage      *
 *                     - Improve Reporting when sending reports       *
 *                     - other minor cleanup                          *
 *          2003-10-03 - v0.07                                        *
 *                     - Report XMITIPSP messages on REPORT DD        *
 *          2003-10-02 - v0.06                                        *
 *                     - Strip trailing blanks from sepval and thus   *
 *                       improve key detection and separation.        *
 *                       Thanks to David Clark of Brown University    *
 *          2003-09-24 - v0.05                                        *
 *                     - Allow comments in Control File               *
 *                       and report comments out                      *
 *                     - Correct bug with 2 symbolics (&sepnum and    *
 *                       &sepval) in subject of filename              *
 *          2003-09-24 - v0.04                                        *
 *                     - Add KEYPREF keyword                          *
 *                     - Major corrections if key not on line 1       *
 *          2003-09-23 - v0.03                                        *
 *                     - Remove PAGESEP statement and dynamically     *
 *                       determine the carriage control value         *
 *          2003-09-23 - v0.02                                        *
 *                     - Report on KEYV values that are found in the  *
 *                       input file that are ignored because the user *
 *                       did not request them.                        *
 *                     - Allow subject coded in quotes (' and ")      *
 *                     - Allow multiple TO statements                 *
 *          2003-09-23 - v0.01                                        *
 *                     - Major coding and testing.                    *
 *          2003-09-21 - Creation of header and specs                 *
 *                                                                    *
 * ------------------------------------------------------------------ */

/* --------------------------------------------------------- *
 * Get the input parameters from the command line.           *
 *   INPUT is the input data set to process                  *
 *   CONTROL is the control file with our control statements *
 * --------------------------------------------------------- */
 parse arg input control options

msgid = "XMITIPSP:"

/* ----------------------------------- *
 * Convert input/control to upper case *
 * ----------------------------------- */
 input   = translate(input)
 control = translate(control)

/* ---------------------- *
 * Test validity of INPUT *
 * ---------------------- */
if left(input,3) <> "DD:" then
if sysdsn(input) <> "OK" then do
   say msgid "Error: the specified input data set" input ,
       "has the following error."
   say msgid sysdsn(input)
   say msgid "Exiting....."
   exit 8
   end

/* ------------------------ *
 * Test validity of CONTROL *
 * ------------------------ */
if left(control,3) <> "DD:" then
if sysdsn(control) <> "OK" then do
   say msgid "Error: the specified control data set" control ,
       "has the following error."
   say msgid sysdsn(control)
   say msgid "Exiting....."
   exit 8
   end

/* ------------ *
 * Test Options *
 * ------------ */
 if wordpos("DEBUG",translate(options)) > 0 then
    debug = 1
 else debug = 0
 if wordpos("TRACE",translate(options)) > 0 then
    trace "i"

/* ----------------------------------- *
 * Setup the defaults for this routine *
 * ----------------------------------- */
parse value "" with key. keys len filename null ,
                    col len row subject xmconfig ,
                    seplines seppages septo free_msg ,
                    msgdd msgds msgflag first sepval ,
                    pagesep keypref log. gmail ,
                    combine cmailids combmail. msgerr ,
                    mergeflag mergeids mergemail. mergedd. ,
                    mergedds sub. keysubjf report

 sepcount  = -1
 msgtext.0 = 0
 mails     = 0
 lrecl     = 80
 key.      = null
 log.0     = 0
 cdd       = 0

 xmdd     = "XMSP"random(9999)
 if left(input,3) = "DD:" then do
    parse value input with "DD:"xmidd .
    end
 else do
      xmidd    = "XMISP"random(999)
      "Alloc f("xmidd") shr reuse ds("input")"
      end

/* --------------------------------------- *
 * Determine if the REPORT DD is allocated *
 * --------------------------------------- */
 call listdsi "report" "file"
 if pos(sysreason+0,"03") > 0
    then report = 1
    else report = 0

/* ------------------------------ *
 * Find Carriage Control on Input *
 * ------------------------------ */
 call listdsi(xmidd "FILE")
 if pos(right(sysrecfm,1),"AM") > 0 then
    cc = right(sysrecfm,1)
 else cc = null
 if cc = "A" then pagesep = "1"
 if cc = "M" then pagesep = x2c("89 8b")

/* ---------------------------- *
 * Read in the Control data set *
 * ---------------------------- */
if left(control,3) = "DD:" then
    "Execio * diskr" substr(control,4) "(finis stem control."
else do
    "Alloc f("xmdd") shr reuse ds("control")"
    "Execio * diskr" xmdd "(finis stem control."
    "Free  f("xmdd")"
    end

 call add_log "XMITIP Splitter Utilty version" ver
 call add_log " "
 call add_log "Control Statements:"
 call add_log " "

/* --------------------------- *
 * Process the control records *
 * --------------------------- */
do i = 1 to control.0
   if left(control.i,1) = "*" then do
      call add_log "Comment:" control.i
      iterate
      end
   record = translate(control.i)
   parse var control.i keywd '=' keyval
   keywd = translate(strip(keywd,"L"))
   Select
      When word(record,1) = "MSGEND" then do
           msgflag = null
           msgtext.0 = msgc
           call add_log "End of Inline Message Text selection."
           end
      When msgflag = 1 then do
           msgc = msgc + 1
           msgtext.msgc = strip(control.i,'t')
           if length(msgtext.msgc) = 0 then msgtext.msgc = '   '
           if length(msgtext.msgc) > lrecl
              then lrecl = length(msgtext.msgc)
           end
      When keywd = "FILENAME" then do
           if filename <> null then do
              call add_log "Warning... Duplicate FILENAME keyword",
                           "specifed."
              call add_log " Overriding filename:" filename
              call add_log "   with new filename:" strip(substr(control.i,10))
              end
           filename = strip(keyval)
           call add_log "Filename:" filename
           end
      When keywd = "COMBINE" then do
           combine = 1
           call add_log "Combine: Enabled"
           end
      When keywd = "MERGEMAIL" then do
           mergeflag = 1
           call add_log "Mergemail: Enabled"
           end
      When keywd = "GMAIL" then do
           if keys <> null then do
              call add_log "Error: GMAIL keyword incorrectly used."
              call add_log "       GMAIL must be used BEFORE any" ,
                           "KEYV statements."
              call add_log "Exiting..."
              end
           km = strip(keyval)
           if wordpos(km,gmail) = 0 then
              gmail = strip(gmail km)
           if wordpos(km,cmailids) = 0 then
              cmailids = cmailids km
           call add_log "Global Mail to:" km
           end
      When keywd = "KEYMAIL" then do
           km = strip(keyval)
           key.keyv = key.keyv km
           if wordpos(km,cmailids) = 0 then
              cmailids = cmailids km
           call add_log "Mail to:" km
           end
      When keywd = "KEYSUBJ" then do
           keysubjf = 1
           temp    = strip(keyval)
           if left(temp,1) = "'" then
              temp = substr(temp,2,length(temp)-2)
           if left(temp,1) = '"' then
              temp = substr(temp,2,length(temp)-2)
           call add_log "Key Subject:" temp
           sub.keyv = temp
           end
      When keywd = "KEYPREF" then do
           keypref = strip(keyval)
           keylen  = length(keypref)
           call add_log "KeyPref:" keypref
           end
      When keywd = "KEYV" then do
           keyv = strip(keyval)
           key.keyv = null
           xkeyv = translate(keyv,x2c("01"),' ')
           if pos("?",keyv) > 0 then
              if pos("*",keyv) > 0 then do
                 call add_log "Error: KEYV" keyv
                 call add_log "       contains both ? and * which is" ,
                              "not allowed."
                 call add_log "Exiting..."
                 end
           call add_log "New key:" keyv
           if gmail <> null then
              do cm = 1 to words(gmail)
                 key.keyv = key.keyv word(gmail,cm)
                 end
           if wordpos(xkeyv,keys) = 0
              then keys = strip(keys xkeyv)
           end
      When keywd = "MSGDD" then do
           parse value record with "MSGDD="msgdd .
           call add_log "MSGDD:" msgdd
           end
      When keywd = "MSGDS" then do
           parse value record with "MSGDS="msgds .
           call add_log "MSGDS:" msgds
           end
      When word(record,1) = "MSGSTART" then do
           msgflag = 1
           msgc    = 0
           drop msgtext.
           call add_log "Starting Inline Message Text selection."
           end
      When keywd = "SEPLOC" then do
           parse value record with "SEPLOC="col"/"len"/"row .
           call add_log "SEPLOC:" col"/"len"/"row
           end
      When keywd = "SEPLINES" then do
           parse value record with "SEPLINES="seplines
           call add_log "SEPLINES:" seplines
           end
      When keywd = "SEPPAGES" then do
           parse value record with "SEPPAGES="seppages
           call add_log "SEPPAGES:" seppages
           end
      When keywd = "SUBJECT" then do
           if subject <> null then do
              call add_log "Warning... Duplicate SUBJECT keyword",
                           "specifed."
              call add_log " Overriding subject:" subject
              call add_log "   with new subject:" strip(substr(control.i,9))
              end
           subject = strip(keyval)
           if left(subject,1) = "'" then
              subject = substr(subject,2,length(subject)-2)
           if left(subject,1) = '"' then
              subject = substr(subject,2,length(subject)-2)
           call add_log "SUBJECT:" subject
           end
      When keywd = "TO" then do
           septo = septo strip(keyval)
           call add_log "To:" strip(keyval)
           end
      When keywd = "XMITIPCONFIG" then do
           parse value record with "XMITIPCONFIG="xmconfig .
           call add_log "XMITIPCONFIG:" xmconfig
           end
      Otherwise do
           call add_log "Error: Invalid Control File Statement,"
           call add_log "keyword:" keywd
           call add_log control.i
           call add_log "Exiting....."
           call exit_code
           end
      end
  end

 call add_log " "
 call add_log "XMITIP Splitter Control Statement Processing Completed."
 call add_log " "

/* ------------------------------------------------------ *
 * Now validate that we have all the required information *
 * and that no mutually exclusive keywords were used.     *
 * ------------------------------------------------------ */
 if col <> null then do
 if length(keys) = 0 then do
    call add_log "Error: No KEYV values were specified."
    call add_log "Exiting..."
    call exit_code
    end
 if cc = null & row <> null then do
    call add_log "Error: SEPLOC ROW requested with input data" ,
                 "lacking carriage control in the DCB RECFM."
    call add_log "Exiting..."
    call exit_code
    end
    end
 if length(xmconfig) = 0 then do
    call add_log "Error: No XMITIPCONFIG (XMITIP Configuration) specified."
    call add_log "Exiting..."
    call exit_code
    end
 if length(filename) = 0 then do
    call add_log "Error: No FILENAME specified."
    call add_log "Exiting..."
    call exit_code
    end
 if length(seppages) > 0 then
    if cc = null then do
       call add_log "Error: SEPPAGES requested with input data" ,
                    "lacking carriage control in the DCB RECFM."
       call add_log "Exiting..."
       call exit_code
       end
 if length(seplines) + length(seppages) = 0 then
 if length(col) = 0 then do
    call add_log "Error: No SEPLOC value specified."
    call add_log "Exiting..."
    call exit_code
    end
 if length(seplines) + length(seppages) > 0 then
 if length(keypref) > 0 then do
    call add_log "Error: KEYPREF specification is invalid with"
    call add_log " SEPLINES or SEPPAGES."
    call add_log "Exiting..."
    call exit_code
    end
 if length(seplines) + length(seppages) > 0 then
 if length(septo) = 0 then do
    call add_log "Error: SEPLINES or SEPPAGES specified but no TO specified."
    call add_log "Exiting..."
    call exit_code
    end
 if combine = 1 then if mergeflag = 1 then cmerr = 1
 if mergeflag = 1 then if combine = 1 then cmerr = 1
 if cmerr = 1 then do
    call add_log "Error: COMBINE and MERGEMAIL are mutually exclusive."
    call add_log "Exiting..."
    call exit_code
    end
 if combine = 1 & mergeflag = 1 & keysubjf = 1 then do
    call add_log "Error: You specified eitehr COMBINE or MERGEMAIL"
    call add_log "along with KEYSUBJ. KEYSUBJ is not allowed with"
    call add_log "either COMBINE or MERGEMAIL."
    call add_log "Exiting..."
    call exit_code
    end
 if msgtext.0 > 0 then
   if length(msgdd) + length(msgds) > 0 then do
      call add_log "Error: You specified MSGSTART/MSGEND in the control"
      call add_log " records along with either MSGDD or MSGDS."
      call add_log "Exiting..."
      call exit_code
      end
 if length(msgdd) > 0
    then if length(msgds) > 0 then msgerr = 1
 if length(msgds) > 0
    then if length(msgdd) > 0 then msgerr = 1
 if msgerr = 1 then do
    err = null
    if length(msgdd) > 0 then err = "MSGDD"
    if length(msgds) > 0 then err = err "MSGDD"
    call add_log "Error: two or more mutually exclusive message keywords"
    call add_log " were specified. You specified:"
    call add_log err
    call add_log "Exiting..."
    call exit_code
    end

/* ------------------------------------------------------ *
 * If the Message Text was inline write it to a temporary *
 * data set and set the MSGDD for later use.              *
 * ------------------------------------------------------ */
 if msgtext.0 > 0 then do
    msgdd = "XMSG"random(999)
    free_msg = msgdd
    "Alloc f("msgdd") new spa(1,1) tr" ,
       "recfm(v b) lrecl("lrecl+4") blksize(0)"
    "Execio * diskw" msgdd "(finis stem msgtext."
    end

/* ---------------------------------------- *
 * Build the initial XMITIP command options *
 * ---------------------------------------- */
 xcmd = null

 if length(msgdd)    > 0 then xcmd      = "MSGDD" msgdd
 if length(msgds)    > 0 then xcmd      = "MSGDS" msgds
 if length(xmconfig) > 0 then do
 if left(xmconfig,3) = "DD:"
    then do
       parse value xmconfig with "DD:"txmconfig
       xcmd = xcmd "CONFIGDD" txmconfig
       end
    else xcmd = xcmd "CONFIG" xmconfig
    end

/* ----------------------------------- *
 * Begin Processing the Input file now *
 * ----------------------------------- */
 drop page.
 linec = 0
 rowc  = 0
 plrecl = 120
 do forever
    "Execio 1 diskr" xmidd "(stem in."
    if rc > 0 then leave
    if length(in.1) > plrecl
       then plrecl = length(in.1)
    Select
      When col <> null then do
           rowc = rowc + 1
           if pagesep <> null THEN
              if pos(left(in.1,1),pagesep) > 0 then do
                 last_page = linec
                 first = 1
                 rowc = 1
                 end
              ELSE NOP /* pagesep not found */
           ELSE DO  /* null pagesep, rowc doesn't apply */
              last_page = linec
              END
           if row = null then do
              if substr(in.1,col,len) <> left(" ",len) then do
                 if keypref <> null then do
                    if substr(in.1,col,keylen) = keypref then
                       if substr(in.1,col,len) <> sepval then do
                          call new_split
                          sepval = strip(substr(in.1,col,len))
                          end
                    end
                 if keypref = null then do
                    if substr(in.1,col,len) <> sepval then do
                       call new_split
                       sepval = strip(substr(in.1,col,len))
                       end
                    end
                 end
              end
           if row = rowc then do
              if substr(in.1,col,len) <> left(" ",len) then do
              if keypref <> null then do
                 if substr(in.1,col,keylen) = keypref then
                    if substr(in.1,col,len) <> sepval then do
                       call new_split
                       sepval = strip(substr(in.1,col,len))
                       end
                    end
              if keypref = null then do
                 if substr(in.1,col,len) <> sepval then do
                    call new_split
                    sepval = strip(substr(in.1,col,len))
                    end
                    end
                 end
              end
           linec = linec + 1
           page.linec = in.1
           end
      When seplines <> null then do
           sepcount = sepcount + 1
           if sepcount = seplines
              then call send_it
           linec = linec + 1
           page.linec = in.1
           end
      When seppages <> null then do
           if pos(left(in.1,1),pagesep) = 0 then do
              linec = linec + 1
              page.linec = in.1
              end
           else do
                sepcount = sepcount + 1
                if sepcount = seppages
                   then call send_it
                linec = linec + 1
                page.linec = in.1
                end
           end
      Otherwise nop
      end
    end

/* ---------------------------------------------------------- *
 * Encountered the end of file for the Input                  *
 * Now close the input file and process any remaining records *
 * ---------------------------------------------------------- */
"Execio * diskr" xmidd "(finis"

 call test_key

  if sub.rsepval <> null
     then subject = sub.rsepval

 skip = 0
 if col <> null then
    if key.sepval =  null
       then do
            call add_log "Skipping Key Value:   " sepval
            skip = 1
            end
       else do
            col = null
            septo = "("strip(key.sepval)")"
            end

 if skip = 0 then do
    if col = null then
         if combine = null & mergeflag <> 1 then call send_it /* dgc */
                         else do
                              last_page = linec
                              call new_split
                              end
    end

/* ------------------------------ *
 * Process all e-mails with MERGE *
 * ------------------------------ */
 if mergeflag = 1 then do
    call add_log " "
    save_filename = filename
    do i = 1 to words(mergedds)
       wdd = word(mergedds,i)
       "Execio * diskw" wdd "(finis"
       end
    do i = 1 to words(mergeids)
       filename = save_filename
       mm = word(mergeids,i)
       xmdd = mergemail.mm
       call add_log "Processing mail to:" mm
       fns = null
       do md = 1 to words(xmdd)
          ddn = word(xmdd,md)
          rsepval =  mergedd.ddn
          call add_log "      with sepvals:" rsepval
          rsepval = translate(rsepval,"___","()_")
          rsepval = translate(rsepval,"_"," ")
          fn      = proc_sym(filename)
          fns     = space(fns fn)
          end
       filename = fns
       septo = mm
       call do_mail
       end
    end

/* -------------------------------- *
 * Process all e-mails with COMBINE *
 * -------------------------------- */
 else if combine <> null then do
    call add_log " "
    do i = 1 to words(cmailids)
       septo = word(cmailids,i)
       xmdd  = combmail.septo
       if xmdd = null then do
          call add_log "No data separated for:" septo
          end
       else do
          "Execio * diskw" xmdd "(finis"
          call do_mail
          end
       end
    end

/* ------------------------------ *
 * Now free all the allocated DDs *
 * ------------------------------ */
 do i = 1 to cdd
    "Free F(CS"i")"
    end

 call add_log " "
 call add_log "Separation processing completed."
 call add_log mails "separations processed and mailed."
 call add_log " "
 if left(input,3) <> "DD:" then "Free f("xmidd")"
 if free_msg <> null then "Free f("free_msg")"

/* --------------------------------------------------- *
 * Finished Processing - Now Display Messages and Exit *
 * --------------------------------------------------- */
 Exit_Code:
  if sysvar('sysispf') = "ACTIVE" then do
     "Alloc f("xmdd") new spa(1,1) tr recfm(v b) lrecl(80)" ,
            "ds("xmdd")"
     "Execio * diskw" xmdd "(finis stem log."
     Address ISPExec "Browse Dataset("xmdd")"
     call msg 'off'
     "Del" xmdd
     call msg 'on'
     end

 exit 0

/* --------------------------------------------------- *
 * Process a new split because the sepval has changed. *
 * --------------------------------------------------- */
 New_Split:
/* -------------------------------------- *
 * If first time then set flag and return *
 * -------------------------------------- */
 if first = null then do
    first = 1
    return
    end

/* ------------------------------------- *
 * Copy the data for separation and mail *
 * ------------------------------------- */
 drop new.
 do i = 1 to last_page
    new.i = page.i
    end
    new.0 = last_page  /* # lines in new. */

/* -------------------------------------------------- *
 * Save the pages we want to keep into holding buffer *
 * drop all the old pages.                            *
 * Then copy the saved pages from the buffer          *
 * -------------------------------------------------- */
 holdc = 0
 drop hold.
 if last_page <> linec then do /* have saved lines for nxt rpt */
    do i = last_page+1 to linec
       holdc = holdc + 1
       hold.holdc = page.i
       end
    drop page.
    linec = 0
    do i = 1 to holdc
       linec = linec + 1
       page.linec = hold.i
       end
    end
 else do
      drop page.
      linec = 0   /* start next rpt at page.1 for seploc on row 1 */
      end

/* ---------------------------------------- *
 * Test if keyvalue specified - else ignore *
 * ---------------------------------------- */
 call test_key

 septo = "("strip(key.sepval)")"
 if strip(key.sepval) = null
    then do
         call add_log "Skipping Key Value:   " sepval
         return
         end

  if sub.rsepval = null
     then savesub = subject
     else do
          savesub = subject
          subject = sub.rsepval
          end

  if combine = null ,
  then do;
           call send_it
       end;
  else do;
           call combine_it
       end;
  subject = savesub
  return

/* ----------------------------------------------------------- *
 * Test the SEPVAL to see if it matches any of the KEYV values *
 * if masking has been used.                                   *
 *                                                             *
 * Masking is:   ? masks any single character                  *
 *               * masks current and all subsequent characters *
 *                                                             *
 * Note: May not use ? and * in the same mask.                 *
 * ----------------------------------------------------------- */
 Test_Key:
 rsepval = sepval
 if pos("?",keys) = 0
    then if pos("*",keys) = 0 then return
 kw = words(keys)
 do tk = 1 to kw
    wkey = translate(word(keys,tk),' ',x2c("01"))
    hkey = wkey
    Select
      When pos("*",wkey) > 0 then do
           ap = pos("*",wkey)-1
           if left(sepval,ap) = left(wkey,ap)
              then do
                   sepval = hkey
                   return
                   end
           end
      When pos("?",wkey) > 0 then do
           do until pos("?",wkey) = 0
              qp = pos("?",wkey)
              wkey = overlay(substr(sepval,qp,1),wkey,qp)
              end
              if wkey = sepval
                 then do
                      sepval = hkey
                      return
                      end
           end
      Otherwise nop
      end
    end
 return

/* ---------------------------------------------------- *
 * Combine the separated report into individual         *
 * data sets to be sent to individual e-mail addresses. *
 * ---------------------------------------------------- */
 Combine_It:
  if pos("(",septo) > 0 then
     parse value septo with "("c_mail")"
  else c_mail = septo
  do cx = 1 to words(c_mail)
     cm = word(c_mail,cx)
     if combmail.cm = null then do
        cdd = cdd + 1
        tempdd      = "CS"cdd
        combmail.tempdd = sub.rsepval
        combmail.cm = tempdd
        "ALLOC F("combmail.cm") new" ,
           "spa(30,30) tr" ,
           "recfm(v b" cc") lrecl(254) blksize(0)"
        end
     call add_log "Processing Key:" rsepval
     call add_log "            to:" cm
     "Execio * diskw" combmail.cm "(stem new."
     end
  return

/* ---------------------------------------------------- *
 * MergeMail processing to save each separation into    *
 * unique data sets for later mailing.                  *
 * ---------------------------------------------------- */
 Merge_It:
  if pos("(",septo) > 0 then
     parse value septo with "("m_mail")"
  else m_mail = septo
  cdd = cdd + 1
  workdd = "CS"cdd
  mergedds = mergedds workdd
  "ALLOC F("workdd") new" ,
  "spa(30,30) tr" ,
  "recfm(v b" cc") lrecl(254) blksize(0)"
     "Execio * diskw" workdd "(stem new."
  do mx = 1 to words(m_mail)
     mm = word(m_mail,mx)
     if mergemail.mm = null then
        mergemail.mm = workdd
        else mergemail.mm = mergemail.mm workdd
     mergedd.workdd = rsepval
     if pos(mm,mergeids) = 0 then
        mergeids = mergeids mm
     call add_log "Processing Key:" rsepval
     call add_log "            to:" mm
     end
  return

/* -------------------------------------------------- *
 * Now Send the separated/split data to the specified *
 * e-mail addresses.                                  *
 * -------------------------------------------------- */
 Send_It:
  if mergeflag = 1 then signal merge_it
  space = (linec * plrecl)%24000
  space = space + 10
  space = space","space
  "ALLOC F("xmdd") new" ,
     "spa("space") tr" ,
     "recfm(v b" cc") lrecl("plrecl+4") blksize(0)"
  if col = null then
     "Execio * diskw" xmdd "(finis stem page."
  else
     "Execio * diskw" xmdd "(finis stem new."
  call do_mail
  return

/* ------------------------------------------- *
 * Generate the XMTIIP e-mail command and send *
 * the separated report.                       *
 * ------------------------------------------- */
 Do_Mail:
  mails = mails + 1
  sepcount = 0
  if septo <> null then
     cmd = "xmitip" septo
   if length(xmdd) > 0 then
      cmd = cmd xcmd "FILEDD ("xmdd")"
   else cmd = cmd xcmd
   if length(filename) > 0 then do
      wfilen = proc_sym(filename)
      cmd = cmd "FILENAME ("wfilen")"
      end
  if cc = "A" then cmd = cmd "ASA"
  if cc = "M" then cmd = cmd "MACH"

  if length(subject)  > 0 then do
     Select
        when pos("'",subject) > 0 then
           wsub = '"'subject'"'
        when pos('"',subject) > 0 then
           wsub = "'"subject"'"
        otherwise wsub = "'"subject"'"
        end
     wsub = proc_sym(wsub)
     cmd = cmd "SUBJECT" wsub
     end

/* --------------------------- *
 * Report out this E-Mail Info *
 * --------------------------- */
  if sepval = null then
     call add_log "Processing Separation:" mails
  else do
     if combine = null then
        call add_log "Processing Separation:" sepval
     else
        call add_log "Processing Combination to:" septo
     end
  call add_log "Report Subject: " wsub
  call add_log "       Filename:" wfilen
  if pos("(",septo) > 0 then
     parse value septo with "("report_to")"
  else report_to = septo
  do rt = 1 to words(report_to)
     call add_log "       To:      " word(report_to,rt)
     end

  if debug = 1 then call add_log "Cmd:" cmd
     else do
          say "  "
          cmd
          say "  "
          end

  if combine = null then
     if mergeflag <> 1 then
        "Free f("xmdd")"
  if col <> null then return
  drop page.
  linec = 0
  return

/* -------------------------- *
 * Add Message to Message Log *
 * -------------------------- */
 Add_Log: procedure expose log. msgid report
 parse arg msg
 c = log.0 + 1
 log.c = " "msgid msg
 log.0 = c
 if report = 1 then do
         Queue log.c
         "Execio 1 diskw REPORT"
         end
    else say log.c
 return

/* ----------------- *
 * Process Symbolics *
 * ----------------- */
 Proc_Sym: procedure expose mails rsepval
 parse arg data
 if pos("&SEPNUM",translate(data)) > 0 then do
    p  = pos("&SEPNUM",translate(data))
    sl = left(data,p-1)
    sr = substr(data,p+7)
    data = sl""mails""sr
    end
 if pos("&SEPVAL",translate(data)) > 0 then do
    p  = pos("&SEPVAL",translate(data))
    sl = left(data,p-1)
    sr = substr(data,p+7)
    data = sl""rsepval""sr
    end
 Return data
