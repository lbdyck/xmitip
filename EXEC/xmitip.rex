        /* ---------------------  rexx procedure  ------------------- */
        ver = "23.12"
        /* Name:      XMITIP                                          *
         *                                                            *
         * Function:  Transmit a message to a user on the LAN via     *
         *            using the Internet gateway                      *
         *                                                            *
         * Syntax:    %XMITIP user@node  option......                 *
         *                                                            *
         *            where:                                          *
         *                                                            *
         *            user@node                                       *
         *              e-mail address of the recipient               *
         *            or                                              *
         *            (user@node user2@node ...)                      *
         *            or                                              *
         *            "first last" <first.last@address>               *
         *            or                                              *
         *            ("first last" <first.last@address> ...)         *
         *            or                                              *
         *            *list-id*  (not an address but used in the TO   *
         *            tag in the envelope with BCC for addressing.    *
         *            List-id need only start with an *               *
         *            or                                              *
         *            'list id'                                       *
         *            text enclosed in single or double quotes which  *
         *            will be used as the to address in the           *
         *            envelope (but not for smtp delivery)            *
         *            or                                              *
         *            * if using an AddressFile/AddressFileDD which   *
         *            will cause the * to be replaced by the TO       *
         *            addresses in the AddressFile.                   *
         *                                                            *
         *            CC user@node                                    *
         *              e-mail address of the recipient               *
         *              specifies 'carbon copy' recipients            *
         *              (note the space after CC)                     *
         *            or                                              *
         *            CC (user@node user2@node ...)                   *
         *            or                                              *
         *            CC "first last" <first.last@address>            *
         *            or                                              *
         *            CC ("first last" <first.last@address> ...)      *
         *                                                            *
         *            BCC user@node                                   *
         *              specifies 'blind carbon copy' recipients      *
         *              (note the space after BCC)                    *
         *              These addresses will NOT be in the message    *
         *              envelope.                                     *
         *            or                                              *
         *            BCC (user@node user2@node ...)                  *
         *            or                                              *
         *            BCC "first last" <first.last@address>           *
         *            or                                              *
         *            BCC ("first last" <first.last@address> ...)     *
         *                                                            *
         *            AddressFile dsname                              *
         *              Defines a dataset that contains               *
         *              a sequential list of addresses in the form:   *
         *              TO address                                    *
         *              CC address                                    *
         *              BCC address                                   *
         *              FROM address                                  *
         *              REPLYTO address                               *
         *              * comment                                     *
         *              Note 1: FROM & REPLYTO ignored if used in the *
         *                     XMITIP command                         *
         *              Note 2: only 1 address per record in col 1-72.*
         *              address can be of the format:                 *
         *              first.last@address                            *
         *              or                                            *
         *              "first last" <first.last@address>             *
         *                                                            *
         *              Abbreviation: AFILE                           *
         *                                                            *
         *            AddressFileDD ddname                            *
         *              Defines a ddname that contains                *
         *              a sequential list of addresses in the form:   *
         *              TO address                                    *
         *              CC address                                    *
         *              BCC address                                   *
         *              FROM address                                  *
         *              REPLYTO address                               *
         *              * comment                                     *
         *              Note 1: FROM & REPLYTO ignored if used in the *
         *                     XMITIP command                         *
         *              Note 2: only 1 address per record in col 1-72.*
         *              address can be of the format:                 *
         *              first.last@address                            *
         *              or                                            *
         *              "first last" <first.last@address>             *
         *                                                            *
         *              Abbreviation: AFILEDD                         *
         *                                                            *
         *            ASA                                             *
         *              Converts ASA carriage controls to Form Feed   *
         *                etc. as are used on ASCII printers.         *
         *              (defaults if RECFM indicates ASA carriage     *
         *               control)                                     *
         *                                                            *
         *            IGNORECC                                        *
         *              forces a bypass for all cc checking           *
         *                                                            *
         *            MACH                                            *
         *              Converts MACH carriage controls to Form Feed  *
         *                etc. as are used on ASCII printers.         *
         *              (defaults if RECFM indicates MACH carriage    *
         *               control)                                     *
         *                                                            *
         *            CONFMSG option                                  *
         *              Either TOP or BOTTOM to over-ride the         *
         *              location of the confirmation message in       *
         *              the e-mail.                                   *
         *                                                            *
         *            CONFIG configuration-file                       *
         *              A sequential dataset or member of a PDS       *
         *              which contains XMITIP keywords and options    *
         *              of the format:                                *
         *                                                            *
         *                keyword option +                            *
         *                                                            *
         *              where keyword is any valid XMITIP keyword     *
         *              followed by its valid option(s).              *
         *                                                            *
         *              multiple keyword/options may be coded on      *
         *              each record.                                  *
         *                                                            *
         *              only data in columns 1 to 72 will be used.    *
         *                                                            *
         *              a '+' or '-' may be used as a continuation    *
         *              character as an option if the user prefers.   *
         *                                                            *
         *              An * in column 1 indicates a comment.         *
         *                                                            *
         *              Note: multiple CONFIG and/or CONFIGDD's may   *
         *                    be coded and they are recursive.        *
         *                                                            *
         *              Important: CONFIG information OVER-RIDES      *
         *                         prior specified information as it  *
         *                         is added to the end of the existing*
         *                         keywords.                          *
         *                                                            *
         *                         A maximum of 20 config/configdd    *
         *                         are allowed.                       *
         *                                                            *
         *                 Abbreviation: CFG                          *
         *                                                            *
         *            CONFIGDD configuration-file-dd                  *
         *              A DD that references a valid configuration    *
         *              dataset.  See CONFIG for details.             *
         *                                                            *
         *                 Abbreviation: CFGDD                        *
         *                                                            *
         *            DEBUG - do not send but echo output via say     *
         *                                                            *
         *            EMSG                                            *
         *                                                            *
         *              When used under ISPF and with a MSGDS dsn     *
         *              makes a copy of the dsn and opens ISPF Edit   *
         *              to allow changes to the data.                 *
         *                                                            *
         *            ERRORSTO e-mail.address@node                    *
         *                                                            *
         *              Genearates a SMTP Errors-To: SMTP header      *
         *              used by some mail clients.                    *
         *                                                            *
         *              Only 1 e-mail address is allowed.             *
         *                                                            *
         *            FILE dataset.to.be.attached or                  *
         *            FILE (dsn1 dsn2 ....)                           *
         *              sequential dataset to be sent as an attachment*
         *                                                            *
         *              if the dataset starts with an * then the dsn  *
         *              will be allocated and ISPF Edit opened on it  *
         *                                                            *
         *              Note: gdg's are supported.                    *
         *                                                            *
         *              Abbreviation: FI                              *
         *                                                            *
         *            FILEDD ddname or                                *
         *            FILEDD (ddn1 ddn2 ...)                          *
         *              a ddname(s) used instead of or in addition to *
         *              the FILE keyword to reference datasets via    *
         *              a JCL //xx DD statement.                      *
         *                                                            *
         *            FILEO hfs-file-name                             *
         *            FILEO (hfs-1 hfs-2 ...)                         *
         *              a hfs file is used                            *
         *                                                            *
         *            FILEDESC description-of-file or                 *
         *            FILEDESC (desc-file1 desc-file2 ...)            *
         *              Descriptions of the attached files without    *
         *              imbedded blanks.                              *
         *              - a filedesc of x (or X) may be used when     *
         *                multiple files are attached and one or      *
         *                more do not have a description.             *
         *                e.g filedesc (x file-desc x file-desc)      *
         *                                                            *
         *            Note: Filedesc may contain any of these         *
         *                  supported symbolics.  See below.          *
         *                                                            *
         *            FILENAME or                                     *
         *            FILENAME (file1 file2 ...)                      *
         *            the name of the file attachment that will       *
         *            appear in the e-mail.                           *
         *                                                            *
         *            Note: Filename may contain any of these         *
         *                  supported symbolics.  See below.          *
         *                                                            *
         *            e.g report.&sdate.rtf                           *
         *                                                            *
         *            if the filename contains blanks then it must    *
         *            be enclosed in single quotes and within ( )'s   *
         *                                                            *
         *                 Abbreviation: FILEN                        *
         *                                                            *
         *            FOLLOWUP - Generate a ToDo Calendar Entry       *
         *            FOLLOWUP date                                   *
         *               date is mmddyy                               *
         *               or                                           *
         *               date is +nnn (for +nnn days from today)      *
         *                                                            *
         *               Note: any message text will be included in   *
         *                     the followup todo item                 *
         *                                                            *
         *                 Abbreviation: FUP                          *
         *                                                            *
         *            FORMAT - the format of the file attachment      *
         *            FORMAT xxx or .xxx                              *
         *                   xxx = file attachment suffix             *
         *                                                            *
         *            FORMAT *xxx/xxx....                             *
         *                   Only allowed once and will be the format *
         *                   used for ALL file attachments.           *
         *                                                            *
         *            FORMAT TXT/suffix                               *
         *                    plain text attachment (default)         *
         *                    suffix is the file attachment suffix    *
         *                        (e.g. csv, txt, html, ...)          *
         *            FORMAT BIN/suffix                               *
         *                        (e.g. csv, txt, html, ...)          *
         *                    format.                                 *
         *            FORMAT CSV                                      *
         *                    text file attachment of a CSV file      *
         *                    - no conversion performed               *
         *            FORMAT GIF                                      *
         *                    binary GIF file attachment              *
         *                    - no conversion performed               *
         *            FORMAT XMIT                                     *
         *                    binary XMIT (tso transmit) file         *
         *                    - no conversion performed               *
         *            FORMAT HTML/color/suffix/font-size/banner/      *
         *                        table/noheader/wrap/semicolon       *
         *         or FORMAT HTML/ds:txt2html-config-file-dsn         *
         *         or FORMAT HTML/dd:txt2html-config-file-dd          *
         *                   color is documented below (after FORMAT) *
         *                   suffix is the file attachment suffix     *
         *                       (e.g. xls or .xls)                   *
         *                   font-size (default is null for browser)  *
         *                       values from 1 (very small)           *
         *                              to 7 (very large)             *
         *                   - no conversion if already in HTML       *
         *                     format (<html> in record 1 )           *
         *                  table is any non-blank to indicate convert*
         *                     the csv input file to html table       *
         *                  noheader is N to indicate no header row   *
         *                     in the csv                             *
         *                  wrap is any non-blank to indicate to wrap *
         *                     text within the table cell             *
         *                  semicolon is any non-blank to indicate to *
         *                     use a semicolon instead of a comma     *
         *                     in the csv input                       *
         *            FORMAT ICAL                                     *
         *                    The file to be attached is in iCalendar *
         *            FORMAT PDF/layout/font/paper/lpi/rpo            *
         *         or FORMAT PDF/ds:txt2pdf-config-file-dsn           *
         *         or FORMAT PDF/dd:txt2pdf-config-file-dd            *
         *                   layout is Landscape (11x8.5)             *
         *                             Portrait  (8.5x11)             *
         *                             - default is Portrait          *
         *                   font is a font size where 72 points      *
         *                        is one inch (default is 9)          *
         *                        for BOLD add B after size (9B)      *
         *                   paper is LETter for Letter (8.5 x 11)    *
         *                            LEGal for Legal (11x14)         *
         *                            A4 for A4 (European paper)      *
         *                               (8.27 x 11.7)                *
         *                   lpi is lines per inch (default is 8)     *
         *                   rpo or rpo:pw                            *
         *                       rpo = read/print only                *
         *                       rpo may be No for No security        *
         *                                  40 for 40 bit encrypt     *
         *                                 128 for 128 bit encrypt    *
         *                       pw optional and is user password     *
         *                          to read the file                  *
         *            FORMAT RTF/layout/font/paper/suffix/ro          *
         *         or FORMAT RTF/ds:txt2rtf-config-file-dsn           *
         *         or FORMAT RTF/dd:txt2rtf-config-file-dd            *
         *                   layout is Landscape (11x8.5)             *
         *                             Portrait  (8.5x11)             *
         *                             - default is Portrait          *
         *                   font is a font size where 72 points      *
         *                        is one inch (default is 9)          *
         *                   paper is LETter for Letter (8.5 x 11)    *
         *                            LEGal for Legal (11x14)         *
         *                            A4 for A4 (European paper)      *
         *                            or                              *
         *                            widthXheight (e.g. 4x6)         *
         *                   suffix is the file attachment suffix     *
         *                       (default is .rtf)                    *
         *                   ro is Yes or No (default No) to set      *
         *                      the document read only                *
         *            FORMAT ZIP/name-in-archive                      *
         *                   to zip a text file                       *
         *                   name-in-archive is the name the file     *
         *                        will have in the zip file           *
         *            FORMAT ZIPBIN/name-in-archive                   *
         *                   to zip a binary file                     *
         *            FORMAT ZIPCSV/name-in-archive                   *
         *                   to zip a text CSV file                   *
         *            FORMAT ZIPGIF/name-in-archive                   *
         *                   to zip a binary GIF file                 *
         *            FORMAT                                          *
         *            ZIPHTML/name-in-archive/color/font-size/banner  *
         *                        table/noheader/wrap/semicolon       *
         *         or FORMAT ZIPHTML/nia/ds:txt2html-config-file-dsn  *
         *         or FORMAT ZIPHTML/nia/dd:txt2html-config-file-ddd  *
         *                   to convert the file to HTML and then     *
         *                   zip the file                             *
         *            FORMAT ZIPPDF/nia/layout/font/paper/lpi/rpo     *
         *         or FORMAT ZIPPDF/nia/ds:txt2pdf-config-file-dsn    *
         *         or FORMAT ZIPPDF/nia/dd:txt2pdf-config-file-ddd    *
         *                   to convert the file to PDF and then      *
         *                   zip the file                             *
         *            FORMAT ZIPRTF/name-in-archive/layout/font/paper *
         *                         /ro                                *
         *         or FORMAT ZIPRTF/nia/ds:txt2rtf-config-file-dsn    *
         *         or FORMAT ZIPRTF/nia/dd:txt2rtf-config-file-ddd    *
         *                   to convert the file to RTF and then      *
         *                   zip the file                             *
         *            FORMAT ZIPXMIT/name-in-archive                  *
         *                   to zip a binary TSO Transmit file        *
         *                                                            *
         *            Color definitions for HTML attachments          *
         *                   If color is just color then it is the    *
         *                   text color with a white background.      *
         *                   If color is color-color then the first   *
         *                   color is the background color and the    *
         *                   second color is the text color           *
         *                                                            *
         *                   Color      Abbrev   Color     Abbrev     *
         *                   Aqua       A        Navy      N          *
         *                   Black      Bla      Olive     O          *
         *                   Blue       Blu      Purple    P          *
         *                   Fuchsia    F        Red       R          *
         *                   Gray       Gra      Silver    S          *
         *                   Green      Gre      Teal      T          *
         *                   Lime       L        White     W          *
         *                   Maroon     M        Yellow    Y          *
         *                                                            *
         *            - Each set applies to the relative FILE dsn or  *
         *              FILEDD ddname or FILEO file.
         *              If FILE and FILEDD and FILEO are coded        *
         *              then the dsn's are counted first from         *
         *              FILE and then FILEDD and then FILEO.          *
         *                                                            *
         *              Abbreviation: FORM                            *
         *                                                            *
         *            FROM from.mail.address@node                     *
         *            or                                              *
         *            FROM "from name" <from.name@address>            *
         *              specifies the return mail address             *
         *              (see REPLYTO keyword)                         *
         *                                                            *
         *              Abbreviation: FR                              *
         *                                                            *
         *            HLQ hlq                                         *
         *              High level qualifier to be used for all       *
         *              dataset allocations that are not fully        *
         *              qualified in single quotes.  useful for       *
         *              batch tmp without tso racf segments.          *
         *                                                            *
         *            HTML                                            *
         *              flag to indicate that the MSGDx is in         *
         *              HTML format (user must enter text in html)    *
         *                                                            *
         *            IDVAL                                           *
         *              This option will force e-mail address         *
         *              validation. The LDAP information *must* be    *
         *              correctly configured for this to work.        *
         *              *** see NOIDVAL ***                           *
         *                                                            *
         *            IDWARN                                          *
         *              This option will force e-mail address         *
         *              validation and will generate a warning if     *
         *              the address is invalid.                       *
         *              The LDAP information *must* be                *
         *              correctly configured for this to work.        *
         *                                                            *
         *            IGNOREENC                                       *
         *              Flag to Ignore any Encoding (as defined in    *
         *              XMITIPCU).                                    *
         *                                                            *
         *            IGNORESUFFIX                                    *
         *              flag used to prevent a format friendly        *
         *              suffix from being added to the file           *
         *              attachment name (filename) if the suffix      *
         *              is not appropriate to the format.             *
         *                                                            *
         *            IMPORTANCE value                                *
         *              importance of the note - values may be        *
         *              LOW                                           *
         *              NORMAL                                        *
         *              HIGH                                          *
         *              or abbreviated as HI, LO, NO                  *
         *                                                            *
         *            MURPHY                                          *
         *              Include some random words of wisdom from      *
         *              Edward A. Murphy, Jr and others.              *
         *                                                            *
         *            MAILFMT HTML or PLAIN                           *
         *              over-rides the site default in XMITIPCU for   *
         *              the mail format                               *
         *                                                            *
         *            MSGDS data-set-name                             *
         *              specifies the data set that contains the      *
         *              message                                       *
         *              If the data-set-name is '*' and this is under *
         *              ISPF then the ISPF Editor will be invoked to  *
         *              create the message text.                      *
         *                                                            *
         *              If the data-set-name is prefixed with *@      *
         *              then debug mode is enabled and the            *
         *              data-set-name is set with the *@ removed.     *
         *                                                            *
         *            MSGDD ddname                                    *
         *              specifies the DDname that contains the        *
         *              message                                       *
         *                                                            *
         *            MSGQ                                            *
         *              Indicates that the message will be passed     *
         *              in the TSO QUEUE                              *
         *                                                            *
         *            MSGT 'message text'                             *
         *               This keyword is used to include the          *
         *               message text as part of the command.         *
         *               The rules are:                               *
         *               - if first word is html: then html: is       *
         *                 removed and html flag is set               *
         *               - must be enclosed in ' or "                 *
         *               - symbolics are allowed (see list)           *
         *               - use of backslash as line separator         *
         *               - use of / before a backslash allows the     *
         *                 backslash to display                       *
         *                                                            *
         *            MSG72                                           *
         *              Indicates that only the first 72 characters   *
         *              per record of the message will be used.       *
         *              (thus ignoring sequence numbers)              *
         *                                                            *
         *            NOCONFIRM                                       *
         *              indicates that no 'confirmation' message will *
         *              be generated out of this command.             *
         *                                                            *
         *            NOEMPTY                                         *
         *              Flag - causes XMITIP to terminate if any      *
         *              input file is empty.                          *
         *                                                            *
         *            NOIDVAL                                         *
         *              If ID validation is enabled then this option  *
         *              will prevent the userids from being checked   *
         *              - use this if you know the ids are good       *
         *                and to save overhead in xmitip.             *
         *              *** see IDVAL ***                             *
         *                                                            *
         *            NOMSG                                           *
         *              indicates that no message is being sent,      *
         *              only a file transmit is to occur.             *
         *                                                            *
         *            NOMSGSUM                                        *
         *              indicates that no message summary is to be    *
         *              generated                                     *
         *                                                            *
         *            NOSTRIP                                         *
         *              indicates that trailing blanks will NOT be    *
         *              removed from file attachments.                *
         *              >>> Only works if smtp_secure is set in       *
         *              >>> XMITIPCU to cause XMITIP to use TSO XMIT  *
         *              >>> to send the e-mail to z/OS SMTP           *
         *                                                            *
         *            NORTFXlate                                      *
         *              used to bypass the translation of the RTF     *
         *              characters by inserting escape chars          *
         *                 curly bracket left                         *
         *                 curly bracket right                        *
         *                 slash                                      *
         *                                                            *
         *            NOSPOOF                                         *
         *              used to bypass the antispoof message block    *
         *              generated at the end of all messages.         *
         *              ** usage controlled by installation defaults  *
         *                                                            *
         *            PAGE 'message text for page'                    *
         *              specifies the message text for the page       *
         *              or                                            *
         *            PAGE "subject for message"                      *
         *              you may use either single (') or double (")   *
         *              quotes on both ends (both must be the same    *
         *              and then you can use the other flavour quote  *
         *              inside the page message text.                 *
         *              Special keywords supported are defined under  *
         *                 supported symbolics below.                 *
         *                                                            *
         *            TPAGELEN nnn                                    *
         *             Defines an over-ride to the system default     *
         *             text page length.                              *
         *                                                            *
         *             A value of 0 is unlimited size.                *
         *                                                            *
         *            RC0                                             *
         *             Informs XMITIP to always generate a zero       *
         *             return code on data set empty.                 *
         *                                                            *
         *            REPLYTO reply.to.address@node                   *
         *            or                                              *
         *            FROM "reply name" <reply.name@address>          *
         *              specifies the reply address which is different*
         *              from the FROM address.                        *
         *                                                            *
         *              Abbreviation: REP                             *
         *                                                            *
         *            RECEIPT address                                 *
         *            will cause a return receipt request to get asked*
         *            for to the specified address.                   *
         *                                                            *
         *            RESPOND option                                  *
         *            RESPOND (optiona optionb optionc ... )          *
         *                                                            *
         *            will use provided subject with Re: prefixed     *
         *            and add response to end of subject (response)   *
         *            ** will set the HTML tag for the message text   *
         *                                                            *
         *            MARGIN Lm/Rm/Tm/Bm                              *
         *            or                                              *
         *            MARGIN (Lm/Rm/Tm/Bm Lm/Rm/Tm/Bm ...)            *
         *              defines the margins for the FORMAT attachments*
         *              Lm = left margin   Rm = right margin          *
         *              Tm = top margin    Bm = bottom margin         *
         *            the values in inches (e.g. .8 for .8 inch)      *
         *            - Each set applies to the relative FILE dsn or  *
         *              FILEDD ddname or FILEO file.
         *              If FILE and FILEDD and FILEO are coded        *
         *              then the dsn's are counted first from         *
         *              FILE and then FILEDD and then FILEO.          *
         *                                                            *
         *            If FORMAT *xxx is used then a single value for  *
         *            MARGIN is used for all File attachments.        *
         *                                                            *
         *            PDFIDX row/column/length                        *
         *            or                                              *
         *            PDFIDX (row/column/length row/column/length ..) *
         *              defines selection criteria for creating an    *
         *              index for the generated PDF document          *
         *                                                            *
         *            PRIORITY value                                  *
         *              priority of the note - values may be          *
         *              NON-URGENT                                    *
         *              NORMAL                                        *
         *              URGENT                                        *
         *              or abbreviated as NON, NOR, UR                *
         *              (may be used to influence transmission speed) *
         *                                                            *
         *              Abbreviation: PR                              *
         *                                                            *
         *            SENSITIVITY value                               *
         *              sensitivity of the note - values may be       *
         *              PERSONAL                                      *
         *              PRIVATE                                       *
         *              CONFIDENTIAL                                  *
         *              COMPANY-CONFIDENTIAL                          *
         *              or abbreviated as PE, PR, CON, COM            *
         *                                                            *
         *              Abbreviation: SENS                         *
         *                                                            *
         *            SIG dsname                                      *
         *              specifies a dsname for a signature block      *
         *                                                            *
         *            SIGDD ddname                                    *
         *              specifies a ddname for a signature block      *
         *                                                            *
         *            SIZELIM size-in-bytes                           *
         *              defines the user e-mail size limit which      *
         *              over-rides the site defaults                  *
         *                                                            *
         *            SMTPCLAS sysout-class                           *
         *              defines an over-ride for the default          *
         *              SYSOUT class to be used for SMTP              *
         *                                                            *
         *            SMTPDEST node.dest                              *
         *                  or dest                                   *
         *              defines an over-ride to the default dest      *
         *              that routes the SMTP sysout to the correct    *
         *              SMTP (or CSSMTP) address space                *
         *                                                            *
         *            SUBJECT 'subject for message'                   *
         *              specifies the subject for the message         *
         *              or                                            *
         *            SUBJECT "subject for message"                   *
         *              you may use either single (') or double (")   *
         *              quotes on both ends (both must be the same    *
         *              and then you can use the other flavour quote  *
         *              inside the subject.                           *
         *              Special keywords supported are defined under  *
         *                 supported symbolics below.                 *
         *                                                            *
         *              Abbreviation: SUB                             *
         *                                                            *
         *            VIANJE  nje-node                                *
         *                   Defines the NJE host where SMTP resides  *
         *                                                            *
         *            ZIPMETHOD method                                *
         *                   The method of compression to be used     *
         *                    by the ZIP utility.                     *
         *                    PKZIP supports:                         *
         *                          Normal, Maximum, Fast,            *
         *                          Superfast, and Store              *
         *                                                            *
         *            ZIPPASS pwd                                     *
         *                    pwd is a password (case sensitive)      *
         *                            that will be used by ZIP to     *
         *                            encrypt the file                *
         *                                                            *
         * Supported Symbolics are:                                   *
         *                     &date    Current date mmm dd, ccyy     *
         *                              on subject or msgt and        *
         *                              yymmdd in filename            *
         *                     &day     Current day of week           *
         *                     &month   Current month                 *
         *                     &cdate   Current date ccyymmdd         *
         *                     &ctime   Current time hhmmss           *
         *                     &edate   European date dd/mm/yy        *
         *                     &idate   Current ISO Date ccyy-mm-dd   *
         *                     &iweek   Current ISO Week num 01 to 53 *
         *                     &iweeke  Current ISO week ccyy-Wnn-d   *
         *                     &iweekr  Current ISO week ccyy-Wnn red.*
         *                     &jdate   Current Julian date yyddd     *
         *                     &job     Current jobname               *
         *                     &job8    Current jobname (padded to 8) *
         *                     &jobid   Current job number(JOBnnnnn)  *
         *                     &jobnum  Current job number(Jnnnnn)    *
         *                     &rc      report last return code       *
         *                     &rca     report all step return codes  *
         *                     &rch     report highest return code    *
         *                     &sdate   Current short date  mmdd      *
         *                     &udate   Current short date  mmddyy    *
         *                     &sysid   Current system name (&sysname)*
         *                     &sysname Current system name           *
         *                     &sysplex Current sysplex name          *
         *                     &time    Current time        hh:mm:ss  *
         *                     &userid  Current userid                *
         *                     &xmitver Current XMITIP Version        *
         *                     &year    Current year ccyy             *
         *                     &year2   Current year yy               *
         *                     &year4   Current year ccyy             *
         *                     &z       Symbolic and space before are *
         *                              removed                       *
         *                                                            *
         *                     Remark:  To avoid confusion the formats*
         *                              mm/dd/yy and dd/mm/yy are     *
         *                              not supported as symbolics:   *
         *                               use idate ccyy-mm-dd instead *
         *                                                            *
         *                     Calculations may be performed on       *
         *                     &date, &cdate, &sdate, &edate, &idate, *
         *                     &udate,                                *
         *                     &day, &month,                          *
         *                     &iweek, &iweeke, &iweekr               *
         *                     &year, &year2, &year4                  *
         *                     e.g. &date-10 &day-10  &iweekr--1      *
         *                                                            *
         *                     All symbolics may be concatenated with *
         *                     other symbolics or text except those   *
         *                     used in a calculation. &SDATEabc works *
         *                     but &SDATE-1abc will not work.         *
         *                                                            *
         * Notes: The default margins for FORMAT are .8" for left and *
         *        right and 1" for top and bottom.                    *
         *                                                            *
         * Customization: 1) update exec XMITIPCU for local custom    *
         *                   values then                              *
         *                2) find *custom* to find where you          *
         *                   need to customize some processing        *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * ---------------------------------------------------------- *
         * License:   This EXEC and related components are released   *
         *            under terms of the GPLV3 License. Please        *
         *            refer to the LICENSE file for more information. *
         *            Or for the latest license text go to:           *
         *                                                            *
         *              http://www.gnu.org/licenses/                  *
         *                                                            *
         * ---------------------------------------------------------- *
         * Thanks to Leland Lucius for providing the code for the     *
         *           PDF conversion.                                  *
         *           (Leland.Lucius@ecolab.com)                       *
         * ---------------------------------------------------------- *
         * Thanks to Mark Feldman for the XMITB64 encoding BAL code   *
         *          mark.feldman@empirebcbs.com                       *
         * ---------------------------------------------------------- *
         * Thanks to Paul Wells for the Murphy code                   *
         *          Paul.Wells@ladbrokes.co.uk                        *
         * ---------------------------------------------------------- *
         * Thanks to Dana Mitchell for the code to support the        *
         * Interlink TCPACCESS SMTP     dana.mitchell@ing-dm.com      *
         * ---------------------------------------------------------- *
         * Thanks to Rich Stuemke (rstuemke@ILSOS.NET)                *
         * of the Office of the Illinois Secretary of State           *
         * for the Machine Carriage Control code                      *
         * ---------------------------------------------------------- *
         * Thanks to Wolfram Schwenzer (Wolfram.Schwenzer@SAC.AOK.DE) *
         * for the code to support in rtf files the                   *
         * backslash, curly bracket left and curly bracket right      *
         * ---------------------------------------------------------- *
         * Thanks to Felipe Cvitanich (Felipe@dk.ibm.com)             *
         * for the code to support hfs binary and atsign.             *
         * ---------------------------------------------------------- *
         * Thanks to john-ellis@ntlworld.com                          *
         * for the code to support:                                   *
         *     - sending all members of a pds                         *
         *     - support for UDSMTP for smtp delivery                 *
         *     - code to send all members of a pds                    *
         *     udsmtp can be found at http://www.dignus.com/freebies/ *
         * ---------------------------------------------------------- *
         * History:                                                   *
         *          2023-12-12 - 23.10                                *
         *                     - Add NOMSGSum option                  *
         *          2021-03-25 - 21.03                                *
         *                     - Add SLK as valid format @DM03252021  *
         *          2020-08-26 - 20.08                                *
         *                     - Support multiple addresses in REPLYTO*
         *          2019-09-14 - 18.10                                *
         *                     - Add NODISCLAIM (hidden option)       *
         *          2018-10-15 - 18.10                                *
         *                     - Correct test for existing HTML text  *
         *          2018-07-05 - 18.07                                *
         *                     - Remove OS/390 from X-Mailer          *
         *          2018-07-05 - 18.07                                *
         *                     - Add correction for attachment display*
         *                       with Outlook 365   (see *filename*)  *
         *          2018-05-29 - 18.05                                *
         *                     - Support SMTPDEST keyword             *
         *          2018-04-11 - 18.04                                *
         *                     - Support file suffix of XLSX          *
         *          2018-03-28 - 18.03                                *
         *                     - Enable &year-n, &year2-7, &year4-n   *
         *          2017-09-05 - 17.09                                *
         *                     - Fix txt attachments from CC files    *
         *                     - Add message info about which smtp    *
         *                       destination was used                 *
         *          2016-11-15 - 16.11                                *
         *                     - Add MAILFMT keyword                  *
         *                     - Bug fix from Barry Morton to fix a   *
         *                       problem is msgdd is empty.           *
         *          2016-09-21 - 16.09                                *
         *                     - Add SIZELIM keyword                  *
         *          2016-06-23 - 16.06                                *
         *                     - Corrections for html headers in the  *
         *                       clear for COnf/PRivate from          *
         *                       Dana Mitchell                        *
         *                     - Remove duplicate addresses from      *
         *                       cc and bcc                           *
         *                     - Correction to the sub_head from      *
         *                       Dana Mitchell                        *
         *          2016-04-26 - 16.04                                *
         *                     - Change name of encode64 to encodexm  *
         *          2016-03-17 - 16.03                                *
         *                     - Add default mail format in config    *
         *                       keyword is mailfmt                   *
         *          2016-02-23 - 16.02                                *
         *                     - Add unit to SYSUT1/2 allocations     *
         *          2015-12-02 - 15.12                                *
         *                     - STARTTLS support                     *
         *                       User keyword TLS On or TLS OFF       *
         *                       - XMITIPCU setting STARTTLS          *
         *                       Requested and tested by:             *
         *                       Hoi Keung Tong                       *
         *          2013-10-18 - 13.10                                *
         *                     - Add &YEAR (same as &YEAR4)           *
         *                     - Fix null char removal (null to nullc)*
         *                       Thanks to Marc Di Edwardo            *
         *          2010-10-01 - 10.10                                *
         *                     - Fix null char removal                *
         *          2010-07-26 - 10.08                                *
         *                     - Add day of week to Date SMTP Header  *
         *          2010-07-01 - 10.07                                *
         *                     - bug fix mail header lines            *
         *          2010-05-03 - 10.05                                *
         *                     - fix fax blank page                   *
         *                     - add parm ADDRBYP to bypass rewriting *
         *                       of address: list of special email    *
         *                       addresses - separated by blank(s)    *
         *                       - generic supported (only 1 '*')     *
         *                         like NN*FAX.domain.com             *
         *          2010-01-18 - 10.01                                *
         *                     - fix some html statements and add     *
         *                       differencess to the HTML code (DEBUG)*
         *          2009-12-10 - 09.12b                               *
         *                     - fix bug in processing HTML files     *
         *                       (encoding now bypassed)              *
         *                     - new exec TESTCUHT (TESTCU help tool) *
         *                       to 'dump' the XMITIPCU settings      *
         *                       (thx to Werner)                      *
         *          2009-12-04 - 09.12a                               *
         *                     - fix bug in followup routine if the   *
         *                       value of AtSign is longer than 1     *
         *                     - cleanup in processing respond option *
         *          2009-12-02 - 09.12                                *
         *                     - Add NoNotify and NoEpilog for TSO    *
         *                       XMIT file attachment creation        *
         *                     - Correct parse for e-mail address     *
         *                     - add parm <CALLEDAS> to the parms if  *
         *                       an exit is called. So a compiled exec*
         *                       can find out its name.               *
         *                     - add cu_add check messages            *
         *                     - add encoding mode TEST to avoid      *
         *                       encodings that are not supported     *
         *                     - add encoding_check to set the option *
         *                       in XMITIPCU (default NO)             *
         *                       valid: YES / NO / WARN / ONCE        *
         *                       (Be careful: WARN produces overhead) *
         *                     - add Force_Suf to fix problem with    *
         *                       missing '.txt' suffix                *
         *                     - add number of attachment file in     *
         *                       process messages (nnn)               *
         *                     - correction of edate format:          *
         *                       add "." after day                    *
         *                       (day - number without leading "0")   *
         *                     - minor corrections and cosmetics      *
         *          2009-10-19 - 09.10 (never published)              *
         *          2009-06-xx - 09.06 (under construction ...)       *
         *                     - full STEMPUSH/STEMPULL support for   *
         *                       encoding (performance booster)       *
         *                     - bug fix for atsign (multi chars)     *
         *          2009-05-25 - 09.05 (never published)              *
         *                     - check_send_to exit:                  *
         *                       -- full STEMPUSH/STEMPULL support    *
         *                       -- check whether default exit name   *
         *                          is used or not to call original   *
         *                          name function xmitzex2,           *
         *                          otherwise command interpreting    *
         *                          is necessary                      *
         *                       -- add sub_err_* routine (from ?)    *
         *                          (used in sub_interpret_command)   *
         *                       --> check your exit modifications    *
         *                     - leave TESTCU with a return value     *
         *                       (callable as a function - only tests)*
         *          2009-03-20 - 09.04 (never published)              *
         *                     - minor update for new xmitldap parms  *
         *          2009-03-05 - 09.03                                *
         *                     - correction for ldap validation msg   *
         *                     - support additional values in var     *
         *                       special_chars from xmitipcu          *
         *                       cp_used sp_chars cp_info             *
         *                     - enhance %logit mode (i.e. migration) *
         *                       logdsn logtype logmsg                *
         *                       logdsn  - log dataset name           *
         *                       logtype - <blank> log messages       *
         *                                 U  log only usage (version)*
         *                                 M  log only message        *
         *                                 A  log all (messages usage)*
         *                                 N  log nothing             *
         *                       logmsg  - message added to usage info*
         *                     - stg: stepname procstep program       *
         *          2009-01-28 - 09.02                                *
         *                     - Allow symbolics in the FORMAT        *
         *                       e.g. &date &time                     *
         *                       thanks to Maurizio Violi             *
         *          2009-01-02 - 09.01                                *
         *                     - Correction for HTML in MSG           *
         *          2008-12-01 - 08.12                                *
         *                     - Improvement for TXT2PDF XLATE        *
         *                     - fix long subject line wrapping       *
         *                     - call TXT2PDF in a sub routine to     *
         *                       get control if TXT2PDF is not found. *
         *                     - use quotes for x2c strings           *
         *                     - check xmitipcu_infos                 *
         *          2008-11-05 - 08.11                                *
         *                     - If the MSGDD or MSGDS has a CC then  *
         *                       shift the text left 1 character      *
         *          2008-10-12 - 08.10                                *
         *                     - new xmitipcu parms:                  *
         *                       txt2pdf_parms (i.e. XLATE COMPRESS)  *
         *                       tcp_stack (if different from default *
         *                       or several stacks are available)     *
         *          2008-09-25 - 08.09c                               *
         *                     - Alignment of header records          *
         *                     - Fix: free fi('workdd') in debug mode *
         *          2008-09-24 - 08.09b                               *
         *                     - Activate new option check_send_to    *
         *                       check to address(es) like TO CC BCC  *
         *                       in an external routine (and rewrite) *
         *          2008-09-12 - 08.09a                               *
         *                     - Update signature to remove trailing  *
         *                       blanks and leave leading blanks      *
         *                     - Correct typo in "Resetting..." msgs  *
         *                     - Correct msgs  msgid": ..." - colon   *
         *                     - DDname XMITDBG for additional infos  *
         *                     - CORRECTION for use of AddressfileDD  *
         *                       with a FROM or REPLYTO               *
         *                     - add code to support check_send_to    *
         *          2008-09-04 - 08.09                                *
         *                     - Move XMITIP application infos to be  *
         *                       written before exits are called.     *
         *                     - Add Support for XMITSOCK             *
         *                     - support smtp_method="SOCKETS" with   *
         *                       external routine XMITSOCK via DDname *
         *                       or STEMPUSH/STEMPULL (if available)  *
         *                       (Thx Werner Tomek)                   *
         *                     - bug fix: use new var global_vars     *
         *                         to define all those variables that *
         *                         are globally used in XMITIP like   *
         *                         null msgid _sysispf_ _sysenv_      *
         *          2008-08-20 - 08.08                                *
         *                     - Add routine sub_set_zispfrc          *
         *                       and give back RC info                *
         *                     - Correct Date substitution in dsn     *
         *                     - Add VIANJE - thx to James Yee        *
         *                       remove never executed "return"       *
         *                     - compiled exec - fix rexxname problem *
         *                     - uniform msgid                        *
         *          2008-06-18 - 08.07                                *
         *                     - Add IgnoreEnc option                 *
         *                     - Add NOEMPTY option                   *
         *                     - Add &MM symbolic (e.g month 05)      *
         *          2008-05-01 - 08.05                                *
         *                     - Add new option smtp_array to support *
         *                       different smtp tasks/writer/delivery *
         *                       methods                              *
         *          2008-04-03 - 08.04                                *
         *                     - Fix BCC in addressfile               *
         *          2008-02-20 - 08.02                                *
         *                     - Allow &userid for Sender field       *
         *                     - fix HTML encoding                    *
         *                     - add label support if from address is *
         *                       to be rewritten                      *
         *          2008-01-16 - 08.01                                *
         *                     - Change of versioning to year.month   *
         *                     - Add &RCH for the highest return code *
         *                     - Update to RTF Mime encoding          *
         *                     - Fix &jdate to allow &jdate-n         *
         *                     - Fix &jobidl usage                    *
         *                     - Add FROM and REPLYTO for AddressFile *
         *                       and AddressFileDD                    *
         *                     - Update from Hartmut for subject      *
         *                     - Improved NLS support from Hartmut    *
         *                     - Fix length of work file names for    *
         *                       pdfwork, htmlwork, rtfwork & zipwork *
         *                     - xmitipcu:                            *
         *                       -- use always the same structure     *
         *                       -- use always the same variable names*
         *                       -- avoid variable names which are    *
         *                          REXX words like center right left *
         *                                                            *
         *          2007-11-06 - 5.70                                 *
         *                     - Make temp dsn for pdf, html, rtf     *
         *                       more random                          *
         *                     - Allow abbreviations for the following*
         *                       FILE     - FI                        *
         *                       FROM     - FR                        *
         *                       FORMAT   - FORM                      *
         *                       PRIORITY - PR                        *
         *                       REPLYTO  - REP                       *
         *                       SUBJECT  - SUB                       *
         *                     - Fix long subject wrapping            *
         *                     - Add &iweek, &iweek, &iweekr symbolics*
         *                       uses new xmitfdat function exec      *
         *                     - Add new options for NLS              *
         *                       codepage_default   encoding_default  *
         *                     - Add symbolic &ctime hhmmss           *
         *                       (compact current time)               *
         *                     - Add new option check_send_from       *
         *                       check from address in an external    *
         *                       routine i.e. to bypass spam filter   *
         *                     - Add new option check_send_to (future)*
         *                     - Add new option smtp_fax to support   *
         *                       different smtp tasks/writer (future) *
         *                     - Fix default_lang for &month          *
         *          2007-09-20 - 5.68a                                *
         *                     - fix sending all pds members so member*
         *                       name is part of the file name        *
         *          2007-06-29 - 5.68                                 *
         *                     - translation bug correction (senility)*
         *          2007-06-08 - 5.66                                 *
         *                     - Fix minor bug when removing nulls    *
         *                       on input file                        *
         *          2007-05-04 - 5.64                                 *
         *                     - New Mime8Bit option for Mime Header  *
         *                     - Set text message to HTML if going to *
         *                       a FAX                                *
         *                     - New symbolic of &idate (iso date)    *
         *                       ccyy-mm-dd                           *
         *                     - New symbolic of &job8 (padded 8 char *
         *                       jobname)                             *
         *          2007-03-20 - 5.62                                 *
         *                     - Add timezone symbolic                *
         *                     - Add left and right paren symbolics   *
         *          2007-02-02 - 5.60                                 *
         *                     - Version change only                  *
         *          2007-01-13 - 5.58                                 *
         *                     - Add &CUSTSYM symbolic capability     *
         *          2006-11-27 - 5.56                                 *
         *                     - Add &Z symbolic                      *
         *                       &z and leading blank are eliminated  *
         *                     - Add mime header for rtf attachments  *
         *                       applidation/rtf                      *
         *                     - Update ZIP not supported msg to      *
         *                       indicate not supported on this lpar  *
         *          2006-10-26 - 5.54                                 *
         *                     - Add support for &year2 and &year4    *
         *          2006-09-26 - 5.52                                 *
         *                     - Add support for &sysname and &sysplex*
         *                       symbolics                            *
         *          2006-09-12 - 5.50                                 *
         *                     - Correction if LANG used in a CONFIG  *
         *                       file                                 *
         *          2006-07-06 - 5.48                                 *
         *                     - version change only to match xmitipi *
         *          2006-04-06 - 5.46                                 *
         *                     - remove rcpt to tag for errorto addr  *
         *          2006-01-20 - 5.44                                 *
         *                     - add option for MSGT to have the text *
         *                       in HTML format by:                   *
         *                       MSGT "html: message text"            *
         *                     - Correct extra line with HTML disclaim*
         *                     - Set disclaim in small font and navy  *
         *                       if in HTML format                    *
         *                     - Add fixup for symbolics for html     *
         *                       title. *thx to Robert Phillips       *
         *          2005-12-30 - 5.42                                 *
         *                     - Correct undefined variable when using*
         *                       Conf_Msg of Bottom                   *
         *                     - Add new user keyword option of       *
         *                       CONFMSG (so I could debug this issue)*
         *          2005-11-10 - 5.40                                 *
         *                     - Correction to MSGT processing for    *
         *                       the escape chars (error is > 3)      *
         *          2005-10-08 - 5.38                                 *
         *                     - If Message is HTML then set Sensitify*
         *                       color to red                         *
         *                     - Correct for HTML with Sensitivity    *
         *                       usage and when used with RESPOND     *
         *                     - Correct for HTML with Murphy and     *
         *                       Signature usage                      *
         *          2005-05-26 - 5.36                                 *
         *                     - get jobid and jobidl from xmitipcu   *
         *                       and replace jnbr by jobid            *
         *                       i.e. jobid=J12345 jobidl=JOB12345    *
         *                     - add &JOBID to use jobidl value       *
         *                     - fix use of symbolics &jobnum and     *
         *                       &jobid                               *
         *          2005-05-17 - 5.34                                 *
         *                     - Correction for zipwork temp name     *
         *                       to add jobid                         *
         *                     - Correction for byte count for limit  *
         *                       for binary attachments (was too high)*
         *          2005-05-09 - 5.32                                 *
         *                     - Correcttion for language and for from*
         *                       for Exchange usage (thx Barry Gilder)*
         *          2005-04-19 - 5.30                                 *
         *                     - Correcttion to enable IgnoreSuffix   *
         *                       to be honored (thx to Greg Morgan)   *
         *          2005-01-24 - 5.28                                 *
         *                     - Correct extraneous / in              *
         *                       application/ms-excel                 *
         *          2004-10-08 - 5.26                                 *
         *                     - Change text/enrich to text/enriched  *
         *                     - Correction to asa suppress cc (+)    *
         *                       processing for format txt            *
         *          2004-09-10 - 5.24                                 *
         *                     - Change space calc trk size from 56000*
         *                       to 28000 to reduce B37 potential.    *
         *                     - Change tso xmitip sysout to use      *
         *                       nullsysout variable from xmitipcu    *
         *                     - Comment updates thx to Hartmut       *
         *                     - Remove space before subject text     *
         *                     - If empty filedd and format XMIT      *
         *                       correct to send empty message d/s    *
         *                     - Enhance &jobnum to have accurate     *
         *                       STC/TSU/JOB char before number       *
         *                     - Add SEQ to FORMAT XMIT if FILEDD     *
         *                     - Enhance AntiSpoof thx to Hartmut     *
         *                     - Make backslash a variable for NLS    *
         *                     - Updates from XMITIPCU                *
         *          2004-07-07 - 5.22                                 *
         *                     - Add Keyword RC0 to always generate   *
         *                       a zero return code on data set empty *
         *          2004-06-25 - 5.20                                 *
         *                     - Correct NoRTFXlate thx to            *
         *                       David Ingoldsby                      *
         *                     - Allow multiple domains in the        *
         *                       restrict_domain field                *
         *                     - Change Infozip to use last 2 quals   *
         *                       from input dsn for the file name     *
         *                       unless there are only 1 or 2 quals   *
         *                     - translate lang/default_lang to upper *
         *                     - call xmitiptr for antispoof header   *
         *                       and sent line                        *
         *                     - correct calls to xmitiptr for -L     *
         *                     - if Faxcheck enabled and address is a *
         *                       fax then ignore msg_summary          *
         *                     - Improve space calc for infozip work  *
         *                       with vb records. thx Jean-Marc LUCE  *
         *                     - Support new Restrict_HLQ option from *
         *                       XMITIPCU                             *
         *                     - Support new Default_Lang option from *
         *                       XMITIPCU                             *
         *                     - Correct missing expose               *
         *                     - Correct return test from XMITIPID    *
         *                       to ignore when the ldap server is    *
         *                       not available.                       *
         *          2004-05-18 - 5.18                                 *
         *                     - Move date for antispoof from xmitipcu*
         *                       and support nls for the date         *
         *          2004-05-12 - 5.16a                                *
         *                     - Correct typo in variable name        *
         *          2004-05-11 - 5.16                                 *
         *                     - Add support for csv to html table    *
         *                       for format html and ziphtml thx to   *
         *                       Alain Janssens efforts with txt2html *
         *                     - Correction to delete work files for  *
         *                       external routines (e.g. txt2...)     *
         *                       that were retained if the rc > 0     *
         *          2004-04-30 - 5.14                                 *
         *                     - Correction for bogus .'s added to    *
         *                       &month, &day, etc. calculations      *
         *                     - Change usage of "" to null           *
         *          2004-04-22 - 5.12                                 *
         *                     - Correction if using MSGQ             *
         *          2004-04-13 - 5.10                                 *
         *                     - If no MSG option provided then  NOMSG*
         *                       and ignore NOMSG if MSG option found *
         *                     - Correct test for multiple msg options*
         *                     - Support for new LOG option and call  *
         *                       to %logit external routine           *
         *                     - Add logging if validfrom enabled     *
         *                       * invalid are any that are not local *
         *                         as well as local that are invalid  *
         *                     - For UDSMTP remove all dsnames from   *
         *                       allocations - use ddname only        *
         *                     - Support new VALIDFROM option         *
         *                       if 0 then nop                        *
         *                       if 1 then validate from/replyto and  *
         *                          terminate if invalid.             *
         *                       if 2 then validate from/replyto and  *
         *                          warn if invalid.                  *
         *                     - Change workdsn for udsmtp d/s to     *
         *                       insure unique dsn                    *
         *          2004-03-24 - 5.08                                 *
         *                     - New &EDATE option for European Date  *
         *                     - New IDWARN option                    *
         *                     - Correct bug with 1 line html message *
         *                     - Support new XMITIPCU option          *
         *                       DateFormat (for non-US format)       *
         *                     - XMITIPCU options From2Rep support    *
         *                     - Correct bug if msgdd is pds member   *
         *                       and filedd is tape                   *
         *                     - Better diag message if gdg on tape   *
         *                     - If fromreq is non-zero and if        *
         *                       from_default is * then set           *
         *                       from_default to from                 *
         *          2004-03-11 - 5.06                                 *
         *                     - Move antispoof jobname set to        *
         *                       XMITIPCU                             *
         *                     - Correct &month/&date/&cdate/&sdate/  *
         *                       &udate/&date calculations for file   *
         *                     - Change sig/disclaim/antispoof to     *
         *                       html text if HTML message            *
         *                     - If FROM and no REPLYTO then set      *
         *                       REPLYTO to FROM                      *
         *                     - Add support for RESPOND keyword      *
         *                     - Add support for IDVAL keyword        *
         *                     - Add support for FAXCHECK to bypass   *
         *                       anti-spoof block from XMITIPCU       *
         *                     - Add support for TPAGEEND and         *
         *                       TPAGELEN from XMITIPCU               *
         *                     - Add support for TPAGELEN keyword to  *
         *                       over-ride XMITIPCU TPAGELEN option   *
         *          2004-02-09 - 5.04                                 *
         *                     - Remove userid length checking        *
         *                     - Add return code test from XMITIPCU   *
         *                     - Bypass Site Disclaimer if PAGE       *
         *                     - Allow commas as address sperators    *
         *                       in the address fields                *
         *          2004-01-28 - 5.02                                 *
         *                     - Correct bug if FORMAT *xxx and mult  *
         *                       MARGIN values to use just the 1st    *
         *                       and issue a message.                 *
         *          2004-01-19 - 5.00                                 *
         *                     - Correct bug if fromreq is an addr    *
         *                       and ispffrom is 1 - used to issue    *
         *                       message of no from and exit          *
         *                     - Implement support correctly for      *
         *                       fromreq being an address             *
         *                     - Test length of userid and if invalid *
         *                       then exit (length of 0).             *
         *                     - Add ending mime boundary for msg html*
         *                     - Support abbreviations for some opts: *
         *                       AFILE for AddressFile                *
         *                       AFILEDD for AddressFileDD            *
         *                       CFG for CONFIG                       *
         *                       CFGDD for CONFIGDD                   *
         *                       FILEN for FILENAME                   *
         *                       FUP for FollowUp                     *
         *                       SENS for Sensitivity                 *
         *          2003-12-08 - 4.98                                 *
         *                     - If FORMAT *xxx then MARGIN used for  *
         *                       all files                            *
         *                     - Correct Format RTF Readonly to only  *
         *                       be on when YES is specified.         *
         *          2003-11-18 - 4.96a                                *
         *                     - Allow symbolics in name-in-archive   *
         *                       for INFOZIP                          *
         *                       Thanks to Doug Rogers                *
         *          2003-11-10 - 4.96                                 *
         *                     - Correct using ZIPPDF for existing PDF*
         *          2003-10-23 - 4.94                                 *
         *                     - Correct message when HTML option used*
         *          2003-10-21 - 4.92d                                *
         *                     - Add suffix setup fro CSV and XLS     *
         *          2003-10-16 - 4.92c                                *
         *                     - Add application/ms-excel for CSV and *
         *                       XLS attachments                      *
         *          2003-10-14 - 4.92b                                *
         *                     - Fix work space for format rtf        *
         *          2003-10-10 - 4.92a                                *
         *                     - Fix max lrecl with msgt              *
         *          2003-10-09 - 4.92                                 *
         *                     - Test for <HTML in record 1 and 2 to  *
         *                       support files created by B2H         *
         *                     - Change for PDF files to change       *
         *                       application/octet to appliation/pdf  *
         *          2003-09-30 - 4.90                                 *
         *                     - Support CONFIG on FORMAT HTML/ZIPHTML*
         *          2003-09-25 - 4.88                                 *
         *                     - Call TXT2RTF for RTF conversion *NEW**
         *                     - Add IGNORESUFFIX Keyword             *
         *                     - Fix if zip_hlq is null               *
         *                     - Support FORMAT RTF config option     *
         *                     - If the input file is already in rtf  *
         *                       format then don't convert again.     *
         *                     - Issue error message and exit if the  *
         *                       input file is in error.              *
         *                     - Issue "No Message Test - File xfer   *
         *                       Only" if applicable with antispoof   *
         *                     - Add RO option to FORMAT RTF          *
         *                     - Support FORMAT ICAL                  *
         *                     - New FOLLOWUP keyword                 *
         *                     - Allow file attachment names with     *
         *                       blanks                               *
         *                     - update MSGT to allow backslash if    *
         *                       preceeded by a slash                 *
         *                     - Correction in machine cc for rtf     *
         *                       for 89 and 8b records                *
         *          2003-08-02 - 4.86                                 *
         *                     - Correct file attachment pdf when     *
         *                       the input is already a pdf           *
         *          2003-07-30 - 4.84                                 *
         *                     - Level change only                    *
         *          2003-07-10 - 4.82                                 *
         *                     - Add HLQ keyword when calling TXT2PDF *
         *          2003-07-01 - 4.80                                 *
         *                     - Allow USS files in MSGDS             *
         *                     - correctly remove x'00' from attach   *
         *          2003-05-27 - 4.78                                 *
         *                     - correct bogus comma in say command   *
         *                     - correct hlq for fileo                *
         *                     - add ending period to zip_hlq if req. *
         *                     - support empty_opt of 2 for rc 0      *
         *                     - pass carriage control in recfm to    *
         *                       txt2pdf                              *
         *                     - pass carriage control in recfm to    *
         *                       txt2html                             *
         *                     - correct bug with comments in addrfile*
         *                     - support 4 lines in anti-spoof        *
         *          2003-04-11 - 4.76                                 *
         *                     - version change to match xmitipi      *
         *          2003-04-04 - 4.74                                 *
         *                     - new &udate symbolic to give date in  *
         *                       mmddyy format                        *
         *                     - new RFC_MaxRecLen to handle the      *
         *                       RFC limit of 998.                    *
         *          2003-03-28 - 4.72                                 *
         *                     - remove b64_load references           *
         *                     - correct html format e-mail message   *
         *                     - if html banner and no filedesc use   *
         *                       file                                 *
         *          2003-03-22 - 4.70                                 *
         *                     - add &jobnum symbolics thanks to Barry*
         *                       Gilder                               *
         *                     - add &RC and &RCA symbolics thx to    *
         *                       Barry Gilder and Ken Tomiak          *
         *                     - add PAGE Keyword, MSGx options and   *
         *                       File, Filedd, and FileO not allowed  *
         *                     - Test empty_opt if message text file  *
         *                       is empty                             *
         *                     - line up antispoof jobname            *
         *          2003-02-14 - 4.68                                 *
         *                     - Add &month variable with &month-n    *
         *                     - Correct overlay cc processing        *
         *                     - Make Secure smtp work dataset unique *
         *          2003-01-15 - 4.66                                 *
         *                     - Correct test for empty antispoof     *
         *                     - Add CONFIG Keywork option for XMITIP *
         *                     - Test FROMREQ value and if 1 then     *
         *                       require a FROM address.              *
         *                     - Make zip_dsn more unique             *
         *                     - Correction for time('s') if          *
         *                       before/after midnight.               *
         *                       (thanks to John Kamp)                *
         *          2002-12-30 - 4.64f                                *
         *                     - Add ErrorsTo keyword                 *
         *          2002-12-19 - 4.64e                                *
         *                     - Translate antispoof to return /'s    *
         *          2002-12-19 - 4.64d                                *
         *                     - Correction for edit message which    *
         *                       lost all other keywords (sigh)       *
         *          2002-12-09 - 4.64c                                *
         *                     - Correction for address_file and      *
         *                       append_domain if atsign var has >1   *
         *          2002-11-20 - 4.64b                                *
         *                     - Correction for RTFXlate per BIll Lee *
         *          2002-11-05 - 4.64                                 *
         *                     - Correct label for proc_nortfxlate    *
         *          2002-10-29 - 4.64                                 *
         *                     - fix from John Ellis to prevent adding*
         *                       append_domain all the time           *
         *          2002-10-23 - 4.62                                 *
         *                     - support new format default option    *
         *                       by prefixing the first and only      *
         *                       format type with * (e.g. format *rtf)*
         *                     - move site_disclaimer process and     *
         *                       only display if ocnfirm enabled      *
         *                     - new symbolic of &xmitver for current *
         *                       XMITIP version                       *
         *                     - fully support addresses with blanks  *
         *                       in addressfiles now                  *
         *                     - Support Format PDF/ds: PDF/dd:       *
         *                     - Enhanced murphy parse routine thanks *
         *                       to Gordon Todd                       *
         *                     - Report out murphy quote if using     *
         *                       MSGT                                 *
         *          2002-09-20 - 4.60                                 *
         *                     - add support for PDF security         *
         *                       read/print only (rpo) and rpo with   *
         *                       password.                            *
         *                     - Add NOSTRIP option                   *
         *                     - Add NORTFXlate option                *
         *                     - Acccept comments in addressfile      *
         *                     - Correct if FILEDD is DUMMY/NULLFILE  *
         *                     - ensure no null lines in msg          *
         *                     - strip trailing blanks from msg and   *
         *                       file attachments                     *
         *                     - change pdf index to generate outline *
         *                     - If format BIN test suffix of file    *
         *                     - correct test for IGNORECC            *
         *                     - If message is empty and no file,     *
         *                       filedd or fileo then exit            *
         *                     - Add message summary for counts of    *
         *                       records and files at end of msg      *
         *                       only if the msg_summary is set       *
         *          2002-08-05 - 4.58                                 *
         *                     - rollup 4.57 beta                     *
         *                     - fix infozip name-in-archive for      *
         *                       FILEDD usage                         *
         *                     - add default_hlq from xmitipcu        *
         *                     - support quoted addresses             *
         *                       e.g. "first last"@address            *
         *                     - fix NoConfirm not attaching file :<  *
         *                     - fix bug with pdf creation (drop in.) *
         *          2002-07-25 - 4.56                                 *
         *                     - include 4.55 beta level              *
         *                     - allow addressfile to/cc/bcc          *
         *                     - if no valid addresses found in the   *
         *                       addressfile/addressfiledd then exit  *
         *                     - translate all nulls to blanks in     *
         *                       input file.                          *
         *                     - if input is pdf and format pdf       *
         *                       then don't convert to pdf            *
         *                     - Move empty message into message      *
         *                       text instead of in file attachment   *
         *                     - support font of bold for PDF         *
         *                       use sizeB (e.g. 9B)                  *
         *                     - support very long subjects           *
         *                     - support &USERID in an address        *
         *                     - fix get pds member routine to ignore *
         *                       gdg datasets.                        *
         *                     - support a from of name-in-archive for*
         *                       InfoZip                              *
         *                     - correction if FROM keyword with no   *
         *                       from address (prevent loop)          *
         *                     - fix for batch with no good stc userid*
         *          2002-05-17 - 4.54                                 *
         *                     - Add PDFIDX option                    *
         *                     - Add ignorecc option                  *
         *                     - Fix HTML MSG option for some mailers *
         *                     - If format XMIT and input isn't then  *
         *                       put it into XMIT before sending.     *
         *                     - Add nullsysout from xmitipcu         *
         *                     - Move Murphy to after Signature       *
         *                     - Add "Murphy says:" before Murphy     *
         *                     - Fix font_size usage in 3 places      *
         *                     - Change workdd dsn to random dsn      *
         *                     - Auto-detect input file as PDF format *
         *                       and send as binary                   *
         *                     - Add banner option to html formats    *
         *                     - replace do_base64 routine to use     *
         *                       new ENCODE64 external routine.       *
         *                     - Fix ZIPCSV                           *
         *                     - Fix length problem for long names in *
         *                       the antispoof message                *
         *                     - Fix generated filename suffix        *
         *                       by testing for valid suffix in       *
         *                       the dsn first.                       *
         *                     - Minor report enhancements            *
         *                     - fix implicit format html variables   *
         *                     - Add space before year in mon dd, yyyy*
         *                     - Add new &cdate variable              *
         *                     - Test for zero length cc and bcc and  *
         *                       tell the user and exit               *
         *                     - Add support for UDSMTP mailer. Set   *
         *                       variables smtp_method & smtp_loadlib *
         *                     - Add ability to attach every member   *
         *                       of a PDS if specified in DD card or  *
         *                       'file' without member name.          *
         *                       See section on FILE and FILEDD parms *
         *                       and Proc_GET_DD_DSN and              *
         *                       Proc_GET_PDS_MEMBERS subroutines.    *
         *                     - attachment boundary text changed to  *
         *                       use some date/time specific text as  *
         *                       a problem occurred when attaching a  *
         *                       dataset that was previous output and *
         *                       contained the boundary text.         *
         *                     - helo statement etc. capitalised as   *
         *                       destination unix smtp server does    *
         *                       not like them in lower case.         *
         *                                                            *
         *          2002-02-07:- 4.52                                 *
         *                     - Fix generated filename for dd        *
         *                     - Correct symbolic substitution to     *
         *                       allow concatenated symvolics and     *
         *                       support math on &date, &sdate, &day  *
         *          2002-02-06   4.51 GA                              *
         *                       -    Fix typo in Margin report       *
         *                       -    Fix &date on subject and in file*
         *                            so &date = mmm dd, yyyy for sub *
         *                            and msgt or mmddyy elsewhere    *
         *                       -    Fix problem with MSGQ in 4.50   *
         *                       -    Support symbolics concatenated  *
         *                            (thanks to Barry Gilder for    *
         *                             finding this and the solution)*
         *          2002-02-04:  4.50 GA                              *
         *                       -    Change to 4.50 because of major *
         *                            ISPF interface changes          *
         *                       -    New MSGT keyword for message    *
         *                            text in command.                *
         *                       -    Remove obsolete REPORT option   *
         *                       -    If no Format then look at       *
         *                            filename suffix for format      *
         *                       -    If no Format or Filename then   *
         *                            test for GIF, PDF, XMIT and     *
         *                            send as binary.                 *
         *                       -    New FORMAT options:             *
         *                            - CSV - text CSV file           *
         *                              - no conversion               *
         *                            - GIF - binary GIF file         *
         *                              - no converesion              *
         *                            - XMIT - binary TSO Transmit    *
         *                              - no conversion               *
         *                       -    For FORMAT HTML do not do the   *
         *                            conversion if <HTML> in record  *
         *                            one of the input file.          *
         *                       -    Calculate work space using      *
         *                            # records per 56000 byte track  *
         *                            htmlwork, pdfwork, and zipwork  *
         *                       -    New DESCOPT in XMITIPCU         *
         *                       -    New EMSG (Edit Message DSN)     *
         *                            option.                         *
         *                       -    Support multiple symbols for    *
         *                            AtSign but only use the first   *
         *                            for generated addresses.        *
         *                       -    set all addresses to use the    *
         *                            first atsign symbol             *
         *                       -    Fix for zip files with input    *
         *                            data with lrecl > 1024          *
         *                       -    New XMITIPCU metric for metric  *
         *                            centimeter measurments for      *
         *                            margins and custom paper size   *
         *                       -    Convert to use TXT2HTML for     *
         *                            HTML conversions.               *
         *                       -    add code from Rich Stuemke to   *
         *                            make pdf and html temp files    *
         *                            more unique                     *
         *                       -    Add Confidential phrasing at    *
         *                            end of e-mail if sensitivity    *
         *                            - call xmitipm for message txt  *
         *                       -    corrections from Barry Gilder   *
         *                            - for filename &sysid           *
         *                            - support in filedesc           *
         *                              &date, &jdate, &sdate and     *
         *                              &sysid                        *
         *                       -    allow filename or filedesc to   *
         *                            use all allowed variables       *
         *                       -    combine symbolic substitution   *
         *                            into single subroutine and allow*
         *                            all symbolics in filename,      *
         *                            filedesc, subject, and text     *
         *          2001-11-19:  4.46 change for enrich text/html     *
         *                       -    Change comment on rtf to rich   *
         *                       -    support antispoof option        *
         *                       -    add blank line after antispoof  *
         *                       -    minor cleanup                   *
         *                       -    correct test for file gdg       *
         *                       -    add validation of format value  *
         *                       -    support font_size and def_orient*
         *                       -    support &sysid in subject       *
         *                       -    fix hlq for batch for unqual    *
         *                            data sets and noprefix          *
         *          2001-10-01:  4.45 add space to report before file *
         *          2001-09-26:  4.44 Change RTF Machine CC process   *
         *                       -    Change exit 4 to exit 8         *
         *                       -    Remove name-in-archive message  *
         *                            if not pkzip.                   *
         *                       -    Issue informational msg if      *
         *                            name-in-archive not supported.  *
         *                       -    Enclose *list-id* in quotes     *
         *                            and remove the *'s              *
         *                       -    Add comma for CC's in envelop   *
         *          2001-08-23:  4.43 fix vget zapplid if under       *
         *                            ISPF and under another app (sas)*
         *                       -    test for empty attachments      *
         *                       -    fix *create* edit macro name    *
         *                       -    fix *create* file suffix        *
         *                       -    change random() to              *
         *                            to right(time('l'),4)           *
         *          2001-08-01:  4.42 match xmitipi level             *
         *          2001-07-23:  4.41 fix zip work alloc if blocks    *
         *                       -    fix zip return code check       *
         *                       -    add disclaimer support defined  *
         *                            in xmitipcu                     *
         *          2001-06-21:  4.40 fix hlq for smtp secure d/s     *
         *          2001-06-14:  4.39 cleanup the envelope header     *
         *                            by removing extra double quote  *
         *          2001-06-06:  4.38 use charuse option from xmitipcu*
         *          2001-06-06:  4.37 fix free for encode dd          *
         *                       - Change Text attachment charset     *
         *          2001-05-21:  4.36 Fix null record in zipwork      *
         *                       - fix append_domain                  *
         *                       - change edit macro name to xmitipem *
         *                       - support GDG file attachments       *
         *                       - cleanup if base64 fails            *
         *                       - change size alloc for zipwork      *
         *                       - enhance xmitip report              *
         *                       - warn if filename and format        *
         *                         don't match (still send)           *
         *                       - fix nulls in message text          *
         *                       - change *create* to just * test     *
         *                         for attachment dsname              *
         *                       - fix h.w test for .                 *
         *                       - updates from Felipe Cvitanich      *
         *                         for binary hfs and atsign support  *
         *                       - move count for zip files to after  *
         *                         zip and encode then test limit     *
         *          xxxx-xx-xx:- 4.35 beta level                      *
         *          2001-03-23:  4.34 Fix Addressfile hlq             *
         *          2001-03-15:  4.33 Add FILEO option                *
         *                       - correct blank/null lines for pdf   *
         *                       - correct format/filename/etc for    *
         *                         filedd                             *
         *          2001-02-12:  4.32 Add : after mail_relay          *
         *                       4.32 Free encodin/encodout           *
         *          2001-01-31:  4.31 add default file suffix         *
         *                       - add mail_relay variable            *
         *                       - clean up history                   *
         *                       - change sender to use from_default  *
         *                         for identification purposes        *
         *          2001-01-03:  4.30 add default paper size          *
         *          2000-12-21:  4.29 change to match xmitipi level   *
         *          2000-12-07:  4.28 add option for receipt type     *
         *          2000-12-06:  4.27 add support for                 *
         *                            create_dsn_lrecl variable       *
         *                       - correct *create* processing        *
         *            ..                                              *
         *          1993-04-15:  redone for XMITIP                    *
         *          1990-09-21:  creation of exec as xmitvm           *
         *                                                            *
         * ---------------------------------------------------------- */

        parse arg options
        if options = "VER" then Return Ver

        signal on novalue name sub_novalue
        _junk_ = sub_init();

        _exit_sample_ = "N"
        if _exit_sample_ = "Y" ,
        then do;
                _x_ = gol_header() ;
                _t_ = "any messages, hints or tipps gathered in gol."
                _x_ = gol(msgid" "_t_""); _t_ = "" ;
                _t_ = "more lines"
                _x_ = gol(msgid" "_t_""); _t_ = "" ;
                _x_ = exit_msg(343" garbage")
             end;

        /* ---------------------------------------------------- *
         * If no options provided and under ISPF then           *
         * call the ISPF front-end. Then exit the code when the *
         * front-end returns.                                   *
         * ---------------------------------------------------- */
        if length(options) = 0 then do;
           if _sysispf_ = "ACTIVE" then do;
             if _sysenv_ = "FORE" then do;
                Address ISPExec,
                   "Select cmd(xmitipi) scrname(XMITIP)"
                exit 0
             end
           end
        end

        /* -------------------------- *
         * set up defaults            *
         * -------------------------- */
        parse value "" with address_n. printcc bcc bcc_n. cc cc_n. ,
                            confirm ddn dsn file filedd filedesc ,
                            filename zip_method fileo emsg ,
                            from from_def from_n. header. msg72 ,
                            importance lp margin msgdd msgds msgq ,
                            msgsub murphy ng nomsg null priority ,
                            receipt receipt_n.  replyto replyto_n. ,
                            rtf sensitivity sigddn sigdsn rc0 ,
                            smtp_secure subject writer_kw zone ,
                            create_dsns size debug format zippass ,
                            file_dsn file_ddn pdf hlq enrich ldap,
                            fsuf mail_relay address_file lang ,
                            msg_rec empty_ds msgtext symtype pdfidx ,
                            pdsloop ignorecc nostrip nortfx format_all ,
                            errorsto config_ds config_dd config_files ,
                            page rfc_warn followup fupdate ,
                            ignore_suffix msg_html ,
                            nomsgt $fax skip_email_text ,
                            responds fromx check_addrs idwarn ,
                            codepage codepage_default vianje ,
                            encoding encoding_default ignoreenc ,
                            smtp_address_override sysout_override

        wtime  = right(time('s') + 10,2)
        workdd = "XM"wtime""right(time('l'),4)
        indd   = "XM"wtime""right(time('l'),4)
        eddd   = "XM"wtime""right(time('l'),4)
        nullc =  "00"x
        _enctype_ = null     /* set _enctype_ to null     */

        ff     = x2c("0C")   /* Form Feed */
        lf     = x2c("0A")   /* Line Feed */
        in.0   = 0           /* set input counter to zero */
        cfopts = 0
        cfctr  = 0

        zipcount    = 0
        pdf_count   = 0
        html_count  = 0
        rtf_count   = 0
        bytes       = 0
        save_lrecl  = 100
        enrich_msg  = 0
        html_msg    = 0

        /* ------------------------------------------------- *
         * Define the MIME Boundary (without the leading --) *
         * ------------------------------------------------- */
        bnd1 = "Mime.Part.XMITIP."
        bnd2 = subword(date(),1,1)subword(date(),2,1)
        bnd3 = subword(date(),3,1)time("S")".0x0zlrhg"
        bnd  = bnd1""bnd2""bnd3  /* concat all parts */

        /* ------------------------------------------- *
         * Test if E-Mail Validation Already Completed *
         * ------------------------------------------- */
         zapplid = null
         if _sysispf_ = "ACTIVE" then do
            Address ISPExec "Vget (Zapplid)"
            if zapplid = "XMIT" then ldap = 1
            end

        /* ----------------------------------------------------- *
         * Invoke XMITIPCU for local customization values        *
         * ----------------------------------------------------- */
        cu = xmitipcu()
        if datatype(cu) = "NUM" ,
        then do;
                 _junk_ = sub_set_zispfrc(cu)
             end;

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

        /* ------------------------------------------------------ *
         * Now remove any leading/trailing blanks from the values *
         * ------------------------------------------------------ */
        _center_      = strip(_center_)
        tcp_domain    = strip(tcp_domain)
        tcp_hostid    = strip(tcp_hostid)
        tcp_name      = strip(tcp_name)
        tcp_stack     = strip(tcp_stack)
        smtp          = strip(smtp)
        log           = strip(log)
        parse var log 1 logdsn logother
        parse var logother 1 . ,
                           1 . "<LOGTYPE>" _logtype_ "</LOGTYPE>" . ,
                           1 . "<LOGMSG>"  _logmsg_  "</LOGMSG>"  . ,
                             .
        logdsn        = strip(logdsn)
        _logtype_     = translate(strip(_logtype_))
        _logmsg_      = strip(_logmsg_)
        _junk_ = sub_logit("XMIT-USAGE")

        zone          = strip(zone)
        vio           = strip(vio)
        writer        = strip(writer)
        mtop          = strip(mtop)
        mbottom       = strip(mbottom)
        mleft         = strip(mleft)
        mright        = strip(mright)
        deflpi        = strip(deflpi)
        tenter        = strip(text_enter)
        dateformat    = strip(dateformat)
        site_disclaim = strip(site_disclaim)
        smtp_address  = strip(smtp_address)
        smtp_domain   = strip(smtp_domain)
        smtp_secure   = strip(smtp_secure)
        sysout_class  = strip(sysout_class)
        faxcheck      = translate(strip(faxcheck))
        from_center   = strip(from_center)
        from_default  = strip(from_default)
             fromx = from_default
        append_domain = strip(append_domain)
        default_hlq   = strip(default_hlq)
        default_lang  = translate(strip(default_lang))
        disable_antispoof = strip(disable_antispoof)
        if tpageend = 1 then tpageend = "ABORT"
                        else tpageend = "WARNING"
        zip_hlq       = strip(zip_hlq)
          if zip_hlq <> null then
             if right(zip_hlq,1) <> "."
                then zip_hlq = zip_hlq"."
        zip_load      = strip(zip_load)
        zip_type      = strip(zip_type)
        zip_unit      = strip(zip_unit)
        paper_size    = strip(paper_size)
        file_suf      = strip(file_suf)
        force_suf     = translate(strip(force_suf))
        mail_relay    = strip(mail_relay)
        if length(mail_relay) > 0 then
                  mail_relay = mail_relay":"
        AtSign        = strip(AtSign)
        AtSIgnC       = left(AtSign,1)
        char          = strip(char)
        charuse       = strip(charuse)
        disclaim      = strip(disclaim)
        font_size     = strip(font_size)
        def_orient    = strip(def_orient)
        conf_msg      = translate(strip(conf_msg))
        mailfmt       = translate(strip(mailfmt))
        nullsysout    = strip(nullsysout)
        fromreq       = strip(fromreq)
        starttls      = strip(starttls)
        if translate(starttls) = "ON" then starttls = 1
                           else starttls = 0
        smtp_method   = strip(smtp_method)
        smtp_loadlib  = translate(strip(smtp_loadlib))
        smtp_server   = strip(smtp_server)
        txt2pdf_parms = strip(txt2pdf_parms)
        parse var txt2pdf_parms ,
                  1 . "<COMPRESS>" _txt2pdf_compress_ "</COMPRESS>" . ,
                  1 . "<XLATE>"    _txt2pdf_xlate_    "</XLATE>"    . ,
                               1 .
        xmitsock_parms = strip(xmitsock_parms)
        parse var special_chars 1 cp_used sp_chars cp_info
        sp_codepage   = strip(cp_used)
        sp_chars      = strip(sp_chars)
        sp_chars_info = strip(cp_info)
        excl          = substr(sp_chars,1,1)
        basl          = substr(sp_chars,2,1)
        diar          = substr(sp_chars,3,1)
        brsl          = substr(sp_chars,4,1)
        brsr          = substr(sp_chars,5,1)
        brcl          = substr(sp_chars,6,1)
        brcr          = substr(sp_chars,7,1)
        hash          = substr(sp_chars,8,1)
        systcpd       = strip(systcpd)
        restrict_domain = translate(strip(restrict_domain))
        restrict_hlq    = translate(strip(restrict_hlq))
        jobid         = strip(jobid)
        jobidl        = strip(jobidl)
        codepage_default = strip(codepage_default)
        encoding_default = strip(encoding_default)
        encoding_check   = translate(strip(encoding_check))
        select;
          when ( left(encoding_check,1) = "Y" ) ,
                 then encoding_check    = "YES"
          when ( left(encoding_check,1) = "W" ) ,
                 then encoding_check    = "WARN"
          when ( left(encoding_check,1) = "O" ) ,
                 then encoding_check    = "ONCE"
          when ( left(encoding_check,1) = "N" ) ,
                 then encoding_check    = "NO"
          otherwise   encoding_check    = "NO"
        end;
        check_send_from  = strip(check_send_from)
        check_send_to    = strip(check_send_to)
        smtp_array       = strip(smtp_array)
        if   codepage = "" ,
        then codepage = codepage_default
        if   encoding = "" ,
        then encoding = encoding_default

        if Mime8Bit = 0 then MimeHead = "7bit"
                        else MimeHead = "8bit"

        Select
        when receipt_type = 1 then
           receipt_key = "Return-Receipt-To"
        when receipt_type = 2 then
           receipt_key = "Disposition-Notification-To"
        otherwise
           receipt_key = "Disposition-Notification-To"
           end

        /* --------------------------------------------------------- *
         * Add to the CUSTSYM additional symbolics to be handled  by *
         * XMITIP. These work in file names, msgt text, and subject  *
         * lines.                                                    *
         *                                                           *
         * &plr = parenthesis left round (                           *
         * &prl = parenthesis right round )                          *
         * &timezone = current active time zone                      *
         * --------------------------------------------------------- */
         if custsym /= null then
            custsym       = strip(custsym) "&plr ( &prr )" ,
                           "&timezone" zone

        /* --------------------------- *
         * Setup variables for CUSTSYM *
         * --------------------------- */
         custsym_var   = null
         custsym_val.0 = 0
         if custsym   /= null ,
         then do;
                 do until length(custsym) = 0
                    parse value custsym with "&"sym symv "&"syml
                    custsym_var = custsym_var "&"translate(sym)
                    cv = custsym_val.0 + 1
                    custsym_val.0 = cv
                    custsym_val.cv = strip(symv)
                    if length(strip(syml)) > 0 ,
                       then custsym = "&"syml
                       else custsym = null
                 end
              end;

         _s_double_ = _s_""_s_
         parse value cu with . (_s_double_) cu_add_check
         if strip(cu_add) = strip(cu_add_check) ,
         then nop
         else do;
                    _rcode_ = 12
                    say msgid "XMITIPCU parms not plausible."
                    say msgid "cu_add      : ***"cu_add"***"
                    say msgid "cu_add_check: ***"cu_add_check"***"
                    say msgid "(Use of TESTCU may help.)"
                    say msgid "Terminating (rcode="_rcode_")."
                    say msgid "Contact your XMITIP Support."
                    _junk_ = sub_set_zispfrc(_rcode_);
              end;

        /* ----------------------------------------------------- *
         *  Test if xmitipcu_infos are available                 *
         *  format: <msgtype><MSG>text</MSG></msgtype>           *
         *          - <msgtype>values</msgtype> ...    m times   *
         *            with values in the following format        *
         *          - <MSG>text</MSG><MSG>text2</MSG>  n times   *
         * ----------------------------------------------------- */
         parse var xmitipcu_infos ,
             1 . "<CU#RC>"   cu_rc   "</CU#RC>"        . ,
             1 . "<CU#MSG>"  cu_msg  "</CU#MSG>"       . ,
             1 .
         select;
           when ( datatype(cu_rc) /= "NUM" ) ,
             then do;
                      /* misconfiguration but continue */
                      nop;
                  end;
           when ( cu_rc = 0 ) then nop
           otherwise do;
                   say msgid "version: "ver
                   say msgid "XMITIPCU infos available.",
                             "Please check messages."
                   _junk_ = sub_xml(cu_msg)
                   do i = 1 to xml.0
                      say msgid" "xml.i.1" (message type)"
                      _count_ = 0
                      _messages_   = xml.i.2
                      do forever
                         parse var _messages_ ,
                                     . "<MSG>" _msg_ "</MSG>" ,
                                     _messages_
                         _msg_     = strip(_msg_)
                         if _msg_ /= "" ,
                         then do;
                                 _count_ = _count_ + 1
                                 say msgid"   "right(_count_,2,0)"",
                                     ""strip(_msg_)"",
                                     ""
                              end;
                         _messages_ = strip(_messages_)
                         if _messages_ = "" then leave
                      end
                   end
                   if cu_rc < 5 ,
                   then do;
                            say msgid "(WARNING/INFO - processing",
                                      "continues.)"
                        end;
                   else do;
                            _rcode_ = cu_rc
                            say msgid "Terminating ..."
                            _junk_ = sub_set_zispfrc(_rcode_);
                        end;
                  end
         end;

        /* ----------------------------------------------------- *
         *  Test if Batch e-mail validation enabled              *
         * ----------------------------------------------------- */
         if batch_idval > 0 then ldap = 1

        /* ------------------------------- *
         * Save the Original Input Options *
         * ------------------------------- */
         save_options = options

        /* ---------------------------------------------------------- *
         * Process the to/recipient address into the address variable *
         * ---------------------------------------------------------- */
         Select
            when left(options,1) = '"' then do
                 pl = pos(">",options)
                 address = left(options,pl)
                 options = substr(options,pl+1)
                 end
            when left(options,1) = "'" then do
                 pl = pos(">",options)
                 address = left(options,pl)
                 options = substr(options,pl+1)
                 end
            when left(options,1) = "(" then do
                 parse value options with "(" address ")" options
                 end
            otherwise
                 parse value options with address options
            end
         options = strip(options)
         address = translate(address," ",",")

        save_address = address
        call process_address "("address")"
        address = t_addrs
        do i = 1 to t_names.0
           address_n.i = strip(t_names.i)
           end

        if address = "?" then signal exit_8
        if length(address) = 0 then signal exit_8

        /* ----------------------------- *
         * get uppercase copy of options *
         * ----------------------------- */
        options       = strip(options)
        upper_options = translate(options)

        /* ------------------------------------------------ *
         * Test for Default_Lang and use if no Lang defined *
         * ------------------------------------------------ */
         if wordpos("LANG",upper_options) > 0 then call proc_lang
         if lang = null then
            if default_lang <> null
               then lang = default_lang
               else do
                    lang         = "English"
                    default_lang = lang
                    end

        /* --------------------------------------- *
         * Check the MAILFMT default from XMITIPCU *
         * if HTML then set html environment.      *
         * --------------------------------------- */
         if mailfmt = "HTML" then do
            enrich = "html"
            msg_html = 1
            end

        /* ----------------------------------------------------- *
         * Now process the keywords                              *
         * ----------------------------------------------------- */
        do until length(options) = 0
           option = word(upper_options,1)
           Select
             When abbrev("FROM",option,2)    then call proc_from
             When abbrev("REPLYTO",option,3) then call proc_replyto
             When abbrev("NOMSGSUM",option,6) then call proc_nomsgsum
             When option = "CONFMSG"       then call proc_confmsg
             When option = "ADDRESSFILE"   then call proc_addressfile
             When option = "AFILE"         then call proc_addressfile
             When option = "ADDRESSFILEDD" then call proc_addressfiledd
             When option = "AFILEDD"       then call proc_addressfiledd
             When option = "ASA"           then call proc_asa
             When option = "BCC"           then call proc_bcc
             When option = "CC"            then call proc_cc
             When option = "CONFIG"        then call proc_config
             When option = "CFG"           then call proc_config
             When option = "CP"            then call proc_codepage
             When option = "CODEPAGE"      then call proc_codepage
             When option = "CONFIGDD"      then call proc_configdd
             When option = "CFGDD"         then call proc_configdd
             When option = "DEBUG"         then call proc_debug
             When option = "EMSG"          then call proc_emsg
             When option = "ERRORSTO"      then call proc_errorsto
             When abbrev("FILE",option,2)  then call proc_file
             When option = "FILEDD"        then call proc_filedd
             When option = "FILEDESC"      then call proc_filedesc
             When option = "FILENAME"      then call proc_filename
             When option = "FILEN"         then call proc_filename
             When option = "FILEO"         then call proc_fileo
             When option = "FOLLOWUP"      then call proc_followup
             When option = "FUP"           then call proc_followup
             When abbrev("FORMAT",option,4) then call proc_format
             When option = "HLQ"           then call proc_hlq
             When option = "HTML"          then call proc_html
             When option = "IMPORTANCE"    then call proc_importance
             When option = "IGNOREENC"     then call proc_ignoreenc
             When option = "IGNORECC"      then call proc_ignorecc
             When option = "IGNORESUFFIX"  then call proc_ignore_suffix
             When option = "MACH"          then call proc_mach
             When option = "MAILFMT"       then call proc_mailfmt
             When option = "MARGIN"        then call proc_margin
             When option = "MSGDD"         then call proc_msgdd
             When option = "MSGDS"         then call proc_msgds
             When option = "MSGQ"          then call proc_msgq
             When option = "MSGT"          then call proc_msgt
             When option = "MSG72"         then call proc_msg72
             When option = "MURPHY"        then call proc_murphy
             When option = "NOCONFIRM"     then call proc_noconfirm
             When option = "NOEMPTY"       then call proc_noempty
             When option = "IDVAL"         then call proc_idval
             When option = "IDWARN"        then call proc_idwarn
             When option = "LANG"          then call proc_lang
             When option = "NOIDVAL"       then call proc_noidval
             When option = "NOSTRIP"       then call proc_nostrip
             When option = "NOMSG"         then call proc_nomsg
             When option = "NORTFXLATE"    then call proc_nortfxlate
             When option = "NOSPOOF"       then call proc_nospoof
             When option = "NODISCLAIM"    then do
                  options = delword(options,1,1)
                  disclaim = null
                  end
             When option = "PAGE"          then call proc_page
             When option = "PDFIDX"        then call proc_pdfidx
             When abbrev("PRIORITY",option,2) then call proc_priority
             When option = "RC0"           then call proc_rc0
             When option = "RECEIPT"       then call proc_receipt
             When option = "RESPOND"       then call proc_responds
             When abbrev("SENSITIVITY",option,4)
                  then call proc_sensitivity
             When option = "SIG"           then call proc_sig
             When option = "SIGDD"         then call proc_sigdd
             When option = "SIZELIM"       then call proc_sizelim
             When option = "SMTPCLAS"      then call proc_smtpclas
             When option = "SMTPDEST"      then call proc_smtpdest
             When option = "TLS"           then call proc_tls
             When abbrev("SUBJECT",option,3) then call proc_subject
             When option = "TPAGELEN"      then call proc_tpagelen
             When option = "VIANJE"        then call proc_vianje
             When option = "ZIPMETHOD"     then call proc_zipmethod
             When option = "ZIPPASS"       then call proc_zippass
             /* reserved for testing purposes */
             When option = "XMZIP"         then call proc_xmzip
             Otherwise do
               say msgid "keyword: >"option"<" ,
                   "is invalid in the syntax of this command."
               signal exit_8
             end
           end
           options       = strip(options)
           upper_options = translate(options)
         end

        /* ----------------------------------- *
         * Test for VIANJE and update _center_ *
         * ----------------------------------- */
       if vianje <> null  then do
           _center_ = vianje
           _center_= strip(_center_)
            smtp_address = _center_"."smtp
          end

        /* ----------------------------------------------------- *
         * Test to see if HLQ specified, otherwise default       *
         * ----------------------------------------------------- */
        if default_hlq <> null
           then if hlq = null
                then hlq = default_hlq
        if hlq = null  then
           Select
           when sysvar("syspref") = null then do
              hlq  = sysvar("sysuid")
              bhlq = hlq
              end
           When sysvar("syspref") <> sysvar("sysuid") then do
              if sysvar("sysuid") = null ,
                 then hlq  = sysvar("syspref")
                 else hlq  = sysvar("syspref")"."sysvar("sysuid")
              bhlq = sysvar("syspref")
              end
           Otherwise do
              hlq  = sysvar("syspref")
              bhlq = hlq
              end
           end
        else bhlq = hlq

        /* ------------------------------------------------------- *
         * Test Restrict_HLQ                                       *
         *                                                         *
         * If the hlq is in the restrict_hlq list then perform the *
         * requested action:                                       *
         *                                                         *
         *     Log - notify the user, log the violation, continue  *
         *     Term - notify the user, log the violation, exit     *
         * ------------------------------------------------------- */
         if restrict_hlq <> null then do
            parse value restrict_hlq with raction rhlqs
            Select
            When  wordpos(hlq,rhlqs)  = 0 then nop
            When raction = "LOG" then do
               say msgid "Warning: The default high level qualifier" ,
                         "for this job is" hlq "which is restricted."
               say msgid "         The XMITIP parameter" ,
                         "of HLQ needs to be coded with",
                         "a valid high level qualifier",
                         "for this job."
               say msgid "         This job will be allowed to" ,
                         "continue execution for now but this problem" ,
                         "should be addressed soon."
               _junk_ = sub_logit("HLQ Violation LOG HLQ" hlq)
               end
            When raction = "TERM" then do
               say msgid "Error: The default high level qualifier" ,
                         "for this job is" hlq "which is restricted."
               say msgid "       The XMITIP parameter" ,
                         "of HLQ needs to be coded with",
                         "a valid high level qualifier",
                         "for this job."
               say msgid "       This job is being terminated."
               _junk_ = sub_logit("HLQ Violation TERM HLQ" hlq)
               _junk_ = sub_set_zispfrc("8")
               end
            otherwise nop;
            end /* end select */
            end

        /* --------------------------------------------------------- *
         * Test AddressFile dsname                                   *
         * --------------------------------------------------------- */
        if address_file <> null then
           call Proc_AddressFile_Setup

        /* ---------------------------- *
         * Test to see if FROM Required *
         * ---------------------------- */
         Select
            When fromreq = 1 then
                 if strip(from) = null then do
                    say msgid" "copies("*",40)
                    say msgid "Error: No FROM e-mail address specified."
                    say msgid "       XMITIP is terminating. This is a"
                    say msgid "       required parameter for XMITIP."
                    say msgid" "copies("*",40)
                    say msgid " "
                    _junk_ = sub_set_zispfrc("8")
                    end
            When fromreq = 0 then nop
            When datatype(fromreq) = "CHAR" then
                 if strip(from) = null then do
                    bcc = strip(bcc fromreq)
                    say msgid" "copies("*",40)
                    say msgid "Warning: No FROM e-mail address",
                              "specified."
                    say msgid "         Message logged to:" fromreq
                    say msgid" "copies("*",40)
                    say msgid " "
                 end
            Otherwise nop
         end

        /* ------------------------------------------ *
         * Test Send_From and if set to 1             *
         *      then if a from was specified          *
         *           then copy from into from_default *
         * ------------------------------------------ */
         if send_from = 1 then
            if length(from) > 0 then
               from_default = from

        /* ---------------------------------------------------- *
         * Test if From_Default is * and if FromReq is non-zero *
         * and if all true set From_Default to From             *
         * ---------------------------------------------------- */
         if from_default = "*" then
            if fromreq <> 0 then do
               fromx        = from
               from_default = from
               end

        /* ----------------------------------------- *
         * Test if PAGE specified and then for Files *
         * ----------------------------------------- */
         if page <> null then do
            if length(subject) > 0 then do
               say msgid "Error: PAGE was specified along with",
                         "SUBJECT - select one or the other."
               _junk_ = sub_set_zispfrc("8")
               end
            if length(file) + length(fileo) + length(filedd) > 0
               then do
                    say msgid "Error: PAGE was specified along with",
                              "either FILE, FILEDD, or FILEO. Files" ,
                              "are not allowed with PAGE."
                    _junk_ = sub_set_zispfrc("8")
                    end
            end

        /* ----------------------------------------------------- *
         * Test for Format * (all) and Margins.  If multiple     *
         * margin values use only the first and inform the user. *
         * ----------------------------------------------------- */
         if format_all = 1 then
            if words(margin) > 1 then do
               parse value margin with margin mx
                    say msgid "Warning:"
                    say msgid "FORMAT * specified with multiple" ,
                              "Margin values coded."
                    say msgid "Margin" margin "will be used."
                    say msgid "Margins" mx "will be ignored."
                    say msgid " "
               end

        /* ----------------------------------------------------- *
         * Test validity of FILE dsnames (if specified)          *
         * ----------------------------------------------------- */
         if length(file) > 0 then
            do i = 1 to words(file)
               fthit = 0
               ng    = 0
               if left(word(file,i),1) = "*" then iterate
               if left(word(file,i),1) <> "'" then do
                  templ = subword(file,1,i-1)
                  tempr = subword(file,i+1)
                  file = templ "'"bhlq"."word(file,i)"'" tempr
                  end
               if pos("(",word(file,i)) > 0 then do
                  parse value word(file,i) with templ"("gdg")"tempr
                  if datatype(gdg) <> "NUM" then do
                  if pos("*",gdg) = 0 then leave
                  templ = templ""tempr
                  if "OK" <> sysdsn(templ) then do
                      ng = 1
                      say msgid "DSN:" word(file,i) ,
                                "-" sysdsn(templ)
                     end
                  end
                  if gdg = "*" then do
                     _junk_ = outtrap("junk","*")
                     "listcat ent("templ") gdg"
                     if rc = 0 then file = templ
                     call outtrap "off"
                     end
                  end
               if ng = 0 then
               if pos("(",word(file,i)) > 0 then do
                  parse value word(file,i) with templ "("gdg")"
                  if datatype(gdg) <> "NUM" then leave
                  tempd = allocgdg("*" word(file,i))
                  if datatype(tempd) = "NUM" then do
                     say msgid "Requested GDG could not be processed",
                               "either because it is on tape or does",
                               "not exist."
                     say msgid "Exiting - try again."
                     _junk_ = sub_set_zispfrc("8")
                     end
                  templ = subword(file,1,i-1)
                  tempr = subword(file,i+1)
                  file = templ tempd tempr
                  end
               if ng = 0 then
               if "OK" <> sysdsn(word(file,i)) then do
                   ng = 1
                   say msgid "DSN:" word(file,i) ,
                             "-" sysdsn(word(file,i))
                   end
               if ng = 1 then do
                  _rcode_ = 8
                  Say msgid "Ending because of invalid dsnames."
                  _junk_ = sub_set_zispfrc(_rcode_)
                  end
               end

        /* ---------------------------------------------- *
         * Test for FAX and if so turn off anti_spoof and *
         * turn on enrich (html) message text.            *
         * ---------------------------------------------- */
         if faxcheck <> null ,
         then do
                if pos(faxcheck,translate(address)) > 0 ,
                then do
                         antispoof = null
                         enrich    = "html"
                         $fax      = 1
                     end
              end

        /* ----------------------------------------------------- *
         * Test enrich keyword and default if needed             *
         * ----------------------------------------------------- */
        if enrich = null then
           enrich = "plain"

        /* ----------------------------------------------------- *
         * Test if to=*list-id  then must have cc or bcc         *
         * ----------------------------------------------------- */
           if left(address,1) = "*" then do
              if words(cc) + words(bcc) = 0 then do
                 say msgid "A *list-id* address must have a CC or" ,
                           "BCC list of addresses."
                 say msgid "Process ending."
                 signal exit_8
                 end
             end

        /* ----------------------------------------------------- *
         * Test Validity of all e-mail addresses.                *
         * ----------------------------------------------------- */
         parse value "" with t_address t_cc t_bcc temp_address
         do i = 1 to words(address)
            call test_address word(address,i) "To"
            if trc = 1 then
               t_address = strip(t_address temp_address)
            else
               t_address = strip(t_address word(address,i))
            end
         do i = 1 to words(cc)
            call test_address word(cc,i) "CC"
            if pos(word(cc,i),t_address) = 0 then do
               if trc = 1 then
                  t_cc = strip(t_cc temp_address)
               else
                  t_cc = strip(t_cc word(cc,i))
               end
            end
         do i = 1 to words(bcc)
            call test_address word(bcc,i) "BCC"
            if pos(word(bcc,i),t_address t_cc) = 0 then do
               if trc = 1 then
                  t_bcc = strip(t_bcc temp_address)
               else
                  t_bcc = strip(t_bcc word(bcc,i))
               end
            end
         address = t_address
         cc      = t_cc
         bcc     = t_bcc

         if check_send_to   /= "" ,
         then do;
                 chk_val = sub_check_send_to() ;
                 datatype_chk_val = datatype(chk_val)
                 if datatype_chk_val = "NUM" ,
                 then do;
                         if chk_val /= 0 ,
                         then do;
                                 say msgid ""check_send_to
                                 say msgid "check_send_to routine",
                                     "ends with RC="chk_val
                                 say msgid "Exiting ..."
                                 _junk_ = sub_set_zispfrc("8")
                              end;
                      end;
              end;

        /* ----------------------------- *
         * Define line separator if html *
         * ----------------------------- */
         if enrich = "html" then linesep = "<br>"
                            else linesep = null

        /* --------------------------------------------------------- *
         * Process Confidential Statement if Sensitivity coded       *
         * if Conf_msg = TOP
         * --------------------------------------------------------- */
         if sensitivity <> null then
            if conf_msg = "TOP" then do
               m = in.0 + 1
               if enrich = "html" then do
                  in.m = "<html>"
                  m = m + 1
                  in.m = "<head>"
                  m = m + 1
                  in.m = "<"excl"-- conf_msg top -->"
                  m = m + 1
                  in.m = "</head>"
                  m = m + 1
                  in.m = "<body>"
                  m = m + 1
                  in.m = "<pre><font color=red><b>"
                  m = m + 1
                  end
               call do_conf_msg
               m = m + 1
               if enrich = "html" then do
                  in.m = "</b></font></pre>"
                  m = m + 1
                  in.m = "<pre>"     /* keep pre active */
                  m = m + 1
                  end
               in.m = " "
               in.0 = m
               end

        /* -------------------------------------------------------- *
         * Test to determine if multiple MSG options were specified *
         * or if none were. If none then default to MSGT with       *
         * default text.                                            *
         * -------------------------------------------------------- */
         mhit = null
         if dsn     <> null then mhit = "MSGDS"
         if ddn     <> null then mhit = mhit "MSGDD"
         if msgq    <> null then nop
         if msgtext <> null then mhit = mhit "MSGT"
         if page    <> null then mhit = mhit "PAGE"
         if nomsg   <> null then mhit = mhit "NOMSG"
         if words(mhit) = 2 then
            if wordpos("NOMSG",mhit) > 0 then do
               nomsg = null
               mp = wordpos("NOMSG",mhit)
               if mp = 1 then mhit = subword(mhit,2,1)
                         else mhit = subword(mhit,1,1)
               say msgid "NOMSG was found along with" mhit
               say msgid "Ignoring NOMSG request."
               end
         if words(mhit) > 1 then do
            say msgid "Multiple Message options specified:",
                      mhit
            say msgid "Only one message option allowed."
            say msgid "Exiting..."
            _junk_ = sub_set_zispfrc("8")
            end
         if mhit = null then do;
            if length(file) + length(fileo) + length(filedd) > 0 ,
            then do
                 say msgid "Neither the MSGDS, MSGDD, MSGQ," ,
                           "MSGT or NOMSG were specified."
                 say msgid "NOMSG assumed."
                 say msgid " "
                 msgtext = "No message provided for this e-mail" ,
                           "- file attachment only."
                 nomsgt  = 1
                 end
            else do
                 say msgid "No Message text specified and no" ,
                           "FILE, FILEDD, or FILEO specified."
                 say msgid "Command terminating - try again."
                 signal exit_8
                 end
            end;
            if wordpos("NOMSG",mhit) > 0 then do
                 nomsgt  = 1
            end;

        /* -------------------------------------------- *
         * Test for PAGE and setup msgtext accordingly. *
         * -------------------------------------------- */
         if page <> null then do
            msgtext = page
            if antispoof <> null then ,
               msgtext = msgtext "("sysvar('sysuid')")"
            pagelen = length(from msgtext)
            if tpagelen > 0 then do
               if pagelen > tpagelen then do
                    Select
                     When tpageend = "ABORT" then do
                          say msgid "Text page length of" pagelen ,
                              "exceeds limit of" tpagelen
                          say msgid "Aborting...."
                          _junk_ = sub_set_zispfrc("8")
                          end
                     Otherwise do
                          say msgid "Warning....."
                          say msgid "Text page length of" pagelen ,
                              "exceeds limit of" tpagelen
                          say msgid "Part of your message text may" ,
                              "be truncated."
                          say msgid " "
                          end
                    end
                  end
               end
            end

        /* ---------------------------------------- *
         * If MSGT keyword used insert message text *
         * ---------------------------------------- */
         if msgtext <> null then do
            if length(dsn) + length(ddn) + length(msgq) > 0
              then do
                   if page <> null then
                   say msgid "PAGE was specified but so was" ,
                             "MSGT, MSGDS, MSGDD or MSGQ."
                   else
                   say msgid "MSGT was specified but so was" ,
                             "MSGDS, MSGDD or MSGQ."
                   say msgid "Only 1 of these is allowed."
                   say msgid "Command terminating - try again."
                   signal exit_8
                   end
            nomsg = "off"
            m = in.0

           /* ------------------------------------------------------- */
           /* Process MSGTEXT with backslash as a newline but comb.   */
           /* slash backslash allows the backslash (escape character) */
           /* ------------------------------------------------------- */
            if pos("/"basl,msgtext) > 0 then do
               do until pos("/"basl,msgtext) = 0
                  p = pos("/"basl,msgtext)
                  ml = left(msgtext,p-1)
                  mr = substr(msgtext,p+2)
                  msgtext = ml""x2c("01")""mr
                  end
               end
            do until pos(basl,msgtext) = 0
               m = m + 1
               parse value msgtext with msgtextl(basl)msgtext
               msgtextl = translate(msgtextl,basl,x2c("01"))
               in.m = msgtextl
               end
            if length(msgtext) > 0 then do
               m = m + 1
               msgtext = translate(msgtext,basl,x2c("01"))
               in.m = msgtext
               end
            in.0    = m
            msg_rec = m
            end

        /* ----------------------------------------------------- *
         * If MSGQ is specified then read in the QUEUED message  *
         * ----------------------------------------------------- */
         if msgq = 1 then do
            msgqc = queued()
            m = in.0
            do i = 1 to msgqc
               parse pull msgqd
               m = m + 1
               in.m = msgqd
               end
            in.0 = m
            end

        /* -------------------------- */
        /* Test for MSGDS, MSGDD or   */
        /* MSGQ unless NOMSG.         */
        /* -------------------------- */
        if nomsg = null then do

          /* ----------------------------------------------------- */
          /* If MSGDS is * then check for ISPF environment and     */
          /* create dsn....                                        */
          /* ----------------------------------------------------- */
         if dsn = "*" then do
            if _sysispf_ <> "ACTIVE" then do
               say msgid "MSGDS of * specified but ISPF is not active."
               say msgid "Try again when under ISPF."
               _junk_ = sub_set_zispfrc("8")
               end
            else do
                 "Alloc f("eddd") unit("vio") spa(15,15) tr dsorg(ps)" ,
                       "recfm(v b) lrecl(76) new reuse blksize(0)"
                 if enrich = "html" then do
                 /*
                    o.1 = "Mime-Version: 1.0"
                    o.2 = "Content-type: multipart/mixed;"
                    o.3 = '  boundary="'bnd'"'
                    o.4 = " "
                    o.5 = "This is a multi-part message in MIME format."
                    o.6 = "--"bnd
                    o.7 = "Content-Type: text/html; charset="char
                    o.8 = "Content-Transfer-Encoding:" MimeHead
                    o.9 = " "
                    o.10 = "<html><head></head><body><pre>"
                 */
                    o.1 = "<html><pre>"
                    enrich_msg = 0   /* was 1 */
                    "Execio * diskw "eddd" (finis stem o."
                    o. = null
                    end
                 if _sysispf_ <> "ACTIVE" then do
                    say msgid "Your request for ISPF Services (EDIT)",
                        "can not be honored as you are not under",
                        "ISPF at this time."
                    say msgid "Processing is ending."
                    _junk_ = sub_set_zispfrc("8")
                    end
                 Address ISPExec
                 "LMInit dataid(xmited) ddname("eddd")"
                 edtitle = "XMITIP Message"
                  "Vput (tenter enrich)"
                 "Edit dataid(&xmited) profile(xmitip)" ,
                      "macro(xmitipem) Panel(xmitiped)"
                 e_rc = rc
                 ddn  = eddd
                 indd = ddn
                 Address TSO
                 if e_rc > 3 then do
                    "Free f("eddd")"
                    say msgid "Ending per your request."
                    _junk_ = sub_set_zispfrc(e_rc)
                    end
                 end
            end

        /* -------------------------- *
         * If nomsg not specified     *
         * process MSGDS or MSGDD     *
         * -------------------------- */
         Select
           When dsn = null then do
                indd = ddn
                call listdsi(ddn "FILE")
                if datatype(syslrecl) <> "NUM" ,
                   then syslrecl = 0
                save_lrecl = max(syslrecl, save_lrecl)
                dsn = sysdsname
                msgds_omvs = 0
                end
           When left(dsn,2) = "'/" | left(dsn,1) = "/" then do
                mlq = "V"time('s') + random(1000) + random(10000)
                file_msg = "'"hlq"."mlq".xmitip.omvs.msg'"
                if left(dsn,1) <> "'" then ,
                   dsn = "'"strip(dsn)"'"
                file_msg = translate(file_msg)
                call msg "off"
                "OGet" dsn file_msg "TEXT"
                _rcode_ = rc
                if _rcode_ > 0 then do
                   say msgid dsn "access or read error."
                   _junk_ = sub_set_zispfrc(_rcode_)
                   end
                dsn = file_msg
                msgds_omvs = 1
                end
           When dsn <> "*" then do
                if left(dsn,1) <> "'" then ,
                   dsn = "'"bhlq"."dsn"'"
                if "OK" <> sysdsn(dsn) then do
                   say msgid "Message dataset error"
                   say msgid dsn sysdsn(dsn)
                   say msgid "Terminating - try again."
                   _junk_ = sub_set_zispfrc("8")
                   end
                call listdsi(dsn)
                save_lrecl = max(syslrecl, save_lrecl)
                msgds_omvs = 0
                end
           Otherwise msgds_omvs = 0
           end

           if save_lrecl > 1024 then signal big_lrecl
           if save_lrecl > 998  then call rfc_maxlrecl

           if ddn = null then ,
              "ALLOC F("indd") DS("dsn") SHR"

           drop inx.
           "EXECIO * DISKR" indd "(FINIS STEM inx."
           e_rc = rc
           listdsi_rc = listdsi(indd "FILE")
           sysrecfm = sysrecfm
           if pos(right(sysrecfm,1),"AM") > 0 then ,
              do fcc = 1 to inx.0
                 inx.fcc = substr(inx.fcc,2)
                 end
           if msgds_omvs = 1 then ,
              "Delete" file_msg

          /* --------------------------------------------------- *
           * Translate the contents of the message for variables *
           * -- thanks to Dana Mitchell                          *
           * --------------------------------------------------- */
           do fcc = 1 to inx.0
              inx.fcc = fix_symbolics(inx.fcc)
              end

          /* ------------------------------------------------------- *
           * Test for EMSG option and if on then:                    *
           * 1. create a temporary dataset                           *
           * 2. write the msgds dsn to it                            *
           * 3. open ispf edit                                       *
           * 4. read in the updated dsn                              *
           * 5. delete temporary dataset                             *
           * ------------------------------------------------------- */
           if emsg = "on" then do
              "Free f("indd")"
              if _sysispf_ <> "ACTIVE" then do
                 say msgid "Your request for ISPF Services (EDIT)",
                     "can not be honored as you are not under",
                     "ISPF at this time."
                 say msgid "Processing is ending."
                 _junk_ = sub_set_zispfrc("8")
                 end
              if left(sysrecfm,1) = "F" then ,
                 trecfm = "F B"
                 else trecfm = "V B"
              "Alloc f("indd") unit("vio") dsorg(ps)" ,
                     "new reuse blksize(0)" ,
                     "recfm("trecfm") lrecl("syslrecl")" ,
                     "dsn(emsg."indd") tr spa(90,90)"
              "Execio * diskw" indd "(finis stem inx."
              Address ISPExec
                 "LMInit dataid(xmited) ddname("indd")"
                 "Edit dataid(&xmited) profile(xmitip)" ,
                      "Panel(xmitiped)"
                 e_rc = rc
                 "Vget (zeditcmd)"
                 if pos(zeditcmd,"CANCEL") = 0
                    then e_rc = 0
                 "LMFree dataid(&xmited)"
              call msg "off"
              Address TSO
              if e_rc > 3 then do
                 "Free f("indd")"
                 "Delete emsg."indd
                 say msgid "Ending per your request."
                 _junk_ = sub_set_zispfrc(e_rc)
                 end
              drop inx.
              "Execio * diskr" indd "(Finis stem inx."
              "Delete emsg."indd
              end

           /* -------------------------------------------------- */
           /* fix up message lines that start with a . as the    */
           /* first . will be lost via smtp...                   */
           /* And count bytes                                    */
           /* -------------------------------------------------- */
           m = in.0
           if inx.0 > 0 then do
              if enrich = "html" then do
                 first_html = 0
                 if pos("MIME",translate(inx.1)) > 0 then first_html = 1
                 if pos("HTML",translate(inx.1)) > 0 then first_html = 1
                 if first_html = 0 then do
                    if sensitivity = null then do
                       m = m + 1
                       in.m = "<html><head> </head><body><pre>"
                       html_msg = 1
                       end
                    end
                 end
              do i = 1 to inx.0
                 m = m + 1
                 if left(inx.i,1) = "." ,
                    then in.m = "."inx.i
                    else in.m = inx.i
                 if pos(nullc,in.m) > 0 then
                    in.m = translate(in.m,' ',nullc)
                 bytes = bytes + length(in.m)
                 save_lrecl = max(save_lrecl,length(in.m))
                 end
              end
           in.0 = m
           msg_rec = in.0
           save_bytes = bytes

           /* --------------------------------------------------- */
           /* Test for Message records and if zero test for file, */
           /* filedd, or fileo.                                   */
           /* --------------------------------------------------- */
           if msg_rec = 0 then do
              if empty_opt = 1 then do
                 if length(file)+length(filedd)+length(fileo) = 0 ,
                    then do
                     say msgid "No Message text specified and no" ,
                               "FILE, FILEDD, or FILEO specified."
                     say msgid "Command terminating - try again."
                     signal exit_8
                    end
                 end
              end

           if msgdd = null then "FREE F("indd")"
           if msgds = "*" then ,
              Address ISPExec "LMFree dataid("xmited")"
           if e_rc > 0 then do
              _rcode_ = 8
              say msgid "Error in reading message file."
              _junk_ = sub_set_zispfrc(_rcode_)
              end
           end

        /* ------------------------------ */
        /* If Followup then Save msg text */
        /* ------------------------------ */
         fupmsg.0 = 0
         if word(nomsg" off",1) = "off" then do
            if followup <> null then do
               ix = 0
               do x = 1 to in.0
                  if length(in.x) < 73 then do
                     ix = ix + 1
                     fupmsg.ix = " "in.x""basl"n"
                     end
                  else do
                       ix = ix + 1
                       parse value in.x with flt 73 flr
                       fupmsg.ix = " "flt
                       ix = ix + 1
                       fupmsg.ix = " "flr""basl"n"
                       end
                  end
               fupmsg.0 = ix
               end
            end

        /* -------------------------------- */
        /* Clear out msgds listdsi settings */
        /* -------------------------------- */
         sysdsorg = null

        /* ------------------- */
        /* reset indd          */
        /* ------------------- */
        wtime  = right(time('s') + 10,2)
        indd   = "XM"wtime""right(time('l'),4)

        /* --------------------------- */
        /* Process any RESPOND options */
        /* --------------------------- */
         if responds <> null then do
            m = in.0 + 1
            in.m = "<p>Please respond using the link(s) below:</p>"
            do rw = 1 to words(responds)
               resp = word(responds,rw)
               resp_rec = "<p>"
               if replyto = "" ,
               then resp_rec = resp_rec'<A HREF="mailto:'fromx
               else resp_rec = resp_rec'<A HREF="mailto:'replyto
               if charuse /= 1 ,
               then do ;
                       hexB5 = x2c("B5") /* at-sign */
                       resp_rec = translate(resp_rec,hexb5,AtSign)
                    end;
               resp_rec = resp_rec"?Subject=re:"subject":"resp
               resp_rec = resp_rec"&Body="resp
               resp_rec = resp_rec'">'resp"</A></p>"
               m = m + 1
               in.m = resp_rec
               end
            in.0 = m
            end

        /* --------------------- */
        /* If html turn of <pre> */
        /* --------------------- */
         if enrich = "html" ,
            then do
                 m    = in.0 + 1
                 in.m = "</pre>"
                 in.0 = m
                 end

        if $fax /= null ,
        then if nomsgt = 1 ,
             then in.0 = 0

        /* -------------------------- */
        /* Process SIGnature          */
        /* -------------------------- */
         if length(sigdsn) + length(sigddn) > 0 then do
            if sigdsn <> null then do
               if left(sigdsn,1) <> "'" then ,
                  sigdsn = "'"bhlq"."sigdsn"'"
               "ALLOC F("indd") DS("sigdsn") SHR"
               end
            else do
               save_dd = indd
               indd = sigddn
               end
            "EXECIO * DISKR" indd "(FINIS STEM sig."
            e_rc = rc
            if sigddn = null then ,
               "Free  f("indd")"
            if sigddn <> null then ,
               indd = save_dd
            if e_rc > 0 then do
               _rcode_ = 8
               say msgid "Error reading Signature file."
               _junk_ = sub_set_zispfrc(_rcode_)
               end
            if enrich = "html" then do
               m = in.0 + 1
               in.m = "<pre>"
               in.0 = m
               end
            m = in.0 + 1
            in.m = "  "
            in.0 = m
            do i = 1 to sig.0
               m = in.0 + 1
               in.m = strip(sig.i,"t")
               in.0 = m
               end
            end

        /* ----------------------------------------------------- *
         * Setup Murphy footnote to be written out in SMTP data. *
         * ----------------------------------------------------- */
        mu. = null
        mu.0 = 0
        mn = 0
        if murphy = "on" then do
           murph = xmitipmu(,'x')
           n     = in.0 + 1
           mn = n + 1
           in.n  = " "
           n     = n + 1
           if enrich = "html" then do
              in.n = "<blockquote>"
              n     = n + 1
              end
           in.n  = "Murphy says:"
           n     = n + 1
           in.n  = "  "
           in.0  = n
           do until murph = null
              n = n + 1
              parse value murph with in.n '0A'x murph
              in.n = translate(in.n,excl,"5A"X) ;
              end
           if enrich = "html" then do
              n     = n + 1
              in.n  = "</blockquote>"
              end
           in.0  = n
           mnx = 1
           do mx = mn to n
              if in.mx = null then iterate
              if left(in.mx,1) = "<" then iterate
              if linesep = null ,
                 then mu.mnx = in.mx
                 else parse value in.mx with mu.mnx "<br>"
              mnx = mnx + 1
              end
              mu.0 = mnx
           end

        /* --------------------------------------------------------- *
         * Process Disclaimer if one is defined in XMITIPCU.         *
         *                                                           *
         * This data set is an installation standard. If it doesn't  *
         * exist then it won't be added and no warning will be       *
         * issued.                                                   *
         * --------------------------------------------------------- */
         if page = null then ,
         if length(disclaim) > 0 then ,
            if "OK" <> sysdsn(disclaim) then disclaim = null
            else do
               "ALLOC F("indd") DS("disclaim") SHR"
               "EXECIO * DISKR" indd "(FINIS STEM disclaim."
               e_rc = rc
               "Free  f("indd")"
               if e_rc = 0 then do

               m = in.0 + 1
               in.m =
               in.0 = m

               if enrich = "html" then do
                  m = in.0 + 1
                  pre = '</pre>'
                  if $fax /= null ,
                     then if nomsgt = 1 ,
                         then pre = ''
                  in.m = '<body><font color="Navy" size="2"><b>'pre
                  in.0 = m
                  end
               do i = 1 to disclaim.0
                  m = in.0 + 1
                  in.m = strip(disclaim.i)
                  in.0 = m
                  end
               if enrich = "html" then do
                  m = in.0 + 1
                  in.m = "</font></b><pre>"
                  in.0 = m
                  end
               end
               end

        /* --------------------------------------------------------- *
         * Process Confidential Statement if Sensitivity coded       *
         * if Conf_msg = BOTTOM
         * --------------------------------------------------------- */
         if sensitivity <> null then do;
            if conf_msg = "BOTTOM" then do
               m = in.0 + 1
               if enrich = "html" then do
                  in.m = "<html><body><pre><font color=red><b>"
                  m = m + 1
                  end
               in.m = " " linesep
               m = m + 1
               call do_conf_msg
               if enrich = "html" then do
                  m = m + 1
                  in.m = "</b></font></pre>"
                  end
               in.0 = m
               end
            end;

        /* -------------------------------------------------------- *
         * Process the AntiSpoof but first translate any x'01' back *
         * to / in case any were used.                              *
         * -------------------------------------------------------- */
         if page = null then ,
         if antispoof <> null then do
               antispoof    = strip(translate(antispoof,'/',x2c("01")))
               a. = null
               a.0 = 9
               as_sep = x2c("02")

               parse value antispoof with a.1 (as_sep) a.2 (as_sep) ,
                                          a.3 (as_sep) a.4 (as_sep) ,
                                          a.5 (as_sep) a.6 (as_sep) ,
                                          a.7 (as_sep) a.8 (as_sep) ,
                                          a.9 (as_sep)

               orig_msg = "E-Mail originated from"
               _phrase_ = "<PHRASE>"orig_msg"</PHRASE>"
               _phrase_ = sub_xmitiptr(_phrase_)":"
               parse var _phrase_ 1    "<PHRASE>" ,
                                       orig_msg     ,
                                      "</PHRASE>" .
               orig_msg = strip(orig_msg)":"
               l1  = pos(word(a.1,2),a.1)
               if l1 > 1 then l1 = l1 - 1

               date_txt = "Date:"
               date_day  = DATE("W")
               date_day  = sub_xmitiptr(date_day)
               select
                 when ( dateformat = "I" ) then do
                  adate = INSERT("-",INSERT("-",DATE('s'),6),4)
                  date_txt ="Date (ISO):"
                 end
                 when ( dateformat = "E" ) then do
                  adate = word(date('n'),1) date('m') word(date('n'),3)
                  adate = sub_xmitiptr(adate)
                 end
                 otherwise do
                  adate = ,
                       date('m') word(date('n'),1)"," word(date('n'),3)
                 end
               end /* end select */

               x_string   = sub_xmitiptr(date_txt)
               x_string   = left(x_string" ",l1)""adate

               y_string   = TIME("N")
               a.0 = a.0 + 1
               a_val = a.0
               a.a_val    = x_string"  "y_string"  ("date_day")"
               a.a_val  = x_string" "y_string" ("zone")  ("date_day")"

               ll = length(orig_msg)
               lu = ll
               do   a_idx = 1 to a.0
                  a.a_idx = strip(a.a_idx)
                  l.a_idx = 0
                  if a.a_idx /= null then do
                     l.a_idx = length(a.a_idx)
                     lu = max(l.a_idx,lu)
                  end
               end
               m = in.0 +1
               if msg_rec = 0 then do
                  in.m = " " linesep
                  m = m + 1
                  in.m = "No message text - file transfer only" ,
                         linesep
                  m = m + 1
                  end
               if enrich = "html" then do
                  in.m = '<p><pre><FONT size="2">'
                  m = m + 1
                  end
               in.m = "  "
               m = m + 1
               in.m = "*" center(" "ver" ",lu,"-") "*"
               m = m + 1
               in.m = "*" left(orig_msg, ,
                             lu) "*"
               m = m + 1
               do a_idx = 1 to a.0
                  if l.a_idx > 0 then do
                     in.m = "*" left(a.a_idx,lu) "*"
                  m = m + 1
                  end
                  end
               in.m = "*" left("-",lu,"-") "*"
               m = m + 1
               in.m = left(" ",10)
               m = m + 1
               in.m = left(" ",10)
               in.0 = m
               end

        /* ----------------------------------------------------- *
         * begin-of-information                                  *
         * ----------------------------------------------------- */
        if confirm = null then do
           Say msgid "XMITIP Application level:" ver
           say msgid " "
           if fupdate <> null then ,
              say msgid "Follow Up generated for:" fupdate
           if length(config_files) > 0 then do
              say msgid "Using XMITIP Configuration File(s):"
              blanks = left(" ",5)
              do ic = 1 to words(config_files)
                 parse value word(config_files,ic) with type":"value
                 if type = "DSN" then ,
                    say msgid blanks "DSN:" value
                 else
                    say msgid blanks "DD: " value
                 end
              say msgid "with the following options:"
              do cf = 1 to cfoptions.0
                 say msgid ">" left(strip(cfoptions.cf),72)
                 end
              end
           end

        /* ---------------------------------- *
         * Display Site Disclaimer if present *
         * ---------------------------------- */
         if confirm = null then ,
         if site_disclaim <> null then do
            say msgid " "
            if pos("#",site_disclaim) = 0 then ,
               say msgid site_disclaim
            else do forever
                 parse value site_disclaim with sd_msg "#" ,
                             site_disclaim
                 say msgid strip(sd_msg)
                 if strip(site_disclaim) = null then leave
                 end
            say msgid " "
            end

        /* ----------------------------------------------------- *
         * Fix the default from address to support nje if the    *
         * note originates other than where smtp runs.           *
         * Setup the Sender address                              *
         * If FROM and no REPLYTO set REPLYTO = FROM             *
         * ----------------------------------------------------- */
        if replyto = null ,
           then if from <> null ,
                then if from2rep = 1 ,
                     then replyto = from
        if from = null then do
           from_def = 1
           from = from_default
           end

        if check_send_from /= "" ,
        then do ;
                /* parameter format hardcoded */
                parse var check_send_from 1 check_send_from_cmd ,
                                            check_send_from_parms
                parse var check_send_from_parms ,
                          1 . "<ADDRPRE>"_addrpre_"</ADDRPRE>" . ,
                          1 . "<ADDRSUF>"_addrsuf_"</ADDRSUF>" . ,
                          1 . "<ADDRREW>"_addrrew_"</ADDRREW>" . ,
                          1 . "<ADDRDOM>"_addrdom_"</ADDRDOM>" . ,
                          1 . "<ADDRLAB>"_addrlab_"</ADDRLAB>" . ,
                          1 . "<ADDRBYP>"_addrbyp_"</ADDRBYP>" . ,
                                                               .
                checkparm = "FUNCTION=CHECKFROM "
                checkparm = checkparm" AtSign="AtSign" "
                checkparm = checkparm" smtp_domain="smtp_domain" "
                checkparm = checkparm" from="from" "
                if _addrpre_ /= "" then ,
                checkparm = checkparm" addrpre="_addrpre_" "
                if _addrsuf_ /= "" then ,
                checkparm = checkparm" addrsuf="_addrsuf_" "
                if _addrrew_ /= "" then ,
                checkparm = checkparm" addrrew="_addrrew_" "
                if _addrdom_ /= "" then ,
                checkparm = checkparm" addrdom="_addrdom_" "
                if _addrlab_ /= "" then ,
                checkparm = checkparm" addrlab="_addrlab_" "
                if _addrbyp_ /= "" then ,
                checkparm = checkparm" addrbyp="_addrbyp_" "
                checkparm = msgid" "checkparm""
                checkparm = space(checkparm,1)
                checkparm_length = length(checkparm) /* debugging */
                check_cmd = ""check_send_from_cmd"('"checkparm"')";
                check_cmd = "from = "check_cmd ;
                interpret   ""check_cmd
                _cmd_rc_  = rc
                parse var from 1 from _from_more_
                _from_more_ = strip(_from_more_)
                if from_n.1 = "" then do ;
                  if _from_more_ = "" then nop ;
                  else parse var _from_more_ ,
                         1 . "<LABEL>" from_n.1 "</LABEL>" .
                end;
             end;

        if replyto = null ,
           then if from <> null ,
                then if from2rep = 1 ,
                     then replyto = from
        if from = null then do
           from_def = 1
           from = from_default
           end

        /* -------------------- *
         * Fixup Sender Address *
         * -------------------- */
         call test_address from_default "From_Default"
              if trc = 1 then from_default = temp_address
         call test_address from "From"
              if trc = 1 then from = temp_address
         if from_n.1 <> null ,
            then Sender = from_n.1" <"from_default">"
            else Sender = "<"from_default">"

        /* -------------------------- *
         * Fixup ReplyTo              *
         * -------------------------- */
        replyto_addrs = null
        if replyto <> null then do
           do ir = 1 to words(replyto)
           call test_address word(replyto,ir) "ReplyTo"
           if trc = 1 then replyto_addrs = replyto_addrs temp_address
           end
           replyto = replyto_addrs
           end

        /* -------------------------- *
         * Fixup Receipt              *
         * -------------------------- */
        if receipt <> null then do
           call test_address receipt "Receipt"
           if trc = 1 then receipt = temp_address
           end

        /* ----------------------------------------------------- *
         * Test for invalid addresses via flag ldap = 2          *
         * ----------------------------------------------------- */
         if ldap = 2 then do
            say msgid "Invalid Addresses encountered. Terminating",
                      "sending - correct and retry."
            _junk_ = sub_set_zispfrc("8")
            end

        /* -------------------------- *
         * Fix SUBJECT.               *
         * -------------------------- */
        if length(subject) = 0 then ,
        if length(page) = 0 then ,
           Select
           When file <> null then ,
                if words(file) = 1 then subject = "File:" file
                   else subject = "Multiple Files"
           When nomsg = null then subject = msgsub
           When nomsg = "off" then subject = "Message from" from
           otherwise subject = "Note from" from
           end

        /* ----------------------------------------------------- *
         * Test for FROM or REPLYTO                              *
         * ----------------------------------------------------- */
        if confirm = null then do
           if from_def = 1 then do
              if replyto""from = null then do
                 say msgid substr("-",1,64,"-")
                 say msgid "Warning: " ,
                           "No FROM or REPLYTO keyword specified.",
                            "Using Default."
                 say msgid "Replys to this e-mail will be delivered" ,
                           "to TSO address:"
                 say msgid "  " from
                 say msgid "These must be read using the",
                           "TSO RECEIVE command."
                 say msgid substr("-",1,64,"-")
                 say msgid " "
                 end
              end
           end

        /* --------------------------------------------------------- *
         * Build SMTP E-Mail Header                                  *
         * --------------------------------------------------------- */
        if confirm = null then ,
           say msgid "Message Addressing Information:"

        /* --------------------------------------------------------- *
         * Test for Interlink TCP/IP and build correct format        *
         * From keyword.  Use the From_Default e-mail so that the    *
         * SMTP log will accurately reflect who is sending the       *
         * e-mail (note that this information is not reflected in    *
         * the delivered e-mail - only in the SMTP Logfile).         *
         * --------------------------------------------------------- */
        /* --------------------------------------------------------- *
         * changes:                                                  *
         * use sub_head to build the header lines                    *
         *     <C>val</C> value of variable 'confirm' or "NO"        *
         *     <D>val</D> header data                                *
         *     <M>val</M> message text instead of header data        *
         *     <X>val</X> exclude from align process (like SUBJECT)  *
         * --------------------------------------------------------- */
        header.0 = 0
        _av_     = 12
        if interlink = 0 then do
           if starttls = 1 then helo = "EHLO"
                           else helo = "HELO" /* default */
               _d_ = helo _center_
               _x_ = sub_head("<C>NO</C><D>"_d_"</D>");_d_=null;
               if helo = "EHLO" then do
                  _d_ = "STARTTLS"
                  _x_ = sub_head("<C>NO</C><D>"_d_"</D>");_d_=null;
                  end
               _d_ = "MAIL FROM:<"from">"
               _x_ = sub_head("<C>NO</C><D>"_d_"</D>");_d_=null;
           end
        else do
               _d_ = "X-From:"from
               _x_ = sub_head("<C>NO</C><D>"_d_"</D>");_d_=null;
             end

        xhead = left("From: ",_av_)
        if confirm = null then ,
           Say msgid xhead from

        xhead = left("To:   ",_av_)
        address = strip(address)

        /* --------------------------------------------------------- */
        /* Set the RCPT TO syntax                                    */
        /* --------------------------------------------------------- */
        if interlink = 0 then ,
           rcpt = "RCPT TO:"
        else
           rcpt = "X-To:"

        /* --------------------------------------------------------- */
        /* Now build the RCPT TO statements                          */
        /* --------------------------------------------------------- */
        if datatype(fromreq) = "CHAR" then do
               _d_ = ""rcpt"<"fromreq">"
               _x_ = sub_head("<C>NO</C><D>"_d_"</D>");_d_=null;
           end

        do i = 1 to words(address)
           if left(strip(address),i) = "*" then iterate
           w_addr = word(address,i)
           if pos(x2c("01"),w_addr) > 0 then ,
              w_addr = translate(w_addr,' ',x2c("01"))
           _d_ = ""rcpt"<"mail_relay""w_addr">"
           _m_ = ""xhead w_addr
           _x_ = sub_head("<C>NO</C><M>"_m_"</M><D>"_d_"</D>");
           _d_ = null ; _m_ = null
           xhead = left("",_av_)
           end

        xhead = "Cc:"
        if length(cc) > 0 then ,
        do i = 1 to words(cc)
           w_addr = word(cc,i)
           if pos(x2c("01"),w_addr) > 0 then ,
              w_addr = translate(w_addr,' ',x2c("01"))
           _d_ = ""rcpt"<"mail_relay""w_addr">"
           _m_ = ""xhead" "w_addr
           _x_ = sub_head("<C>NO</C><M>"_m_"</M><D>"_d_"</D>");
           _d_ = null ; _m_ = null
           xhead = left("",_av_)
           end

    /*  h = header.0    */
        xhead = "Bcc:"
        if length(bcc) > 0 then ,
        do i = 1 to words(bcc)
           w_addr = word(bcc,i)
           if pos(x2c("01"),w_addr) > 0 then ,
              w_addr = translate(w_addr,' ',x2c("01"))
           _d_ = ""rcpt"<"mail_relay""w_addr">"
           _m_ = ""xhead" "w_addr
           _x_ = sub_head("<C>NO</C><M>"_m_"</M><D>"_d_"</D>");
           _d_ = null ; _m_ = null
           end

        if errorsto <> null then do
           xhead = left("Errors-To:",_av_)
           if confirm = null then ,
                 Say msgid xhead errorsto
           end

        /* --------------------------------------------------------- */
        /* Now insert the 'data' statement                           */
        /* --------------------------------------------------------- */
        _m_ = null
        _d_ = "DATA"
        _x_ = sub_head("<C>NO</C><M></M><D>"_d_"</D>");
        _d_ = null ; _m_ = null

        /* --------------------------------------------------------- */
        /* Now Build the SMTP E-Mail Envelope                        */
        /* --------------------------------------------------------- */
         if confirm = null then do
            say msgid " "
            say msgid "The Mail Envelope:"
            end

        parse value date("s") date("m") with yy 5 . 7 dd 9 10 mm 13 .

        _d_ = ""left("Sender:",_av_)" "sender
        _d_ = "Sender: "sender
        _x_ = sub_head("<C>"confirm"</C><D>"_d_"</D>");_d_=null;

        if priority <> null then do
           _d_ = "Priority: "priority
           _x_ = sub_head("<C>"confirm"</C><D>"_d_"</D>");_d_=null;
           end

        if importance <> null then do
           _d_ = "Importance: "importance
           _x_ = sub_head("<C>"confirm"</C><D>"_d_"</D>");_d_=null;
           end

        if sensitivity <> null then do
           _d_ = "Sensitivity: "sensitivity
           _x_ = sub_head("<C>"confirm"</C><D>"_d_"</D>");_d_=null;
           end

        _day_ = sub_xmitiptr(left(date('w'),3))
        _d_ = "Date: "_day_ dd mm yy time() zone
        _x_ = sub_head("<C>"confirm"</C><D>"_d_"</D>");_d_=null;

        if from_n.1 <> null then do
           _d_ = "From:" '"'from_n.1'" <'from'>'
        end
        else do
           _d_ = "From: "from
        end
        _x_ = sub_head("<C>"confirm"</C><D>"_d_"</D>");_d_=null;

        if errorsto <> null then do
           _d_ = ""left("Errors-To:",_av_)" "errorsto
           _d_ = "Errors-To: "errorsto
           _x_ = sub_head("<C>"confirm"</C><D>"_d_"</D>");_d_=null;
           end

        if replyto <> null then do
           if replyto_n.1 <> null then do
              _d_ = "Reply-To: "'"'replyto_n.1'" <'replyto'>'
              _x_ = sub_head("<C>"confirm"</C><D>"_d_"</D>");_d_=null;
           end
           else do ir = 1 to words(replyto)
              _d_ = "Reply-To: "word(replyto,ir)
              _x_ = sub_head("<C>"confirm"</C><D>"_d_"</D>");_d_=null;
           end
           end

        if receipt <> null then do
           if receipt_n.1 <> null then do
              _d_ = receipt_key": " '"'receipt_n.1 ,
                         '" <'receipt'>'
           end
           else do
              _d_ = receipt_key": " receipt
           end
           _m_ = null ;
           _x_ = sub_head("<C>"confirm"</C><M>"_m_"</M><D>"_d_"</D>");
           _d_ = null ; _m_ = null ;
           end

        to_head = "To:"
        comma   = ","
        do i = 1 to words(Address)
               if word(address,i) = "*" then iterate
               if i      = words(address) then comma = " "
               addr      = word(address,i)
               if pos(x2c("01"),addr) > 0 then ,
                  addr = translate(addr,' ',x2c("01"))
               if address_n.i <> null ,
                  then select
                       when pos('"'atsign,addr) > 0 then ,
                          addr = strip(address_n.i) '<'addr'>'
                       when left(address_n.i,1) <> '"' then ,
                          addr = '"'strip(address_n.i)'" <'addr'>'
                       otherwise
                          addr = strip(address_n.i) '<'addr'>'
                       end
               if left(addr,1) = "*" then do
                  addr = substr(addr,2)
                  if right(addr,1) = "*" then ,
                     addr = left(addr,length(addr)-1)
                  addr = '"'addr'"'
                  end
               _d_ = ""to_head" "addr""comma
               _m_ = null ;
               _d_ = strip(_d_,"T")
               _x_ = sub_head("<C>"confirm"</C><M></M><D>"_d_"</D>");
               to_head   = left(" ",3)
               end

        if length(strip(address)) = 0 then do
           _d_ = "To:      " save_address
           _x_ = sub_head("<C>"confirm"</C><M></M><D>"_d_"</D>");
           end

        cc_head = "Cc:"
        comma   = ","
        do i = 1 to words(cc)
               addr      = word(cc,i)
               if i      = words(cc) then comma = " "
               if pos(x2c("01"),addr) > 0 then ,
                  addr = translate(addr,' ',x2c("01"))
               if cc_n.i <> null then do
                  if left(cc_n.i,1) = '"' ,
                     then addr = strip(cc_n.i)  '<'addr'>'
                     else addr = '"'strip(cc_n.i)'" <'addr'>'
                  end
               _d_ = cc_head" "addr""comma
               _d_ = strip(_d_,"T")
               _x_ = sub_head("<C>"confirm"</C><M></M><D>"_d_"</D>");
               cc_head = "         "
               end

     /* sub_head - add 1 to header.0 - set new stem */
        _d_         = "X-Mailer: XMITIP" ver "Rexx Exec for" ,
                      "z/OS" ,
                      "created by" sysvar('sysuid') ,
                      "job:"strip(mvsvar('symdef','jobname'))"/"jobid
        _x_ = sub_head("<C>NO</C><M></M><D>"_d_"</D>");
        if page = null then do
             _subdata_  = "Subject: "subject
             _x_ = sub_gen_subject(_subdata_);
           end
        out.  = null
        out.0 = 0

        /* --------------------------------------------------------- */
        /* Now put out Process Report                                */
        /* --------------------------------------------------------- */
        if confirm = null then do
           say msgid " "
           say msgid "Process Section"
           say msgid " "
           end

        /* --------------------------------------------- */
        /* If any File attachment specified, or Followup */
        /* setup the mime headers.                       */
        /* --------------------------------------------- */
        if charuse = 1 ,
        then charuse_value = 0
        else charuse_value = 1
        tfl = length(file) + length(filedd) + ,
              length(fileo) + length(followup) + charuse_value
        if tfl > 0 | enrich = "html" then do
           tfl = tfl ; enrich = enrich
           _cs_ = char
           _mh_ = MimeHead
           if enrich_msg = 0 then do
           if encoding /= "" ,
           then do ;
            Select
             when ( "BYP"="BXP" ) then nop       ; /* bypass ?    */
             when ( charuse = 0 ) then ,
                do ;
                   _cs_ = encoding
                   _mh_ = "quoted-printable"
                end;
             when ( charuse = 1 ) then nop       ;
             otherwise                 nop       ;
            end
                end;
           /* $FAX ?|?| */
           mh.0 = 0
           _j_ = sub_mh("Mime-Version: 1.0");
           _j_ = sub_mh('Content-type: multipart/mixed; boundary="'bnd'"');
           _j_ = sub_mh(" ");
           _j_ = sub_mh("This is a multi-part message in MIME format.");
           skip_email_text = "NO"
           if $fax /= null ,
              then if nomsgt = 1 ,
                   then skip_email_text = "YES"

           if skip_email_text = "YES" ,
           then nop;
           else do;
                  _j_ = sub_mh("--"bnd);
                  _j_ = sub_mh("Content-Type: text/"enrich"; charset="_cs_);
                  _j_ = sub_mh("Content-Transfer-Encoding:" _mh_);
                  _j_ = sub_mh(" ");
                  if enrich = "html" ,
                  then do;
                         if html_msg = 0 ,
                         then do;
                                if pos('HTML',translate(in.1)) = 0 ,
                                then do;
                                      _j_ = sub_mh("<html><body><pre>");
                                     end;
                              end;
                       end;
                end;
           do i = 1 to mh.0
              out.0 = out.0 + 1
              n = out.0
              out.n = mh.i
              end
           end
        end

        /* -------------------------- */
        /* Write out message.         */
        /* -------------------------- */
        if msgq = 1 then nomsg = null
        if in.0 > 0 then do
           nomsg = null
           out.0 = out.0 + 1
           n = out.0
           out.n = "  "
        if translate(substr(in.1,1,4)) = "MIME" then out.0 = out.0 - 1
        do i = 1 to in.0
           out.0 = out.0 + 1
           n = out.0
           if msg72 = 1 then ,
              out.n = strip(left(in.i,72),'t')
           else out.n = strip(in.i,'t')
           if length(out.n) = 0 then out.n = " "
           select ;
             when ( charuse = 1 ) then nop ;
             otherwise ,
              do ;
                if encoding_default /= "" ,
                then do ;
                        _enctype_ = "TXT" ;
                        out.n = sub_encode_data(out.n) ;
                     end;
              end;
           end;
           save_lrecl = max(save_lrecl,length(out.n))
           if save_lrecl > 1024 then signal big_lrecl
           if save_lrecl > 998  then call rfc_maxlrecl
           end
        if confirm = null then ,
              if msg_rec <> null then do
                 Say msgid "Message records sent:" msg_rec
                 say msgid " "
                 if mn > 0 then do
                    do mx = 1 to mu.0
                       say msgid mu.mx
                       end
                    end
                 end
           end
        else do
             n     = out.0 + 1
             out.n = "No message text - file transfer only"
             out.0 = n
             end
        if skip_email_text = "YES" ,
        then out.0 = mh.0

        /* ----------------------------------------------- */
        /* Insert two blank records and then               */
        /* Save the record number of the last message line */
        /* ----------------------------------------------- */
         if faxcheck <> null then do
            if pos(faxcheck,translate(address)) > 0 then ,
               msg_summary = 0
            end
         if msg_summary = 1 then do
            n = out.0
            if length(strip(out.n)) > 0 then ,
               n = n + 1
            out.n = "Message Summary:"
            n = n + 1
            out.n = "   "
            msg1 = n
            n = n + 1
            out.n = "   "
            msg2 = n
            n = n + 1
            out.n = "   "
            n = n + 1
            out.n = "   "
            out.0 = n
            end
         last_msg = out.0

        /* ------------------- */
        /* Setup file counters */
        /* ------------------- */
         tot_files = 0

        /* -------------------------------- */
        /* Write out the Followup iCalender */
        /* -------------------------------- */
         if followup <> null then do
            tot_files = tot_files + 1
            fmt1      = "ICAL"
            t         = fmt1
            tl        = fmt1
            save_fn   = filename
            file_name = "FollowUp.ics"
            desc_d    = null
            mh_type = "dsn"
            _sfi_ = set_file_info();
            filename = save_fn

            icc.0   = 0

            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "BEGIN:VCALENDAR"
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "METHOD:Publish"
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "VERSION:2.0"
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "PRODID:-//XMITIP" ver"//NONSGML zOS E-Mail//EN"
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "BEGIN:VTODO"
            stamp_time = time('n')
            parse value stamp_time with hh":"mm":"ss
            stamp_time = right(hh+100,2)right(mm+100,2)"00"
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "DTSTAMP:"date('s')"T"stamp_time
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "SEQUENCE:0"
            if replyto = "" ,
            then _from_ = from
            else _from_ = replyto
            do icx = 1 to length(atsign)
               icfpos = pos(substr(atsign,icx,1),_from_)
               if icfpos > 0 then leave
            end
            icfrom = left(from,icfpos-1)
            icfrom = translate(icfrom," ",".")
            icfn = null
            do icx = 1 to words(icfrom)
               icw = word(icfrom,icx)
               if length(icw) > 1 then do
                  parse value icw with iccl 2 icr
                  icfn = strip(icfn  translate(iccl)""icr)
                  end
               else icfn = strip(icfn  translate(icw)".")
               end
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "ORGANIZER;ROLE=CHAIR:"icfn
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "DTSTART:"date("s")
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "DUE:"fupdate
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "SUMMARY:"subject
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "STATUS:NEEDS-ACTION"
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "DESCRIPTION: E-Mail follow up"basl"n"
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = " Follow Up on e-mail from "icfn" ("_from_") "
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            if dateformat <> "E" then ,
               icc._i_ = "  on" date() time()""basl"n"basl"n"
            else ,
               icc._i_ = "  on" date("e") time()""basl"n"basl"n"
            if fupmsg.0 > 0 then ,
            do ficx = 1 to fupmsg.0
               icc.0   = icc.0 + 1 ; _i_ = icc.0
               icc._i_ = fupmsg.ficx
               end
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "END:VTODO"
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = "END:VCALENDAR"
            icc.0   = icc.0 + 1 ; _i_ = icc.0
            icc._i_ = " "

            do _i_  = 1 to icc.0
               icc     = out.0 + 1
               out.0   = icc
               _data_  = icc._i_
               if charuse = 0 ,
               then do ;
                     /* translate at-sign */
                     hexB5 = x2c("B5")  /* at-sign */
                     _enctype_ = "TXT" ;
                     do idx = 1 to length(atsign)
                      _data_    = ,
                      translate(_data_,x2c("B5"),substr(atsign,idx,1))
                     end;
                     _data_    = sub_encode_data(_data_) ;
                    end;
               out.icc = _data_
            end

            followup = null
            end

        /* -------------------------- */
        /* Write out FILE attachment  */
        /* -------------------------- */
        if length(file) > 0 then do

          do f = 1 to words(file)
              fd = f
              if format_all = 1 then do
                 t  = translate(format)
                 tl = format
                 end
                 else do
                      t  = translate(word(format,f))
                      tl = word(format,f)
                      end
              file_dsn = word(file,f)
              pds_dsn = null
              if pos("(",file_dsn) > 0 then do
                 parse value file_dsn with pds_dsn "(" member ")" .
                 if left(pds_dsn,1) = "'" then pds_dsn = pds_dsn"'"
                 end
              else member = null
              if left(file_dsn,1) = "*" then do
                 call create_file
                 file_dsn = create_dsn
                 end
              if pds_dsn <> null then call listdsi(pds_dsn)
              else call listdsi(file_dsn)
              if sysrecfm = "U" then do
                 say msgid file_dsn "error - can not process RECFM=U",
                          "datasets."
                 _junk_ = sub_set_zispfrc("8")
                 end

              /* If a PDS has been specified without a member or with */
              /* a member mask then get a list of those members and   */
              /* attach each one. The output format will be the same  */
              /* for each member of the PDS.                          */

              If sysdsorg = "PO",
               & (member = null,
                  | Pos('*',member) > 0),
              Then Do
                Say '.. Process 'file_dsn' members......'
                Call Proc_GET_PDS_MEMBERS
                pdsloop = 'Y'
                file_loop = file_member.0
                file_dsn_save = file_dsn
              End
              Else Do
                pdsloop = 'N'
                file_loop = 1
              End

              Do _mfl = 1 To file_loop

                If pdsloop='Y',
                Then Do
                  If Substr(file_dsn_save,1,1)="'",
                  Then file_dsn = Strip(file_dsn_save,'T',"'"),
                                        || "("file_member._mfl")'"
                  Else file_dsn = file_dsn_save"("file_member._mfl")"

                  Say '..... PDS processing 'file_dsn
                End

               /* --------------------------------------- */
               /* Test the validity of the input data set */
               /* --------------------------------------- */
                if sysdsn(file_dsn) <> "OK" then do
                   say msgid "Error: the input file encountered",
                                     "an error"
                   say msgid file_dsn sysdsn(file_dsn)
                   say msgid "Exiting at this point...."
                   _junk_ = sub_set_zispfrc("8")
                   end

                "ALLOC F("indd") DS("file_dsn") SHR Reuse"
                drop in.
                "EXECIO * DISKR" indd "(FINIS STEM in."
                e_rc = rc
                "Free f("indd")"
                if in.0 = 0 ,
                then do
                       Select
                        When empty_opt = 0 then do
                           say msgid "Warning:" file_dsn "is empty. "
                           say msgid " "
                           empty_ds = 1
                           in.0 = 3
                           in.1 = " Warning: The original file" file_dsn
                           in.2 = "          was empty. If this is",
                                  "in error contact the sender."
                           in.3 = "   "
                           call do_empty
                           end
                        When empty_opt = 1 then do
                           _rcode_ = 8
                           say msgid "Error:" file_dsn "is empty. "
                           _junk_ = sub_set_zispfrc(_rcode_)
                           end
                        When empty_opt = 2 then do
                           say msgid "Warning:" file_dsn "is empty. "
                           say msgid " "
                           in.0 = 3
                           in.1 = " Warning: The original file" file_dsn
                           in.2 = "          was empty. If this is",
                                  "in error contact the sender."
                           in.3 = "   "
                           call do_empty
                           end
                        Otherwise nop
                       end
                     end
                else do
                       mh_type = "dsn"
                       _sfi_ = set_file_info();
                       save_bytes = bytes
                       call count_bytes
                       call test_limit
                       if e_rc > 0 then do
                          _rcode_ = 8
                          Say msgid " "
                          say msgid "Error reading file:" file_dsn
                          _junk_ = sub_set_zispfrc(_rcode_)
                          end
                       if confirm = null then do
                          Say msgid " "
                          Say msgid "("right(f,3,0)")",
                                    left("File:               ",20),
                                    ""file_dsn
                        if name <> null then do
                           parse var name '"'rname'"'
                           say msgid "("right(f,3,0)")",
                                     left("Attachment filename:",20),
                                     ""rname
                           end
                        end
                        call process_file
                      end
              end
              pdsloop = null
          end
        end

        /* -------------------------- */
        /* Write out FILEDD attachment*/
        /* -------------------------- */
        if length(filedd) > 0 then do

          call Proc_GET_DD_DSN           /* Get list of allocted DDs */

          do f = 1 to words(filedd)
              fd = f + words(file)
              if format_all = 1 ,
                 then do
                      t  = translate(format)
                      tl = format
                      end
                 else do
                      t  = translate(word(format,fd))
                      tl = word(format,fd)
                      end
              file_ddn = word(filedd,f)
              Upper file_ddn

              /* Check out the DD, see if it's a concatination, and  */
              /* check if any of the datasets are PDSs that need     */
              /* processing of every member.                         */

              /* Firstly, make sure the dd name is allocated */
              _thedd = 0
              Do _d = 1 To xmitip_dd.0 Until(file_ddn=xmitip_dd._d)
                If file_ddn=xmitip_dd._d,
                Then _thedd = _d
              End

              If _thedd=0,
              Then Do
                Say msgid "Error: DDname "file_ddn" not allocated"
                _junk_ = sub_set_zispfrc("8")
              End

              Parse Value "" With file_ddn_dsn. sysmembers pdsloop,
                                  file_ddn_dsn_pds. ,
                                  file_ddn_dsn_pdsloop. ,
                                  file_ddn_dsn_members.

              /* Go through the datasets - check for PDSs */
              /* specified without a member name.         */

              pdstempflag = "N"              /* Any temp datasets ? */

              Do _d = 1 To xmitip_dsn._thedd.0

                file_ddn_dsn._d = "'"xmitip_dsn._thedd._d"'"

                If xmitip_dsntype._thedd._d^='PERM',
                Then Do
                  pdstempflag = "Y"
                  sysdsorg    = null
                End
                Else Do
                  /* Concat - is it a PDS or recfm U ? */
                  call listdsi(file_ddn_dsn._d)

                  If sysrecfm = "U" then do
                    say msgid "DD("file_ddn") DSN("file_ddn_dsn._d")",
                        "error - can not process RECFM=U datasets"
                    _junk_ = sub_set_zispfrc("8")
                  End
                End

                If sysdsorg <> 'PO' ,
                Then Do
                  file_ddn_dsn_pds._d = "N"
                  file_ddn_dsn_pdsloop._d = "N"
                End
                Else file_ddn_dsn_pds._d = "Y"

                If file_ddn_dsn_pds._d = "Y",
                Then If Pos('(',file_ddn_dsn._d) > 0,
                     Then file_ddn_dsn_pdsloop._d = "N"
                     Else file_ddn_dsn_pdsloop._d = "Y"

                /* If we're processing the whole PDS, need to know */
                /* how many members. However, we're not allowing a */
                /* combination of whole PDSs and individual files  */
                /* in a concatonation.                             */

                If (pdsloop="Y" & file_ddn_dsn_pdsloop._d = "N"),
                 | (pdsloop="N" & file_ddn_dsn_pdsloop._d = "Y"),
                Then Do
                  If pdstempflag="N",
                  Then Say msgid "Error: DDname("file_ddn")",
                           "Cannot process a mix of whole PDSs and",
                           "single dataset / members in a DD",
                           "concatonation."
                  Else Say msgid "Error: DDname("file_ddn")",
                           "Cannot mix whole PDSs/single/temporary",
                           "datasets or process a whole temporary PDS."
                  _junk_ = sub_set_zispfrc("8")
                End

                If file_ddn_dsn_pdsloop._d = "N",
                Then pdsloop = "N"
                Else Do
                  pdsloop = "Y"
                  Say '... #'_d' Process all members in',
                      file_ddn_dsn._d
                End

              End  /* _d through dd concat */

              /* If there are PDSs with all their members to process */
              /* then go through them and get the member details.    */
              /* Store each full member name is file_ddn_members. .  */

              If pdsloop="N",
              Then Do
                   file_loop = 1
                   file_ddn_members.file_loop = ,
                         Strip(file_ddn)
                   End
              Else Do
                file_loop = 0
                member = '*'
                Do _d = 1 To xmitip_dsn._thedd.0

                  file_dsn = file_ddn_dsn._d
                  Call Proc_GET_PDS_MEMBERS

                  Do _m = 1 To file_member.0
                    file_loop = file_loop + 1
                    file_ddn_members.file_loop =,
                         Strip(file_dsn,'T',"'")"("file_member._m")'"
                  End
                End
              End
              file_ddn_members.0 = file_loop

              Do _mfl = 1 To file_loop
                If pdsloop='N',
                Then Do
                  mh_type = "ddn"
                  drop in.
                  "EXECIO * DISKR" file_ddn "(FINIS STEM in."
                  if rc > 0 then do
                     _rcode_ = 8
                     say msgid "Error reading file:" file_ddn
                     _junk_ = sub_set_zispfrc(_rcode_)
                  end
                End
                Else Do
                  mh_type = "dsn"
                  file_dsn = file_ddn_members._mfl
                  Say '.... Processing DD('file_ddn') 'file_dsn
                  "ALLOC F("indd") DS("file_dsn") SHR Reuse"
                  drop in.
                  "EXECIO * DISKR" indd "(FINIS STEM in."
                  e_rc = rc
                  "FREE F("indd")"
                  if e_rc > 0 then do
                     _rcode_ = 8
                     say msgid "Error reading file: DD("file_ddn")" ,
                               ""file_dsn
                     _junk_ = sub_set_zispfrc(_rcode_)
                  end
                End

                if in.0 = 0 then
                   Select
                   When empty_opt = 0 then do
                      If pdsloop="N",
                      Then say msgid "Warning:" file_ddn "is empty. "
                      Else say msgid "Warning: DD("file_ddn")",
                               file_dsn" is empty."
                      say msgid " "
                      empty_ds = 1
                      in.0 = 3
                      If pdsloop="N" then,
                       in.1 = " Warning: The original file" file_ddn
                      else,
                       in.1 = " Warning: The original file DD("file_ddn,
                           || ") "file_dsn
                      in.2 = "          was empty. If this is in error",
                             "contact the sender."
                      in.3 = "   "
                      call do_empty
                      end
                   When empty_opt = 1 then do
                      _rcode_ = 8
                      say msgid "Error:" file_ddn "is empty. "
                      _junk_ = sub_set_zispfrc(_rcode_)
                      end
                   Otherwise nop
                   end
                if in.0 > 0 then do
                  /**** changed mh_type from dsn to ddn - clearing */
                   mh_type = "ddn"
                   file_dsn = file_ddn_members._mfl
                   _sfi_parms_ = "<STEM>in.</STEM>"
                   _sfi_ = set_file_info(_sfi_parms_); _sfi_parms= "";
                   save_bytes = bytes
                   call count_bytes
                   call test_limit
                   if confirm = null then do
                      say msgid "FileDD:" file_ddn
                      end
                   call listdsi(file_ddn "FILE")
                   call process_file
                   end
              end  /* mfl loop */
          end  /* f loop */
          pdsloop = null
        end  /* if */

        /* -------------------------- */
        /* Write out FILEO attachment */
        /* -------------------------- */
        if length(fileo) > 0 then
        do f = 1 to words(fileo)
              fd = f + words(file) + words(filedd)
              if format_all = 1 ,
                 then do
                      t  = translate(format)
                      tl = format
                      end
                 else do
                      t  = translate(word(format,fd))
                      tl = word(format,fd)
                      end
              /* Check for binary OGET: (FEC 20010425) */
              Select
                When left(t,3) = "GIF"    then Oget_fmt = "BINARY"
                When left(t,3) = "BIN"    then Oget_fmt = "BINARY"
                When left(t,6) = "ZIPBIN" then Oget_fmt = "BINARY"
                Otherwise Oget_fmt = "TEXT"
                end
              file_omvs = word(fileo,f)
              call msg "off"
              odsn = "'"hlq".xmitip.omvs.file"fd"'"
              "OGet" file_omvs odsn Oget_fmt
              _rcode_ = rc
              if _rcode_  > 0 then do
                 say msgid file_omvs "access or read error."
                 _junk_ = sub_set_zispfrc(_rcode_)
                 end
              file_dsn = odsn
              call listdsi(file_dsn)
              if sysrecfm = "U" then do
                 say msgid file_dsn "error - can not process RECFM=U",
                          "datasets."
                 _junk_ = sub_set_zispfrc("8")
                 end
              in. = null
              save_bytes = bytes
              "ALLOC F("indd") DS("file_dsn") SHR Reuse"
              drop in.
              "EXECIO * DISKR" indd "(FINIS STEM in."
              e_rc = rc
              "Free f("indd")"
              "Delete" file_dsn
              if e_rc > 0 then do
                 _rcode_ = 8
                 say msgid "Error reading file:" file_omvs
                 _junk_ = sub_set_zispfrc(_rcode_)
                 end
              if in.0 = 0 then
                 Select
                 When empty_opt = 0 then do
                    say msgid "Warning:" file_omvs "is empty. "
                    say msgid " "
                    empty_ds = 1
                    in.0 = 3
                    in.1 = " Warning: The original file" file_omvs
                    in.2 = "          was empty. If this is in error",
                           "contact the sender."
                    in.3 = "  "
                    call do_empty
                    end
                 When empty_opt = 1 then do
                    _rcode_ = 8
                    say msgid "Error:" file_omvs "is empty. "
                    _junk_ = sub_set_zispfrc(_rcode_)
                    end
                 Otherwise nop
                 end
              if in.0 > 0 then do
                 mh_type = "dsn"
                 _sfi_ = set_file_info();
                 call count_bytes
                 call test_limit
                 if confirm = null then do
                    say msgid "FileOMVS:" file_omvs
                    if name <> null then do
                       parse var name '"'rname'"'
                       say msgid "Attachment filename:" rname
                       end
                    end
                 call process_file
                 end
              end

        /* ----------------------------------------------------- */
        /* If no more file attachments then write out ending     */
        /* boundary statement.                                   */
        /* Also if the Message was in HTML format.               */
        /* Additional check:                                     */
        /*   If last line is already a 'boundary line' then nop  */
        /*   to avoid an empty attachment.                       */
        /* ----------------------------------------------------- */
        if msg_html = 1 | ,
           length(file) + length(filedd) + length(fileo) > 0 ,
        then do
               i = out.0
               if out.i = "--"bnd"--" ,
               then nop
               else do;
                       i = out.0 + 1
                       out.i = "--"bnd"--"
                       out.0 = i
                    end;
             end

        /* ----------------------------------------------------- */
        /* Test for size_limit .........                         */
        /* ----------------------------------------------------- */
         bytes = 0
         do bytecnt = 1 to out.0
            bytes = bytes + length(out.bytecnt)
            end
         call test_limit

         Select

           When(smtp_method="SMTP"),
           Then Do
             if abbrev(smtp_address,".") = 1 ,
             then do;
                      say msgid "Error:",
                          "Value for smtp_address is invalid:",
                          ""smtp_address"",
                          ""
                      say msgid" contact your sysprog to fix this."
                      _junk_ = sub_set_zispfrc("8")
                  end;

            /* ----------------------------------------------------- */
            /* Allocate sysout file for SMTP data to be routed to    */
            /* the z/OS TCP/IP SMTP Server.                          */
            /* ----------------------------------------------------- */
             if smtp_secure = null ,
             then do;
                     if writer <> null ,
                     then do
                             writer_kw = "Writer("writer")"
                             dest_kw = null
                          end
                      else   dest_kw = "DEST("smtp_address")"
                     "ALLOC F("workdd") SYSOUT("sysout_class")" ,
                        "recfm(v b) lrecl("save_lrecl+4") blksize(0) ",
                        ""writer_kw" "dest_kw
                     _rcode_ = rc
                  end;
             else do;
                     space = (out.0 * save_lrecl)%34000
                     space = space + 1
                     space = space","space
                     wtime = strip(right(time('l'),5))
                     xmsmtp_dsn = "'"hlq".xmitp.smtp.t"wtime"'"
                     "ALLOC F("workdd") ds("xmsmtp_dsn")" ,
                        "spa("space") tr" ,
                        "recfm(v b) lrecl("save_lrecl+4") blksize(0)"
                     _rcode_ = rc
                  end;

            /* ----------------------------------------------------- */
            /* If allocation failed tell the user...                 */
            /* ----------------------------------------------------- */
             if _rcode_ > 0 ,
             then do;
                    say msgid" allocation failed to" smtp_address""
                    say msgid" Check XMITIPCU settings or",
                              "contact your sysprog to fix this."
                    _junk_ = sub_set_zispfrc("8")
                  end;

           End    /* smtp_method = "SMTP" */

           When(smtp_method="UDSMTP"),
           Then Do;

             /* ----------------------------------------------------- */
             /* Allocate output dataset to store e-mail cards for use */
             /* as input to batch UDSMTP job (recfm FB).              */
             /* ----------------------------------------------------- */

             workdd = "STDIN"                        /* UDSMTP input */

             space = (out.0 * save_lrecl)/34000
             parse value space with space "." .
             space = space + 1
             space = space","space
             /* Note recfm(f b) - UDSMTP does not like VB */
             "ALLOC F("workdd") spa("space") tr " ,
                "recfm(f b) lrecl("save_lrecl") blksize(0) " ,
                "new catalog unit("vio") reuse"
             _rcode_ = rc

            /* ----------------------------------------------------- *
             * If allocation failed tell the user...                 *
             * ----------------------------------------------------- */
             if _rcode_ > 0 ,
             then do;
                     say msgid "UDSMTP alloc:",
                            "allocation rc "_rcode_" to dd "workdd"."
                     say msgid "UDSMTP alloc:",
                            "contact your sysprog to fix this."
                     _junk_ = sub_set_zispfrc("8")
                  end;

           End;   /* smtp_method="UDSMTP" */

           When(smtp_method="SOCKETS"),
           Then Do;

            /* ----------------------------------------------------- */
            /* if STEMPUSH/STEMPULL is available use TOKEN           */
            /* ----------------------------------------------------- */
             if _stem_push_pull_available_ = "YES" ,
             then do;
                     Socket_Call = "TOKEN"
                     nop   /* Socket_Call = "TOKEN" */
                  end;
             else do;      /* Socket_Call = "FILE"  */

                                                   /* XMITSOCK input */
                     workdd = "MTXT"right(random(1,9999),4,0)
                     Say MsgId "STEMPUSH/STEMPULL not found"
                     Say Msgid "... will use //"workdd""
                     Socket_Call = "FILE"

                     /*--------------------------------------------- */
                     /* Allocate output dataset to store e-mail      */
                     /* cards for use as input to XMITSOCK           */
                     /* -------------------------------------------- */

                     space = (out.0 * save_lrecl)/34000
                     parse value space with space "." .
                     space = space + 1
                     space = space","space
                     "ALLOC F("workdd") spa("space") tr " ,
                       "recfm(f b) lrecl("save_lrecl") blksize(0) " ,
                       "new unit("vio") reuse"
                     _rcode_ = rc
                     /* -------------------------------------------- */
                     /* If allocation failed tell the user...        */
                     /* -------------------------------------------- */
                     if _rcode_ > 0 ,
                     then do;
                             say msgid "XMITSOCK alloc:",
                                 "allocation rc "_rcode_"",
                                 "to dd" workdd"."
                             say msgid "XMITSOCK alloc:",
                                 "contact your sysprog to fix this."
                             _junk_ = sub_set_zispfrc("8")
                          end;
                  end;     /* Socket_Call = "FILE"  */

             /* ---------------------------------------------------- */
             /* SOCKETS needs no Work-File; if Information is passed */
             /* to XMITSOCK via stem-vars with STEMPULL/STEMPUSH     */
             /* ---------------------------------------------------- */

           End;   /* smtp_method="SOCKETS" */
           Otherwise Do;
                        say msgid "Invalid smtp_method",
                            "from XMITIPCU: "smtp_method"."
                        say msgid "Contact your sysprog to fix this."
                        _junk_ = sub_set_zispfrc("8")
           End

        End  /* Select */

        /* ----------------------------------------------------- */
        /* Setup suffix to be written out in SMTP data.          */
        /* ----------------------------------------------------- */
        suf. = null
        suf.1 = "  "
        if interlink = 0 then do
           suf.2 = "."
           suf.3 = "QUIT"
           suf.0 = 3
           end
        else suf.0 = 1

        /* -------------------------------- */
        /* Insert Summary info into Message */
        /* -------------------------------- */
         count=strip(translate('0,123,456,789,abc,def', ,
                         right(out.0,16,','), ,
                         '0123456789abcdef'),'L',',')
         count = strip(count)
         out.msg1 = " Total Records processed:" right(count,10)
         out.msg2 = " Total Files sent:       " right(tot_files,10)

        /* ----------------------------------------------------- */
        /* Write out the header then the data and finally the    */
        /* suffix.  Close and free the output to the SMTP        */
        /* server.                                               */
        /* ----------------------------------------------------- */
         if debug = "on" ,
         then do;
                 /* should never been used in debug mode */
                 _msg_ = msg("OFF")
                 "Free fi("workdd")"
                 _msg_ = msg(_msg_)
              end;
         if debug <> "on" ,
         then do;
              if smtp_method = "SOCKETS" ,
              then do;
                    if Socket_Call = "TOKEN" ,
                    then do;
                            /* ----------------------------------- */
                            /* copy mail to stem mail. and         */
                            /* use STEMPUSH to save the vars       */
                            /* for recall in XMITSOCK via STEMPULL */
                            /* ----------------------------------- */
                            Mail_Line = 0
                            do _x_ = 1 to header.0
                               Mail_Line = Mail_Line + 1
                               mail.Mail_Line = header._x_
                            end
                            do _x_ = 1 to out.0
                               Mail_Line = Mail_Line + 1
                               mail.Mail_Line = out._x_
                            end
                            do _x_ = 1 to suf.0
                               Mail_Line = Mail_Line + 1
                               mail.Mail_Line = suf._x_
                            end
                            mail.0 = Mail_Line
                            Mail_Token = STEMPUSH("mail.")
                         end;
                   end;
              else do
                    "EXECIO * DISKW" workdd "(STEM header."
                    "EXECIO * DISKW" workdd "(STEM out."
                    "EXECIO * DISKW" workdd "(FINIS STEM suf."
                   end;

              if xmitdbg = "YES" ,
              then do;
                    xmitdbgx.0 = 1
                    xmitdbgx.1 = " <*DEBUG*BEGINNING*>"
                    "EXECIO * DISKW xmitdbg (STEM xmitdbgx. )"
                    drop xmitdbgx.

                    if symbol("xmitdbg.0") = "VAR" ,
                    then do;
                           "EXECIO * DISKW xmitdbg (STEM xmitdbg. )"
                           drop xmitdbg.
                         end;

                    do i = 1 to header.0;
                       xmitdbg.i = " <*DEBUG*HEAD>" header.i;
                    end;
                    xmitdbg.0 = header.0
                    "EXECIO * DISKW xmitdbg (STEM xmitdbg. )"
                    drop xmitdbg.

                    do i = 1 to out.0;
                       xmitdbg.i = " <*DEBUG*OUT*>" out.i;
                    end;
                    xmitdbg.0 = out.0
                    "EXECIO * DISKW xmitdbg (STEM xmitdbg. )"
                    drop xmitdbg.

                    if symbol("suf.0") = "VAR" ,
                    then do;
                            do i = 1 to suf.0;
                               xmitdbg.i = " <*DEBUG*SUF*>" suf.i;
                            end;
                            xmitdbg.0 = suf.0
                            "EXECIO * DISKW xmitdbg (STEM xmitdbg. )"
                            drop xmitdbg.
                         end;

                    if symbol("mu.0") = "VAR" ,
                    then do;
                            do i = 1 to mu.0;
                               xmitdbg.i = " <*DEBUG*MU**>" mu.i ;
                            end;
                            xmitdbg.0 = mu.0
                            "EXECIO * DISKW xmitdbg (STEM xmitdbg. )"
                            drop xmitdbg.
                         end;

                    xmitdbg.0 = 1
                    xmitdbg.1 = " <*DEBUG*ENDING***>"
                    "EXECIO * DISKW xmitdbg (STEM xmitdbg. )"
                    drop xmitdbg.
                   end;

              Select
               When(smtp_method="SMTP"),
                Then Do
                     /* ---------------------------------------------*/
                     /* Close and free the output to the SMTP server */
                     /* -------------------------------------------- */
                       if smtp_secure <> null then do
                          "Transmit" smtp_address "ds("xmsmtp_dsn")" ,
                                  "nolog nonotify"
                          "FREE F("workdd")"
                          call msg "Off"
                          "Delete" xmsmtp_dsn
                          end
                       else
                       "FREE F("workdd")"
                     End  /* smtp_method="SMTP" */

               When(smtp_method="UDSMTP"),
                Then Do
                     /* -------------------------------------------- */
                     /* Powergen: call UDSMTP to deliver the mail    */
                     /* -------------------------------------------- */

                       "ALLOC F(STDOUT) spa(1 1) tr " ,
                          "recfm(f b) lrecl(133) blksize(26600) " ,
                          "new catalog unit("vio") reuse"
                       "ALLOC F(STDERR) spa(1 1) tr " ,
                          "recfm(f b) lrecl(133) blksize(26600) " ,
                          "new catalog unit("vio") reuse"

                       if smtp_loadlib <> null then
                          "CALL '"smtp_loadlib"(UDSMTP)'",
                               "'--host,"smtp_server"'"
                       else
                          "CALL *(UDSMTP) '--host,"smtp_server"'"
                       udsmtp_rc = rc

                       "EXECIO * DISKR STDOUT (FINIS STEM stdout."
                       "EXECIO * DISKR STDERR (FINIS STEM stderr."

                       "FREE F(STDOUT)"
                       "FREE F(STDERR)"
                       "FREE F("workdd")"

                       /* Check the messages, rc=0 not always ok */

                       udsmtp_error = 'N'

                       If udsmtp_rc=0,
                       Then Do
                         errtxt = "code signifies an error"
                         Do _i = 1 to stdout.0
                           If Pos(errtxt,stdout._i) > 0
                           Then udsmtp_error = 'Y'
                         End
                         Do _i = 1 to stderr.0
                           If Pos(errtxt,stderr._i) > 0
                           Then udsmtp_error = 'Y'
                         End
                       End

                       Say msgid "UDSMTP  return code : "udsmtp_rc

                       If udsmtp_error="Y",
                        | udsmtp_rc<>0,
                       Then Do
                         Say msgid "****"
                         Say msgid "**** An error occurred within",
                                   "UDSMTP - check the output below"
                         Say msgid "****"
                         Say msgid "**** SMTP Server: "smtp_server
                         Say msgid "****"
                       End

                       if udsmtp_error = "Y" then do
                          Say msgid 'UDSMTP STDOUT messages :'
                          Do _i = 1 to stdout.0
                            Say msgid Strip(stdout._i)
                          End
                          Say msgid 'UDSMTP STDERR messages :'
                          Do _i = 1 to stderr.0
                            Say msgid Strip(stderr._i)
                          End
                       End

                       If udsmtp_error = "Y" ,
                        | udsmtp_rc<>0 ,
                        then _junk_ = sub_set_zispfrc("8")

                     End  /* smtp_method="UDSMTP" */

               When(smtp_method="SOCKETS") ,
                Then Do
                     /* -------------------------------------------- */
                     /*  call XMITSOCK to deliver the mail           */
                     /* -------------------------------------------- */
                       if Socket_Call = "TOKEN" then,
                          Socket_Parm = "T("Mail_Token")"
                       else,
                          Socket_Parm = "D("workdd")"

                       sock_rc = XMITSOCK(""Socket_Parm"",
                                 ""xmitsock_parms"",
                                 "I("smtp_server")" ,
                                 "X("_txt2pdf_xlate_")" ,
                                 "S("tcp_stack")")

                       Say msgid 'XMITSOCK  return code : 'sock_rc

                       If sock_rc <> 0,
                       Then Do
                         Say msgid "****"
                         Say msgid "**** An error occurred within",
                                         "XMITSOCK"
                         Say msgid "****"
                         Say msgid "**** Mail Server:" smtp_server
                         Say msgid "****"
                       End

                       if sock_rc /= 0 ,
                       then _junk_ = sub_set_zispfrc("8")

                     End  /* smtp_method="SOCKETS" */
               Otherwise nop
              End  /* select */
         end  /* if debug */
         else do
                  say msgid " "
                  say msgid "XMITIP Debug Option Enabled"
                  say msgid "The following is the generated message:"
                  say " "
                  do deb = 1 to header.0
                     say header.deb
                     end
                  do deb = 1 to out.0
                     say out.deb
                     end
                  do deb = 1 to suf.0
                     say suf.deb
                     end
                  say " "
                  say msgid "XMITIP Debug Report ending."
                  say msgid " "
              end

        /* -------------------------- */
        /* Issue confirmation msg     */
        /* -------------------------- */
        if confirm = null ,
        then do;
          /* ----------------------------------------------------- */
          /* number format code thanks to Doug Nadel               */
          /* ----------------------------------------------------- */
           str=strip(translate('0,123,456,789,abc,def', ,
                           right(bytes,16,','), ,
                           '0123456789abcdef'),'L',',')
           bytes = strip(str)

           say msgid " "
           say msgid "Message maximum record size is:" save_lrecl+4
           say msgid " "
           if smtp_address_override = 1
              then say msgid "Message successfully transmitted via:" ,
                             smtp_address
              else say msgid "Message successfully transmitted using:",
                              smtp
           if sysout_override = 1
              then say msgid "Sysout Class used:                   ",
                              sysout_class
           if length(sigdsn) + length(sigddn) > 0 then do
                 say msgid "Signature file used:" sigdsn
                 say msgid " "
              end
           if page = null ,
           then do;
                   if length(disclaim) > 0 ,
                   then do
                           say msgid "Standard Disclaimer used from:",
                                     ""disclaim
                           say msgid " "
                        end;
                end;

           if debug = "on" ,
           then send_msg = "Not-Sent"
           else send_msg = "Sent"

           say msgid send_msg out.0+header.0 ,
               "records as text, attachments," ,
               "and control information."
           say msgid "Approximate byte count is:" bytes
           if responds <> null ,
           then do;
                   say msgid " "
                   do rx = 1 to words(responds)
                      say msgid "Processed Response:" word(responds,rx)
                   end
                end;
         end

        /* ----------------------------------------------------- */
        /* All Done - now delete any Created DSNs                */
        /* ----------------------------------------------------- */
        Address TSO
        x = msg("off")
        if length(create_dsns) > 0 then ,
           do i = 1 to words(create_dsns)
              deldsn = word(create_dsns,i)
              "Delete" deldsn
              end

        /* -------------------------- */
        /* All Done - Exit rc = 0     */
        /* unless an empty ds found   */
        /* -------------------------- */
         if empty_ds > 0 ,
         then do;
                 if rc0 = null ,
                 then _junk_ = sub_set_zispfrc("4")
              end;
         exit 0

        /* ----------------------------------------------------- */
        /* Sub-routines used by the application.                 */
        /* ----------------------------------------------------- */

        /* --------------------------------- */
        /* Insert Empty Messages into e-mail */
        /* --------------------------------- */
         Do_Empty:
            do ix = 1 to last_msg
               outn.ix = out.ix
               end
            ix = ix - 1
            do ixn = 1 to in.0
               ix = ix + 1
               outn.ix = in.ixn
               end
            if out.0 > last_msg+1 then
            do ixn = last_msg+1 to out.0
               ix = ix + 1
               outn.ix = out.ixn
               end
            outn.0 = ix
            do ix = 1 to outn.0
               out.ix = outn.ix
               end
            out.0 = ix-1
            drop outn.
            return

        /* ----------------------------------------------------- */
        /* set file info for report and file header              */
        /* ----------------------------------------------------- */
         set_file_info:
         parse arg _all_
         parse var _all_ 1 . "<STEM>" _stem_ "</STEM>" .
         parse value "" with type zip suffix z_type ,
                             html_color html_fsize banner ,
                             html_cfg html_table html_head ,
                             html_wrap html_semi
         if left(t,2)  = "//" then do
            t  = null
            tl = null
            end
         parse value t with fmt1 "/" fmt2 "/" fmt3 "/" fmt4 "/" fmt5 ,
                            "/" fmt6 "/"fmt7 "/" fmt8 "/" fmt9
         parse value tl with fmt1l"/"fmt2l"/"fmt3l"/" . "/" . ,
                            "/" fmt6 "/"fmt7 "/" fmt8 "/" fmt9
         fmt1 = strip(fmt1)
         fmt2 = strip(fmt2)
         fmt3 = strip(fmt3)
         fmt4 = strip(fmt4)
         fmt5 = strip(fmt5)
         fmt6  = strip(fmt6)
         fmt7  = strip(fmt7)
         fmt8  = strip(fmt8)
         fmt9  = strip(fmt9)
         fmt1l = strip(fmt1l)
         fmt2l = fix_symbolics(fmt2l)
         fmt2l = strip(fmt2l)
         fmt3l = strip(fmt3l)
         tot_files = tot_files + 1
         Select
            When left(fmt1,3) = "ZIP" then do
                 parse value "" with type enrich suffix html_color ,
                                z_type zip
                 if zip_type = null then do
                    say msgid "The ZIP option is not supported by your"
                    say msgid "installation or not on this LPAR",
                              "(sorry)."
                    _x_ = sub_set_zispfrc(_rcode_)
                    end
                 if fmt1   = "ZIPHTML" then do
                    type   = "HTML"
                    enrich = "html"
                    suffix = ".html"
                    if translate(left(fmt3,3)) = "DS:" then do
                       html_cfg = substr(fmt3,4)
                       end
                    if translate(left(fmt3,3)) = "DD:" then do
                       html_cfg = fmt3
                       end
                    if html_cfg = null then do
                       html_color = fmt3
                       html_fsize = fmt4
                       banner = fmt5
                       if translate(left(fmt6,1)) = "Y"
                          then html_table = fmt6
                       if translate(left(fmt7,1)) = "N"
                          then html_head = fmt7
                       if translate(left(fmt8,1)) = "Y"
                          then html_wrap = fmt8
                       if translate(left(fmt9,1)) = "Y"
                          then html_semi = fmt9
                       end
                    end
                 if fmt1   = "ZIPRTF" then do
                    type   = "RTF"
                    suffix = ".rtf"
                    end
                 if fmt1   = "ZIPBIN"  then do
                    type   = "Binary"
                    z_type = "ZIPBIN"
                    suffix = ".bin"
                    end
                 if fmt1   = "ZIPCSV"  then do
                    type = "ZIP"
                    suffix = ".csv"
                    end
                 if fmt1   = "ZIPGIF"  then do
                    type   = "Binary"
                    z_type = "ZIPBIN"
                    suffix = ".gif"
                    end
                 if fmt1   = "ZIPPDF" then do
                    type   = "PDF"
                    z_type = "ZIPBIN"
                    suffix = ".pdf"
                    end
                 if fmt1   = "ZIPXMIT" then do
                    type   = "Binary"
                    z_type = "ZIPBIN"
                    suffix = ".xmit"
                    end
                 if fmt1   = "ZIP"  then do
                    type   = null
                    suffix = ".txt"
                    end
                 zip  = fmt1
                 end
            When fmt1 = "HTML" then do
                 type = fmt1
                 if translate(left(fmt2,3)) = "DS:" then do
                    html_cfg = substr(fmt2,4)
                    end
                 if translate(left(fmt2,3)) = "DD:" then do
                    html_cfg = fmt2
                    end
                 if html_cfg = null then do
                    html_color = fmt2
                    enrich = "html"
                    if fmt3 <> null ,
                       then suffix = fmt3l
                       else suffix = ".html"
                    html_fsize = fmt4
                    banner = fmt5
                    if translate(left(fmt6,1)) = "Y"
                       then html_table = fmt6
                    if translate(left(fmt7,1)) = "N"
                       then html_head = fmt7
                    if translate(left(fmt8,1)) = "Y"
                       then html_wrap = fmt8
                    if translate(left(fmt9,1)) = "Y"
                       then html_semi = fmt9
                    end
                 end
            When fmt1 = "RTF" then do
                 type = fmt1
                 if fmt5 <> null ,
                    then suffix = fmt5
                    else suffix = ".rtf"
                    end
            When fmt1 = "BIN" then do
                 type = "Binary"
                 if fmt2 <> null ,
                    then suffix = fmt2
                    else suffix = ".bin"
                 if fmt3""fmt4""fmt5""fmt6""fmt7""fmt8""fmt9 = "" ,
                 then nop;
                 else do;
                         _special_xlate_ = "YES"
                         say msgid" special_xlate_ needed ..."
                         say msgid"   future use"
                         if userid() = "XXXX740" ,
                         then do;
                                   x = trace("R");nop
                              end;
                      end;
                    end
            When fmt1 = "GIF" then do
                 type = "Binary"
                 if fmt2 <> null ,
                    then suffix = fmt2
                    else suffix = ".gif"
                    end
            When fmt1 = "XMIT" then do
                 type = "Binary"
                 if fmt2 <> null ,
                    then suffix = fmt2
                    else suffix = ".xmit"
                    end
            When fmt1 = "PDF" then do
                 type = "Binary"
                 suffix = ".pdf"
                 end
            When fmt1 = "CSV" then do
                 if fmt2 = null ,
                    then suffix = ".csv"
                    end
            When fmt1 = "SLK" then do        /* @DM03252021 */
                 if fmt2 = null ,            /* @DM03252021 */
                    then suffix = ".slk"     /* @DM03252021 */
                    end                      /* @DM03252021 */
            When fmt1 = "ICAL" then do
                    type = "Calendar"
                    suffix = ".ics"
                    end
            When fmt1 = "TXT" then do
                 if fmt2 <> null ,
                    then suffix = fmt2
                    else suffix = ".txt"
                    end
            When fmt1 = "XLS" then do
                 type = fmt1
                 if fmt5 <> null ,
                    then suffix = fmt2
                    else suffix = ".xls"
                end
            When fmt1 = "XLSX" then do
                 type = fmt1
                 if fmt5 <> null ,
                    then suffix = fmt2
                    else suffix = ".xlsx"
                end
            When fmt1 = "CSV" then do
                 type = fmt1
                 if fmt5 <> null ,
                    then suffix = fmt2
                    else suffix = ".csv"
                 end
            otherwise do
                      type = null
                      suffix = file_suf
                      end
            end

         if ignore_suffix = 1 then
            suffix = null
         if translate(suffix) = "X" then
            suffix = null
         if suffix <> null then
            if left(suffix,1) <> "." then
               suffix = "."suffix

         if followup = null then do
            desc = strip(word(filedesc,fd))
            if pos("/",desc) > 0 then
               parse value desc with file_name "/" desc_d
            else do
                 file_name = null
                 desc_d = desc
                 end
            if file_name <> null then do
               say msgid "---------------------------------------------"
               say msgid "The FILEDESC usage for filename is being"
               say msgid "changed to FILENAME.  FILEDESC will remain as"
               say msgid "the keyword for the description."
               say msgid "syntax for FILENAME is: FILENAME filename"
               say msgid "---------------------------------------------"
               end
           if file_name = null then
              file_name = strip(word(filename,fd))
           file_name = translate(file_name,' ',x2c("01"))
           if translate(file_name) = "X" then
              file_name = null
           end

        /* --------------------------------------------------------- */
        /* If no format test filename for suffix to determine format */
        /* --------------------------------------------------------- */
         if fmt1 = null then
            if file_name <> null then do
               tname = translate(file_name," ",".")
               tsuff = translate(word(tname,words(tname)))
               Select
                 When left(tsuff,3) = "HTM" then fmt1 = "HTML"
                 When tsuff = "BIN"  then fmt1 = "BIN"
                 When tsuff = "CSV"  then fmt1 = "CSV"
                 When tsuff = "SLK"  then fmt1 = "SLK"   /* @DM03252021 */
                 When tsuff = "GIF"  then fmt1 = "GIF"
                 When tsuff = "ICS"  then fmt1 = "ICAL"
                 When tsuff = "PDF"  then do
                      fmt1 = "PDF"
                      type = "Binary"
                      end
                 When tsuff = "RTF"  then fmt1 = "RTF"
                 When tsuff = "TXT"  then fmt1 = "TXT"
                 When tsuff = "XMIT" then fmt1 = "XMIT"
                 When tsuff = "ZIP"  then fmt1 = "ZIP"
                 Otherwise fmt1 = "TXT"
                 end
               end

        /* --------------------------------------------------------- */
        /* If no Format and no Filename then test for file_dsn       */
        /* suffix of GIF, PDF, or XMIT and set to Binary.            */
        /* --------------------------------------------------------- */
         if fmt1 = null | fmt1 = "BIN" then
         if file_name = null then do
                   if file_dsn <> null then do
                      if left(file_dsn,1) = "'" ,
                         then parse var file_dsn "'"tname"'"
                         else tname = file_dsn
                      tname = translate(tname)
                      hits = null
                      Select
                        When right(tname,4) = ".PDF" then do
                             hits = 1
                             fmt1 = "PDF"
                             end
                        When right(tname,4) = ".GIF"
                             then hits = 1
                        When right(tname,5) = ".XMIT"
                             then hits = 1
                        Otherwise nop
                        end
                        if hits = 1 then do
                           if fmt1 = null then
                              fmt1 = "BIN"
                           type = "Binary"
                           suffix = null
                           end
                      end
                   end

        /* --------------------------------------------------------- */
        /* Test file_name for symbolics and make substitutions.      */
        /* --------------------------------------------------------- */
         file_name = fix_symbolics(file_name)

        /* --------------------------------------------------------- */
        /* Test filedesc for symbolics and make substitutions.       */
        /* --------------------------------------------------------- */
         desc_d = fix_symbolics(desc_d)

        /* --------------------------------------------------------- */
        /* Compare Filename and Suffix                               */
        /* --------------------------------------------------------- */
         if length(suffix) > 0 then do
            xl = length(suffix)
            xf = translate(right(file_name,xl))
            if left(xf,1) = "." then ,
               xf = substr(xf,2)
            fmtmm = 0
            Select
              When left(fmt1,3) = "CSV" then
                   if xf <> "CSV" then fmtmm = 1
              When left(fmt1,3) = "SLK" then              /* @DM03252021 */
                   if xf <> "SLK" then fmtmm = 1          /* @DM03252021 */
              When left(fmt1,3) = "ICS" then
                   if xf <> "ICS" then fmtmm = 1
              When left(fmt1,3) = "GIF" then
                   if pos("GIF",xf) = 0 then fmtmm = 1
              When left(fmt1,3) = "HTM" then
                   if pos("HTM",xf) = 0 then fmtmm = 1
              When left(fmt1,3) = "PDF" then
                   if xf <> "PDF" then fmtmm = 1
              When left(fmt1,3) = "RTF" then
                   if xf <> "RTF" then fmtmm = 1
              When left(fmt1,3) = "TXT" then ,
                   do;
                      if force_suf = "NO" ,
                      then nop
                      else if xf <> "TXT" then fmtmm = 1
                   end;
              When left(fmt1,3) = "ZIP" then
                   if pos("ZIP",xf) = 0 then fmtmm = 1
              Otherwise nop
              end
           /* --------------------------- */
           /* Now test for a mismatch     */
           /* --------------------------- */
            if xf = null then fmtmm = 0
            if fmtmm = 1 then do
               lfmt13 = left(fmt1,3)
               say msgid "> Warning: FILENAME" file_name "and Format" ,
                   fmt1 "are not the same."
               say msgid "> There may be a mismatch when opening on" ,
                         "the recipients workstation."
               if ignore_suffix = null then do
                  say msgid "> To avoid a mismatch when opening on the",
                            "recipients workstation, an extension of",
                            "'."lfmt13"' will be added"
                  file_name = file_name"."lfmt13
                  end
               end
            end

         mh. = null
         if suffix <> null ,
              then mh_suf = suffix
              else mh_suf = null
         if left(fmt1,3) = "ZIP"
            then mh_suf = ".zip"
         if mh_type = "dsn" then do
            sl = length(mh_suf)
            if right(file_dsn,1) = "'" then do
               sr = right(file_dsn,sl+1)
               sr = left(sr,sl)
               end
            else sr = right(file_dsn,sl)
            if translate(mh_suf) = translate(sr)
               then mh_suf = null
            if left(file_dsn,1) = "'" then
            name = substr(file_dsn,2,length(file_dsn)-2)""mh_suf
            else name = file_dsn""mh_suf
            if pos("(",file_dsn) > 1 then do
               parse value file_dsn with . "(" name ")" .
               name = '"'strip(name)""mh_suf'"'
               end
            else name = '"'strip(name)'"'
            end
         if mh_type = "ddn" then
            name = '"'file_ddn""mh_suf'"'

         if file_name <> null ,
         then do;
                 /* If processing an entire PDS and a file name */
                 /* has been specified, then add '_membername'  */
                 /* before the extension                        */
                 If pdsloop = "Y" ,
                 Then Do
                        Parse Value file_dsn with . "(" name ")"
                        If Pos(".",file_name) = 0 ,
                        Then name = '"'filename'_'name'"'
                        Else Do
                               tname = translate(file_name," ",".")
                               tsuff = word(tname,words(tname))
                               name  = '"'Substr(file_name,1,,
                                 Length(file_name)-1-Length(tsuff)),
                                      || '_'name'.'tsuff'"'
                             End
                      End
                 Else Do
                        name = '"'file_name'"'
                      End
              end;

         m_type = MimeHead
         mh.1 = "--"bnd
         if pos(translate(right(filename,4)),".HTM HTML") > 0 then do
             mh.2 = "Content-Type: text/"enrich"; charset="char";"
            end
         else do
            if type = null then
               select
               when charuse = 1 then
                   mh.2 = "Content-Type: text/plain;"
               otherwise
                   mh.2 = "Content-Type: text/plain; charset="char";"
               end

            if type = "Calendar" then do ;
               mh.2 = "Content-Type: text/calendar;"
               if _cs_ /= "" ,
               then do ;
                       mh.2 = ""mh.2" charset="_cs_";"
                       m_type = "quoted-printable"
                    end;
               else do ;
                       mh.2 = ""mh.2" charset="char";"
                    end;
               end

            if type = "HTML" then do
               mh.2 = "Content-Type: text/enriched; charset="char";"
               end

            if wordpos(left(fmt1,3),"RTF") > 0 then do
                 Select
                   when charuse = 1 then ,
                       mh.2 = "Content-Type: text/plain;"
                   otherwise do
                       mh.2 = "Content-Type: application/rtf; ",
                              "charset="char";"
                       m_type = "quoted-printable"
                       end
                 end
               end

            if translate(left(suffix,4)) = ".HTM" then do
               mh.2 = "Content-Type: text/enriched; charset="char";"
               end

         end /* end else */

         if wordpos(left(fmt1,3),"ZIP BIN GIF XMI") > 0 then do
            mh.2 = "Content-Type: application/octet-stream;"
            m_type = "base64"
            end

         if wordpos(left(fmt1,3),"CSV XLS SLK") > 0 then do   /* @DM03252021 */
            mh.2 = "Content-Type: application/ms-excel;"
            end

         if wordpos(left(fmt1,4),"HTML" ) > 0 then do
            encoding = encoding
            if encoding /= "" ,
            then do ;
                   _cs_ = '"'strip(encoding)'"'
                 end;
            else do ;
                   _cs_ = char
                 end;
            mh.2 = "Content-Type: text/enriched;"
              Select
               when ( "BYP"="BYx" ) then _cs_ = "" ; /* bypass this */
               when ( charuse = 0 ) then ,           /* use char    */
                      do ;
                        mh.2 = ""mh.2" charset="_cs_";"
                        m_type = "quoted-printable"
                      end;
               when ( charuse = 1 ) then _cs_ = "" ;
               otherwise                 nop       ;
              end
            end

         if wordpos(left(fmt1,3),"TXT"  ) > 0 then do
            if encoding /= "" ,
            then do ;
                   _cs_ = '"'strip(encoding)'"'
                 end;
            else do ;
                   _cs_ = char
                 end;
            mh.2 = "Content-Type: text/plain;"
            Select
             when charuse = 0 then nop       ;
             when charuse = 1 then _cs_ = "" ;
             otherwise             nop       ;
            end
            if _cs_ /= "" ,
            then do ;
                    mh.2 = ""mh.2" charset="_cs_";"
                    m_type = "quoted-printable"
                 end;
            end

         if wordpos(left(fmt1,3),"RTF"  ) > 0 then do
            if encoding /= "" ,
            then do ;
                   _cs_ = '"'strip(encoding)'"'
                 end;
            else do ;
                   _cs_ = char
                 end;
            mh.2 = "Content-Type: application/rtf;"
            Select
             when charuse = 0 then nop       ;
             when charuse = 1 then _cs_ = "" ;
             otherwise             nop       ;
            end
            if _cs_ /= "" ,
            then do ;
                    mh.2 = ""mh.2" charset="_cs_";"
                    m_type = "quoted-printable"
                 end;
            end

         if left(fmt1,3) = "PDF" then do
            mh.2 = "Content-Type: application/pdf;"
            m_type = "base64"
            end
         mh.3 = "              name="name
         mh.4 = "Content-Transfer-Encoding:" m_type
         mh.5 = "Content-Disposition: attachment;"
         mh.6 = "   filename="name

         if desc_d <> null then
            if desc_d <> "x" then
               mh.7 = "Content-Description:" desc_d
         if descopt = 0 then do
            if mh_type = "dsn" then
               mh.7 = "Content-Description:" strip(file_dsn,"B","'")
            else
               mh.7 = "Content-Description:" file_ddn""mh_suf
            end
         else
               mh.7 = "Content-Description:" name
        /* ------------------------ *filename* ----------------------- *
         | Fix for the file name displayed in the e-mail client having |
         | a double quote around it and the file suffix being          |
         | added.                                                      |
         | Remove the " around the filename and all works well but     |
         | if you have a client that needs them then comment this.     |
         * ----------------------------------------------------------- */
         mh.7 = translate(mh.7,' ','"')

         mh.8 = " "
         do i = 1 to 8
            out.0 = out.0 + 1
            n = out.0
            out.n = mh.i
            end
         if _stem_ /= null ,
         then do ;
                select ;
                  when ( charuse = 0 ) then ,
                   do ;
                     if encoding_default /= "" ,
                     then do ;
                             _stem_ = translate(_stem_)
                             _txt_  = "encode info >>>",
                                      "fmt1 = <"fmt1">"
                             _junk_ = ,
                                  sub_xmitdbg(" <*DEBUG*prcs> "_txt_);
                             select ;
                               when (abbrev(fmt1,"ZIP")=1) then ,
                                   _enctype_save_ = substr(fmt1,4)
                               when (       fmt1 = "HTML") then ,
                                   _enctype_save_ = ""
                               otherwise ,
                                   _enctype_save_ = fmt1
                             end

                             _txt_  = "encode info >>>",
                                      "_enctype_save_ =",
                                      "<"_enctype_save_">"
                             _junk_ = ,
                                  sub_xmitdbg(" <*DEBUG*prcs> "_txt_);
                             select ;
                               when ( _enctype_save_="HTML" ) then nop;
                               otherwise _enctype_save_ = ""
                             end

                             select ;
                               when ( _enctype_save_ = ""   ) ,
                                 then do;
                                         _txt_  = "<*DEBUG*prcs>",
                                                  "encode info >>>",
                                           "encoding bypassed for in."
                                         _junk_ = ,
                                               sub_xmitdbg(" "_txt_);
                                      end;
                               when ( _stem_ = "IN." ) ,
                                 then do ;
                                        _enctype_ = _enctype_save_
                                        do idx = 1 to in.0
                                          in.idx= ,
                                            sub_encode_data(in.idx) ;
                                        end;
                                         _txt_  = "<*DEBUG*prcs>",
                                                  "encode info >>>",
                                           "encoding done     for in."
                                         _junk_ = ,
                                               sub_xmitdbg(" "_txt_);
                                      end;
                               otherwise nop;
                             end;
                          end;
                   end;
                  otherwise nop ;
                end;
                _stem_ = null
              end;
         return 0

        /* ----------------------------------------------------- */
        /* Test size limit and if we're over exit                */
        /* ----------------------------------------------------- */
         Test_Limit:
         over = bytes - size_limit
         if size_limit > 0 then
            if bytes > size_limit then do
               say msgid "Severe Error: You have exceeded the allowed"
               say msgid "              size.  Current size:" bytes
               say msgid "              over by:" over
               say msgid "              limit:  " size_limit
               _x_ = sub_set_zispfrc("8")
               end
            return

        /* --------------------------------------------------------- */
        /* Count the bytes in the input file                         */
        /* and translate nulls to blanks                             */
        /* --------------------------------------------------------- */
         Count_Bytes:
         if left(fmt1,3) /= "ZIP" then
            do bytecnt = 1 to in.0
               if type /= "Binary" then
                  in.bytecnt = translate(in.bytecnt,' ',nullc)
               bytes = bytes + length(in.bytecnt)
               end
         return

        /* ----------------------------------------------------- */
        /* process the file here                                 */
        /* ----------------------------------------------------- */
         Process_file:
              start_out = out.0
              pmeasure  = null
              if printcc = "on" then do_cc = 1
                            else do_cc = 0
              if ignorecc <> null then do_cc = 0
              if confirm = null then do
                 as = null
                 if pos("RTF",fmt1) > 0 then
                    as = "as Rich Text"
                 else if type <> null ,
                       then as = "as" type
                       else as = fmt1
                 if pos("PDF",fmt1) > 0 then
                    as = "as PDF"
                 if left(fmt1,3) <> "ZIP" then
                    say msgid "-Input Records:" in.0 as
                 if fmt1 = null then do
                    say msgid "format defaulting to text."
                    say msgid " "
                    end
                 if file_name <> null then
                    say msgid "as attachment name:" file_name
                 if desc_d <> "x" then
                    if desc_d <> null then
                       say msgid "as description:" desc_d
                 end
              if ignorecc = null then do
                 if right(sysrecfm,1) = "A" then do_cc = 1
                 if right(sysrecfm,1) = "M" then do_cc = 1
                 end
              if ignorecc <> null then do_cc = 0
              if fmt1 = "PDF" then do
                 if left(in.1,4) = x2c("25 50 44 46") ,
                    then do
                         pdf = null
                         end
                 else do
                 pdf = null
                 if fmt2 = null then
                    fmt2 = def_orient
                 if fmt2 <> null then
                    pdf = "ORIENT" fmt2
                 if fmt3 = null then
                    fmt3 = font_size
                 if fmt3 <> null then do
                    if translate(right(fmt3,1)) = "B" then do
                       fsl = length(fmt3)-1
                       pdf = pdf "FONT" left(fmt3,fsl)"/CourierBold"
                       end
                       else pdf = pdf "FONT" fmt3
                    end
                 if fmt4 <> null then do
                    if pos("X",translate(fmt4)) > 0 then
                       if metric = "C" then do
                          parse var fmt4 w "X" h
                          pmeasure = "in Centimeters"
                          w = w * 0.3937
                          h = h * 0.3937
                          fmt4 = strip(w)"X"strip(h)
                          end
                    pdf = pdf "PAPER" fmt4
                    end
                 if fmt5 = null then fmt5 = deflpi
                 if fmt5 <> null then
                    pdf = pdf "LPI" fmt5
                 if fmt6 <> null then
                 if translate(fmt6) <> "NO" then do
                    if left(fmt6,2) = '40'  then e = 40
                    else if left(fmt6,3) = '128' then e = 128
                    else e = 40
                    if pos(":",fmt6) > 0 then do
                       parse value fmt6 with x ":"upw
                       pdf = pdf "encrypt st/xx/"upw"/"e"/ne/nc"
                       end
                    else
                       pdf = pdf "encrypt st/xx//"e"/ne/nc"
                    end
                 if translate(left(fmt2,3)) = "DS:" then
                    pdf = "CONFIG" substr(fmt2,4)
                 if translate(left(fmt2,3)) = "DD:" then
                    pdf = "CONFIG" fmt2
                 if confirm = null then do
                    if left(pdf,3) <> "CON" then do
                       say msgid "Orientation:" fmt2
                       say msgid "Font size:  " fmt3
                       say msgid "Paper size: " fmt4 pmeasure
                       say msgid "LPI:        " fmt5
                       say msgid "Security:   " fmt6
                       end
                    else say msgid "Configuration:" fmt2
                    end
                 call do_pdf
                 end
                 end
              if fmt1 = "ZIPPDF" then do
                 if left(in.1,4) = x2c("25 50 44 46") ,
                    then do
                         type = "Binary"
                         pdf = null
                         end
                 else do
                 pdf = null
                 if fmt3 = null then
                    fmt3 = def_orient
                 if fmt3 <> null then
                    pdf = "ORIENT" fmt3
                 if fmt4 = null then
                    fmt4 = font_size
                 if fmt4 <> null then do
                    if translate(right(fmt4,1)) = "B" then do
                       fsl = length(fmt4)-1
                       pdf = pdf "FONT" left(fmt3,fsl)"/CourierBold"
                       end
                       else pdf = pdf "FONT" fmt4
                    end
                 if fmt5 <> null then do
                    if pos("X",translate(fmt5)) > 0 then
                       if metric = "C" then do
                          parse var fmt5 w "X" h
                          pmeasure = "in Centimeters"
                          w = w * 0.3937
                          h = h * 0.3937
                          fmt5 = strip(w)"X"strip(h)
                          end
                    pdf = pdf "PAPER" fmt5
                    end
                 if fmt6 = null then fmt6 = deflpi
                 if fmt6 <> null then
                    pdf = pdf "LPI" fmt6
                 if fmt7 <> null then
                 if translate(fmt7) <> "NO" then do
                    if left(fmt7,2) = '40'  then e = 40
                    else if left(fmt7,3) = '128' then e = 128
                    else e = 40
                    if pos(":",fmt7) > 0 then do
                       parse value fmt7 with x ":"upw
                       pdf = pdf "encrypt st/xx/"upw"/"e"/ne/nc"
                       end
                    else
                       pdf = pdf "encrypt st/xx//"e"/ne/nc"
                    end
                 if translate(left(fmt3,3)) = "DS:" then
                    pdf = "CONFIG" substr(fmt3,4)
                 if translate(left(fmt3,3)) = "DD:" then
                    pdf = "CONFIG" fmt3
                 if confirm = null then do
                    if left(pdf,3) <> "CON" then do
                       say msgid "Orientation:" fmt3
                       say msgid "Font size:  " fmt4
                       say msgid "Paper size: " fmt5 pmeasure
                       say msgid "LPI:        " fmt6
                       say msgid "Security:   " fmt7
                       end
                    else say msgid "Configuration:" fmt3
                    end
                    call do_pdf
                 end
                 end
              if pos("HTML",translate(fmt1)) > 0 then do
                 if pos("HTML>",translate(in.1)) = 0 then
                    if in.0 > 1 then
                       if pos("HTML>",translate(in.2)) = 0 then
                          call do_html
                 n = out.0
                 do i = 1 to in.0
                    n = n + 1
                    if nostrip = null then
                       out.n = strip(in.i,'t')
                    else out.n = in.i
                    if length(out.n) = 0 then out.n = " "
                    save_lrecl = max(length(out.n),save_lrecl)
                    if save_lrecl > 1024 then signal big_lrecl
                    if save_lrecl > 998  then call rfc_maxlrecl
                    end
                 out.0 = n
                 end
              if pos("RTF",translate(fmt1)) > 0 then do
                 _left11_ = left(in.1,11)                  /* debug */
                 _leftcm_ = ""brcl""basl"rtf1"basl"ansi"   /* debug */
                 if left(in.1,11) <> brcl""basl"rtf1"basl"ansi" then
                    call do_rtf
                 n = out.0
                 do i = 1 to in.0
                    n = n + 1
                    if nostrip = null then
                       out.n = strip(in.i,'t')
                    else out.n = in.i
                    if length(out.n) = 0 then out.n = " "
                    save_lrecl = max(length(out.n),save_lrecl)
                    if save_lrecl > 1024 then signal big_lrecl
                    if save_lrecl > 998  then call rfc_maxlrecl
                    end
                 out.0 = n
                 end
              if pos("XMIT",fmt1) > 0 then do
                 if substr(in.1,3,4) <> "INMR" then
                    call do_xmit
                 end
              if pos(left(type,3),"ZIP Bin PDF HTM RTF") = 0 then do
                 bytes = save_bytes
                 do i = 1 to in.0
                    skip_record = 0
                    if do_cc = 1 then call do_cc
                    if skip_record = 1 then iterate
                    out.0 = out.0 + 1
                    n = out.0
                    if length(in.i) = 0 then in.i = " "
                    /* Translate out all null characters */
                    hex00 = x2c("00")
                    hex40 = x2c("40")
                    if pos(hex00,in.i) > 0 then
                       in.i = translate(in.i,hex40,hex00)
                    if left(in.i,1) = "." then
                       in.i = "."in.i
                    if nostrip = null then
                       out_r = strip(in.i,'t')
                    else out_r = in.i
                    if wordpos(fmt1,"TXT") > 0 ,
                    then do ;
                            _enctype_ = "TXT" ;
                            out_r = sub_encode_data(out_r) ;
                         end;
                    out.n = out_r
                    if length(out.n) = 0 then out.n = " "
                    if left(fmt1,3) <> "ZIP" then do
                       bytes = bytes + length(in.i)
                       save_lrecl = max(length(out.n),save_lrecl)
                       if save_lrecl > 1024 then signal big_lrecl
                       if save_lrecl > 998  then call rfc_maxlrecl
                       end
                    end
                 call test_limit
                 end
              if left(fmt1,3) = "ZIP" then do
                 zip_formats = "ZIP ZIPRTF ZIPPDF ZIPHTML ZIPRTF"
                 if wordpos(fmt1,zip_formats) > 0 ,
                    then suf = strip(substr(fmt1,4))
                 else suf = "bin"
                 fi = 0
                 lrec = 0
                 zip_formats = "ZIPBIN ZIPGIF ZIPPDF ZIPXMIT ZIPCSV"
                 if wordpos(fmt1,zip_formats) = 0 ,
                    then do
                    drop in.
                    bytes = save_bytes
                    lrecl = 0
                    do fo = start_out+1 to out.0
                       fi = fi + 1
                       in.fi = out.fo
                       len = length(in.fi)
                       if len = 0 then in.fi = " "
                       if lrec <= len then
                          lrec = len
                       out.fo = null
                       end
                    out.0 = start_out
                    in.0 = fi
                    end
                    else do fi = 1 to in.0
                          len = length(in.fi)
                          if len = 0 then in.fi = " "
                          if lrec <= len then
                             lrec = len
                         end
                 if mh_type = "ddn" then
                    file_dsn = "dd."file_ddn".zip"
                 save_file_dsn = file_dsn
                 zipwork = null
                 if fmt2l    = null then do
                    if mh_type = "ddn" ,
                       then fmt2l = file_ddn""suffix
                       else do
                            if pos("(",save_file_dsn) > 0 ,
                            then do
                                 parse value save_file_dsn ,
                                             with "(" mem ")" .
                                 fmt2l = strip(mem)""suffix
                                 end
                            else do
                                 sl = length(suffix)
                                 tl = translate(save_file_dsn)
                                 if left(tl,1) = "'" then
                                    parse var tl "'"tl"'"
                                 if right(tl,sl) = translate(suffix)
                                    then suffix = null
                                 fmt2l = strip(save_file_dsn,"B","'")""suffix
                                 end
                            end
                    end
                    if zip_type = "INFOZIP"
                       then do
                            fmt2l = fix_symbolics(fmt2l)
                            fmt2l = space(fmt2l,0)
                            zd  = translate(fmt2l,' ','.')
                            if words(zd) > 2
                               then zd  = subword(zd,words(zd)-2)
                            zd  = translate(zd,'.',' ')
                            zipwork = "'"zip_hlq""strip(zd)"'"
                            call test_dsn zipwork
                            fmt2l = zipwork
                            end
                    if confirm = null then do
                       say msgid "Using ZIP:  " zip_type
                       say msgid "zip file as:" fmt2l
                       end
                    if zipwork = null
                       then zipwork = "'"hlq".zipw."eddd"."jobid""suffix"'"
                    file_dsn = zipwork
                    if suf = null then suf = "txt"
                    call msg "off"
                    "Delete" zipwork
                    vbytes = 0
                    do bytecnt = 1 to in.0
                       vbytes = vbytes + length(in.bytecnt)
                       end
                    vlrec = vbytes % in.0
                    trpt = 28000%vlrec
                    tpri = (in.0%trpt) + 1
                    tsec = (tpri%10) + 1
                    "Alloc f("eddd") ds("zipwork") new tr" ,
                       "Spa("tpri+tsec","tsec")" ,
                       "Recfm(V B) lrecl("lrec+8")" ,
                       "Blksize(0) reuse"
                    "Execio * diskw" eddd "(Finis stem in."
                    "Free f("eddd")"
                 if confirm = null then do
                    say msgid " zip'ing file" save_file_dsn
                    if fmt2l <> null then
                       if pos(zip_type,"PKZIP INFOZIP") > 0 then
                       say msgid " with name-in-archive of" fmt2l
                       else
                       say msgid " name-in-archive of" fmt2l ,
                                 "not supported by" zip_type"," ,
                                 "using data set name."
                    end
                 save_bytes = bytes
                 call do_zip
                 type = "Binary"
                 end
              if type = "Binary" then do
                 bytes = save_bytes
                 call do_base64
                 end
         return

        /* ---------------------------------------------- */
        /* Test the validity of the zip work dataset name */
        /* ---------------------------------------------- */
         Test_DSN: procedure expose (global_vars)
         arg dsname
         msg = null
         if length(dsname) > 46 then msg = "too long"
         if pos(" ",dsname) > 0 then msg = "imbedded blanks"
         if pos("_",dsname) > 0 then msg = "invalid character"
         if pos("-",dsname) > 0 then msg = "invalid character"
         if msg = null then return 0
         say msgid " "
         say msgid "Error: Invalid name-in-archive dataset name"
         say msgid "       Generated dataset name:" dsname
         say msgid "       Problem:" msg
         say msgid "       Transmission is ending."
         _x_ = sub_set_zispfrc("8")

        /* ----------------------------------------------------- */
        /* Test validity (as much as we can) of e-mail address   */
        /* ldap = 2 when set indicates an invalid address        */
        /* ----------------------------------------------------- */
        Test_Address: Procedure Expose (global_vars) ,
                                       test_address tcp_domain ,
                                       append_domain trc ldap ,
                                       temp_address atsign atsignc ,
                                       restrict_domain check_addrs ,
                                       idwarn
        parse arg temp_address field
        inv  = 0
        atrc = 0
        trc  = 0
        if left(temp_address,1) = "*" then return

        if left(translate(temp_address),7) = "&USERID" then do
           rest = substr(temp_address,8)
           temp_address = sysvar('sysuid')""rest
           end

        atsignl = length(atsign)
        do c = 1 to atsignl
           atsigntc = substr(atsign,c,1)
           if pos(atsigntc,temp_address) > 0 then atrc = 1
           if atrc = 1 then do
              temp_address = translate(temp_address,AtSignC,atsigntc)
              trc = 1
              end
           end
        if atrc <> 1 then do
           if append_domain = null then inv = 1
           else do
                temp_address = temp_address""AtSignC""append_domain
                trc = 1
                end
           end
        p1 = pos(AtSigntc,temp_address)
        if pos(AtSigntc,temp_address,p1+1) > 0 then inv = 1
        if words(restrict_domain) > 0 then do
           inv = 2
           do rd = 1 to words(restrict_domain)
              rdn = word(restrict_domain,rd)
              rl = length(rdn)
              if right(translate(temp_address),rl) = rdn
                 then inv = 0
              end
           end
        if pos(":",temp_address,p1+1) > 0 then inv = 0
        if inv = 0 & ldap = 0 then do
              if pos(temp_address,check_addrs) > 0 then x_rc = 0
                 else check_addrs = strip(check_addrs temp_address)
              x_rc = xmitipid(temp_address)
              Select
                 when x_rc = 4 then do
                      if idwarn <> null then mf = "Warning:"
                                        else mf = "Error:"
                      say msgid mf temp_address ,
                                "is an invalid e-mail address",
                                "in Parameter -" field
                      if idwarn = null then
                         ldap = 2
                      end
                 when x_rc = 8 then do
                      say msgid "Unable to validate e-mail address",
                                "LDAP Server unavailable"
                      ldap = 1
                      end
                 otherwise nop
                 end
           end
        if inv = 1 then do
           say msgid "Invalid address ("temp_address") was specified"
           say msgid "The address must be of the format",
                      "userid"AtSignC"internet.address"
           say msgid "for example:",
                     ""sysvar('sysuid')""AtSignC""tcp_domain
           _x_ = sub_set_zispfrc("8")
           end
        if inv = 2 then do
           say msgid "Invalid address ("temp_address") was specified"
           say msgid "The address does not reference an allowed" ,
                      "domain."
           _x_ = sub_set_zispfrc("8")
           end
         Return

        /* ----------------------------------------------------- */
        /* Do_PDF:                                               */
        /* Convert the input file into Adobe Acrobat PDF format. */
        /* ----------------------------------------------------- */
         Do_PDF:
         if format_all = 1 ,
            then margins = word(margin,1)
            else margins = word(margin,fd)
         parse value margins with left"/"right"/"top"/"bottom
         pindex  = word(pdfidx,fd)
         left   = strip(left)
         right  = strip(right)
         top    = strip(top)
         bottom = strip(bottom)
         if left   = null then left   = mleft
         if right  = null then right  = mright
         if top    = null then top    = mtop
         if bottom = null then bottom = mbottom
         if metric = "C" then marg =  "Centimeters"
                          else marg = "Inches"
         if metric = "C" then     do
            top    = top    * 0.3937
            bottom = bottom * 0.3937
            left   = left   * 0.3937
            right  = right  * 0.3937
            end
         pdf_count = pdf_count + 1
         mlq = time('s') + random(1000) + random(10000)
         mlq = mlq"."jobid
         pdf_in  = "'"hlq".PW"pdf_count".X"mlq".txt'"
         pdf_out = "'"hlq".PW"pdf_count".X"mlq".pdf'"
         call msg "off"
         Address TSO
         "Delete" pdf_in
         "Delete" pdf_out
         lrec = 0
         do flr = 1 to in.0
            if length(in.flr) > lrec
               then lrec = length(in.flr)
            if length(in.flr) = 0
               then in.flr = " "
            end
         vbytes = 0
         do bytecnt = 1 to in.0
            vbytes = vbytes + length(in.bytecnt)
            end
         vlrec = vbytes % in.0
         trpt = 28000%vlrec
         tpri = (in.0%trpt) + 1
         tsec = (tpri%10) + 1
         dsn_cc = right(sysrecfm,1)
         if pos(dsn_cc,"AM") = 0 then dsn_cc = null
         "Alloc f("eddd") ds("pdf_in") new" ,
             "Spa("tpri+tsec","tsec") Tracks" ,
             "Recfm(V B" dsn_cc") lrecl("lrec+8")" ,
             "Blksize(0) reuse"
         "Execio * diskw" eddd "(Finis stem in."
         "Free f("eddd")"
         if left(pdf,3) <> "CON" then do
            if left <> null then
               pdf = pdf "LM" left
            if right <> null then
               pdf = pdf "RM" right
            if top <> null then
               pdf = pdf "TM" top
            if bottom <> null then
               pdf = pdf "BM" bottom
            if pindex <> null then
               pdf = pdf "OUTLINE RC/"pindex
            if do_cc = 1 then
               pdf = pdf "CC Yes"
            if hlq <> null then
               pdf = pdf "HLQ "hlq
            end
         if confirm = null then do
            say msgid " "
            tmsgid = msgid "TXT2PDF:"
            if txt2pdf_parms = "" ,
            then nop
            else do;
                     say tmsgid "parms: "txt2pdf_parms
                     if _txt2pdf_compress_ = null ,
                     then nop
                     else pdf = pdf ,
                                "COMPRESS "_txt2pdf_compress_ ,
                                ""
                     if _txt2pdf_xlate_    = null ,
                     then nop
                     else pdf = pdf ,
                                "XLATE    "_txt2pdf_xlate_    ,
                                ""
                     pdf = strip(pdf)
                 end;
            say tmsgid "txt2pdf IN" pdf_in
            say tmsgid "OUT" pdf_out
            say tmsgid pdf
            end
         say msgid " "
         _rcode_ = sub_txt2pdf("txt2pdf in "pdf_in" out "pdf_out" "pdf)
         if _rcode_ = 0 then do
            "Alloc f("eddd") ds("pdf_out") shr reuse"
            drop in.
            "Execio * diskr" eddd "(Finis stem in."
            "Free f("eddd")"
            "Delete" pdf_in
            "Delete" pdf_out
            Address ISPExec
            type = "Binary"
            end
         else do
              if _rcode_ = -3 ,
              then do;
                      say msgid " "
                      say msgid "Command TXT2PDF not found."
                   end;
              say msgid " "
              say msgid "Error in Text-to-PDF processing".
              say msgid " "
              "Free f("eddd")"
              "Delete" pdf_in
              "Delete" pdf_out
              _x_ = sub_set_zispfrc("8")
              end
         return

        /* ----------------------------------------------------- */
        /* Do_HTML:                                              */
        /* Convert the input file into HTML format.              */
        /* ----------------------------------------------------- */
         Do_HTML:
         html_count = html_count + 1
         mlq = time('s') + random(1000) + random(10000)
         mlq = mlq"."jobid
         html_in = "'"hlq".hw"html_count".X"mlq".txt'"
         html_out = "'"hlq".hw"html_count".X"mlq".html'"
         call msg "off"
         Address TSO
         "Delete" html_in
         "Delete" html_out
         lrec = 0
         do flr = 1 to in.0
            if length(in.flr) > lrec
               then lrec = length(in.flr)
            if length(in.flr) = 0
               then in.flr = " "
            end
         vbytes = 0
         do bytecnt = 1 to in.0
            vbytes = vbytes + length(in.bytecnt)
            end
         vlrec = vbytes % in.0
         trpt = 28000%vlrec
         tpri = (in.0%trpt) + 1
         tsec = (tpri%10) + 1
         dsn_cc = right(sysrecfm,1)
         if pos(dsn_cc,"AM") = 0 then dsn_cc = null
         "Alloc f("eddd") ds("html_in") new" ,
             "Spa("tpri+tsec","tsec")" ,
             "Recfm(V B" dsn_cc") lrecl("lrec+8")" ,
             "Blksize(0) reuse"
         "Execio * diskw" eddd "(Finis stem in."
         "Free f("eddd")"
         htmlv = null
         if html_fsize <> null then
            htmlv = htmlv "Font" html_fsize
         if html_color <> null then
            htmlv = htmlv "Color" html_color
         if do_cc = 1 then
            htmlv = htmlv "CC Yes"
         if banner <> null then
            htmlv = htmlv "BANNER Yes"
         if html_cfg <> null then
            htmlv = htmlv "CONFIG" html_cfg
         if html_table <> null then
            htmlv = htmlv "TABLE"
         if html_head <> null then do
            if translate(left(html_head,1)) = "N" then
               htmlv = htmlv "NOHEADER"
            end
         if html_wrap <> null then
            htmlv = htmlv "WRAP"
         if html_semi =  null then do ;
            select ;
              when ( codepage = "01141" ) ,
              then do ;
                      html_semi = "SEMI"
                      html_cp = ""
                      html_cp = html_cp"CODEPAGE "strip(codepage)
                      html_cp = html_cp"-"sp_chars
                      htmlv = htmlv" "html_cp
                   end;
              otherwise nop ;
            end;
         end;
         if html_semi <> null then
            htmlv = htmlv "SEMICOLON"
         if charuse /= 1    then ,
            htmlv = htmlv" ENCODE YES"
         if confirm <> null then
            htmlv = htmlv "NOCONFIRM"
         else say " "
         t_desc = word(filedesc,fd)
         if t_desc = null then do
            t_desc = word(file,fd)
            if left(t_desc,1) = "'" then
               t_desc = substr(t_desc,2,length(t_desc)-2)
            end
         if t_desc <> null then
            if t_desc <> "x" then do
               t_desc = fix_symbolics(t_desc)
               htmlv = htmlv "TITLE" t_desc
               end

        /* --------------------------------- */
        /* Call the TXT2HTML conversion exec */
        /* --------------------------------- */
         "txt2html in" html_in ,
            "out" html_out htmlv

         "Alloc f("eddd") ds("html_out") shr reuse"
         drop in.
         "Execio * diskr" eddd "(Finis stem in."
         "Free f("eddd")"
         "Delete" html_in
         "Delete" html_out
         Address ISPExec
         type = "HTML"
         return

        /* ----------------------------------------------------- */
        /* Do_RTF                                                */
        /* Convert the input file into Rich Text Format (RTF)    */
        /* ----------------------------------------------------- */
         Do_RTF:
         if format_all = 1 ,
            then margins = word(margin,1)
            else margins = word(margin,fd)
         rtf_count = rtf_count + 1
         mlq = time('s') + random(1000) + random(10000)
         mlq = mlq"."jobid
         rtf_in = "'"hlq".rw"rtf_count".X"mlq".txt'"
         rtf_out = "'"hlq".rw"rtf_count".X"mlq".rtf'"
         call msg "off"
         Address TSO
         "Delete" rtf_in
         "Delete" rtf_out
         lrec = 0
         do flr = 1 to in.0
            if length(in.flr) > lrec
               then lrec = length(in.flr)
            if length(in.flr) = 0
               then in.flr = " "
            end
         vbytes = 0
         do bytecnt = 1 to in.0
            vbytes = vbytes + length(in.bytecnt)
            end
         vlrec = vbytes % in.0
         trpt = 28000%vlrec
         tpri = (in.0%trpt) + 1
         tsec = (tpri%10) + 1
         dsn_cc = right(sysrecfm,1)
         if pos(dsn_cc,"AM") = 0 then dsn_cc = null
         "Alloc f("eddd") ds("rtf_in") new" ,
             "Spa("tpri+tsec","tpri") tr" ,
             "Recfm(V B" dsn_cc") lrecl("lrec+8")" ,
             "Blksize(0) reuse"
         "Execio * diskw" eddd "(Finis stem in."
         "Free f("eddd")"
         if fmt1 = "ZIPRTF" then
            rtfops = translate(fmt3"*"fmt4"*"fmt5"*"fmt6)
         else
            rtfops = translate(fmt2"*"fmt3"*"fmt4"*"fmt6)
         parse value rtfops with rtf1"*"rtf2"*"rtf3"*"rtf4

         rtfv = null
         fmt1 = fmt1 /* debug */
         _junk_ = wordpos(left(fmt1,3),"ZIP")
         Select ;
           when ( charuse      <> 0     ) then _do_encoding_ = "NO"
           when ( left(fmt1,3) =  "ZIP" ) then _do_encoding_ = "NO"
           when ( encoding     /= ""    ) then _do_encoding_ = "YES"
           otherwise                           _do_encoding_ = "NO"
         end;

         if left(rtf1,3) = "DS:" then do
            parse value rtf1 with "DS:"cds
            rtfv = "CONFIG" cds
            end
         if left(rtf1,3) = "DD:" then do
            rtfv = "CONFIG" rtf1
            end
         if rtfv = null then do
            if left(rtf1,1) = "L" ,
               then rtfv = "ORIENT L"
               else rtfv = "ORIENT P"
            if rtf2 <> null then
               rtfv = rtfv "FONT" rtf2
            if rtf3 <> null ,
            then rtfv = rtfv "PAPER" rtf3
       /*   else rtfv = rtfv "PAPER "paper_size   */
            if abbrev("YES",translate(rtf4),1) = 1 then
               rtfv = rtfv "READONLY"
            if do_cc = 1 then
               rtfv = rtfv "CC"
            if length(margins) > 0 then
               rtfv = rtfv "MARGINS" margins
            if confirm <> null then
               rtfv = rtfv "NOCONFIRM"
            if metric = "C" then
               rtfv = rtfv "METRIC"
            end
         nortfx_save = nortfx
         if _do_encoding_ = "NONO" ,
         then nortfx = "off"
         if nortfx = "off" then
            rtfv = rtfv " NORTFXLATE"
         nortfx = nortfx_save
         say msgid " "
         "txt2rtf" rtf_in rtf_out rtfv
         if rc = 0 then do
            "Alloc f("eddd") ds("rtf_out") shr reuse"
            drop in.
            "Execio * diskr" eddd "(Finis stem in."
            "Free f("eddd")"
            "Delete" rtf_in
            "Delete" rtf_out
            end
         else do
              say msgid " "
              say msgid "Error in Text-to-RTF processing".
              say msgid " "
              "Free f("eddd")"
              "Delete" rtf_in
              "Delete" rtf_out
              _x_ = sub_set_zispfrc("8")
              end

         if _do_encoding_ = "YES" ,
         then do ;
                 do _idx_ = 1 to in.0
                    _enctype_ = "RTF"
                    in._idx_ = sub_encode_data(in._idx_)
                 end
              end;
         _do_encoding_ = ""
         Address ISPExec
         type = "RTF"
         return

        /* ----------------------------------------------------- */
        /* Do_CC routine.                                        */
        /* Update output line in attachments for printing on     */
        /* ascii printers.  Converts ASA carriage control or     */
        /* Machine carriage control accordingly.                 */
        /* ----------------------------------------------------- */
         Do_CC:
         Select
            when left(in.i,1) = " " then
                 in.i = substr(in.i,2)
            when left(in.i,1) = "1" then do
                    in.i = substr(in.i,2)
                 end
            when left(in.i,1) = "0" then do
                 call do_cc_add
                 in.i = substr(in.i,2)
                 end
            when left(in.i,1) = "+" then do
                 ip = i - 1
                 i1 = in.ip
                 l1 = length(i1)
                 i2 = substr(in.i,2,length(in.i))
                 in.i = i2
                 maxl = max(l1,length(i2))
                 if i1 <> i2 then
                    i1 = left(i1,maxl,' ')
                    do c = 1 to maxl
                       c1 =  substr(i2,c,1)
                       if substr(i1,c,1) = " " then
                          i1 = overlay(c1,i1,c)
                       end
                 out.n = i1
                 skip_record = 1
                 end
            when left(in.i,1) = "-" then do
                 call do_cc_add
                 call do_cc_add
                 in.i = substr(in.i,2)
                 end
            /* Machine Carriage Control by ISOS */
            when left(in.i,1) = '01'x then    /* before 1           */
                 in.i = substr(in.i,2)
            when left(in.i,1) = '03'x then    /* before 1           */
                 in.i = substr(in.i,2)
            when left(in.i,1) = '09'x then    /* before 1           */
                 in.i = substr(in.i,2)
            when left(in.i,1) = '0B'x then    /* before 1           */
                 in.i = substr(in.i,2)
            when left(in.i,1) = '89'x then   /* Before Top of page */
                    in.i = substr(in.i,2)
            when left(in.i,1) = '8B'x then    /* Before Top of page */
                    in.i = substr(in.i,2)
            when left(in.i,1) = '11'x then do /* Before 2           */
                 call do_cc_add
                 in.i = substr(in.i,2)
                 end
            when left(in.i,1) = '13'x then do /* Before 2           */
                 call do_cc_add
                 in.i = substr(in.i,2)
                 end
            when left(in.i,1) = '19'x then do /* Before 3           */
                 call do_cc_add
                 call do_cc_add
                 in.i = substr(in.i,2)
                 end
            when left(in.i,1) = '1B'x then do /* Before 3           */
                 call do_cc_add
                 call do_cc_add
                 in.i = substr(in.i,2)
                 end
            otherwise do
                      call do_cc_add
                      in.i = substr(in.i,2)
                      end
            end
          return

        /* -------------------------- */
        /* Add blank line             */
        /* -------------------------- */
          Do_CC_Add:
             out.0 = out.0 + 1
             n = out.0
             out.n = "    "
             return

        /* ----------------------------------------------------- */
        /* Process the AddressFile/AddressFileDD data            */
        /* ----------------------------------------------------- */
         Process_Address_File:
         use_address = null
         address = strip(address)
         if left(address,1) = "*" then
            if length(address) > 1
               then use_address = 1
               else address = null
         addr_cnt = 0
         do i = 1 to addr.0
            parse value addr.i with w1 waddr
            if pos("<",waddr) = 0 then
               if length(append_domain) > 0 then do
                  c_hit = 0
                  do cat = 1 to length(atsign)
                     if pos(substr(atsign,cat,1),waddr) > 0 then
                        c_hit = 1
                  end
                  if c_hit = 0 then
                     waddr = waddr""atsignc""append_domain
               end
            call process_address waddr
            waddr = t_addrs
            w1 = translate(word(addr.i,1))
            if left(w1,1) = "*" then iterate
            Select
              when left(waddr,1) = '"' then do
                   pl   = pos(">",waddr)
                   if pl > 0 then
                      xaddr = left(waddr,pl)
                   else xaddr = waddr
                   end
              when left(waddr,1) = "'" then do
                   pl   = pos(">",waddr)
                   if pl > 0 then
                      xaddr = left(waddr,pl)
                   else xaddr = waddr
                   end
              otherwise xaddr = waddr
              end
            if pos("<",xaddr) = 0 then
               naddr = null
            else
               parse value waddr with naddr "<" xaddr ">"
            Select
              When w1 = "TO"   then nop
              When w1 = "CC"   then nop
              When w1 = "BCC"  then nop
              When w1 = "FROM" then nop
              When w1 = "REPLYTO" then nop
              When w1 = "TO:"  then w1 = "TO"
              When w1 = "CC:"  then w1 = "CC"
              When w1 = "BCC:" then w1 = "BCC"
              When w1 = "FROM:"    then w1 = "FROM"
              When w1 = "REPLYTO:" then w1 = "REPLYTO"
              otherwise do
                        addr_cnt = addr_cnt + 1
                        say msgid "Invalid addressfile entry:" ,
                                  addr.i
                        say msgid "Entry must begin with TO, CC,",
                                  "BCC, FROM, REPLYTO or an *",
                                  "for a comment."
                        end
              end
            if w1 = "TO" then
               if use_address = 1 then w1 = "CC"
            Select
               when w1 = "TO" then do
                    w  = words(address) + 1
                    address = address xaddr
                    address_n.w = strip(naddr)
                    end
               when w1 = "CC" then do
                    w  = words(cc) + 1
                    cc = cc xaddr
                    cc_n.w = strip(naddr)
                    end
               when w1  = "BCC" then do
                    w   = words(bcc) + 1
                    bcc = bcc xaddr
                    end
               when w1 = "FROM" then do
                    if from = null ,
                       then do
                            wopt = w1 waddr
                            call proc_froma translate(wopt)
                            end
                       else do
                            Say msgid "FROM address found in" ,
                                      "AddressFile ignored"
                            Say msgid "as FROM also specified" ,
                                      "in the XMITIP command."
                            end
                    end
               when w1 = "REPLYTO" then do
                    if replyto = null ,
                       then do
                            wopt = w1 waddr
                            call proc_replytoa translate(wopt)
                            end
                       else do
                            Say msgid "REPLYTO address found in" ,
                                      "AddressFile ignored"
                            Say msgid "as REPLYTO also specified" ,
                                      "in the XMITIP command."
                            end
                    end
               otherwise nop
               end
            end
            if addr.0 - addr_cnt = 0 then do
               say msgid "Error: No valid addresses found in",
                         "the address file."
               say msgid "Terminating processing..."
               _x_ = sub_set_zispfrc("8")
               end
            address = strip(address)
            cc      = strip(cc)
            bcc     = strip(bcc)
            Return

        /* -------------------------------------------------------- */
        /* RFC_MaxLrecl routine will be called if the lrecl exceeds */
        /* 998.  Based on the value in rfc_maxreclen a this will be */
        /* ignored (0), issue a warning message and continue (1),   */
        /* or issue an error message and end (2).                   */
        /* -------------------------------------------------------- */
         rfc_maxlrecl:
         Select
           When rfc_maxreclen = 0 then return
           When rfc_maxreclen = 1 then do
               if rfc_warn <> null then return
               rfc_warn = 1
               say msgid "Warning: The largest record processed has"
               say msgid "exceeded the maximum record allowed by the"
               say msgid "SMTP standard of 998. Some mail clients may"
               say msgid "not support records greater than 998."
               say msgid "The current max is:" save_lrecl
               say msgid "Process is continuing....."
               return
               end
           When rfc_maxreclen = 2 then do
               say msgid "Error: The largest record processed has"
               say msgid "exceeded the maximum record allowed by the"
               say msgid "SMTP standard of 998. The current max is:" ,
                         save_lrecl
               say msgid "Process is now terminating....."
               _x_ = sub_set_zispfrc("8")
               end
           otherwise return
           end

        /* ----------------------------------------------------- */
        /* If lrecl > 1024 then exit with error message          */
        /* because of the IBM TCP/IP SMTP Server Limitation      */
        /* ----------------------------------------------------- */
        big_lrecl:
           say msgid "Error: The IBM TCP/IP SMTP Server does not"
           say msgid "support data that is larger than lrecl 1024. The"
           say msgid "lrecl calculated so far is:" save_lrecl
           say msgid "Process is now terminating....."
           _x_ = sub_set_zispfrc("8")

        /* ===================================================== */
        /* Procedure:     Base64      : Sends binary data after  */
        /*                            : converting to base64.    */
        /* ===================================================== */
        do_Base64:
          bdd = "X"right(time('l'),2)""right(time('l'),4)
          space = (in.0 * save_lrecl)%34000
          space = space + 30
          space = space","space
          if left(fmt1,3) = "ZIP" then do
             zipbasei = file_dsn
             "Alloc f("bdd") ds("zipbasei") shr"
             drop in.
             "Execio * diskr" bdd "(finis stem in."
             "Free f("bdd")"
             end
          x_rc = sub_encodexm() ;
          if x_rc <> 0 then do
             if x_rc = 999 ,
             then do ;
                   _rcode_ = 20
                   _t_ = "----- "copies("- ERROR - ",5)" -----"
                   _x_ = gol_header(""_t_"") ;
                   _t_ = "Error calling encoding routine ENCODEXM.",
                         "Return code:" x_rc
                   _x_ = gol(msgid" "_t_""); _t_ = "" ;
                   _t_ = "Program ENCODEXM must be provided",
                         "i.e. via LINKLIST or STEPLIB."
                   _x_ = gol(msgid" "_t_""); _t_ = "" ;
                   _t_ = "Please check your environment:"
                   _x_ = gol(msgid" "_t_""); _t_ = "" ;
                   _t_ = "Terminating (rcode="_rcode_")."
                   _x_ = gol(msgid" "_t_""); _t_ = "" ;
                   _x_ = exit_msg(""_rcode_" NOMSG")
                  end;
             else do ;
                   _rcode_ =  8
                   say msgid "Error in mime encoding routine." ,
                             "Return code:" x_rc
                   say msgid "Terminating (rcode="_rcode_")."
                   say msgid "Contact your XMITIP Support."
                  end;
             _x_ = sub_set_zispfrc(_rcode_)
             end
          call msg 'off'
          if left(fmt1,3) = "ZIP" then
            "Del" zipbasei
          b64o = out.0 + 0
          bytes = save_bytes
          do b64 = 1 to encode.0
             b64o = b64o + 1
             out.b64o = encode.b64
             bytes = bytes + length(encode.b64)
             end
          out.0 = b64o
          drop encode.
          call test_limit
          return

        /* ----------------------------------------------------- */
        /* Process Address                                       */
        /* ----------------------------------------------------- */
        Process_Address: Procedure Expose (global_vars) ,
                                          t_names. t_addrs atsign
        parse arg address

        /* ----------------------------------------------------- */
        /* Remove parens                                         */
         if left(address,1) = "(" then
            parse value address with "(" address
         if right(address,1) = ")" then
            parse value address with address ")"
         address = strip(address)
         address = translate(address,' ',',')

        /* ----------------------------------------------------- */
        /* Test for parenthesis                                  */
          parens = 0
          if pos("(",address) > 1 then parens = 1
          if pos(")",address) > 1 then parens = 1
          if parens = 1 then do
             say msgid "Error in address:" address
             say msgid "                   includes '(' or ')'"
             say msgid "                   which is invalid"
             _x_ = sub_set_zispfrc("8")
             end

        /* ----------------------------------------------------- */
        /* set up our variables                                  */
         t_addrs   = null
         t_names.  = null
         t_names.0 = 0
         tn = 0

        /* ----------------------------------------------------- */
        /* Now process thru the provided address                 */
        /* ----------------------------------------------------- */
        do until length(address) = 0
              Select
                /* -------------------------------------------------- */
                /* No name just an address in <>                      */
                /* e.g. <first.last@address>                          */
                when left(address,1) = '<' then do
                     tn = tn + 1
                     parse value address with "<" addr ">" address
                     t_addrs = t_addrs addr
                     address = strip(address)
                     end
                /* -------------------------------------------------- */
                /* quoted address                                     */
                /* e.g. "first last"@address                          */
                /* note: replace blanks with x'01' for now            */
                when pos('"'atsign,address) > 0 then do
                     parse value address with '"'addr'"'addrh address
                     addr = translate(addr,x2c("01"),' ')
                     t_addrs = t_addrs '"'addr'"'addrh
                     address = strip(address)
                     end
                /* -------------------------------------------------- */
                /* double quotes                                      */
                /* e.g. "first last" <first.last@address>             */
                when left(address,1) = '"' then do
                     right = pos(">",address)
                     if right = 0 then ,
                        if pos("<",address) > 1 ,
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
                /* -------------------------------------------------- */
                /* single quotes                                      */
                /* e.g. 'first last' <first.last@address>             */
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
                 * No name just an address without <>                 *
                 * e.g. first.last@address                            */
                when left(address,1) /= '<' then do
                     tn = tn + 1
                     parse value address with addr address
                     t_addrs = t_addrs addr
                     address = strip(address)
                     end
                /* ---------------------------------------------------*/
                /* Only 1 word so must be an address                  */
                when pos(">",address) = 0 then do
                     tn = tn + 1
                     t_addrs = t_addrs address
                     address = null
                     end
                /* ---------------------------------------------------*/
                /* Only 1 word so must be an address                  */
                when words(address) = 1 then do
                     tn = tn + 1
                     t_addrs = t_addrs address
                     address = null
                     end
                /* ---------------------------------------------------*/
                /* otherwise assume name with no quotes               */
                /* e.g. first last <first.last@address>               */
                otherwise do
                     right = pos(">",address)
                     data = left(address,right)
                     address = substr(address,right+1)
                     address = strip(address)
                     tn = tn + 1
                     parse value data with t_names.tn "<" .
                     parse value data with . "<" addr ">" .
                     t_addrs = t_addrs address
                     end
                end
              end
              t_names.0 = tn
              return

        /* ----------------------------------------------------- */
        /* Create_file: create a file attachment using ISPF      */
        /*              Edit                                     */
        /* ----------------------------------------------------- */
         Create_File:
            if _sysispf_ <> "ACTIVE" then do
               say msgid "* specified for attachment data set," ,
                         "but ISPF is not active."
               say msgid "Try again when under ISPF."
               _x_ = sub_set_zispfrc("8")
               end

            parse value t with cr1 "/" cr2 "/" .

            Select
              When cr1 = "ICAL" then do
                   cs = "text"
                   enrich = "calendar"
                   end
              When abbrev("HTML",cr2,3) = 1
               then do
                    cs = "HTML"
                    enrich = "html"
                    end
               otherwise do
                    cs = "TXT"
                    enrich = "plain"
                    end
                    end
            create_suf = "XMIT"right(time('l'),4)"."cs
            create_dsn = hlq"."create_suf
            create_dsn = "'"create_dsn"'"
            Address TSO,
              "Alloc ds("create_dsn") new spa(15,90) tr",
                 "Recfm(v b) lrecl("create_dsn_lrecl")" ,
                 "blksize(9004)",
                 "Unit("vio") f("eddd")"
            if enrich = "calendar" then do
                Address ISPExec
               "Control Display Save"
               "Display Panel(xmitipcc)"
               e_rc = rc
               "Control Display Restore"
               if icdur = 0 then ictype = "VTODO"
                            else ictype = "VEVENT"
               if e_rc = 0 then do
                  ical.1 = "BEGIN:VCALENDAR"
                  ical.2 = "METHOD:Publish"
                  ical.3 = "VERSION:2.0"
                  ical.4 = "PRODID:-//XMITIP" ver"//NONSGML zOS E-Mail//EN"
                  ical.5 = "BEGIN:"ictype
                  stamp_time = time('n')
                  parse value stamp_time with hh":"mm":"ss
                  stamp_time = right(hh+100,2)right(mm+100,2)"00"
                  ical.6 = "DTSTAMP:"date('s')"T"stamp_time
                  ical.7 = "SEQUENCE:0"
                  icfpos = pos(atsign,from)
                  icfrom = left(from,icfpos-1)
                  icfrom = translate(icfrom," ",".")
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
                  ictm   = right(ictm+10000,4)
                  if icdur = 0 then
                     ical.9 = "DTSTART:"sicdate
                     else
                     ical.9 = "DTSTART:"sicdate"T"ictm
                  if datatype(right(icdur,1)) = "NUM" then
                     icdur = icdur"M"
                  ical.10 = "SUMMARY:"ictitle
                  icalc = 10
                  if ictype = "VEVENT" then do
                     icalc = icalc + 1
                     ical.icalc= "DURATION:PT"icdur
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
                  "Execio * diskw" eddd "(finis stem ical."
                  drop ical.
                  end
               end
            else do
                 if enrich = "html" then do
                    o.1 = "<html><body><pre>"
                    "Execio * diskw "eddd" (finis stem o."
                    o. = null
                    end
                 Address ISPExec
                 save_tenter = tenter
                 tenter = null
                 "Vput (tenter enrich)"
                 edtitle = "XMITIP Attachment"
                 "Control Display Save"
                 "Edit Dataset("create_dsn") Macro(xmitipem)" ,
                    "profile(xmitip) Panel(xmitiped)"
                 e_rc = rc
                 "Control Display Restore"
                 tenter = save_tenter
                 "Vput tenter"
                 end
            Address TSO
                "Free ds("create_dsn")"
            create_dsns = create_dsns create_dsn
            if e_rc > 3 then do
               say msgid "Ending per your request."
               _x_ = sub_set_zispfrc(e_rc)
               end
            return

        /* ------------------------------------- */
        /* Add the iCalendar Description records */
        /* ------------------------------------- */
         Add_iCal: procedure expose (global_vars) ,
                                    icalc ical. dateformat
           parse arg data
           icalc = icalc + 1
           ical.icalc = " "data
           return

        /* -------------------------------------- */
        /* Process input into TSO Transmit (XMIT) */
        /* -------------------------------------- */
         Do_XMIT:
         xmtout  = "'"hlq".xmitwork."eddd".XMIT'"
         call msg "off"
         if empty_ds = 1 then do
            "Free f("file_ddn")"
            "Alloc f("file_ddn") new spa(1,1) tr" ,
                  "recfm(v b) lrecl(80) blksize(0)" ,
                  "unit("vio")"
            "Execio * diskw" file_ddn "(finis stem in."
            end
         drop in.
         if mh_type = "dsn" ,
            then "XMIT x.y ds("file_dsn") outds("xmtout") nolog" ,
                 "SYSOUT("nullsysout") nonotify noepilog"
            else "XMIT x.y dd("file_ddn") outds("xmtout") nolog" ,
                 "SYSOUT("nullsysout") SEQ nonotify noepilog"
         "Alloc f("eddd") ds("xmtout") shr reuse"
         drop in.
         "Execio * diskr" eddd "(finis stem in."
         "Free  f("eddd")"
         "Delete" xmtout
         return

        /* ----------------------------------------------------- */
        /* Do ZIP routine...........                             */
        /* ----------------------------------------------------- */
         Do_Zip:
         zipcount = zipcount + 1
         wtime    = right(time('s') + 10000,4)
         zip_dsn  = "'"hlq".ZIPw.zip"zipcount"."jobid".T"wtime".ZIP'"
         if zip_method = null then method = "*"
                              else method = zip_method
         if zippass  = null then password = "*"
                            else password = zippass
         if z_type   = null then z_type   = "ZIP"
         if zip_load = null then zip_load = "*"
         if hlq      = null then hlq      = "*"
         Address TSO
         "xmitipzp" translate(file_dsn zip_dsn) ,
                    translate(zip_type zip_load) ,
                    z_type fmt2l password ,
                    method zip_unit hlq debug
         e_rc = rc
         "Delete" zipwork
         if e_rc > 0 then do
            call msg 'off'
            "Delete" file_dsn
            "Delete" zip_dsn
            call msg 'on'
            _rcode_ = 8
            say msgid "Error in zip processing for:" save_file_dsn
            _x_ = sub_set_zispfrc(_rcode_)
            end
         file_dsn = zip_dsn
         Address ISPExec
         if e_rc <> 0 then do
            _rcode_ = 8
            say msgid "Error reading generated zip file:" file_dsn
            _x_ = sub_set_zispfrc(_rcode_)
            end
         return

        /* ----------------------------------------------------- */
        /* Fix up the color specified.......                     */
        /* ----------------------------------------------------- */
         Fix_Color: Procedure Expose (global_vars) ,
                                     basl
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
                        say msgid "Color specified:" color ,
                                  "is not a valid color. -",
                                  "Will use default colors."
                        say msgid "Valid colors are:"
                        say msgid "Color      Abbrev   Color     Abbrev"
                        say msgid "Aqua       A        Navy      N     "
                        say msgid "Black      Bla      Olive     O     "
                        say msgid "Blue       Blu      Purple    P     "
                        say msgid "Fuchsia    F        Red       R     "
                        say msgid "Gray      Gra       Silver    S     "
                        say msgid "Green     Gre       Teal      T     "
                        say msgid "Lime      L         White     W     "
                        say msgid "Maroon    M         Yellow    Y     "
                        end
              end
            return newcolor

            /*
             * ========================================================
             * Routine:       RTFXlate    : Escapes characters within
             *                            : text
             * Arguments:     strData     : Data to scan
             * Return:        strData     : Updated data
             * Exposed vars:  (all)       : All
             * ========================================================
             */
            RTFXlate:
            PARSE ARG strData

              /* ======================================================
               * The characters we need to escape
               */
              strFrom = brcl""brcr""basl

              /* ======================================================
               * Loop, prefixing all above characters with a
               * a backslash
               */
              strOut = null
              DO UNTIL numPos = 0
                numPos =  Verify( strData, strFrom, "Match" )
                IF numPos <> 0 THEN DO
                  strChar = Substr( strData, numPos, 1 )
                  PARSE VAR strData strLeft (strChar) strData
                  strOut = strOut""strLeft""basl""strChar
                 END
               END
               strOut = strOut""strData

               /* =====================================================
                * Return escaped data
                */
             RETURN strOut

        /* ----------------------------------------------------- *
         * Exit message if an error.                             *
         * ----------------------------------------------------- */
      exit_8:
        say msgid " "
        say msgid "The requested options are:"
        say msgid save_options
        say msgid " "
        /*FEC 20010423: AtSign Support */
        say msgid "The correct syntax for XMITIP (version)" ver "is: "
        say msgid "%XMITIP user"AtSignC"address"
        say msgid "     or (u1"AtSignC"address u2"AtSignC"address..) "
        say msgid "     or *list-id* "
        say msgid "     or * "
        say msgid "        AddressFile"
        say msgid "        AddressFileDD"
        say msgid "        ASA or MACH or IGNORECC"
        say msgid "        BCC user"AtSignC"address"
        say msgid "     or BCC (u1"AtSignC"add1 u2"AtSignC"add2 ..)"
        say msgid "        CC user"AtSignC"address"
        say msgid "     or CC (u1"AtSignC"add1 u2"AtSignC"add2 ..)"
        say msgid "        CONFIG filename"
        say msgid "     or CONFIGDD ddname"
        say msgid "        CONFMSG Top or Bottom"
        say msgid "        DEBUG"
        say msgid "        EMSG"
        say msgid "        ERRORSTO"
        say msgid "        FILE dsn"
        say msgid "     or FILE (dsn1 dsn2 ...)  "
        say msgid "        FILEDD ddn1"
        say msgid "     or FILEDD (ddn1 ddn2 ...)  "
        say msgid "        FILEDESC file-description "
        say msgid "     or FILEDESC (desc1 desc2 ...)"
        say msgid "        FILENAME filename"
        say msgid "     or FILENAME (file1 file2 ..)"
        say msgid "        FILEO hfs-file-name "
        say msgid "     or FILEO (hfs-file-name1 hfs-file-name2 ..) "
        say msgid "        FOLLOWUP date/time"
        say msgid "        FORMAT options (see the doc)"
        say msgid "        FROM from"AtSignC"address"
        say msgid "        HLQ high-level-qualifier"
        say msgid "        HTML (for MSGDx only)"
        say msgid "        IGNORECC"
        say msgid "        IGNOREENC"
        say msgid "        IGNORESUFFIX"
        say msgid "        IMPORTANCE High Normal or Low"
        say msgid "        LANG default_language"
        say msgid "        MAILFMT HTML or PLAIN"
        say msgid "        MARGIN Lm/Rm/Tm/Bm"
        say msgid "     or MARGIN (Lm/Rm/Tm/Bm Lm/Rm/Tm/Bm ...)"
        say msgid "        MSGDS data-set-name"
        say msgid "     or MSGDS /omvs/file/name"
        if _sysispf_ = "ACTIVE" then
           say msgid "     or MSGDS *"
        say msgid "     or MSGDD ddname or MSGQ"
        say msgid "     or NOMSG (if no MSGDS, MSGDD or MSGQ)"
        say msgid "     or MSGT 'message text' "
        say msgid "        Murphy"
        say msgid "        NOConfirm"
        say msgid "        NOEMpty"
        say msgid "        NORTFXlate"
        say msgid "        NOStrip"
        say msgid "        PAGE 'message text' "
        say msgid "        PDFIDX row/colum/length"
        say msgid "     or PDFIDX (row/colum/length ...)"
        say msgid "        PRIORITY Urgent Normal or Non-Urgent"
        say msgid "        RC0"
        say msgid "        RECEIPT receipt"AtSignC"address"
        say msgid "        REPLYTO reply"AtSignC"address"
        say msgid "        SENSITIVITY Private Personal or Confidential"
        say msgid "        SIG dsname or SIGDD ddname"
        say msgid "        SUBJECT 'subject text' "
        say msgid "        SMTPDEST node.dest or dest"
        say msgid "        TLS On (or Off) "
        say msgid "        ZIPMETHOD zip-compression-method"
        say msgid "        ZIPPASS password for zip files"
        say msgid " "
        _x_ = sub_set_zispfrc("8")

        /* ----------------------------------------------------- */
        /* Exit message if an error - with messages in stem gol. */
        /* ----------------------------------------------------- */
      exit_msg:
         parse arg _all_parms_
         parse var _all_parms_ 1 _rcode_ _more_
         if datatype(_rcode_) = "NUM" ,
         then nop
         else _rcode_ = 12
         _more_ = strip(_more_)
         select;
           when ( _more_ = "NOMSG"  ) then _more_ = null
           when ( _more_ = null     ) then ,
              _more_ = "errors detected - see correlating messages"
           otherwise nop;
         end;

         if _more_ = null ,
         then nop;
         else do;
                 _t_ = ""msgid ""_more_
                 _x_ = gol(_t_) ;
              end;
         _t_ = ""msgid "stops with error code: "_rcode_
         _x_ = gol(_t_) ;
         _t_ = " "
         _x_ = gol(_t_) ;
         do idx = 1 to gol.0
            say gol.idx
         end
         _x_ = sub_set_zispfrc(_rcode_) ;

        /* ----------------------------------------------------- */
        /* Process each keyword here.                            */
        /* As each keyword and parameter are processed they are  */
        /* removed from the variable options.                    */
        /* ----------------------------------------------------- */

        /* -------------------------- */
        /* SUBJECT Keyword            */
        /* -------------------------- */
        Proc_Subject:
           qt = '"'
           if left(word(options,2),1) = "'" then do
              parse value options with x "'" subject "'" .
              qt = "'"
              end
           if left(word(options,2),1) = '"' then do
              parse value options with x '"' subject '"' .
              qt = '"'
              end
           /* now remove subject from options */
           lq = pos(qt,options,1)
           options = overlay(" ",options,lq,1)
           rq = pos(qt,options,1)
           options = strip(delstr(options,1,rq))
           symtype = "S"
           subject = fix_symbolics(subject)
           symtype = null
           if encoding /= "" ,
           then do ;
                subject = strip(subject)
                subject_enc = sub_encode_data(subject) ;
                if subject == subject_enc ,
                   then nop
                   else do ;
                        subject = sub_encode(subject_enc) ;
                        end ;
                end;
           return ;

        /* -------------------------- */
        /* PAGE Keyword               */
        /* -------------------------- */
        Proc_Page:
           qt = '"'
           if left(word(options,2),1) = "'" then do
              parse value options with x "'" page "'" .
              qt = "'"
              end
           if left(word(options,2),1) = '"' then do
              parse value options with x '"' page '"' .
              qt = '"'
              end
           /* now remove PAGE from options */
           lq = pos(qt,options,1)
           options = overlay(" ",options,lq,1)
           rq = pos(qt,options,1)
           options = strip(delstr(options,1,rq))
           symtype = "S"
           page = fix_symbolics(page)
           symtype = null
           return

        /* -------------------------------------------------------- */
        /* CONFIG Keyword.                                          */
        /*                                                          */
        /* Get the Configuration dataset and append the information */
        /* to the existing options variable for parsing.            */
        /* -------------------------------------------------------- */
         Proc_Config:
           cfctr = cfctr + 1
           if cfctr > 20 then do
              say msgid "Error: More than 20 Configuration files" ,
                        "requested."
              say msgid "       Possible recursion error."
              say msgid "       XMITIP is terminating."
              _x_ = sub_set_zispfrc("8")
              end
           config_ds = word(upper_options,2)
           config_files = strip(config_files) "DSN:"config_ds
           options = delword(options,1,2)
           if "OK" <> sysdsn(config_ds) then do
              say msgid "Error:" ,
                        "The specified Configuration Dataset:" config_ds
              say msgid sysdsn(config_ds)
              _x_ = sub_set_zispfrc("8")
              end
           cdd = "cfds"random(999)
           Address TSO
           "Alloc f("cdd") ds("config_ds") shr"
           drop cfo.
           "Execio * diskr" cdd "(finis stem cfo."
           "Free  f("cdd")"
           cf_options = null
           cfcomments = 0
           do cdd = 1 to cfo.0
              if left(cfo.cdd,1) = "*" then do
                 cfcomments = cfcomments + 1
                 iterate
                 end
              cfs = cdd + cfopts - cfcomments
              cfoptions.cfs = cfo.cdd
              cfo_data = strip(left(cfo.cdd,72))
              if right(cfo_data,1) = "+"
                 then cfo_data = left(cfo_data,length(cfo_data)-1)
              if right(cfo_data,1) = "-"
                 then cfo_data = left(cfo_data,length(cfo_data)-1)
              options = options strip(cfo_data)
              cf_options = cf_options strip(cfo_data)
              end
           cfopts = cfopts + cdd - 1 - cfcomments
           cfoptions.0 = cfopts
           return

        /* -------------------------------------------------------- */
        /* Process CONFIGDD keyword                                 */
        /*                                                          */
        /* Get the Configuration dataset and append the information */
        /* to the existing options variable for parsing.            */
        /* -------------------------------------------------------- */
         Proc_ConfigDD:
           cfctr = cfctr + 1
           if cfctr > 20 then do
              say msgid "Error: More than 20 Configuration files" ,
                        "requested. Possible recursion loop."
              say msgid "       XMITIP is terminating."
              _x_ = sub_set_zispfrc("8")
              end
           config_dd = word(upper_options,2)
           config_files = strip(config_files) "DD:"config_dd
           options = delword(options,1,2)
           call listdsi(config_dd "FILE")
           if sysreason+0 <> 3 then
              if sysreason+0 <> 27 then
                 if length(sysdsname) = 0 then do
                    say msgid "Error: The CONFIGDD:" config_dd
                    say msgid "Is invalid - not allocated" ,
                              "correct and retry."
                    _x_ = sub_set_zispfrc("8")
                    end
           Address TSO
           "Execio * diskr" config_dd "(finis stem cfo."
           cf_options = null
           cfcomments = 0
           do cdd = 1 to cfo.0
              if left(cfo.cdd,1) = "*" then do
                 cfcomments = cfcomments + 1
                 iterate
                 end
              cfs = cdd + cfopts - cfcomments
              cfoptions.cfs = cfo.cdd
              cfo_data = strip(left(cfo.cdd,72))
              if right(cfo_data,1) = "+"
                 then cfo_data = left(cfo_data,length(cfo_data)-1)
              if right(cfo_data,1) = "-"
                 then cfo_data = left(cfo_data,length(cfo_data)-1)
              options = options strip(cfo_data)
              cf_options = cf_options strip(cfo_data)
              end
           cfopts = cfopts + cdd - 1 - cfcomments
           cfoptions.0 = cfopts
           return

        /* -------------------------- */
        /* MSGT Keyword               */
        /* -------------------------- */
        Proc_Msgt:
           qt = '"'
           if left(word(options,2),1) = "'" then do
              parse value options with x "'" msgtext "'" .
              qt = "'"
              end
           if left(word(options,2),1) = '"' then do
              parse value options with x '"' msgtext '"' .
              qt = '"'
              end
           /* now remove msgt from options */
           lq = pos(qt,options,1)
           options = overlay(" ",options,lq,1)
           rq = pos(qt,options,1)
           options = strip(delstr(options,1,rq))
           symtype = "S"
           msgtext = fix_symbolics(msgtext)
           symtype = null
           if translate(left(msgtext,5)) = "HTML:" then do
              enrich = "html"
              msgtext = strip(substr(msgtext,6))
              end
           return

        /* -------------------------- */
        /* CC Keyword.                */
        /* 'Carbon Copy' recipients   */
        /*  CC id@node  or            */
        /*  CC (id1@node id2@node ..) */
        /* -------------------------- */
        Proc_cc:
           p2 = wordindex(upper_options,2)
           /* make the word CC upper case */
           options = overlay("CC",options,1,2)
           parse value options with "CC" data
           data = strip(data)
           Select
              when left(data,1) = '"' then do
                   pl   = pos(">",data)
                   cc   = left(data,pl)
                   end
              when left(data,1) = "'" then do
                   pl   = pos(">",data)
                   cc   = left(data,pl)
                   end
              when left(data,1) = '(' then do
                   pl   = pos(")",data)
                   parse value data with "(" cc ")" .
                   end
              otherwise
                   cc = word(data,1)
                   pl   = length(cc)
           end
           ropt = substr(options,p2+pl+1)
           options = strip(ropt)
           if length(cc) = 0 then do
              say msgid "Error encountered in the CC",
                        "There are no CC addresses."
              say msgid "XMITIP Terminating...."
              _x_ = sub_set_zispfrc("8")
              end
           call process_address cc
           cc = t_addrs
           do i = 1 to t_names.0
              cc_n.i = strip(t_names.i)
              end
           return

        /* --------------------------- */
        /* BCC Keyword.                */
        /* 'Blind Carbon Copy'         */
        /*  BCC id@node or             */
        /*  BCC (id1@node id2@node ..) */
        /* --------------------------- */
        Proc_BCC:
           p2 = wordindex(upper_options,2)
           /* make the word BCC upper case */
           options = overlay("BCC",options,1,3)
           parse value options with "BCC" data
           data = strip(data)
           Select
              when left(data,1) = '"' then do
                   pl   = pos(">",data)
                   bcc  = left(data,pl)
                   end
              when left(data,1) = "'" then do
                   pl   = pos(">",data)
                   bcc  = left(data,pl)
                   end
              when left(data,1) = '(' then do
                   pl   = pos(")",data)
                   parse value data with "(" bcc ")" .
                   end
              otherwise
                   bcc = word(data,1)
                   pl   = length(bcc)
           end
           ropt = substr(options,p2+pl+1)
           options = strip(ropt)
           if length(bcc) = 0 then do
              say msgid "Error encountered in the BCC",
                        "There are no BCC addresses."
              say msgid "XMITIP Terminating...."
              _x_ = sub_set_zispfrc("8")
              end
           call process_address bcc
           bcc = t_addrs
           return

        /* -------------------------- */
        /* FROM Keyword.              */
        /* Optional From e-mail       */
        /* address.                   */
        /* -------------------------- */
        Proc_From:
           p2 = wordindex(upper_options,2)
           /* make the word FROM upper case */
           options = overlay("FROM",options,1,4)
           parse value options with "FROM" data
           data = strip(data)
           if length(data) > 0 then
           Select
              when left(data,1) = '"' then do
                   pl   = pos(">",data)
                   from = left(data,pl)
                   end
              when left(data,1) = "'" then do
                   pl   = pos(">",data)
                   from = left(data,pl)
                   end
              when left(data,1) = '(' then do
                   pl   = pos(")",data)
                   parse value data with "(" from ")" .
                   end
              otherwise
                   from = word(data,1)
                   pl   = length(from)
           end
           else do
                pl = 0
                p2 = 4
                end
           ropt = substr(options,p2+pl+1)
           options = strip(ropt)
           if length(data) = 0 then return
           call process_address from
           from = strip(t_addrs)
           if pos("<",from) > 0 then
              parse value from with ."<"fromx">" .
           else fromx = from
           from_n.1 = strip(t_names.1)
           if validfrom = 0 then return
           x = xmitldap()
            parse value x with _s "/" _o "/" _d "/" _w "/"local_nodes ,
                                  "/" _name _mail
            if _s = 0 then return
            xhit = 0
            do x = 1 to words(local_nodes)
               xw = word(local_nodes,x)
               if wordpos(xw,fromx) = 1 then iterate
               xhit = 1
               end
           vf = xmitipid(fromx)
           if vf <> 4 then return
           if xhit = 0 then return
           if validfrom = 1
              then do
                    say msgid "****************************************"
                    say msgid "Error: The FROM e-mail address specified"
                    say msgid "       is INVALID." fromx
                    say msgid " XMITIP is terminating...."
                    say msgid "****************************************"
                    _x_ = sub_logit("Invalid From Address" fromx)
                    _x_ = sub_set_zispfrc("8")
                   end
           if validfrom = 2
              then do
                    _msgtmp = "Warning:",
                              "The FROM e-mail address specified",
                              "is INVALID." fromx
                    say msgid ""copies("*",max(length(_msgtmp),60))
                    say msgid ""_msgtmp
                    say msgid ""copies("*",max(length(_msgtmp),60))
                    _x_ = sub_logit("Invalid From Address" fromx)
                   end
           return

        /* -------------------------- */
        /* FROM Keyword.              */
        /* Processed from an          */
        /* addressfile/addressfiledd  */
        /* -------------------------- */
        Proc_FromA:
           arg ufopt
           parse value ufopt with "FROM" data
           data = strip(data)
           if length(data) > 0 then
           Select
              when left(data,1) = '"' then do
                   pl   = pos(">",data)
                   from = left(data,pl)
                   end
              when left(data,1) = "'" then do
                   pl   = pos(">",data)
                   from = left(data,pl)
                   end
              when left(data,1) = '(' then do
                   pl   = pos(")",data)
                   parse value data with "(" from ")" .
                   end
              otherwise
                   from = word(data,1)
                   pl   = length(from)
           end
           else do
                pl = 0
                end
           ropt = substr(ufopt,pl+1)
           ufopt = strip(ropt)
           if length(data) = 0 then return
           call process_address from
           from = strip(t_addrs)
           if pos("<",from) > 0 then
              parse value from with ."<"fromx">" .
           else fromx = from
           from_n.1 = strip(t_names.1)
           if validfrom = 0 then return
           x = xmitldap()
            parse value x with _s "/" _o "/" _d "/" _w "/"local_nodes
            if _s = 0 then return
            xhit = 0
            do x = 1 to words(local_nodes)
               xw = word(local_nodes,x)
               if wordpos(xw,fromx) = 1 then iterate
               xhit = 1
               end
           vf = xmitipid(fromx)
           if vf <> 4 then return
           if xhit = 0 then return
           if validfrom = 1
              then do
                    say msgid "****************************************"
                    say msgid "Error: The FROM e-mail address specified"
                    say msgid "       is INVALID." fromx
                    say msgid " XMITIP is terminating...."
                    say msgid "****************************************"
                    _x_ = sub_logit("Invalid From Address" fromx)
                    _x_ = sub_set_zispfrc("8")
                   end
           if validfrom = 2
              then do
                    say msgid "******************************************"
                    say msgid "Warning: The FROM e-mail address specified"
                    say msgid "         is INVALID." fromx
                    say msgid "******************************************"
                    _x_ = sub_logit("Invalid From Address" fromx)
                   end
           return

        /* -------------------------- */
        /* ERRORSTO Keyword.          */
        /* Optional Errors-To         */
        /* e-mail address.            */
        /* -------------------------- */
        Proc_ErrorsTo:
           p2 = wordindex(upper_options,2)
           /* make the word ERRORSTO upper case */
           options = overlay("ERRORSTO",options,1,8)
           parse value options with "ERRORSTO" data
           data = strip(data)
           if length(data) > 0 then
           Select
              when left(data,1) = '"' then do
                   pl   = pos(">",data)
                   errorsto = left(data,pl)
                   end
              when left(data,1) = "'" then do
                   pl   = pos(">",data)
                   errorsto = left(data,pl)
                   end
              when left(data,1) = '(' then do
                   pl   = pos(")",data)
                   parse value data with "(" errorsto ")" .
                   end
              otherwise
                   errorsto = word(data,1)
                   pl   = length(errorsto)
           end
           else do
                pl = 0
                p2 = 4
                end
           ropt = substr(options,p2+pl+1)
           options = strip(ropt)
           if length(data) = 0 then return
           call process_address errorsto
           errorsto = strip(t_addrs)
           return

        /* -------------------------- */
        /* LANG Keyword               */
        /* Language Selection         */
        /* -------------------------- */
        Proc_Lang:
           langpos = wordpos("LANG",upper_options)
           lang    = word(upper_options,langpos+1)
           options = delword(options,langpos,2)
           return

        /* -------------------------- */
        /* MSGQ Keyword.              */
        /* Input is from the queue    */
        /* -------------------------- */
        Proc_Msgq:
           options = delword(options,1,1)
           msgq    = 1
           nomsg   = "off"
           msgsub  = "MSGDS: input queue"
           return

        /* ----------------------------------------------------- */
        /* MSG72 keyword                                         */
        /* use first 72 characters of each record                */
        /* ----------------------------------------------------- */
        Proc_Msg72:
           options = delword(options,1,1)
           msg72   = 1
           return

        /* -------------------------- */
        /* MSGDS Keyword.             */
        /* Dataset containing the     */
        /* message to be sent.        */
        /* -------------------------- */
        Proc_MsgDS:
           Select
              When left(dsn,2) <> "'/"
                 then w_dsn = word(options,2)
              When  left(dsn,1) <> "'"
                 then w_dsn = word(options,2)
              Otherwise w_dsn = word(upper_options,2)
              end
           dsn = w_dsn
           options = delword(options,1,2)
           msgsub = "MSGDS:" dsn
           if left(dsn,2) = "*@" then do
              dsn = strip(substr(dsn,3))
              debug = "on"
              if dsn = null then do
                 nomsg = "off"
                 in.0 = 0
                 end
              end
           return

        /* -------------------------- */
        /* MAILFMT Keyword            */
        /* HTML or PLAIN              */
        /* -------------------------- */
        Proc_Mailfmt:
           mft = word(upper_options,2)
           options = delword(options,1,2)
           if mft = 'HTML' then do
              enrich = "html"
              msg_html = 1
              end
           else do
              enrich = "plain"
              msg_html = 0
              end
           return

        /* -------------------------- */
        /* MSGDD Keyword.             */
        /* DDname for message text    */
        /* to be sent.                */
        /* -------------------------- */
        Proc_MsgDD:
           ddn = word(upper_options,2)
           call listdsi(ddn "FILE")
           if sysreason+0 <> 3 then
              if sysreason <> 27 then
           if length(sysdsname) = 0 then do
              say msgid "DDname:" ddn "Invalid - not allocated"
              say msgid "correct and retry."
              _x_ = sub_set_zispfrc("8")
              end
           options = delword(options,1,2)
           msgsub = "MSGDD:" ddn
           msgdd = 1
           return

        /* -------------------------- */
        /* SIG Keyword                */
        /* Dataset containing the     */
        /* message to be sent.        */
        /* -------------------------- */
        Proc_Sig:
           sigdsn = word(upper_options,2)
           options = delword(options,1,2)
           return

        /* -------------------------- */
        /* SIGDD Keyword              */
        /* DDname containing the      */
        /* message to be sent.        */
        /* -------------------------- */
        Proc_SigDD:
           sigddn = word(upper_options,2)
           options = delword(options,1,2)
           return

        /* ------------------------------------------ *
         | Proc_SizeLim routine                       |
         |                                            |
         | Check for the SIZELIM keyword and override |
         | the XMITIPCU Size_Limit value              |
         * ------------------------------------------ */
         Proc_SizeLim:
           size_limit = word(upper_options,2)
           options = delword(options,1,2)
           return

        /* ----------------------------------------------------- *
         | Proc_SMTPCLAS                                         |
         |    Process the over-ride for the default sysout_class |
         * ----------------------------------------------------- */
         Proc_SMTPCLAS:
           sclass  = word(upper_options,2)
           sysout_override = 1
           options = delword(options,1,2)
           sysout_class = sclass
           return

        /* ----------------------------------------------------- *
         | Proc_SMTPDEST                                         |
         |    Process the over-ride for the default smtp_address |
         * ----------------------------------------------------- */
         Proc_SMTPDEST:
           sdest   = word(upper_options,2)
           smtp_address_override = 1
           options = delword(options,1,2)
           if pos('.',sdest) > 0
              then smtp_address = sdest
              else smtp_address = _center_'.'sdest
           return

        /* --------------------- */
        /* TLS Keyword           */
        /*    Enable/Disable TLS */
        /* --------------------- */
        Proc_TLS:
           starttls = word(upper_options,2)
           options = delword(options,1,2)
           if starttls = "ON" then starttls = 1
                              else starttls = 0
           return

        /* --------------------- */
        /* Followup keyword      */
        /*    Followup Date/Time */
        /* --------------------- */
         Proc_FollowUp:
           followup = word(upper_options,2)
           options  = delword(options,1,2)
           parse value followup with fupdate
            if left(fupdate,1) = "+" then do
                sfupdate = substr(fupdate,2)
                d      = date('b') + sfupdate
                sfupdate = date("s",d,"b")
               end
            else do
                 mm = left(fupdate,2)
                 dd = substr(fupdate,3,2)
                 yy = "20"right(fupdate,2)
                 sfupdate = yy""mm""dd
                 end
           fupdate = date('w',sfupdate,'s') date('n',sfupdate,'s')
           return

        /* -------------------------- */
        /* HLQ Keyword                */
        /* hql containing the         */
        /* message to be sent.        */
        /* -------------------------- */
        Proc_hlq:
           hlq = word(upper_options,2)
           options = delword(options,1,2)
           return

        /* -------------------------- */
        /* IDVAL Keyword.             */
        /* Indicates that all e-mail  */
        /* addresses are to be checked*/
        /* Invalid = Failure          */
        /* -------------------------- */
        Proc_IDVal:
           options = delword(options,1,1)
           ldap    = 0
           in.0    = 0
           return

        /* -------------------------- */
        /* IDWARN Keyword.            */
        /* Indicates that all e-mail  */
        /* addresses are to be checked*/
        /* Invalid = Warning          */
        /* -------------------------- */
        Proc_IDWarn:
           options = delword(options,1,1)
           ldap    = 0
           in.0    = 0
           idwarn  = 1
           return

        /* -------------------------- */
        /* NOEMPTY Keyword.           */
        /* Indicates to cancel XMITIP */
        /* on an empty dataset        */
        /* -------------------------- */
        Proc_NoEMpty:
           options = delword(options,1,1)
           empty_opt = 1
           return

        /* -------------------------- */
        /* NOIDVAL Keyword.           */
        /* Indicates that no ID       */
        /* validation is to occur.    */
        /* -------------------------- */
        Proc_NoIDVal:
           options = delword(options,1,1)
           ldap    = 1
           in.0  = 0
           return

        /* -------------------------- */
        /* NOMSG Keyword.             */
        /* Indicates that no MSGDS    */
        /* or MSGDD is specified.     */
        /* -------------------------- */
        Proc_NoMsg:
           options = delword(options,1,1)
           nomsg = "off"
           in.0  = 0
           return

        /* -------------------------- */
        /* NOCONFIRM Keyword.         */
        /* Turn off the confirmation  */
        /* message from this exec.    */
        /* -------------------------- */
        Proc_NoConfirm:
           options = delword(options,1,1)
           confirm = "off"
           return

        /* -------------------------- */
        /* NORTFXlate Keyword.        */
        /* Bypass escape chars in RTF */
        /* -------------------------- */
        Proc_NoRTFXlate:
           options = delword(options,1,1)
           nortfx  = "off"
           return

        /* -------------------------- */
        /* NOSPOOF Keyword.           */
        /* Bypass AntiSpoof maybe     */
        /* -------------------------- */
        Proc_NoSpoof:
           options = delword(options,1,1)
           if disable_antispoof = "Y" ,
              then antispoof = null
              else say msgid "NoSpoof option ignored" ,
                   "per installation defaults."
           return

        /* -------------------------- */
        /* NOSTRIP Keyword.           */
        /* Turn OFF stripping of      */
        /* trailing blanks.           */
        /* -------------------------- */
        Proc_NoStrip:
           options = delword(options,1,1)
           nostrip = "on"
           if smtp_secure = null then do
              say msgid "NoStrip was requested but it will only",
                        "work with Binary, XMIT, or ZIP format",
                        "attachments."
              say msgid " "
              end
           return

        /* ---------------------------------------------- */
        /* CONFMSG                                        */
        /* This allows the user to over-ride the Conf_MSG */
        /* setting in XMITIPCU.                           */
        /*                                                */
        /* Valid values are: Top or Bottom                */
        /* ---------------------------------------------- */
        Proc_CONFMSG:
           confmsg = translate(word(options,2))
           options = delword(options,1,2)
           if wordpos(confmsg,"TOP BOTTOM") > 0 then
              conf_msg = confmsg
           return

        /* -------------------------- */
        /* ASA Keyword.               */
        /* (affects attachments only  */
        /* -------------------------- */
        Proc_ASA:
           options = delword(options,1,1)
           printcc = "on"
           return

        /* -------------------------- */
        /* NOMSGSum Keyword           */
        /* (affects attachments only  */
        /* -------------------------- */
        Proc_NOMSGSUM:
           options = delword(options,1,1)
           msg_summary = 0
           return

        /* -------------------------- *
         * MACH Keyword.              *
         * (affects attachments only  *
         * -------------------------- */
        Proc_Mach:
           options = delword(options,1,1)
           printcc = "on"
           return

        /* -------------------------- *
         * IGNORECC Keyword.          *
         * -------------------------- */
        Proc_ignorecc:
           options = delword(options,1,1)
           ignorecc = "on"
           return

        /* -------------------------- *
         * IGNOREENC Keyword          *
         * -------------------------- */
        Proc_ignoreenc:
           options = delword(options,1,1)
           ignoreenc = "on"
           parse value "" with ,
                 codepage encoding encoding_default
           return

        /* ---------------------------- *
         * TPAGELEN keyword             *
         * Text Page Length override    *
         * ---------------------------- */
        Proc_TPageLen:
           tpagelen = word(options,2)
           options = delword(options,1,2)
           return

        /* ---------------------------- *
         * ZIPMETHOD Keyword            *
         * ZIP method                   *
         * compression form to be       *
         * used for all ZIP attachments *
         * ---------------------------- */
        Proc_ZipMethod:
           zip_method  = word(options,2)
           options = delword(options,1,2)
           return

        /* ---------------------------- *
         * ZIPPASS Keyword              *
         * ZIP Password                 *
         * used for all ZIP attachments *
         * ---------------------------- */
        Proc_ZipPass:
           zippass  = word(options,2)
           options = delword(options,1,2)
           return

        /* ------------------------------------------------ *
         * IGNORESUFFIX Keyword                             *
         *  Used to set the flag so that the user specified *
         *  suffix is used and a format friendly suffix is  *
         *  not appended.                                   *
         * ------------------------------------------------ */
         Proc_Ignore_Suffix:
           options = delword(options,1,1)
           ignore_suffix = 1
           return

        /* -------------------------- *
         * IMPORTANCE Keyword.        *
         * Optional importance        *
         * -------------------------- */
        Proc_Importance:
           importance = word(options,2)
           options = delword(options,1,2)
           test = translate(importance)
           select
             when abbrev("HIGH",test,2)   then importance = "High"
             when abbrev("LOW",test,2)    then importance = "Low"
             when abbrev("NORMAL",test,2) then importance = "Normal"
             otherwise nop;
             end
           test = translate(importance)
           valid_importance = "HIGH LOW NORMAL"
           if wordpos(test,valid_importance) = 0 then do
              say msgid "Invalid IMPORTANCE" importance "specified"
              say msgid "valid values are:" valid_importance
              importance = null
              end
           return

        /* -------------------------- *
         * PRIORITY Keyword.          *
         * Optional priority          *
         * -------------------------- */
        Proc_Priority:
           priority = word(options,2)
           test = translate(priority)
           options = delword(options,1,2)
           select
             when abbrev("URGENT",test,2) then priority = "Urgent"
             when abbrev("HIGH",test,2)   then priority = "Urgent"
             when abbrev("NON-URGENT",test,3) then
                  priority = "Non-Urgent"
             when abbrev("LOW",test,2) then
                  priority = "Non-Urgent"
             when abbrev("NORMAL",test,3) then priority = "Normal"
             otherwise nop;
             end
           test = translate(priority)
           valid_priority = "URGENT NORMAL NON-URGENT"
           if wordpos(test,valid_priority) = 0 then do
              say msgid "Invalid PRIORITY" priority "specified"
              say msgid "valid values are:" valid_priority
              priority = null
              end
           return

        /* -------------------------- *
         * SENSITIVITY Keyword.       *
         * Optional sensitivity       *
         * -------------------------- */
        Proc_Sensitivity:
           sensitivity = word(options,2)
           test = translate(sensitivity)
           options = delword(options,1,2)
           select
             when abbrev("CONFIDENTIAL",test,3) then
                  sensitivity = "Confidential"
             when abbrev("COMPANY-CONFIDENTIAL",test,3) then
                  sensitivity = "Company-Confidential"
             when abbrev("PRIVATE",test,2) then
                  sensitivity = "Private"
             when abbrev("PERSONAL",test,2) then
                  sensitivity = "Personal"
             otherwise nop;
             end
           test = translate(sensitivity)
           valid_sensitivity = "PRIVATE PERSONAL CONFIDENTIAL",
               "COMPANY-CONFIDENTIAL"
           if wordpos(test,valid_sensitivity) = 0 then do
              say msgid "Invalid SENSITIVITY" sensitivity "specified"
              say msgid "valid values are:" valid_sensitivity
              sensitivity = null
              end
           return

        /* -------------------------- *
         * REPLYTO Keyword.           *
         * Optional reply e-mail      *
         * address.                   *
         * -------------------------- */
        Proc_ReplyTo:
           p2 = wordindex(upper_options,2)
           parse value options with x data
           data = strip(data)
           Select
              when left(data,1) = '"' then do
                   pl   = pos(">",data)
                   replyto = left(data,pl)
                   end
              when left(data,1) = "'" then do
                   pl   = pos(">",data)
                   replyto = left(data,pl)
                   end
              when left(data,1) = '(' then do
                   pl   = pos(")",data)
                   parse value data with "(" replyto ")" .
                   end
              otherwise
                   replyto = word(data,1)
                   pl   = length(replyto)
           end
           ropt = substr(options,p2+pl+1)
           options = strip(ropt)
           reply_addrs = null
           do ir = 1 to words(replyto)
           call process_address word(replyto,ir)
           reply_addrs = reply_addrs t_addrs
           end
           /* Comment Start
           replyto = strip(t_addrs)
              Comment End */
           replyto = strip(reply_addrs)
           replyto_n.1 = strip(t_names.1)
           if validfrom = 0 then return
           x = xmitldap()
            parse value x with _s "/" _o "/" _d "/" _w "/"local_nodes
            if _s = 0 then return
            xhit = 0
            do x = 1 to words(local_nodes)
               xw = word(local_nodes,x)
               if wordpos(xw,fromx) = 1 then iterate
               xhit = 1
               end
           vf = xmitipid(replyto)
           if vf <> 4 then return
           if xhit = 0 then return
           if validfrom = 1
              then do
                    say msgid "*******************************************"
                    say msgid "Error: The REPLYTO e-mail address specified"
                    say msgid "       is INVALID." replyto
                    say msgid " XMITIP is terminating...."
                    say msgid "*******************************************"
                    _x_ = sub_logit("Invalid ReplyTo Address" replyto)
                    _x_ = sub_set_zispfrc("8")
                   end
           if validfrom = 2
              then do
                    say msgid "*********************************************"
                    say msgid "Warning: The REPLYTO e-mail address specified"
                    say msgid "         is INVALID." replyto
                    say msgid "*********************************************"
                    _x_ = sub_logit("Invalid ReplyTo Address" replyto)
                   end
           return

        /* -------------------------- *
         * REPLYTO Keyword.           *
         * Processed from a           *
         * addressfile/addressfiledd  *
         * -------------------------- */
        Proc_ReplyToa:
           arg uoptr
           parse value uoptr with x data
           data = strip(data)
           Select
              when left(data,1) = '"' then do
                   pl   = pos(">",data)
                   replyto = left(data,pl)
                   end
              when left(data,1) = "'" then do
                   pl   = pos(">",data)
                   replyto = left(data,pl)
                   end
              when left(data,1) = '(' then do
                   pl   = pos(")",data)
                   parse value data with "(" replyto ")" .
                   end
              otherwise
                   replyto = word(data,1)
                   pl   = length(replyto)
           end
           ropt = substr(uoptr,pl+1)
           uoptr = strip(ropt)
           call process_address replyto
           replyto = strip(t_addrs)
           replyto_n.1 = strip(t_names.1)
           if validfrom = 0 then return
           x = xmitldap()
            parse value x with _s "/" _o "/" _d "/" _w "/"local_nodes
            if _s = 0 then return
            xhit = 0
            do x = 1 to words(local_nodes)
               xw = word(local_nodes,x)
               if wordpos(xw,fromx) = 1 then iterate
               xhit = 1
               end
           vf = xmitipid(replyto)
           if vf <> 4 then return
           if xhit = 0 then return
           if validfrom = 1
              then do
                    say msgid "*******************************************"
                    say msgid "Error: The REPLYTO",
                                      "e-mail address specified"
                    say msgid "       is INVALID." replyto
                    say msgid " XMITIP is terminating...."
                    say msgid "*******************************************"
                    _x_ = sub_logit("Invalid ReplyTo Address" replyto)
                    _x_ = sub_set_zispfrc("8")
                   end
           if validfrom = 2
              then do
                    say msgid "*********************************************"
                    say msgid "Warning: The REPLYTO e-mail address specified"
                    say msgid "         is INVALID." replyto
                    say msgid "*********************************************"
                    _x_ = sub_logit("Invalid ReplyTo Address" replyto)
                   end
           return

        /* --------------- *
         * RESPOND Keyword *
         * --------------- */
         Proc_Responds:
           enrich = "html"
           if pos("(",word(options,2)) > 0 then do
              parse value options with x "(" responds ")" x
              /* now remove RESPOND from options */
              lq = pos("(",options,1)
              options = overlay(" ",options,lq,1)
              rq = pos(")",options,1)
              options = delstr(options,1,rq)
              end
           else do
                responds = word(options,2)
                options = delword(options,1,2)
                end
           responds = strip(responds)
         return

        /* -------------------------- *
         * FORMAT Keyword             *
         * -------------------------- */
        Proc_Format:
           if pos("(",word(options,2)) = 1 then do
              parse value options with x "(" format ")" more
              /* now remove FORMAT from options */
              lq = pos("(",options,1)
              options = overlay(" ",options,lq,1)
              rq = pos(")",options,1)
              options = delstr(options,1,rq)
              end
           else do
                format = word(options,2)
                if left(format,1) = "*" then do
                   format = substr(format,2)
                   format_all = 1
                   end
                options = delword(options,1,2)
                end
           ww = words(format)
           if ww = 0 then return
           do wc = 1 to ww
              call test_format word(format,wc)
              end
           return

        /* --------------------------------------------------------- *
         * Verify Valid Format                                       *
         * --------------------------------------------------------- */
         Test_Format: procedure expose (global_vars)
         parse arg fmt
         parse value fmt with format "/" .
         format = translate(strip(format))
         list = "TXT RTF HTML ICAL PDF BIN ZIP ZIPBIN ZIPRTF" ,
                "ZIPPDF ZIPHTML CSV SLK GIF XMIT ZIPCSV ZIPGIF", /*@DM03252021*/
                "ZIPXMIT XLS XLSX * X"
         if wordpos(format,list) > 0 then return
         say msgid "Invalid format specified:" fmt
         say msgid "        must be one of the following:"
         say msgid "       " list
         say msgid " "
         say msgid "XMITIP Processing terminating...."
         _x_ = sub_set_zispfrc("8")

        /* -------------------------- *
         * MARGIN Keyword             *
         * -------------------------- */
        Proc_Margin:
           if pos("(",word(options,2)) > 0 then do
              parse value options with x "(" margin ")" more
              /* now remove MARGIN from options */
              lq = pos("(",options,1)
              options = overlay(" ",options,lq,1)
              rq = pos(")",options,1)
              options = delstr(options,1,rq)
              end
           else do
                margin = word(options,2)
                options = delword(options,1,2)
                end
           return

        /* -------------------------- *
         * PDFIDX Keyword             *
         * -------------------------- */
        Proc_PDFIDX:
           if pos("(",word(options,2)) > 0 then do
              parse value options with x "(" pdfidx ")" more
              /* now remove PDFIDX from options */
              lq = pos("(",options,1)
              options = overlay(" ",options,lq,1)
              rq = pos(")",options,1)
              options = delstr(options,1,rq)
              end
           else do
                pdfidx = word(options,2)
                options = delword(options,1,2)
                end
           return

        /* -------------------------- *
         * RC0 Keyword.               *
         * -------------------------- */
        Proc_rc0:
           options = delword(options,1,1)
           rc0 = 0
           return

        /* -------------------------- *
         * RECEIPT Keyword.           *
         * -------------------------- */
        Proc_Receipt:
           p2 = wordindex(upper_options,2)
           parse value options with x data
           data = strip(data)
           Select
              when left(data,1) = '"' then do
                   pl   = pos(">",data)
                   receipt = left(data,pl)
                   end
              when left(data,1) = "'" then do
                   pl   = pos(">",data)
                   receipt = left(data,pl)
                   end
              when left(data,1) = '(' then do
                   pl   = pos(")",data)
                   parse value data with "(" receipt ")" .
                   end
              otherwise
                   receipt = word(data,1)
                   pl   = length(receipt)
           end
           ropt = substr(options,p2+pl+1)
           options = strip(ropt)
           call process_address receipt
           receipt = strip(t_addrs)
           receipt_n.1 = strip(t_names.1)
           return

        /* -------------------------- *
         * CODEPAGE keyword           *
         * -------------------------- */
        proc_Codepage:
           /* future use */
           codepage_keyword = word(upper_options,2)
           options = delword(options,1,2)
           return

        /* -------------------------- *
         * HTML Keyword.              *
         * -------------------------- */
        Proc_HTML:
           options = delword(options,1,1)
           enrich = "html"
           msg_html = 1
           return

        /* -------------------------- *
         * MURPHY Keyword.            *
         * -------------------------- */
        Proc_Murphy:
           options = delword(options,1,1)
           murphy = "on"
           return

        /* -------------------------- *
         * DEBUG Keyword.             *
         * -------------------------- */
        Proc_Debug:
           options = delword(options,1,1)
           debug = "on"
           return

        /* -------------------------- *
         * EMSG Keyword.              *
         * -------------------------- */
        Proc_Emsg:
           options = delword(options,1,1)
           emsg = "on"
           return

        /* -------------------------- *
         * ADDRESSFILE Keyword.       *
         * -------------------------- */
        Proc_AddressFile:
           address_file = word(options,2)
           options = delword(options,1,2)
           return

        /* -------------------------- *
         * ADDRESSFILE Setup          *
         * -------------------------- */
        Proc_AddressFile_Setup:
           if left(address_file,1) <> "'"
              then address_file = "'"bhlq"."address_file"'"
           if "OK" <> sysdsn(address_file) then do
               say msgid address_file sysdsn(address_file)
               say msgid "correct and retry."
               _junk_ = sub_set_zispfrc("8")
               end
           "Alloc f("eddd") ds("address_file") shr reuse"
           "Execio * Diskr" eddd "(Finis Stem xaddr."
           ia = 0
           do i = 1 to xaddr.0
              if left(xaddr.i,1) = "*" then iterate
              ia = ia + 1
              addr.ia = strip(left(xaddr.i,72))
              end
           drop xaddr.
           addr.0 = ia
           "Free  f("eddd")"
           Call Process_Address_File
           return

        /* -------------------------- *
         * ADDRESSFILEDD Keyword.     *
         * -------------------------- */
        Proc_AddressFileDD:
           address_filedd = word(options,2)
           options = delword(options,1,2)
           call listdsi(address_filedd "FILE")
           if sysreason+0 <> 3 then ,
              if sysreason+0 <> 27 then ,
                 if length(sysdsname) = 0 then do
                    say msgid address_filedd "Invalid - not allocated"
                    say msgid "correct and retry."
                    _junk_ = sub_set_zispfrc("8")
                     end
           "Execio * Diskr" address_filedd "(Finis Stem xaddr."
           ia = 0
           do i = 1 to xaddr.0
              if left(xaddr.i,1) = "*" then iterate
              ia = ia + 1
              addr.ia = strip(left(xaddr.i,72))
              end
           drop xaddr.
           addr.0 = ia
           Call Process_Address_File
           return

        /* -------------------------- *
         * FILEDESC Keyword.          *
         * -------------------------- */
        Proc_FileDesc:
           if pos("(",word(options,2)) > 0 then do
              parse value options with x "(" filedesc ")" x
              /* now remove FILEDESC from options */
              lq = pos("(",options,1)
              options = overlay(" ",options,lq,1)
              rq = pos(")",options,1)
              options = delstr(options,1,rq)
              end
           else do
                filedesc = word(options,2)
                options = delword(options,1,2)
                end
           filedesc = strip(filedesc)
           return

        /* -------------------------- *
         * FILENAME Keyword.          *
         * -------------------------- */
        Proc_Filename:
           if pos("(",word(options,2)) > 0 then do
              parse value options with x "(" filename ")" x
              /* now remove FILENAME from options */
              lq = pos("(",options,1)
              options = overlay(" ",options,lq,1)
              rq = pos(")",options,1)
              options = delstr(options,1,rq)
              end
           else do
                filename = word(options,2)
                options = delword(options,1,2)
                end
           filename = strip(filename)
           if pos("'",filename) = 0 then return
           do until pos("'",filename) = 0
              parse value filename with wlf"'"wfn"'"wrf
              wfn = translate(wfn,x2c("01"),' ')
              filename = strip(wlf wfn wrf)
              end
           return

        /* -------------------------- *
         * FILEO Keyword.             *
         * -------------------------- */
        Proc_Fileo:
           if pos("(",word(options,2)) > 0 then do
              parse value options with x "(" fileo ")" x
              /* now remove FILEO from options */
              lq = pos("(",options,1)
              options = overlay(" ",options,lq,1)
              rq = pos(")",options,1)
              options = delstr(options,1,rq)
              end
           else do
                fileo   = word(options,2)
                options = delword(options,1,2)
                end
           fileo = strip(fileo)
           return

        /* -------------------------- *
         * FILEDD Keyword.            *
         * -------------------------- */
        Proc_FileDD:
           if pos("(",word(options,2)) > 0 then do
              parse value options with x "(" FILEDD ")" more
              /* now remove FILEDD from options */
              lq = pos("(",options,1)
              options = overlay(" ",options,lq,1)
              rq = pos(")",options,1)
              options = delstr(options,1,rq)
              end
           else do
                FILEDD = word(options,2)
                options = delword(options,1,2)
                end
           return

        /* -------------------------- *
         * FILE Keyword.              *
         * Dsname for file to be      *
         * sent as an attachment.     *
         * (Text Only)                *
         * -------------------------- */
        Proc_File:
           options = strip(delword(options,1,1))
           if left(word(options,1),1) <> "(" then do
              fdsn = word(options,1)
              options = strip(delword(options,1,1))
              file = fdsn
              end
            else do
                 lb = 0;rb = 0
                 do i = 1 to length(options)
                    if substr(options,i,1) = "(" then lb = lb + 1
                    if substr(options,i,1) = ")" then rb = rb + 1
                    if rb = lb then leave
                    end
                 work = left(options,i+1)
                 options = substr(options,i+1)
                 do i = 1 to words(work)
                    file = strip(file word(work,i))
                    end
                 file = substr(file,2,length(file)-2)
                 end
         return

        /* --------------------------------------------------------- */
        /* Fixup Symbolics and return to caller.                     */
        /* --------------------------------------------------------- */
           Fix_Symbolics: Procedure expose (global_vars) ,
                                           symtype ver ,
                          dateformat lang basl jobid jobidl ,
                          custsym_var custsym_val. default_lang
           parse arg symbolics

          /* ----------------------------------- */
          /* If no symbolics then return quickly */
          /* ----------------------------------- */
           if pos("&",symbolics) = 0 then
              return symbolics

           /* --------------------------------------------- */
           /* Process the &JOBNUM if it exists              */
           /* --------------------------------------------- */
           do while pos("&JOBNUM",translate(symbolics)) > 0
              dp = pos("&JOBNUM",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&JOBNUM"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              symbolics = lsub""jobid""rsub
              end

         /* ------------------------------------- */
         /* Process the Custom variables (if any) */
         /* ------------------------------------- */
           do cv = 1 to words(custsym_var)
              cvar = word(custsym_var,cv)
              cval = strip(custsym_val.cv)
              call do_custsym
              end

           /* -------------------------------------------- */
           /* Process the &JOBIDL if it exists             */
           /* -------------------------------------------- */
           do while pos("&JOBIDL",translate(symbolics)) > 0
              dp = pos("&JOBIDL",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&JOBIDL"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              symbolics = lsub""jobidl""rsub
              end

           /* -------------------------------------------- */
           /* Process the &JOBID if it exists              */
           /* -------------------------------------------- */
           do while pos("&JOBID",translate(symbolics)) > 0
              dp = pos("&JOBID",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&JOBID"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              symbolics = lsub""jobid""rsub
              end

           /* --------------------------------------------- */
           /* Process the &JOB8 if it exists                */
           /* --------------------------------------------- */
           do while pos("&JOB8",translate(symbolics)) > 0
              dp = pos("&JOB8",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&JOB8"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              tcb     = storage(21c,4)
              tiot    = storage(d2x(c2d(tcb)+12),4)
              jscb    = storage(d2x(c2d(tcb)+180),4)
              ssib    = storage(d2x(c2d(jscb)+316),4)
              jobname = strip(storage(d2x(c2d(tiot)),8))
              symbolics = lsub""left(jobname,8)""rsub
              end

           /* --------------------------------------------- *
            * Process the &JOB if it exists                 *
            * --------------------------------------------- */
           do while pos("&JOB",translate(symbolics)) > 0
              dp = pos("&JOB",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&JOB"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              tcb     = storage(21c,4)
              tiot    = storage(d2x(c2d(tcb)+12),4)
              jscb    = storage(d2x(c2d(tcb)+180),4)
              ssib    = storage(d2x(c2d(jscb)+316),4)
              jobname = strip(storage(d2x(c2d(tiot)),8))
              symbolics = lsub""jobname""rsub
              end

           /* --------------------------------------------- *
            * Process the &RCA symbolic                     *
            * --------------------------------------------- */
           do while pos("&RCA",translate(symbolics)) > 0
              dp = pos("&RCA",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&RCA"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              call outtrap 'rc.'
              "%condcode"
              call outtrap 'off'
              rctext = null
              do i = 1 to rc.0
                 rctext = rctext""basl""strip(rc.i)
                 end
              symbolics = lsub""rctext""basl""rsub
              end

           /* --------------------------------------------- *
            * Process the &RCH symbolic                     *
            * --------------------------------------------- */
           do while pos("&RCH",translate(symbolics)) > 0
              dp = pos("&RCH",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&RCH"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              call outtrap 'rc.'
              "%condcode"
              call outtrap 'off'
              rctext = null
              do i = 1 to rc.0
                 if pos("HIGHESTCOND=",rc.i) = 0 then iterate
                 parse value rc.i with . "HIGHESTCOND="code
                 rctext = code
                 leave
                 end
              symbolics = lsub""rctext""rsub
              end

           /* --------------------------------------------- *
            * Process the &RC symbolic                      *
            * --------------------------------------------- */
           do while pos("&RC",translate(symbolics)) > 0
              dp = pos("&RC",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&RC"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              call outtrap 'rc.'
              "%condcode"
              call outtrap 'off'
              rctext = null
              do i = rc.0 to 1 by -1
                 if wordpos("FLUSH - STEP",rc.i) > 0 then iterate
                 parse value rc.i with step pgm code
                 rctext = ""basl"Step:" step "PGM:" pgm "Code:" code
                 leave
                 end
              symbolics = lsub""rctext""basl""rsub
              end

           /* --------------------------------------------- *
            * Process the &USERID if it exists              *
            * --------------------------------------------- */
           do while pos("&USERID",translate(symbolics)) > 0
              dp = pos("&USERID",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&USERID"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              userid = sysvar("sysuid")
              symbolics = lsub""userid""rsub
              end

           /* --------------------------------------------- *
            * Process the &XMITVER if it exists             *
            * --------------------------------------------- */
           do while pos("&XMITVER",translate(symbolics)) > 0
              dp = pos("&XMITVER",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&XMITVER"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              xmitver = ver
              symbolics = lsub""xmitver""rsub
              end

           /* --------------------------------------------- *
            * Process the &SYSID if it exists               *
            * --------------------------------------------- */
           do while pos("&SYSID",translate(symbolics)) > 0
              dp = pos("&SYSID",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&SYSID"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              symbolics = lsub""mvsvar('sysname')""rsub
              end

           /* --------------------------------------------- *
            * Process the &SYSNAME if it exists             *
            * --------------------------------------------- */
           do while pos("&SYSNAME",translate(symbolics)) > 0
              dp = pos("&SYSNAME",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&SYSNAME"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              symbolics = lsub""mvsvar('sysname')""rsub
              end

           /* --------------------------------------------- *
            * Process the &SYSPLEX if it exists             *
            * --------------------------------------------- */
           do while pos("&SYSPLEX",translate(symbolics)) > 0
              dp = pos("&SYSPLEX",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&SYSPLEX"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              symbolics = lsub""mvsvar('sysplex')""rsub
              end

           /* --------------------------------------------- *
            * Process the &CTIME if it exists               *
            * --------------------------------------------- */
           do while pos("&CTIME",translate(symbolics)) > 0
              dp = pos("&CTIME",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&CTIME"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              _xsub_ = space(translate(time("N"),"",":"),0) ;
              symbolics = lsub""_xsub_""rsub
              end

           /* --------------------------------------------- *
            * Process the &TIME if it exists                *
            * --------------------------------------------- */
           do while pos("&TIME",translate(symbolics)) > 0
              dp = pos("&TIME",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&TIME"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              symbolics = lsub""time()""rsub
              end

           /* --------------------------------------------- *
            * Process the &YEAR2 if it exists               *
            * and support &year2-n                          *
            * --------------------------------------------- */
           do while pos("&YEAR2",translate(symbolics)) > 0
              dp = pos("&YEAR2",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&YEAR2"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              wdate = left(date("j"),2)
              dateminus = 0
              if minus <> null then do
                 parse var minus "-"dateminus
                 if pos(".",dateminus) > 0 then do
                    parse value dateminus with dateminus"."rsub
                    rsub = "."rsub
                    end
                 if datatype(dateminus) <> "NUM" then do
                    say msgid "Error - invalid number:" dateminus,
                              "in &YEAR calculation." ,
                              "Resetting" dateminus "to 0."
                    say msgid " "
                    dateminus = 0
                    end
                 wdate= wdate - dateminus
                 end
              symbolics = lsub""wdate""rsub
              end

           /* --------------------------------------------- *
            * Process the &YEAR4 if it exists               *
            * and support &year4-n                          *
            * --------------------------------------------- */
           do while pos("&YEAR4",translate(symbolics)) > 0
              dp = pos("&YEAR4",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&YEAR4"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              wdate = left(date("s"),4)
              dateminus = 0
              if minus <> null then do
                 parse var minus "-"dateminus
                 if pos(".",dateminus) > 0 then do
                    parse value dateminus with dateminus"."rsub
                    rsub = "."rsub
                    end
                 if datatype(dateminus) <> "NUM" then do
                    say msgid "Error - invalid number:" dateminus,
                              "in &YEAR calculation." ,
                              "Resetting" dateminus "to 0."
                    say msgid " "
                    dateminus = 0
                    end
                 wdate= wdate - dateminus
                 end
              symbolics = lsub""wdate""rsub
              end

           /* --------------------------------------------- *
            * Process the &YEAR if it exists                *
            * and support &year -n                          *
            * --------------------------------------------- */
           do while pos("&YEAR",translate(symbolics)) > 0
              dp = pos("&YEAR",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&YEAR"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              wdate = left(date("s"),4)
              dateminus = 0
              if minus <> null then do
                 parse var minus "-"dateminus
                 if pos(".",dateminus) > 0 then do
                    parse value dateminus with dateminus"."rsub
                    rsub = "."rsub
                    end
                 if datatype(dateminus) <> "NUM" then do
                    say msgid "Error - invalid number:" dateminus,
                              "in &YEAR calculation." ,
                              "Resetting" dateminus "to 0."
                    say msgid " "
                    dateminus = 0
                    end
                 wdate= wdate - dateminus
                 end
              symbolics = lsub""wdate""rsub
              end

           /* --------------------------------------------- *
            * Process the &MONTH if it exists               *
            *    - supports &MONTH-n                        *
            * --------------------------------------------- */
           do while pos("&MONTH",translate(symbolics)) > 0
              dp = pos("&MONTH",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&MONTH"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              dateminus = 0
              if minus <> null then do
                 parse var minus "-"dateminus
                 if pos(".",dateminus) > 0 then do
                    parse value dateminus with dateminus"."rsub
                    rsub = "."rsub
                    end
                 if datatype(dateminus) <> "NUM" then do
                    say msgid "Error - invalid number:" dateminus,
                              "in &MONTH calculation." ,
                              "Resetting" dateminus "to 0."
                    say msgid " "
                    dateminus = 0
                    end
                 end
              d = date('M')
              if dateminus > 0 then do
                 months = "January February March April",
                      "May June July August September October",
                      "November December"
                 mp = wordpos(d,months)
                 mp = mp - dateminus
                 if mp < 1 then mp = mp + 12
                 wdate = word(months,mp)
                 end
              else wdate = d
              if dateformat = "E" then
                 wdate = sub_xmitiptr(wdate)
              if minus <> null then
                 symbolics = lsub""wdate""rsub
               else
                 symbolics = lsub""wdate""rsub
              end

           /* --------------------------------------------- *
            * Process the &MM if it exists                  *
            *    - supports &MM-n                           *
            * --------------------------------------------- */
           do while pos("&MM",translate(symbolics)) > 0
              dp = pos("&MM",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&MM"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              dateminus = 0
              if minus <> null then do
                 parse var minus "-"dateminus
                 if pos(".",dateminus) > 0 then do
                    parse value dateminus with dateminus"."rsub
                    rsub = "."rsub
                    end
                 if datatype(dateminus) <> "NUM" then do
                    say msgid "Error - invalid number:" dateminus,
                              "in &MM calculation." ,
                              "Resetting" dateminus "to 0."
                    say msgid " "
                    dateminus = 0
                    end
                 end
              d = left(date('U'),2)
              if dateminus > 0 then do
                 mp    = d - dateminus
                 if mp < 1 then mp = mp + 12
                 wdate = right(mp+100,2)
                 end
              else wdate = d
              if minus <> null then
                 symbolics = lsub""wdate""rsub
               else
                 symbolics = lsub""wdate""rsub
              end

           /* --------------------------------------------- *
            * Process the &CDATE if it exists               *
            *    - supports &CDATE-n                        *
            * --------------------------------------------- */
           do while pos("&CDATE",translate(symbolics)) > 0
              dp = pos("&CDATE",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&CDATE"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              if minus <> null then do
                 parse var minus "-"n
                 if pos(".",n) > 0 then do
                    parse value n with n"."rsub
                    rsub = "."rsub
                    end
                 if datatype(n) <> "NUM" then do
                    say msgid "Error - invalid number:" n,
                              "in &CDATE calculation." ,
                              "Resetting" n "to 0."
                    say msgid " "
                    n = 0
                    end
                 d = date('B') - n
                 end
              else d = date('b')
              wdate = date("s",d,"b")
              if minus <> null then
                 symbolics = lsub""wdate""rsub
               else
                 symbolics = lsub""wdate""rsub
              end

           /* --------------------------------------------- *
            * Process the &SDATE if it exists               *
            *    - supports &SDATE-n                        *
            * --------------------------------------------- */
           do while pos("&SDATE",translate(symbolics)) > 0
              dp = pos("&SDATE",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub =null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&SDATE"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              if minus <> null then do
                 parse var minus "-"n
                 if pos(".",n) > 0 then do
                    parse value n with n"."rsub
                    rsub = "."rsub
                    end
                 if datatype(n) <> "NUM" then do
                    say msgid "Error - invalid number:" n,
                              "in &SDATE calculation." ,
                              "Resetting" n "to 0."
                    say msgid " "
                    n = 0
                    end
                 d = date('B') - n
                 end
              else d = date('b')
              wdate = date("s",d,"b")
              if minus <> null then
                 symbolics = lsub""right(wdate,4)""rsub
               else
                 symbolics = lsub""right(wdate,4)""rsub
              end

           /* --------------------------------------------- *
            * Process the &UDATE if it exists               *
            *    - supports &UDATE-n                        *
            * --------------------------------------------- */
           do while pos("&UDATE",translate(symbolics)) > 0
              dp = pos("&UDATE",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub =null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&UDATE"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              if minus <> null then do
                 parse var minus "-"n
                 if pos(".",n) > 0 then do
                    parse value n with n"."rsub
                    rsub = "."rsub
                    end
                 if datatype(n) <> "NUM" then do
                    say msgid "Error - invalid number:" n,
                              "in &UDATE calculation." ,
                              "Resetting" n "to 0."
                    say msgid " "
                    n = 0
                    end
                 d = date('B') - n
                 end
              else d = date('b')
              wdate = date("s",d,"b")
              wdate = right(wdate,4)substr(wdate,3,2)
              if minus <> null then
                 symbolics = lsub""wdate""rsub
               else
                 symbolics = lsub""wdate""rsub
           end

           /* --------------------------------------------- */
           /* Process the &IWEEKE if it exists              */
           /*    - supports &IWEEKE-n                       */
           /* --------------------------------------------- */
           /*    calculate always the base date             */
           /*    function returns:                          */
           /*    iso_week(,'-')        ---> ccyy-Wnn-d      */
           /*    iso_week(,'-')        ---> 2007-W39-3      */
           /*    iso_week(dateb,'-')   ---> 2007-W39-3      */
           /* --------------------------------------------- */
           key = "&IWEEKE"
           do while pos(key,translate(symbolics)) > 0 ;
              minus = null ;
              _check_code_ = sub_symbolics_check() ;

              dateb = date("B")  - (7 * (n) )
              iweek = xmitfdat("iso_week("dateb",'-')")
              d = iweek
              symbolics = lsub""d""rsub
           end

           /* --------------------------------------------- */
           /* Process the &IWEEKR if it exists              */
           /*    - supports &IWEEKR-n                       */
           /* --------------------------------------------- */
           /*    calculate always the base date             */
           /*    function returns:                          */
           /*    iso_week(,'-')        ---> ccyy-Wnn-d      */
           /*    iso_week(,'-')        ---> 2007-W39-3      */
           /*    iso_week(dateb,'-')   ---> 2007-W39-3      */
           /*    (left 8) - reduced    ---> 2007-W39        */
           /* --------------------------------------------- */
           key = "&IWEEKR"
           do while pos(key,translate(symbolics)) > 0 ;
              minus = null ;
              _check_code_ = sub_symbolics_check() ;

              dateb = date("B")  - (7 * (n) )
              iweek = xmitfdat("iso_week("dateb",'-')")
              d = left(iweek,8)
              symbolics = lsub""d""rsub
           end

           /* --------------------------------------------- */
           /* Process the &IWEEK if it exists               */
           /*    - supports &IWEEK-n                        */
           /* --------------------------------------------- */
           /*    calculate always the base date             */
           /*    function returns:                          */
           /*    iso_week()            ---> 2007 39 3       */
           /*    iso_week(dateb)       ---> 2007 39 3       */
           /* --------------------------------------------- */
           key = "&IWEEK"
           do while pos(key,translate(symbolics)) > 0 ;
              minus = null ;
              _check_code_ = sub_symbolics_check() ;

              dateb = date("B")  - (7 * (n) )
              iweek = xmitfdat("iso_week("dateb")")
              parse value iweek with . d .
              d = right(d+100,2)
              symbolics = lsub""d""rsub
           end

           /* --------------------------------------------- *
            * Process the &DATE if it exists                *
            *    - supports &DATE-n                         *
            * --------------------------------------------- */
           do while pos("&DATE",translate(symbolics)) > 0
              dp = pos("&DATE",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub =null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&DATE"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              if minus <> null then do
                 parse var minus "-"n
                 if pos(".",n) > 0 then do
                    parse value n with n"."rsub
                    rsub = "."rsub
                    end
                 if datatype(n) <> "NUM" then do
                    say msgid "Error - invalid number:" n,
                              "in &DATE calculation." ,
                              "Resetting" n "to 0."
                    say msgid " "
                    n = 0
                    end
                 d = date('B') - n
                 end
              else d = date('b')
              if symtype <> "S" then do
                 m = date('o',d,'b')
                 parse var m mm"/"dd"/"yy
                 m = mm""dd""yy
                 if minus <> null then
                    symbolics = lsub""m""rsub
                 else
                    symbolics = lsub""m""rsub
                 end
              else do
                    parse value date(,d,'b') with dd x y
                    m = date('m',d,'b')
                    if minus <> null then
                       symbolics = lsub""m dd", "y""rsub
                    else
                       symbolics = lsub""m dd", "y""rsub
                    end
              end

           /* --------------------------------------------- *
            * Process the &JDATE if it exists               *
            *    - supports &JDATE-n                        *
            * --------------------------------------------- */
           do while pos("&JDATE",translate(symbolics)) > 0
              dp = pos("&JDATE",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub =null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&JDATE"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              if minus <> null then do
                 parse var minus "-"n
                 if pos(".",n) > 0 then do
                    parse value n with n"."rsub
                    rsub = "."rsub
                    end
                 if datatype(n) <> "NUM" then do
                    say msgid "Error - invalid number:" n,
                              "in &JDATE calculation." ,
                              "Resetting" n "to 0."
                    say msgid " "
                    n = 0
                    end
                 d = date('B') - n
                 end
              else d = date('b')
                    dd = date('d',d,'b')
                    yy = substr(date('s',d,'b'),3,2)
                    dd = yy""dd
                    if minus <> null then
                       symbolics = lsub""dd""rsub
                    else
                       symbolics = lsub""dd""rsub
              end

           /* --------------------------------------------- *
            * Process the &EDATE if it exists               *
            *    - supports &EDATE-n                        *
            * --------------------------------------------- */
           do while pos("&EDATE",translate(symbolics)) > 0
              dp = pos("&EDATE",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub =null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&EDATE"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              if minus <> null then do
                 parse var minus "-"n
                 if pos(".",n) > 0 then do
                    parse value n with n"."rsub
                    rsub = "."rsub
                    end
                 if datatype(n) <> "NUM" then do
                    say msgid "Error - invalid number:" n,
                              "in &EDATE calculation." ,
                              "Resetting" n "to 0."
                    say msgid " "
                    n = 0
                    end
                 d = date('B') - n
                 end
              else d = date('b')
              if symtype <> "S" then do
                 m = date('o',d,'b')
                 parse var m mm"/"dd"/"yy
                 m = dd""mm""yy
                 if minus <> null then
                    symbolics = lsub""m""rsub
                 else
                    symbolics = lsub""m""rsub
                 end
              else do
                    parse value date(,d,'b') with dd x y
                    m = date('m',d,'b')
                    if minus <> null then
                       symbolics = lsub""dd"." m y""rsub
                    else
                       symbolics = lsub""dd"." m y""rsub
                    end
              end

           /* --------------------------------------------- */
           /* Process the &IDATE if it exists               */
           /*    - supports &IDATE-n                        */
           /* --------------------------------------------- */
           do while pos("&IDATE",translate(symbolics)) > 0
              dp = pos("&IDATE",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub =null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&IDATE"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              if minus <> null then do
                 parse var minus "-"n
                 if pos(".",n) > 0 then do
                    parse value n with n"."rsub
                    rsub = "."rsub
                    end
                 if datatype(n) <> "NUM" then do
                    say msgid "Error - invalid number:" n,
                              "in &IDATE calculation." ,
                              "Resetting" n "to 0."
                    say msgid " "
                    n = 0
                    end
                 d = date('B') - n
                 end
              else d = date('b')
              m = date('s',d,'b')
              parse var m yy 5 mm 7 dd
              m = yy"-"mm"-"dd
              if minus <> null then
                 symbolics = lsub""m""rsub
              else
                 symbolics = lsub""m""rsub
              end

           /* --------------------------------------------- */
           /* Process the &DAY if it exists                 */
           /*    - supports &DAY-n                          */
           /* --------------------------------------------- */
           do while pos("&DAY",translate(symbolics)) > 0
              dp = pos("&DAY",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub =null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = "&DAY"
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              if minus <> null then do
                 parse var minus "-"n
                 if pos(".",n) > 0 then do
                    parse value n with n"."rsub
                    rsub = "."rsub
                    end
                 if datatype(n) <> "NUM" then do
                    say msgid "Error - invalid number:" n,
                              "in &DAY calculation." ,
                              "Resetting" n "to 0."
                    say msgid " "
                    n = 0
                    end
                 d = date('B') - n
                 end
              else d = date('b')
              d = date('w',d,'b')
              if dateformat = "E" then
                 d = xmitiptr("-L" lang d)
              if minus <> null then
                 symbolics = lsub""d""rsub
              else
                 symbolics = lsub""d""rsub
              end

           /* -------------------------------------------- */
           /* Process the &Z symbolic if it exists         */
           /* &z and leading blank are eliminated          */
           /* -------------------------------------------- */
           do while pos(" &Z",translate(symbolics)) > 0
              dp = pos(" &Z",translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              rsub = substr(rsub,4)
              symbolics = lsub""rsub
              end
           return symbolics

           sub_symbolics_check: procedure expose (global_vars) ,
                                                 lsub rsub key ,
                                                 symbolics minus n ;
              _check_code_ = 0 ;
              n = 0 ;
              dp  = pos(key,translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if left(rsub,1) = "-" then do
                 sw = length(word(rsub,1))+1
                 minus = word(rsub,1)
                 rsub = substr(rsub,sw)
                 end
              else minus = null
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              if minus <> null then do
                 parse var minus "-"n
                 _dlms_ = ". , ; * _ )"
                 do i = 1 to words(_dlms_) ;
                    _dlm_ = word(_dlms_,i) ;
                    if  pos(_dlm_,n) > 0 ,
                    then do ;
                          parse value n with n (_dlm_) xrsub
                          rsub = _dlm_""xrsub""rsub
                         end;
                 end;
                 data_type = datatype(n)
                 if data_type   <> "NUM" then do
                    say msgid "Error - invalid number: '"n"'",
                              "(datatype:"data_type")",
                              "in "key" calculation." ,
                              "Resetting '"n"' to '0'."
                    say msgid " "
                    n = 0
                    _check_code_ = 8 ;
                    end
                 end
              else n = 0

            return _check_code_

         /* -------------------------------------- */
         /* Process the custom variable subroutine */
         /* -------------------------------------- */
           Do_Custsym:
           do while pos(cvar,translate(symbolics)) > 0
              dp = pos(cvar,translate(symbolics))
              if dp > 0 then
                 lsub = left(symbolics,dp-1)
              else do
                   lsub = null
                   dp = 0
                   end
              sl = length(symbolics)
              rsub = right(symbolics,sl-dp+1)
              key  = cvar
              kl   = length(key)
              rsub = substr(rsub,kl+1)
              if pos(right(key,1),",)") > 0 then do
                 rkey = right(key,1)
                 rsub = rkey""rsub
                 key  = left(key,length(key)-1)
                 end
              symbolics = lsub""cval""rsub
              end
           return

        /* --------------------------------------------------------- */
        /* Generate Confidential Message                             */
        /* --------------------------------------------------------- */
         Do_Conf_Msg:
           text = xmitipm(sensitivity)
           l = length(text)
           text = "*" text "*"
           text2 = "*" left("-",l,"-") "*"
           in.m = text2
           m = m + 1
           in.m = text
           m = m + 1
           in.m = text2
           drop text text2
           return

        /* -------------------------- */
        /* XMZIP Keyword              */
        /* For testing                */
        /* (type library)             */
        /* -------------------------- */
        Proc_XMZip:
           options = strip(delword(options,1,1))
         if left(options,1) = "(" then do
            rp = pos(")",options)
            work = left(options,rp)
            parse value work with "(" work ")"
            options = delstr(options,1,rq)
            end
         else do
              work = word(options,1)
              options = delword(options,1,1)
              end
         parse value work with zip_type zip_load
         return

          /* ----------------------------------------------------- */
          /* Proc_GET_PDS_MEMBERS                                  */
          /* For a PDS is passed as a 'file' or 'filedd' without   */
          /* any members or with a member mask specified, get a    */
          /* list of those members for attachment. Return the      */
          /* member names in 'file_member.' stem.                  */
          /* ----------------------------------------------------- */

        Proc_GET_PDS_MEMBERS:

          Upper member

          Parse Value "" With file_member.

          if pos("(",file_dsn) > 0 then do
             parse var file_dsn file_dsn"("members")"
             if left(file_dsn,1) = "'" then
                file_dsn = file_dsn"'"
             end

          /* Do the directory list */
          _junk_ = outtrap('listds.','*')
          "listds "file_dsn" members"
          listds_rc = rc
          _junk_ = outtrap("off")

          if listds_rc<>0,
          then do
            say "ERROR: return code "listds_rc,
                "from listds of "file_dsn
            say listds.2
            _junk_ = sub_set_zispfrc("8")
          end

            /* ----------------------------------------------------- */
            /* All headers and no members means the PDS is no fun    */
            /* at all.                                               */
            /* ----------------------------------------------------- */
          if listds.0 < 7,
          then do
            say "Error: "file_dsn" has no members"
            _junk_ = sub_set_zispfrc("8")
          end

          _m = 0
          _wild_ = Pos("*",member)

          do _l = 7 to listds.0
            _mem_ = subword(listds._l,1,1)

            If _wild_ > 1,
            Then Do
              If Substr(_mem_,1,_wild_-1)<>Substr(member,1,_wild_-1),
              Then Iterate
            End

            _m = _m + 1

            file_member._m = _mem_
          end

          if _m=0,
          then do
            say "Error: "file_dsn" has no members matching mask "member
            _junk_ = sub_set_zispfrc("8")
          end

          file_member.0 = _m

        Return

            /* ----------------------------------------------------- */
            /* Proc_GET_DD_DSN                                       */
            /* This gets a list of all the allocations for the TSO   */
            /* session and stores one 'xmitip_dd.' variable for each */
            /* DD name, and one 'xmitip_dsn.<DDname>.' variable for  */
            /* each dataset for each DD name.                        */
            /* ----------------------------------------------------- */

        Proc_GET_DD_DSN:

          Parse Value "" With xmitip_dd. xmitip_dsn. xmitip_dsntype. ,
                              listalc.

          /* list the ddnames etc. in the strange listalc format */
          _junk_ = Outtrap("listalc.","*")
          "listalc status sysnames"
          _junk_ = Outtrap("OFF")

          _ddcount = 0
          _dsncount = 0

          Do _a = 1 To listalc.0

            If Substr(listalc._a,1,1)="-",
             | Word(listalc._a,1)="TERMFILE",
            Then Iterate

            if word(listalc._a,1) = "NULLFILE"
               then do
                    If _ddcount > 0
                    Then xmitip_dsn._ddcount.0 = _dsncount
                    _ddcount = _ddcount + 1
                    _dsncount = 1
                    xmitip_dd._ddcount = word(listalc._a,2)
                    iterate
                    end

            /* Keep that dataset name - don't know it's dd name yet */
            If Substr(listalc._a,1,1)<>" ",
            Then Do
              _lastdsn_ = Strip(listalc._a)
              if right(_lastdsn_,1) = ")" then do
                 parse value _lastdsn_ with x_left"("x_mem")"
                 if datatype(x_mem) = "NUM" then
                    _lastdsn_ = x_left
                 end
              Iterate
            End

            If Substr(listalc._a,12,4)="KEEP",
             | Substr(listalc._a,12,5)="CATLG",
             | Substr(listalc._a,12,6)="DELETE",
             | Substr(listalc._a,12,4)="PASS",
            Then Do
              _ddname_ = Strip(Substr(listalc._a,3,8))

              /* --------------------------------------------------- */
              /* If the ddname is blank, continuation of             */
              /* concatenation                                       */
              /* --------------------------------------------------- */
              If _ddname_<>"",
              Then Do
                If _ddcount > 0,
                Then xmitip_dsn._ddcount.0 = _dsncount
                _ddcount = _ddcount + 1
                _dsncount = 1
                xmitip_dd._ddcount = _ddname_
              End
              Else _dsncount = _dsncount + 1

              /* 2d array - one for each dd/dsn combination */
              xmitip_dsn._ddcount._dsncount = _lastdsn_

              If Pos("?",_lastdsn_) > 0,
              Then xmitip_dsntype._ddcount._dsncount = "SYSIO"
              Else Do
                Parse Var _lastdsn_ _hlq_ "." .
                If Length(_hlq_) = 8 ,
                 & Translate(_hlq_,'SY!!!!!!!!!!','SY0123456789'),
                   ='SYS!!!!!',
                Then xmitip_dsntype._ddcount._dsncount = "TEMP"
                Else xmitip_dsntype._ddcount._dsncount = "PERM"
              End

              _lastdsn_ = ""
            End

          End

          xmitip_dd.0 = _ddcount
          xmitip_dsn._ddcount.0 = _dsncount

        Return

        /* --------------------------------- */
        /* subroutine for VIANJE   Keyword.  */
        /* --------------------------------- */
        Proc_vianje:
          say msgid "entering vianje proc"
           if pos("(",word(options,2)) > 0 then do
              parse value options with x "(" vianje ")" x
              /* now remove VIANJE from options */
              lq = pos("(",options,1)
              options = overlay(" ",options,lq,1)
              rq = pos(")",options,1)
              options = delstr(options,1,rq)
              end
           else do
                vianje = word(options,2)
                options = delword(options,1,2)
                end
           vianje = strip(vianje)
           if pos("'",vianje) = 0 then return
           do until pos("'",vianje) = 0
              parse value vianje with wlf"'"wfn"'"wrf
              wfn = translate(wfn,x2c("01"),' ')
              vianje = strip(wlf wfn wrf)
              end
           return

       /* ----------------------------------------- */
       /* Subroutines to translate or not           */
       /* ----------------------------------------- */
        sub_xmitiptr:
          parse arg opt
          if default_lang = null then ,
             newopt = opt
          else ,
             newopt = xmitiptr("-L" lang opt)
         return newopt

       /* ----------------------------------------- */
       /* Trap uninitialized variables              */
       /* ----------------------------------------- */
        sub_novalue:
         Say "Variable" ,
            condition("Description") "undefined in line" sigl":"
         Say sourceline(sigl)
         _rcode_ = 8
         if _sysenv_ = "FORE" ,
         then do;
                 say "Report the error in this application",
                     "along with the syntax used."
              end;
         _junk_ = sub_set_zispfrc(_rcode_) ;
         exit _rcode_

 /* ----------------------------------------------------- */
 /* sub_init                                              */
 /* ----------------------------------------------------- */
sub_init:
  parse value "" with null
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
  msgid = left(myname":",09)

  _sysispf_  = sub_sysispf() ;
  _sysenv_   = SYSVAR("SYSENV")
  _sysopsys_ = MVSVAR("SYSOPSYS")

  _stem_push_pull_available_ = sub_check_stem_pull_push();

  encoding_check_counter = 0
  msg.0   = 0
  gol.0 = 0

  xmitdbglrecl = 133
  xmitdbg = "NO"
  if _sysenv_ = "BACK" ,
  then do;
          _junk_ = msg("OFF")
          "alloc fi(xmitdbg) data(*)"
          _rcode_ = rc
          _junk_ = msg("ON")
          if _rcode_ = 0 ,
          then do;
                  "free fi(xmitdbg)"
               end;
          else do;
                 _junk_ = listdsi("xmitdbg FILE")
                 if datatype(syslrecl) = "NUM" ,
                 then xmitdbglrecl = max(syslrecl,133)
                 else xmitdbglrecl = 133
                 xmitdbg = "YES"
                 _date_ = ,
                    translate("1234-56-78",date("s"),"12345678")
                 _time_ = ""left(TIME("N"),8)
                 xmitdbg.0 = 6
                 _txt_     = left(ver" "copies("-",20),10)
                 _txt_     = ""_txt_,
                             "XMIT DEBUGging",
                             "--- "_date_" "_time_" "copies("-",10),
                             ""
                 xmitdbg.1 = " "msgid""left("VERSION: ",20)_txt_
                 xmitdbg.2 = " "msgid""left("SYSOPSYS:",20)_sysopsys_
                 xmitdbg.3 = " "msgid""left("SYSENV:  ",20)_sysenv_
                 xmitdbg.4 = " "msgid""left("SYSISPF: ",20)_sysispf_
                 xmitdbg.5 = " "msgid""left("STEMPU* available",19),
                             ""_stem_push_pull_available_
                 xmitdbg.6 = " "msgid""
                 if xmitdbg = "YES" ,
                 then do;
                       "EXECIO * DISKW xmitdbg (STEM xmitdbg. )"
                      end;
                 drop xmitdbg.
               end;
       end;

  global_vars = "null msgid _sysispf_ _sysenv_ ver myname",
                "xmitdbg  xmitdbglrecl" ,
                "_stem_push_pull_available_",
                "encoding_check encoding_check_counter" ,
                ""
 return 0

 /* -------------------------------------------------------------- */
 /* XMITIPCU returns variable log                                  */
 /*  log =  logdsn  <LOGTYPE>...</LOGTYPE>   <LOGMSG>...</LOGMSG>  */
 /*  logdsn   = null - no logging            (as usual)            */
 /*  logtype  optional sub parameter                               */
 /*           null - messages are logged   (as usual)              */
 /*           MSG  - only messages are logged                      */
 /*           USE  - xmitip usage is logged                        */
 /*           ALL  - xmitip usage and messages are logged          */
 /*           NO   - nothing is logged (although logdsn is given)  */
 /*  logmsg   optional sub parameter                               */
 /*           add infos to the usage msg: header version logmsg    */
 /* -------------------------------------------------------------- */
sub_logit: procedure expose (global_vars) ,
                             log logdsn _logtype_ _logmsg_
  if logdsn = null then return 0
  log    = log
  parse arg _log_string_
  _log_string_ = strip(_log_string_)

  select;
    when ( abbrev(_logtype_,"N" ) ) ,
      then do;
                _write_usage_ = "N"
                _write_msgs_  = "N"
           end;
    when ( abbrev(_logtype_,"U" ) ) ,
      then do;
                _write_usage_ = "Y"
                _write_msgs_  = "N"
           end;
    when ( abbrev(_logtype_,"M" ) ) ,
      then do;
                _write_usage_ = "N"
                _write_msgs_  = "Y"
           end;
    when ( abbrev(_logtype_,"A" ) ) ,
      then do;
                _write_usage_ = "Y"
                _write_msgs_  = "Y"
           end;
    otherwise do;
                _write_usage_ = "N"
                _write_msgs_  = "Y"
           end;
  end;

  _write_log_ = "YES"
  if abbrev(_log_string_,"XMIT-USAGE") = 1 ,
  then do;
           _log_msg_ = ""
           _log_msg_ = _log_msg_""left("VER="ver,10)
           if _logmsg_ = null ,
           then _log_msg_ = _log_msg_"."
           else _log_msg_ = _log_msg_""_logmsg_
           if _write_usage_ = "N" ,
           then _write_log_ = "NO"
       end;
  else do;
           _log_msg_ = _log_string_
           if _write_msgs_  = "N" ,
           then _write_log_ = "NO"
       end;
  if _write_log_ = "YES" ,
  then do;
         Address TSO ,
          "%logit "logdsn ,
                 ""_log_msg_"",
                 ""
          rcode = rc
       end;
 return 0

 /* ----------------------------------------------------- */
 /* sub_set_zispfrc                                       */
 /*  purpose: keep the return code                        */
 /*           (especially ISPF BACKGROUND jobs)           */
 /*  This is the central routine to leave the exec with   */
 /*  a return code ne zero with environment dependent     */
 /*  settings: zispfrc for ISPF if not FORE.              */
 /* ----------------------------------------------------- */
 sub_set_zispfrc: procedure expose (global_vars)
   parse arg _all_parms_
   parse var _all_parms_ 1 zispfrc _action_ .
   zispfrc = strip(zispfrc)
   _action_ = translate(strip(_action_))
   if datatype(zispfrc) = "NUM" ,
   then nop
   else zispfrc = 8
   if _sysenv_ = "FORE" ,
   then nop;
   else do;
           if _sysispf_ = "ACTIVE" ,
           then do;
                   address ispexec "vput (ZISPFRC)"
                end;
        end;
   if zispfrc > 0 ,
   then do;
            say msgid "Ending XMITIP (RC="zispfrc")."
        end;
   select;
     when ( _action_ = "RETURN" ) then nop ;
     when ( _action_ = null     ) then _action_ = "EXIT" ;
     otherwise                         _action_ = "EXIT" ;
   end;
   if _action_ = "EXIT" ,
   then do;
            exit zispfrc  /* the one and only exit line */
        end;
   else return 0

 /* ---------------------------- */
 /* separate PARMS in XML format */
 /* ---------------------------- */
 sub_xml: procedure expose xml.
   _rcode_ = 0
   parse arg xml_string
   xml.0 = 0
   do forever
      xml_string = strip(xml_string)
      if xml_string = "" then leave
      if left(xml_string,1) = "<" ,
      then do ;
                parse var xml_string 1 "<"_key_">" .
           end;
      else do ;
                say msgid" ERROR: invalid XML parameter format "
                _rcode_ = 16
           end;
      _key_ = strip(_key_)
      if _key_ = "" ,
      then do ;
                say msgid" ERROR: no keyword found"
                _rcode_ = 16
           end;
      _key_start_ = "<"_key_">"
      _key_end_   = "</"_key_">"
      parse var xml_string 1 (_key_start_) xml_string
      if pos(_key_end_,xml_string) > 0 ,
      then do ;
               parse var xml_string 1 _key_val_ (_key_end_) _rest_
               _key_val_ = strip(_key_val_)
               if _key_val_ = "" ,
               then _key_val_ = "<blank>"
           end;
      else do ;
                say msgid" ERROR: no end tag found: "_key_end_
                _rcode_ = 16
           end;
      xml.0 = xml.0 + 1
      xmlidx  = xml.0
      xml.xmlidx.1 = ""strip(_key_)
      xml.xmlidx.2 = ""strip(_key_val_)
      xml_string = _rest_
  end
  if _rcode_ = 0 ,
  then nop
  else do;
           _junk_ = sub_set_zispfrc(_rcode_);
       end;
  return 0

 sub_syntax_check:
  return sub_syntax_check_rcode

 sub_encodexm:
   sub_syntax_check_rcode = 999
   signal on  syntax name sub_syntax_check
   x_rc = encodexm( "in.", "encode." )
   signal off syntax
  return x_rc

 sub_txt2pdf: procedure
   parse arg _cmd_
   signal   on syntax Name sub_txt2pdf_no
   x_rc = 12
   ""_cmd_""
   x_rc = rc
  sub_txt2pdf_no:
   signal   off syntax
  return x_rc

 sub_edciconv: procedure expose edcin. edcout.
   signal   on syntax Name sub_edciconv_err
   x_rc = 12
   parse arg _all_parms_
   parse var _all_parms_ 1 . ,
                         1 . "<FROMC>" _fromc_  "</FROMC>" . ,
                         1 . "<TOC>"   _toc_    "</TOC>"   . ,
                         1 .
   _fromc_ = strip(_fromc_)
   _toc_   = strip(_toc_)
   _parm_ = "FROMCODE("_fromc_"),TOCODE("_toc_")"
   maxrc = 0
   "alloc fi(sysut1) new delete lrecl(27994) blksize(27998) dsorg(PS)",
                   "space(5 5) cylinder recfm(v,b) reuse unit("vio")"
   maxrc = max(maxrc,rc)
   maxrc = 0

   if maxrc = 0 ,
   then do;
            "alloc fi(sysut1) new delete ",
                   "lrecl(27994) blksize(27998) dsorg(PS)",
                   "space(5 5) cylinder recfm(v,b) reuse unit("vio")"
             maxrc = max(maxrc,rc)
        end;
   if maxrc = 0 ,
   then do;
            "Execio * diskw sysut1 (finis stem edcin.)"
        end;
   if maxrc = 0 ,
   then do;
            "alloc fi(sysut2) new delete ",
                   "lrecl(27994) blksize(27998) dsorg(PS)",
                   "space(5 5) cylinder recfm(v,b) reuse unit("vio")"
             maxrc = max(maxrc,rc)
        end;
   if maxrc = 0 ,
   then do;
            "call *(EDCICONV) '"_parm_"'"
            maxrc = max(maxrc,rc)
        end;
   drop edcout.
   edcout.0 = 0
   if maxrc = 0 ,
   then do;
            "Execio * diskr sysut2 (finis stem edcout.)"
            maxrc = max(maxrc,rc)
        end;
  sub_edciconv_err:
    signal   off syntax
    "free fi(sysut1 sysut2)"
   return maxrc

 gol_header:
   parse arg _header_
   if _header_ = null ,
   then _header_ = "sample header"
   _t_ = " "
   _x_ = gol(_t_) ;
   _t_ = ""msgid" "_header_
   _x_ = gol(_t_) ;
   _t_ = ""msgid" environment and system informations"
   _x_ = gol(_t_) ;
   _t_ = ""msgid" "left("Version",10)" "ver
   _x_ = gol(_t_) ;
   _t_ = ""msgid" "left("ENV:   ",10)" "_sysenv_
   _x_ = gol(_t_) ;
   _t_ = ""msgid" "left("ISPF:  ",10)" "_sysispf_
   _x_ = gol(_t_) ;
   _t_ = ""msgid" "left("OPSYS: ",10)" "_sysopsys_
   _x_ = gol(_t_) ;
   _t_ = " "
   _x_ = gol(_t_) ;
  return 0

 gol:             procedure expose (global_vars) gol.
   /* generate output lines */
   parse arg output_line
   gol.0 = gol.0 + 1
   gidx = gol.0
   gol.gidx = output_line
  return 0

 /* ----------------------------------------------------- */
 /* sub_head                                              */
 /* - only "confirm lines" are aligned                    */
 /* ----------------------------------------------------- */
 sub_head:        procedure expose (global_vars) ,
                                   header. save_lrecl
   parse arg _head_parms_
   parse var _head_parms_ 1 . "<C>" _conf_    "</C>" . ,
                          1 . "<M>" _msgt_    "</M>" . ,
                          1 . "<D>" _data_    "</D>" . ,
                          1 . "<X>" _exclude_ "</X>" . ,
                            .
   _align_vertical_confirm_ = 13
   _align_vertical_ = 0
   _words_to_exclude_ = "SUBJECT"
   _excluded_ = "NO"
   if _excluded_ = "NO" ,
   then do;
           do i = 1 to words(_words_to_exclude_)
              _word_excl_ = word(_words_to_exclude_,i)
              if abbrev(translate(_data_),translate(_word_excl_)) = 1 ,
              then do;
                       _excluded_ = "YES"
                       leave
                   end;
           end
        end;
   if _excluded_ = "NO" ,
   then do;
           do i = 1 to words(_words_to_exclude_)
              _word_excl_ = word(_words_to_exclude_,i)
              if abbrev(translate(_exclude_),translate(_word_excl_))=1,
              then do;
                       _excluded_ = "YES"
                       leave
                   end;
           end
        end;

   if   _msgt_ = null ,
   then _msgt_ = _data_

   header.0 = header.0 + 1
   idx = header.0
   header.idx = _data_
   if   _conf_ = null ,
   then do;
           _dlm_ = ":"
           if pos(_dlm_,left(_data_,15)) > 0 ,
           then do;
                    parse var _data_ 1 _d1_ (_dlm_) _d2_
                end;
           else do;
                    _dlm_ = ""
                    _d1_  = " "
                    parse var _data_ 1              _d2_
                end;
           _d1_ = strip(_d1_)""_dlm_
           _d2_ = strip(_d2_)
           say msgid left(_d1_,_align_vertical_confirm_)""_d2_
        end;
   save_lrecl = max(length(_data_),save_lrecl)
   return 0

 sub_gen_subject: procedure expose (global_vars) ,
                                   header. save_lrecl confirm
    parse arg _data_subject_
    _data_ = _data_subject_
    maxl = 78
    pre  = null
    do forever
         splitpos = maxl
         do i = maxl to 2 by -1
            _char2_ = substr(_data_,i,2)
            if i = 2 ,
            then do ;
                    next_pos = splitpos + 1
                 end;
            else do ;
                    if       _char2_    =  "  " then iterate
                    if right(_char2_,1) <> " "  then iterate
                    splitpos = i
                    next_pos = splitpos + 2
                 end;
            newh = pre""left(_data_,splitpos)
            _data_ = substr(_data_,next_pos)
            _xdebug_ = "OFF"
            if _xdebug_ = "ON" ,
            then do ;
                      say "CHAR=<"_char2_"> "splitpos
                      say "NEWH="newh
                      say "_data_ ="_data_
                      say ""
                 end;
            _d_ = ""newh""
            _x_ = sub_head("<C>"confirm"</C><D>"_d_"</D>");  /* 06/16 */
            _d_=null;
            pre = " "
            leave
         end
         if strip(_data_) = "" then leave
    end
   return 0

  sub_encode:      procedure expose (global_vars) ,
                                    codepage encoding
    parse arg parms_in
    parms_out   = parms_in
    select ;
      when ( parms_in = ""        ) then return parms_out ;
      when ( codepage = ""        ) then return parms_out ;
      when ( codepage = ""        ) then return parms_out ;
      when ( "ALL"    = "ALL"     ) then nop ;
      otherwise nop;
    end;
    encode_header  = "=?"encoding"?Q?"
    encode_trailer = "?="
    encode_out  = encode_header""parms_in""encode_trailer ;
    parms_out   = encode_out ;
   return parms_out  ;

  sub_encode_data: procedure expose (global_vars) ,
                                    codepage encoding _enctype_
    parse arg parms_in
    parms_out   = parms_in

    select ;
      when ( parms_in = ""        ) then return parms_out ;
      when ( codepage = ""        ) then return parms_out ;
      otherwise nop;
    end;
    select;
      when ( _enctype_ = "HTML" ) then nop;
      when ( _enctype_ = "RTF"  ) then nop;
      when ( _enctype_ = "TXT"  ) then nop;
      otherwise _enctype_ = null ;
    end ;
    select ;
      when ( _enctype_ = "XTML" ) then _charset_ = "ISO-8859-15"
      when ( _enctype_ = "HTML" ) then _charset_ = ""encoding""
      when ( _enctype_ = "RTF"  ) then _charset_ = ""encoding""
      when ( _enctype_ = "TXT"  ) then _charset_ = ""encoding""
      otherwise                        _charset_ = "WINDOWS-1252"
    end;
    enc_header = ""
    enc_header = enc_header"<CP>"codepage"</CP>"
    enc_header = enc_header"<ENC>"_charset_"</ENC>"
    if _enctype_ = null ,
    then nop;
    else do ;
              enc_header = enc_header"<TYPE>"_enctype_"</TYPE>"
         end;
    _enctype_  = null
    if encoding_check = "NO" ,
    then encoding_check_to_do = "NO"
    else do;
            encoding_check_to_do = "YES"
            encoding_check_counter = encoding_check_counter + 1
            select;
              when ( encoding_check = "YES"  ) then nop
              when ( encoding_check = "WARN" ) then nop
              when ( encoding_check = "ONCE" ) ,
                then do;
                        if encoding_check_counter > 1 ,
                        then encoding_check_to_do = "NO"
                     end;
              otherwise nop;
            end;
         end;

    if encoding_check_to_do = "NO" ,
    then nop;
    else do;
            chk_header = enc_header"<MODE>TEST</MODE>"
            /* check first if encoding is supported */
            encode_chk = xmitzqen("<HEADER>"chk_header"</HEADER>") ;
            if abbrev(encode_chk,"0 ") = 1 ,
            then nop;
            else do;
                    say msgid ""copies("*",30)
                    say msgid "encoding problem: "encode_chk
                    say msgid "Encoding check setting:",
                               encoding_check
                    if encoding_check = "YES" ,
                    then do;
                            say msgid "Terminating ..."
                            _junk_ = sub_set_zispfrc("8")
                         end;
                    else do;
                            say msgid "Processing continues ..."
                         end;
                 end;
         end;
    encode_out = xmitzqen("<HEADER>"enc_header"</HEADER>"parms_in"") ;
    if strip(encode_out) = null ,
    then nop
    else parms_out   = encode_out ;
   return parms_out  ;

  sub_sysispf:
    "ISPQRY"
    ispfcc1 = rc
    "SUBCOM ISPEXEC"
    ispfcc2 = rc
    if max(ispfcc1,ispfcc2) = 0 ,
    then _sysispf_ = "ACTIVE"
    else _sysispf_ = "NOT ACTIVE"
   return _sysispf_

sub_xmitdbg:
  parse arg _data_
  if strip(_data_) = null ,
  then _data_ = " "
  IF SYMBOL("XMITDBG.0") = "VAR" ,
  then nop
  else xmitdbg.0 = 0
  xmitdbgidx = xmitdbg.0 + 1
  xmitdbg.0  = xmitdbgidx
  xmitdbg.xmitdbgidx = ""left(_data_,xmitdbglrecl)
 return 0

sub_mh: procedure expose (global_vars) mh.
  parse arg _data_
  if symbol("mh.0") = "VAR" ,
  then nop
  else mh.0 = 0
  mh.0 = mh.0 + 1
  idx = mh.0
  mh.idx = _data_
 return 0

sub_xmitdbg_write:
   if xmitdbg = "YES" ,
   then do;
          if symbol("xmitdbg.0") = "VAR" ,
          then do;
                 if xmitdbg.0 > 0 ,
                 then do;
                        _txt_  = copies("-",60)
                        _junk_ = sub_xmitdbg(" <*DEBUG*r*> "_txt_);
                        _junk_ = sub_xmitdbg(" <*DEBUG***> ");
                        "EXECIO * DISKW xmitdbg (STEM xmitdbg. )"
                        drop xmitdbg.
                      end;
                end;
        end;
 return 0

 /* checking must be done in subroutine */
 sub_check_stem_pull_push: procedure
   signal   on syntax Name sub_check_stem_pull_push_no
   TestVar  = "NO"
   StemTok  = StemPush("Testvar")
   TestRC   = StemPull(StemTok)
   if TestRC = 0 ,
   then TestVar  = "YES"
   else TestVar  = "ERR"TestRC
  sub_check_stem_pull_push_no:
   signal   off syntax
  Return   TestVar

 /* interpreting should be done in subroutine */
 sub_interpret_command:
   parse arg _cmd_
   if strip(_cmd_) = null ,
   then return 12
   rcode = 8
   signal on  syntax name sub_err_syntax  /* trap rexx syntax errors */
   say _cmd_
   interpret _cmd_
  sub_interpret_command_ok:
   _x_rc_ = rc
   if _x_rc_ = 0 ,
   then rcode = 0
   else rcode = 8
   signal off syntax
   return rcode

/*************************************************/
/* I don't remeber where I found this.  HB       */
/*************************************************/
/*                                               */
/* Rexx Error Handling Common Routines           */
/*                                               */
/*************************************************/

sub_err_syntax:                      /* Signal ON SYNTAX Entry Point */
sub_err_novalue:                    /* Signal ON NOVALUE Entry Point */
sub_err_error:                        /* Signal ON ERROR Entry Point */
sub_err_failure:                    /* Signal ON FAILURE Entry Point */
sub_err_halt:                          /* Signal ON HALT Entry Point */
/*trace o */                                       /* turn trace off */
if myname = "" then ,
  parse source rexxenv rexxinv me rexxdd rexxdsn . rexxenv addrspc .
else me = myname
  signal off novalue        /* Ignore no-value variables within trap */
  trap_errortext = 'Not Present'/* Error text available only with RC */
  trap_condition = Condition('C')              /* Which trap sprung? */
  trap_description = Condition('D')               /* What caused it? */
  trap_rc = rc                          /* What was the return code? */
  if datatype(trap_rc) = 'NUM' then     /* Did we get a return code? */
     trap_errortext = Errortext(trap_rc)    /* What was the message? */
  trap_linenumber = sigl                     /* Where did it happen? */
  trap_line = sourceline(trap_linenumber)  /* What is the code line? */

  ER. = ''                           /* Initialize error output stem */
  ER.1 = 'An error has occurred in Rexx module:' me
  ER.2 = '   Error Type        :' trap_condition
  ER.3 = '   Error Line Number :' trap_linenumber
  ER.4 = '   Instruction       :' trap_line
  ER.5 = '   Return Code       :' trap_rc
  ER.6 = '   Error Message text:' trap_errortext
  ER.7 = '   Error Description :' trap_description
  ER.8 = 'Please report the problem to your' contact
  ER.0 = 8

  do i = 1 to ER.0                   /* Print error report to screen */
     say ER.i
  end /*do i = 1 to ER.0*/

  return 8

 sub_check_send_to: procedure expose (global_vars) ,
                              msgid atsign debug ,
                              from address cc bcc ,
                              errorsto replyto ,
                              check_send_to

 /* ---------------------------------------------------------- */
 /* - save all exposed variables                               */
 /* scenario:                                                  */
 /*  - stempu*                                                 */
 /*    STEMPULL all native variables including PARMVAR PARMFIX */
 /*    check name of exit: XMITZEX2 (default) or interpret     */
 /*    DOIT                                                    */
 /*    compare all saved fix vars - perhaps warning            */
 /*                                 wrong exit                 */
 /*    compare all variable vars to do what ?                  */
 /*         translate(space(_var_,1))                          */
 /*    return                                                  */
 /*  - NOT stempu*                                             */
 /*    check name of exit: XMITZEX2 (default) or interpret     */
 /*                        if other then checks ...            */
 /*    after: no interpret but select ...                      */
 /*                                                            */
 /* ---------------------------------------------------------- */

   sfix_msgid     = msgid
   sfix_AtSign    = AtSign
   sfix_from      = from
   sfix_debug     = debug
   sfix_null      = null
   svar_address   = address
   svar_cc        = cc
   svar_bcc       = bcc
   svar_errorsto  = errorsto
   svar_replyto   = replyto

   check_send_status = 0
   parse var check_send_to   1 check_send_to_cmd ,
                               check_send_to_parms
   check_send_to_cmd = translate(check_send_to_cmd)

   _txt_  = "sub routine >>> sub_check_send_to:"
   _junk_ = sub_xmitdbg(" <*DEBUG*r*> "_txt_);
   _txt_  = "check_send_to (all):   "check_send_to
   _junk_ = sub_xmitdbg(" <*DEBUG*r*> "_txt_);
   _txt_  = "check_send_to_cmd .:   "check_send_to_cmd
   _junk_ = sub_xmitdbg(" <*DEBUG*r*> "_txt_);
   _txt_  = "check_send_to_parms:   "check_send_to_parms
   _junk_ = sub_xmitdbg(" <*DEBUG*r*> "_txt_);
   _txt_  = "use STEMPUSH/STEMPULL: "_stem_push_pull_available_
   _junk_ = sub_xmitdbg(" <*DEBUG*r*> "_txt_);

                             /* names of variables, not values */
   _p_fix.1.1 = "GLBID"     ;   _p_fix.1.2 = "msgid"
   _p_fix.2.1 = "ATSIGN"    ;   _p_fix.2.2 = "AtSign"
   _p_fix.3.1 = "PARMS"     ;   _p_fix.3.2 = "check_send_to_parms"
   _p_fix.4.1 = "ADDRFROM"  ;   _p_fix.4.2 = "from"
   _p_fix.5.1 = "DEBUG"     ;   _p_fix.5.2 = "debug"
   _p_fix.6.1 = "INFO"      ;   _p_fix.6.2 = "null"
   _p_fix.0 = 6

   _p_var.1.1 = "ADDRTO"    ;   _p_var.1.2 = "address"
   _p_var.2.1 = "ADDRCC"    ;   _p_var.2.2 = "cc"
   _p_var.3.1 = "ADDRBCC"   ;   _p_var.3.2 = "bcc"
   _p_var.4.1 = "ADDRERROR" ;   _p_var.4.2 = "errorsto"
   _p_var.5.1 = "ADDRREPLY" ;   _p_var.5.2 = "replyto"
   _p_var.0 = 5

   select;
     when ( _stem_push_pull_available_ = "YES" ) then nop;
     when ( check_send_to_cmd = "XMITZEX2"     ) then nop;
     otherwise do;
                  /* reduce to important variables */
                  /* if command interpret is done  */
                  _p_fix.0 = 4
                  _p_var.0 = 3
               end;
   end;

   xmlparms = ""
   _parms_ = ""
   _parms_long_ = ""
   parmfix.0 = _p_fix.0
   do i = 1 to _p_fix.0
      parmfix.i.1 = _p_fix.i.1
      parmfix.i.2 = value(_p_fix.i.2)
      _xml_ = "<"_p_fix.i.1">"value(_p_fix.i.2)"</"_p_fix.i.1">"
      xmlparms = xmlparms""_xml_
      if value(_p_fix.i.2) = "" ,
      then nop;
      else do;
               _parms_ = _parms_""_xml_
           end;
      _parms_long_ = _parms_long_""_xml_
      _txt_   = " parm fix "right(i,2,0)": "_xml_
      _junk_  = sub_xmitdbg(" <*DEBUG*r*> "_txt_);
   end
   parmfix      = _parms_
   parmfix_long = _parms_long_

   _parms_ = ""
   _parms_long_ = ""
   parmvar.0 = _p_var.0
   do i = 1 to _p_var.0
      parmvar.i.1 = _p_var.i.1
      parmvar.i.2 = value(_p_var.i.2)
      _xml_ = "<"_p_var.i.1">"value(_p_var.i.2)"</"_p_var.i.1">"
      xmlparms = xmlparms""_xml_
      if value(_p_var.i.2) = "" ,
      then nop;
      else do;
               _parms_ = _parms_""_xml_
           end;
      _parms_long_ = _parms_long_""_xml_
      _txt_   = " parm var "right(i,2,0)": "_xml_
      _junk_  = sub_xmitdbg(" <*DEBUG*r*> "_txt_);
   end
   parmvar      = _parms_
   parmvar_long = _parms_long_

   if _stem_push_pull_available_ = "YES" ,
   then do;
           rcode = 8
           readstem = ""
           xmlparms = ""
           /*
           stempush_parms = "",
                            "parmfix.","parmvar.",
                "PARMS","DEBUG","INFO",
                "GLBID","ATSIGN","ADDRFROM",
                "ADDRTO","ADDRCC","ADDRBCC","ERRORSTO","REPLYTO",
                         "xmlparms",
                         ""
           */
           stempush_parms = "'parmfix.','parmvar.'"
           stempush_parms = space(stempush_parms,0)
           parm_Token = ,
             STEMPUSH("parmfix.","parmvar.","xmlparms")
           _calledas_ = "<CALLEDAS>"check_send_to_cmd"</CALLEDAS>"
           _parms_ = ""
           _parms_ = _parms_""_calledas_
           _parms_ = _parms_"<TOKEN>"parm_Token"</TOKEN>"
           if check_send_to_cmd = "XMITZEX2" ,
           then do;
                   /* default name for this exit   */
                   /* (avoid interpret ...         */
                   chk_val   = xmitzex2(""_parms_"");
                end
           else do
                   check_cmd = ""check_send_to_cmd"('"_parms_"')";
                   _cmd_     = "chk_val = "check_cmd ;
                   _cmd_rc_  = sub_interpret_command(_cmd_)
                   if _cmd_rc_ = 0 ,
                   then nop
                   else do;
                           chk_val = _cmd_rc_
                           rcode   = _cmd_rc_
                           txt.1  = "ERROR: interpreting command"
                           txt.2  = "ERROR: "_cmd_
                           txt.3  = "ERROR: sub routine stops",
                                     "with rcode="rcode"."
                           txt.0  = 3
                           do idx = 1 to txt.0
                              _junk_ = sub_xmitdbg(" <*DEBUG*r*>",
                                                   ""txt.idx);
                              say msgid ""txt.idx
                           end
                        end;
                end
           chk_val = strip(chk_val)
           parse var chk_val 1 . "<TOKEN>" _token_ "</TOKEN>" .
           select
             when ( strip(chk_val) = ""      ) then rcode = 0
             when ( datatype(chk_val) = "NUM") then rcode = chk_val
             when ( _token_        = ""      ) then rcode = chk_val
             otherwise do ;
                    rcode = 0
                    readstem = stempull(""_token_"")
                    msgid          = sfix_msgid
                    AtSign         = sfix_AtSign
                    from           = sfix_from
                    debug          = sfix_debug
                    null           = sfix_null
                    if symbol("addrto")    = "VAR"
                    then do;
                            if translate(addrto) = "N/A" ,
                            then address  = svar_address
                            else address  = addrto
                         end;
                    if symbol("addrcc")    = "VAR"
                    then do;
                            if translate(addrcc) = "N/A" ,
                            then cc       = svar_cc
                            else cc       = addrcc
                         end;
                    if symbol("addrbcc")   = "VAR"
                    then do;
                            if translate(addrbcc) = "N/A" ,
                            then bcc      = svar_bcc
                            else bcc      = addrbcc
                         end;
                    if symbol("addrreply")   = "VAR"
                    then do;
                            if translate(addrreply) = "N/A" ,
                            then replyto  = svar_replyto
                            else replyto  = addrreply
                         end;
                    if symbol("addrerror")   = "VAR"
                    then do;
                            if translate(addrerror) = "N/A" ,
                            then errorsto = svar_errorsto
                            else errorsto = addrerror
                         end;
                    if readstem = 0 ,
                    then rcode = 0
                   end;
           end;
           if rcode = 0 ,
           then nop;
           else do;
                       if readstem = "" ,
                       then _info_ = ""
                       else _info_ = "  (STEMPULL RC="readstem")"
                       say msgid" ERROR after exit"
                       say msgid" "chk_val" "_info_
                end;
           return rcode
        end;

   /* STEMPU* not available */
   _parms_ = ""parmfix""parmvar""
   _parms_length_ = length(_parms_)
   _txt_  = " _parms_ ...: "_parms_
   _junk_ = sub_xmitdbg(" <*DEBUG*r*> "_txt_);
   _txt_  = " _length_ ..: "_parms_length_
   _junk_ = sub_xmitdbg(" <*DEBUG*r*> "_txt_);

   rcode = 0
   if rcode = 0 ,
   then do;
          if check_send_to_cmd = "XMITZEX2" ,
          then nop ;
          else do;
                 if _parms_length_  > 250 ,
                 then do;
                        rcode = 12
                        _txt_  = "ERROR:",
                          "parameter length > 250: "_parms_length_
                        _junk_ = sub_xmitdbg(" <*DEBUG*r*> "_txt_);
                        say msgid" "_txt_
                        _txt_  = "ERROR: Perhaps",
                          "you can install STEMPUSH/STEMPULL"
                        _junk_ = sub_xmitdbg(" <*DEBUG*r*> "_txt_);
                        _txt_  = "ERROR:",
                                 "sub routine stops with rcode="rcode
                        _junk_ = sub_xmitdbg(" <*DEBUG*r*> "_txt_);
                        say msgid ""_txt_
                      end;
               end;
        end;
   if rcode = 0 ,
   then do;
           if check_send_to_cmd = "XMITZEX2" ,
           then do;
                   /* default name for this exit   */
                   /* (avoid interpret ...         */
                   chk_val   = xmitzex2(""_parms_"");
                end
           else do
                   check_cmd = ""check_send_to_cmd"('"_parms_"')";
                   _cmd_     = "chk_val = "check_cmd ;
                   _cmd_rc_  = sub_interpret_command(_cmd_)
                   if _cmd_rc_ = 0 ,
                   then nop
                   else do;
                           chk_val = _cmd_rc_
                           rcode   = _cmd_rc_
                           txt.1  = "ERROR: interpreting command"
                           txt.2  = "ERROR: "_cmd_
                           txt.3  = "ERROR: sub routine stops",
                                     "with rcode="rcode"."
                           txt.0  = 3
                           do idx = 1 to txt.0
                              _junk_ = sub_xmitdbg(" <*DEBUG*r*>",
                                                   ""txt.idx);
                              say msgid ""txt.idx
                           end
                        end;
                end
        end;

   _junk_ = sub_xmitdbg_write();

   if rcode /= 0 then return rcode

   parse var chk_val 1 . "<TOKEN>" _token_ "</TOKEN>" .
   if _token_ = "" ,
   then nop;
   else do;
           say msgid" ERROR after exit: <TOKEN> not valid."
           return 12
        end;

   datatype_chk_val = datatype(chk_val)

   cmds.0 = 0
   select;
     when (    strip(chk_val) = ""    ) ,
       then check_send_status = 0        /* nothing changed */
     when ( datatype_chk_val  = "NUM" ) ,
       then check_send_status = chk_val
     otherwise do;
           do i = 1 to _p_var.0
                _xml1_ = "<"_p_var.i.1">"
                _xml2_ = "</"_p_var.i.1">"
                parse var chk_val 1 . (_xml1_) _p_var.i.3 (_xml2_) .
                select;
                  when (    _p_var.i.3 = _p_var.i.2 ) ,
                       then _new_val_  = _p_var.i.2
                  when (    _p_var.i.3 = ""         ) ,
                       then _new_val_  = _p_var.i.2
                  when (    _p_var.i.3 = "NULL"     ) ,
                       then _new_val_  = ""
                  otherwise _new_val_  = _p_var.i.3
                end;
                if _new_val_ = _p_var.i.2 ,
                then nop
                else do;
                        _cmd_ = ""_p_var.i.2" = '"_new_val_"' ;"
                        _txt_ = "setting: "_cmd_
                        _junk_  = sub_xmitdbg(" <*DEBUG*r*> "_txt_);
                        cmds.0 = cmds.0 + 1
                        cmdidx = cmds.0
                        cmds.cmdidx = _cmd_
                        cmds.cmdidx.1 = _p_var.i.2
                        cmds.cmdidx.2 = _new_val_
                     end;
           end;
       end;
   end;
   _junk_ = sub_xmitdbg_write();
   do i = 1 to cmds.0
      _p_var_ = translate(strip(cmds.i.1))
      _p_val_ = translate(strip(cmds.i.2))
      _p_val_status = "OK"
      select
        when ( _p_var_ = "ADDRESS" )
          then do;
                  if _p_val_ = "N/A" ,
                  then address  = svar_address
                  else address  = _p_val_
               end;
        when ( _p_var_ = "CC"      )
          then do;
                  if _p_val_ = "N/A" ,
                  then cc       = svar_cc
                  else cc       = _p_val_
               end;
        when ( _p_var_ = "BCC"     )
          then do;
                  if _p_val_ = "N/A" ,
                  then bcc      = svar_bcc
                  else bcc      = _p_val_
               end;
        when ( _p_var_ = "REPLYTO" )
          then do;
                  if _p_val_ = "N/A" ,
                  then replyto  = svar_reply
                  else replyto  = _p_val_
               end;
        when ( _p_var_ = "ERRORSTO")
          then do;
                  if _p_val_ = "N/A" ,
                  then errorsto = svar_errorsto
                  else errorsto = _p_val_
               end;
        otherwise do;
            _p_val_status = "ERR"
            check_send_status = 8
            say msgid" ERROR setting of variables:"
            say msgid" Variable "_p_var_" not supported."
            leave
          end;
      end
   end
   return check_send_status
