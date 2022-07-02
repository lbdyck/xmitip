        /* ---------------------  rexx procedure  ------------------- */
        ver = "01.07"
        /* Name:      XMITSOCK                                        *
         *                                                            *
         * Function: send a Mail to a Mail-Server via SOCKET-Services *
         *                                                            *
         * required Parm on call: IPADDR(ipaddr)                      *
         * optional Parm on call: DDNAME(ddname)                      *
         *                        TOKEN(token)                        *
         *                        XLATE(name of translate-table)      *
         *                        SERVICE(Name of TCP/IP)             *
         *                        BACKHLQ(Hlq of Backup-Dataset)      *
         *                                                            *
         * if TOKEN(x) is used, mail will be retrieved via STEMPULL-  *
         * external Function.                                         *
         *                                                            *
         * Default-Value for XLATE: TXT2PDFX                          *
         * Default-Value for Service:  DEFAULT                        *
         * Default-Value for BackHlq:  null-string                    *
         *                                                            *
         * Alternate: DDNAME(x); Default: MAILTEXT                    *
         *            Mail will be read from this DD-Name             *
         *                                                            *
         * STEMPUSH and STEMPULL are freeware from Rob Scotts         *
         *                                                            *
         * ---------------------------------------------------------- *
         *                                                            *
         * Author:    Werner Tomek                                    *
         *            Oberfinanzdirektion Karlsruhe                   *
         *            Landeszentrum fuer Datenverarbeitung            *
         *            70176 Stuttgart                                 *
         *            Germany                                         *
         *            Internet: Werner.Tomek@ofdka.bwl.de             *
         *                                                            *
         * ---------------------------------------------------------- *
         *                                                            *
         * License:   This EXEC and related components are released   *
         *            under terms of the GPLV3 License. Please        *
         *            refer to the LICENSE file for more information. *
         *            Or for the latest license text go to:           *
         *                                                            *
         *              http://www.gnu.org/licenses/                  *
         *                                                            *
         * ---------------------------------------------------------- *
         *                                                            *
         * History:                                                   *
         *          2009-01-28 - 01.07                                *
         *                     - usage of RESOLVE-Service to convert  *
         *                       an "Fully Qualified Domain Name" to  *
         *                       an IP-Addr                           *
         *          2009-01-22 - 01.06                                *
         *                     - cosmetic change on SAY               *
         *          2008-11-20 - 01.05                                *
         *                     - correct <cr><lf> to X'0D15'          *
         *                       (was based on a wrong XLATE table)   *
         *                     - Parameter Debug() added              *
         *                     - Write out some DEBUG infos           *
         *          2008-11-06 - 01.04                                *
         *                     - Parameter Service() is now valid     *
         *          2008-10-28 - 01.03                                *
         *                     - invalid Syntax, if RC > 0 after      *
         *                       EXECIO for Mail                      *
         *                     - New Error-Msg, if Mail-Dataset empty *
         *                       not be sent.                         *
         *          2008-09-29 - 01.02                                *
         *                     - Parameter BACKHLQ()                  *
         *                     - create Backup-Dataset, if Mail could *
         *                       not be sent.                         *
         *          2008-09-09 - 01.01                                *
         *                     - Parameter Xlate(xxxx)                *
         *                     - Parameter Service(xxx)               *
         *                     - X'0D25' in Read/Write-Data is        *
         *                       printed in Log as: <cr><lf>          *
         *          2008-09-05 - 01.00                                *
         *                     - Beta-Version                         *
         *                                                            *
         * ---------------------------------------------------------- */

Parms    = ""
do       P = 1 to Arg()
         Parms = Parms Translate(Arg(P))
end
Parms    = Translate(Parms," ",",")
Token    = ""
DDName   = ""
Debug    = ""
IPAddr   = ""
ExtName  = ""
ServName = ""
BackHlq  = ""
MyName   = "XMITSOCK"
Call     MyMsg "Version:" ver
do       forever
         if Parms = "" then leave
         Parse var Parms NextParm Parms
         Parse var NextParm ParmKey "(" ParmVal ")" .
         if Abbrev("SERVICE", ParmKey,1) = 1 & ParmVal = "" then do
            ParmVal = "DEFAULT"
            Call MyMsg "'SERVICE' defaulted to '"ParmVal"'"
         end
         if ParmVal = "" then do
            Call MyMsg "Parm-Key" ParmKey "has no Value."
            exit 222
         end
         Select
            when Abbrev("DEBUG"  , ParmKey,3) = 1 then do
                 Debug    = "ON"
            end
            when Abbrev("DDNAME" , ParmKey,1) = 1 then do
                 DDName   = ParmVal
            end
            when Abbrev("TOKEN"  , ParmKey,1) = 1 then do
                 Token    = ParmVal
            end
            when Abbrev("IPADDR" , ParmKey,1) = 1 then do
                 IPAddr   = ParmVal
            end
            when Abbrev("XLATE"  , ParmKey,1) = 1 then do
                 ExtName  = ParmVal
            end
            when Abbrev("SERVICE", ParmKey,1) = 1 then do
                 ServName = ParmVal
            end
            when Abbrev("BACKHLQ", ParmKey,1) = 1 then do
                 BackHlq  = ParmVal
            end
            otherwise do
                 Call MyMsg "invalid Parm" NextParm
                 exit 222
            end
         end
end
if       DDName""Token = "" then DDName = "MAILTEXT"
if       IPAddr = "" then do
         Call MyMsg "missing IPADDR"
         exit 222
end
if       ExtName = "" then ExtName = "TXT2PDFX"

Call     MyMsg "IPADDR="IPAddr
ExitCode = 0
Crlf     = X2C("0D 15")
MsgEnd   = Crlf"."Crlf

Hex00FF  = XRange("00"x,"FF"x)

/*          x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 xA xB xC xD xE xF           */
ASCIITab = "00 01 02 03 9C 09 86 7F 97 8D 8E 0B 0C 0D 0E 0F", /* 0x */
           "10 11 12 13 9D 0A 08 87 18 19 92 8F 1C 1D 1E 1F", /* 1x */
           "A4 81 82 83 84 85 17 1B 88 89 8A 8B 8C 05 06 07", /* 2x */
           "90 91 16 93 94 95 96 04 98 99 9A 9B 14 15 9E 1A", /* 3x */
           "20 A0 E2 7B E0 E1 E3 E5 E7 F1 C4 2E 3C 28 2B 21", /* 4x */
           "26 E9 EA EB E8 ED EE EF EC 7E DC 24 2A 29 3B 5E", /* 5x */
           "2D 2F C2 5B C0 C1 C3 C5 C7 D1 F6 2C 25 5F 3E 3F", /* 6x */
           "F8 C9 CA CB C8 CD CE CF CC 60 3A 23 A7 27 3D 22", /* 7x */
           "D8 61 62 63 64 65 66 67 68 69 AB BB F0 FD FE B1", /* 8x */
           "B0 6A 6B 6C 6D 6E 6F 70 71 72 AA BA E6 B8 C6 80", /* 9x */
           "B5 DF 73 74 75 76 77 78 79 7A A1 BF D0 DD DE AE", /* Ax */
           "A2 A3 A5 B7 A9 40 B6 BC BD BE AC 7C AF A8 B4 D7", /* Bx */
           "E4 41 42 43 44 45 46 47 48 49 AD F4 A6 F2 F3 F5", /* Cx */
           "FC 4A 4B 4C 4D 4E 4F 50 51 52 B9 FB 7D F9 FA FF", /* Dx */
           "D6 F7 53 54 55 56 57 58 59 5A B2 D4 5C D2 D3 D5", /* Ex */
           "30 31 32 33 34 35 36 37 38 39 B3 DB 5D D9 DA 9F"  /* Fx */

E2ATab   = Copies('00'x,256)

do       W = 1 to Words(ASCIITab)
         Wd = X2D(Word(ASCIITab,W))
         if Wd = 0 then iterate
         E2ATab = OverLay(D2C(Wd),E2ATab,W,1)
end

Signal   on Syntax Name NoExtTab
Interpret "CALL" ExtName
ExtData  = Result
if       Length(ExtData) > 255 then do
         E2ATab = Left(ExtData,256)
         Call MyMsg "external Translate-Table" ExtName "used"
end

NoExtTab:
Signal   off Syntax

NextFree = 0
do       P = 2 to 256
         if SubStr(E2ATab,P,1) <> "00"x then iterate
         do forever
            if Pos(D2C(NextFree),E2ATab) > 0 then do
               NextFree = NextFree + 1
               iterate
            end
            else do
              E2ATab = OverLay(D2C(NextFree),E2ATab,P,1)
              leave
            end
         end
end

A2ETab   = Copies('00'x,256)

E2A.     = ""
TabError = "N"

do       P = 1 to 256
         HexCode = C2X(SubStr(E2ATab,P,1))
         DecCode = X2D(HexCode)
         if E2A.DecCode <> "" then do
            Call MyMsg "multiple used E2A-Code:" HexCode
            TabError = "Y"
            iterate
         end
         E2A.DecCode = HexCode
         if SubStr(A2ETab,DecCode+1,1) <> "00"x then do
            Call MyMsg "A2E-Code" C2X(HexCode) "multiple occupied"
            TabError = "Y"
            iterate
         end
         A2ETab = OverLay(D2C(P-1),A2ETab,1+X2D(HexCode),1)
end

if       C2X(SubStr(E2ATab,1+X2D(0D),1)) <> "0D" then do
         Call MyMsg "Position X'0D' in" ExtName "should be X'0D'",
                    "and not X'"C2X(SubStr(E2ATab,1+X2D(0D),1))"'"
         TabError = "Y"
end

if       C2X(SubStr(E2ATab,1+X2D(15),1)) <> "0A" then do
         Call MyMsg "Position X'15' in" ExtName "should be X'0A'",
                    "and not X'"C2X(SubStr(E2ATab,1+X2D(15),1))"'"
         TabError = "Y"
end

if       TabError <> "N" then do
         Call MyMsg "The EBCDIC<>ASCII-Table is in error - terminating"
         Return 222
end

ACrlf    = Translate(CRLF,E2ATAB,Hex00FF)

Numeric  Digits 25
TCB      = Adr(0000    , 21C)
JSCB     = Adr(TCB     ,  B4)
SSIB     = Adr(JSCB    , 13C)
JobNr    = Sto(SSIB    ,   C,  8)
MyTaskID = "MTI"SubStr(JobNr,4)

if       Debug = "ON" then do
         Call     MyMsg "DEBUG - CRLF     =",
                        ""Left(Crlf,5)""C2X(Crlf)"",
                        "(should be 0D15)"
         Call     MyMsg "DEBUG - ACrlf    =",
                        ""Left(ACrlf,5)""C2X(ACrlf)"",
                        "(should be 0D0A)"
         Call     MyMsg "DEBUG - MyTaskID = "MyTaskID" ("JobNr")"
end

if       Token = "" then do
         "EXECIO  * DISKR" DDname " (Stem Mail. Finis"
         if RC > 0 then do
            Call MyMsg "RC="Rc "on EXECIO with DD-Name" DDname
            Return 322
         end
         if Mail.0 = 0 then do
            Call MyMsg "missing Data on File with DD-Name" DDName
            Return 422
         end
end
else     do
         StemRead = StemPull(Token)
end

Signal   on Syntax

Service  = "INITIALIZE"
SocketRC = Socket(Service,MyTaskID,,ServName)
if       Word(SocketRC,1) <> 0 then do

         /************************************************************/
         /*                                                          */
         /*  following RC's are possible:                            */
         /*                                                          */
         /*     9 EBADF                                              */
         /*    22 EINVAL                                             */
         /*    38 ENOTSOCK                                           */
         /*    45 EOPNOTSUPP                                         */
         /*  1004 EIBMIUCVERR                                        */
         /*  2001 EINVALIDRXSOCKETCALL                               */
         /*  2003 ESUBTASKINVALID                                    */
         /*  2004 ESUBTASKALREADYACTIVE                              */
         /*  2012 EINVALIDNAME                                       */
         /*                                                          */
         /*  more Informations:                                      */
         /*                                                          */
         /*  Communications Server IP Sockets Application            */
         /*  Programming Interface Guide and Reference               */
         /*  Chapter: REXX socket application programming interface  */
         /*  SC31-8788-xx                                            */
         /*                                                          */
         /************************************************************/

         Call MyMsg "Socket-Initialization failed."
         RCCode = Word(SocketRC,1)
         Call MyMsg "Socket("Service")-RC-Code =" RCCode
         Call Backup
         Return RCCode
end

Service  = "VERSION"
SocketRC = Socket(Service)
if       Word(SocketRC,1) <> 0 then do
         RCCode = Word(SocketRC,1)
         Call MyMsg "Socket("Service")-RC-Code =" RCCode
         Call Backup
         Return RCCode
end
else     do
         Parse var SocketRC . SocketVers
         Call MyMsg "Version-Info:" SocketVers
end

Service  = "RESOLVE"
SocketRC = Socket(Service,IPAddr)
if       Word(SocketRC,1) <> 0 then do

         /************************************************************/
         /*                                                          */
         /*  following RC's are possible:                            */
         /*                                                          */
         /*       22 EINVAL                                          */
         /*     2001 EINVALIDRXSOCKETCALL                            */
         /*     2005 ESUBTASKNOTACTIVE                               */
         /*     2012 EINVALIDNAME                                    */
         /*     2016 EHOSTNOTFOUND                                   */
         /*                                                          */
         /************************************************************/

         RCCode = Word(SocketRC,1)
         Call MyMsg "Socket("Service")-RC-Code =" RCCode
         Call Backup
         Return RCCode
end
else     do
         Parse var SocketRC . ResolveAddr ResolveName .
         if ResolveAddr <> IPAddr then do
            Call MyMsg "'"IPAddr"' translated to",
                 ResolveAddr "by RESOLVE-Service"
            IPAddr = ResolveAddr
         end
end

Service  = "SOCKET"
SocketRC = Socket(Service,"AF_INET","STREAM")
if       Word(SocketRC,1) <> 0 then do

         /************************************************************/
         /*                                                          */
         /*  following RC's are possible:                            */
         /*                                                          */
         /*        9 EBADF                                           */
         /*       22 EINVAL                                          */
         /*       38 ENOTSOCK                                        */
         /*       45 EOPNOTSUPP                                      */
         /*      139 EPERM                                           */
         /*     2001 EINVALIDRXSOCKETCALL                            */
         /*     2005 ESUBTASKNOTACTIVE                               */
         /*     2007 EMAXSOCKETSREACHED                              */
         /*                                                          */
         /************************************************************/

         Call MyMsg "Socket-Initialization failed."
         RCCode = Word(SocketRC,1)
         Call MyMsg "Socket("Service")-RC-Code =" RCCode
         Call Backup
         Return RCCode
end
else     do
         Socketid = Word(SocketRC,2)
end

Service  = "SetSockOpt"
SetOpt   = "So_ASCII"
SetOptV  = "Off"
SocketRC = Socket(Service,SocketID,"Sol_Socket",SetOpt,SetOptV)
if       Word(SocketRC,1) <> 0 then do

         /************************************************************/
         /*                                                          */
         /*  following RC's are possible:                            */
         /*                                                          */
         /*        9 EBADF                                           */
         /*       22 EINVAL                                          */
         /*       38 ENOTSOCK                                        */
         /*       42 ENOPROTOOPT                                     */
         /*       45 EOPNOTSUPP                                      */
         /*       60 ETIMEDOUTP                                      */
         /*     2001 EINVALIDRXSOCKETCALL                            */
         /*     2005 ESUBTASKNOTACTIVE                               */
         /*     2009 ESOCKETNOTDEFINED                               */
         /*     2012 EINVALIDNAME                                    */
         /*                                                          */
         /************************************************************/

         Call MyMsg Service "("SetOpt") failed."
         RCCode = Word(SocketRC,1)
         Call MyMsg "Socket("Service")-RC-Code =" RCCode
         Call Backup
         Return RCCode
end
else     do
         Call MyMsg "Option" SetOpt "set to" SetOptV
end

Call     MyMsg "Start of Transfer; Time:" Time()

Service  = "Connect"
SocketRC = Socket(Service,SocketId,"AF_INET 25" IPAddr)
if       Word(SocketRC,1) <> 0 then do

         /************************************************************/
         /*                                                          */
         /*  following RC's are possible:                            */
         /*                                                          */
         /*        1 EPERM                                           */
         /*        9 EBADF                                           */
         /*       35 EWOULDBLOCK                                     */
         /*       36 EINPROGRESS                                     */
         /*       37 EALREADY                                        */
         /*       47 EAFNOSUPPORT                                    */
         /*       49 EADDRNOTAVAIL                                   */
         /*       51 ENETUNREACH                                     */
         /*       56 EISCONN                                         */
         /*       60 ETIMEDOUT                                       */
         /*       61 ECONNREFUSED                                    */
         /*     2001 EINVALIDRXSOCKETCALL                            */
         /*     2009 ESOCKETNOTDEFINED                               */
         /*                                                          */
         /************************************************************/

         Call MyMsg Service "failed."
         RCCode = Word(SocketRC,1)
         Call MyMsg "Socket("Service")-RC-Code =" RCCode
         ExitCode = RCCode
         Call Backup
         Signal Cancel
end

ReadData = SocketRead()
if       Left(ReadData,3) <> "220" then do
         Call MyMsg "SMTP Server Welcome Message(220) missing"
         ExitCode = 220
         Signal Cancel
end

Data     = "N"
FTime    = ""
TTime    = ""
MinDurat = 99999
MaxDurat = 0
Writes   = 0

MailKeys = "RCPT MAIL FROM: REPLY-TO: TO: ERRORS-TO: SENDER: CC:"
ServerNm = ""

do       Loop = 1 to Mail.0 - 3
         Mail.Loop = Strip(Mail.Loop,"T"," ")
         WS = SocketWrite(Mail.Loop""Crlf)
         if Data = "Y" then iterate
         MailKey = Left(Mail.Loop,4)
         if MailKey = "DATA" then Data = "Y"
         RS = SocketRead()
         if Left(RS,3) = "250" then  do
            if ServerNm = "" then Parse var RS . ServerNm .
            iterate
         end
         if Left(RS,3) = "354" then iterate
         Call MyMsg "missing Reponse 250/354 after sending" MailKey
         ExitCode = 250
         Signal Cancel
end

Data     = "N"
Call     MyMsg Writes "Writes, starting at" FTime,
                    "ending at" TTime,
                    "Min-Duration =" MinDurat,
                    "Max-Duration =" MaxDurat
WS       = SocketWrite(MsgEnd)
RS       = SocketRead()
if       Left(RS,3) <> "250" then do
         Call MyMsg "missing Reponse 250 after sending 'End-Of-Message'"
         ExitCode = 250
         Signal Cancel
end
else     do
         Parse var RS . RS
         if Pos("queued as",RS) = 0 then Call MyMsg Strip(RS,"T","?")
         else do
            if ServerNm <> "" then ServerNm = "on" ServerNm
            Parse var RS . "queued as" MailId .
            Call MyMsg "Your Mail is queued" ServerNm "with ID="MailId
         end
end

WS       = SocketWrite("QUIT"Crlf)
RS       = SocketRead()
if       RS <> "" then do
         if Left(RS,3) <> "221" then do
            Call MyMsg "missing Reponse 221 after sending 'QUIT'"
            ExitCode = 221
            Signal Cancel
         end
end

Service  = "CLOSE"
SocketRC = Socket(Service,SocketId)
if       Word(SocketRC,1) <> 0 then do

         /************************************************************/
         /*                                                          */
         /*  following RC's are possible:                            */
         /*                                                          */
         /*        9 EBADF                                           */
         /*     2001 EINVALIDRXSOCKETCALL                            */
         /*     2009 ESOCKETNOTDEFINED                               */
         /*                                                          */
         /************************************************************/

         Call MyMsg Service "failed."
         RCCode = Word(SocketRC,1)
         Call MyMsg "Socket("Service")-RC-Code =" RCCode
         ExitCode = RCCode
         Signal Cancel
end

Call     MyMsg "End of Transfer; Time:" Time()
Signal   Exit

Cancel:

Call     MyMsg "Transfer canceled; Time:" Time()
signal   Terminate

Terminate:

SocketRC = Socket("SocketSetStatus")
Call     MyMsg SocketRC
SocketRC = Socket("Terminate",SocketID)
Call     MyMsg SocketRC
Signal   Exit

Exit:

Exit     ExitCode

Backup:

if       BackHlq = "" then Return

BUDsn    = Strip(BackHlq,"T",".")
BUDsn    = BUDsn"."Jobnr"."Mvsvar("SYSNAME")
BUDsn    = BUDsn".D"Date("J")
BUDsn    = BUDsn".T"Left(Translate(12345678,Time(),12734856),6)
BackupT  = OutTrap("Trap.")
"ALLOC"  "SP(90,90) TRA NEW CAT DSN('"BUDsn"')",
         "LRECL(4096) RECFM(V B) RELEASE"
BackupT  = OutTrap("OFF")
if       Trap.0 > 0 then do
         Call MyMsg "****"
         Call MyMsg " "
         Call MyMsg "Allocation-Error - '"BUDsn"'"
         do X = 1 to Trap.0
            Call MyMsg Trap.X
         end
         Call MyMsg " "
         Call MyMsg "****"
         Return
end
BackupT  = OutTrap("Trap.")
"LISTA   STATUS"
T        = OutTrap("OFF")
do       X = 1 to Trap.0
         if Trap.X <> BUDsn then iterate
         X = X + 1
         Parse var Trap.X BUDDn .
         leave
end
X        = Mail.0 + 1
Mail.X   = "SERVICE="ServName "IPADDR="IPAddr
Mail.0   = X
do       X = 1 to Mail.0
         Mail.X = Translate(Mail.X,Hex00FF,Reverse(Hex00FF))
end

"EXECIO" Mail.0 "DISKW" BUDDn "(Stem Mail. Finis"
"FREE"   "FI("BUDDn")"
Call     MyMsg "****"
Call     MyMsg "Mail saved under name '"BUDsn"'"
Call     MyMsg "****"

Return

SocketRead:

Service  = "Read"
STime    = Time()
X        = Time("E")
SocketRC = Socket(Service,SocketId)
ETime    = Time()
Parse    var SocketRC RCCode SRLength SRData
Call     MyMsg "<"Left(Service,5)">",
             "Start:" Stime "End:" ETime,
             "Duration:" Right(" "Time("E"),10) "Seconds;",
             EditData(Left(Translate(SRData,A2ETab,Hex00FF),50))
SRData   = Translate(SRData,A2ETab,Hex00FF)
CrlfPos  = 1

if       RCCode <> 0 then do
         Call MyMsg "Socket("Service")-RC-Code =" RCCode
         ExitCode = RCCode
         Call Backup
         Signal Cancel
end

Return   SRData

SocketWrite:

Parse    arg SWData
TData    = SWData
if       WordPos(Translate(Word(SWData,1)),MailKeys) > 0 then do
         SWData = Translate(SWData,"B5"X,"7c"x)
end

SWData   = Translate(SWData,E2ATab,Hex00FF)

Service  = "Write"
STime    = Time()
X        = Time("E")
SocketRC = Socket(Service,SocketId,SWData)
ETime    = Time()
Duration = Time("E")
if       Data = "N" then do
         Call MyMsg "<"Left(Service,5)">",
                  "Start:" Stime "End:" ETime,
                  "Duration:" Right(" "Duration,10) "Seconds;",
                  EditData(Left(TData,50))
end
else     do
         MinDurat = Min(MinDurat,Duration)
         MaxDurat = Max(MaxDurat,Duration)
         if FTime = "" then FTime = Time()
                       else TTime = Time()
         Writes = Writes + 1
end
Parse    var SocketRC RCCode SRLength SRData
if       RCCode <> 0 then do
         Call MyMsg "Socket("Service")-RC-Code =" RCCode
         ExitCode = RCCode
         Call Backup
         Signal Cancel
end

Return   0

Syntax:

Call     MyMsg "Syntax-Error, Error-Code="RC
Call     MyMsg "RC="RC":" ErrorText(RC)
if       Translate(Service) = "INITIALIZE" & RC = 43 then do
         Call MyMsg " "
         Call MyMsg "You want to call SOCKET()-Services"
         Call MyMsg " "
         Call MyMsg "To use this Services, you (or your Sysprog) must:"
         Call MyMsg " "
         Call MyMsg "1. make available the TCP/IP-Load-Lib via",
                    "//STEPLIB"
         Call MyMsg " "
         Call MyMsg "2. Pack required Moduls at IPL-Time in LPA:"
         Call MyMsg " "
         Call MyMsg " following Statements must be added to IEALPAxx",
                    "in SYS1.PARMLIB-Concatenation"
         Call MyMsg " INCLUDE LIBRARY(SYS1.SEZALOAD)"
         Call MyMsg "    MODULES(EZBRXSOC,RXSOCKET,SOCKET,TCPERROR)"
         Call MyMsg " "
         Call MyMsg "3. Make Moduls dynamicly available via",
                    "Operator-Command:"
         Call MyMsg " "
         _msg_ = ""
         _msg_ = _msg_"   SETPROG LPA,ADD,DSN=SYS1.SEZALOAD,"
         _msg_ = _msg_"MOD=(EZBRXSOC,RXSOCKET,SOCKET,TCPERROR)"
         Call MyMsg ""_msg_
end

Return   222

MyMsg:

parse    arg MsgText

Say      MyName":" Strip(MsgText,"T"," ")
Return

EditData:

Parse    arg EText
do       forever
         CRLFPos = Pos(CRLF,EText)
         if CRLFPos = 0 then Return EText
         EText = Left(EText,CRLFPos-1)"<cr><lf>"SubStr(EText,CRLFPos+2)
end

Adr:     arg AdrA,AdrO,AdrL

if       AdrL = "" then AdrL = 4
AdrN     = Sto(AdrA,AdrO,AdrL)
if       Adrl = 4 then AdrN = BitAnd(AdrN,"7FFFFFFF"X)
Return   C2D(AdrN)

Sto:     arg StoA,StoO,StoL

if       StoL = "" then StoL = 4

Return   Storage(D2x(StoA + X2D(StoO)),StoL)
