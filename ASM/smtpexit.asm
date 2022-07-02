*/*                                                                  */
*/* Copyright:    Licensed Materials - Property of IBM               */
*/*               "Restricted Materials of IBM"                      */
*/*               5694-A01                                           */
*/*               (C) Copyright IBM Corp. 2001                       */
*/*               US Government Users Restricted Rights -            */
*/*               Use, duplication or disclosure restricted by       */
*/*               GSA ADP Schedule Contract with IBM Corp.           */
*/*                                                                  */
*/* Status:       CSV1R2                                             */
*/*                                                                  */
*/* Change Activity -                                                */
*/* 07/18/2003 - Cleanup and Improved comments                       */
*/* 07/17/2003 - Modified by Lionel B. Dyck of Kaiser Permanente     */
*/*              to restrict e-mail FROM to KP.ORG only              */
*/* 09/06/2002 - Sample requires Version 2 of EZBZSMTP MACRO         */
*---------------------------------------------------------------------
*
*  This sample exit provided by IBM has been modified to restrict
*  inbound SMTP e-mail to only mail from a specified domain.
*  See the label below IDTABLE for the domain(s) to be checked.
*
*  IT CURRENTLY IMPLEMENTS A CHECK FOR MAIL FROM: AND RCPT TO: TO
*  INSURE THAT THE FIRST CHARACTER IS NOT A '@'.  THIS WILL PREVENT
*  ANYONE FROM USING SOURCE ROUTING VIA THE SMTP PROGRAM ON EITHER THE
*  SENDER OR RECEIVER.
*
*  Caveat: This will NOT prevent 100% of spam as a spammer could create
*          a FROM address that appears to be from your domain.
*
*  A SAMPLE - Modified.
*
*  THIS EXIT MUST BE REENTRANT AND AMODE 31, IN AN AUTHORIZED LIBRARY.
*  THE LINK CARDS I USED ARE AS FOLLOWS:
*       ORDER SMTPEXIT
*       INCLUDE OBJ(SMTPEXIT)
*       SETCODE AC(1)
*       NAME    SMTPEXIT(R)
*
*  THE FOLLOWING IS IN SYS1.PARMLIB(PROGXX)
*   EXIT DELETE EXITNAME(EZBTCPIPSMTPEXIT) MODNAME(SMTPEXIT) FORCE(YES)
*   EXIT ADD EXITNAME(EZBTCPIPSMTPEXIT) MODNAME(SMTPEXIT)
*
*  AT THE MAIN CONSOLE ENTER 'SET PROG=XX' TO ACTIVATE THE PARMLIB
*  MEMBER (OR GET YOUR SYSTEM ADMINISTRATOR TO ACTIVATE IT).
*
*  Then from a authorized TSO ID issue:
*
*      smsg tcpsmtp startexit
*
*  For Production purposes you need to only to the following:
*      1. place this exit in your linklist
*      2. update your PROGxx to include the EXIT ADD ..  statement
*      3. when the SMTP server starts the exit is active
*
*  For Testing purposes and refresh purposes do the following:
*      1. place this exit in your linklist
*      2. create a CSVLLAxx member in PARMLIB with
*         LIBRARIES(your.linklist.library)
*      3. From a operator console (sdsf ulog) issue
*         F LLA,UPDATE=xx
*      4. create a PROGxx with the EXIT DELETE .. followed by the
*         EXIT ADD ..
*      5. From a operator console (sdsf ulog) issue
*         T PROG=xx
*      6. From an authorized TSO ID issue:
*         smsg tcpsmtp stopexit
*         then
*         smsg tcpsmtp startexit
*
*  IT IS STRONGLY SUGGESTED THAT YOU READ RFC2505 AND RFC2635
*  BEFORE ATTEMPTING TO DESIGN YOUR EXIT. RFC821 AND RPC822 CONTAIN
*  BASIC INFORMATION ABOUT HOW SMTP WORKS AND IS ALSO USEFUL.
*
*  REGISTER USAGE:
*
*   # - USE
*   2 - POINTS TO PARMS - USE THE DSECT LABELS
*   3 - CONTAIN ACTION CODE SEE THE DSECT LABELS
*   4 - POINTS TO A PERMANENT USER WORK AREA
*   5 - POINTS TO ACTUAL BUFFER (IF THERE IS ONE)
*   6 - HAS LENGTH OF DATA IN BUFFER IF ANY
*   7 - USED TO MAKE SURE WE ARE CORRECT VERSION
*   8 - Used for the Work Buffer for the Domain Comparison
*  10 - Points to the table of Valid Domains
*  11 - USED AS BASE REGISTER
*  13 - SAVE AREA POINTER
*
*  THE FOLLOWING DSECT ICHRUTKN CAN BE FOUND IN SYS1.MACLIB FOR
*  MAPPING THE SAF TOKEN AREA.
*
*  AND HERE IT IS!
*
*  Register Equates
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
*
SMTP     TITLE 'SMTP SERVER EXIT'
SMTPEXIT CSECT
SMTPEXIT AMODE 31
SMTPEXIT RMODE ANY
         SAVE  (14,12),T,*         SAVE
         LR    R11,R15             GET BASE
         USING SMTPEXIT,R11
         LR    R2,R1               GET PARM REG
         USING EZBZSMTP,R2
         L     R7,EZBPVERS         GET VERSION # OF PARMLIST
         C     R7,F1               HOPE ITS 1
         BE    WEAREOK             --> WHEW
         C     R7,F2               VERSION 2 SUPPORTS OUTBOUND EXIT
         BE    WEAREOK             --> CONTINUE
         ABEND 1,DUMP              VERSION INCOMPATABLE DUMP TAKEN
*
WEAREOK  EQU   *
         L     R3,EZBPACTN         GETTING ACTION CODE
         LTR   R3,R3               CHECK ACTION CODE FOR ZERO OR MINUS
         BZ    BADACTN             GOTO BAD ACTION CODE LABEL
         BCTR  R3,0                SUBTRACT 1
         SLL   R3,2                MULTIPLY BY 4
         LTR   R3,R3               IF 0 NO WORK AREA (INIT CALL)
         BNZ   SKIPINIT            -->
         GETMAIN R,LV=MYLEN        NEED SOME BYTES
         LR    R4,R1               IN DSECT REG
         USING MYAREA,R4
         XC    WORKAREA,WORKAREA   CLEAR IT
         XC    SAFTOKEN,SAFTOKEN   CLEAR IT
         WTO   'SMTPEXIT INIT COMPLETE' MOSTLY FOR DEBUG
         B     COMMON              --> JOIN BACK IN
*
SKIPINIT EQU   *
         L     R4,EZBPUSER         GOT MY WORK AREA BACK
COMMON   EQU   *
         ST    R13,4(R4)           CHAIN SAVE AREA
         ST    R4,8(R13)           DITTO
         LR    R13,R4              SWAP
         L     R5,EZBPBUFF         BUFFER ADDR
         L     R6,EZBPDLEN         LENGTH OF DATA IN BUFFER
         LA    R15,EZBRAGN         AGAIN IS DEFAULT
CKTABLE  EQU   *
         LA    R8,EZBACONN         LOAD MAX ACTION CODE VALUE
         BCTR  R8,0                SUBTRACT 1
         SLL   R8,2                MULTIPLY BY 4
         CR    R3,8                COMPARE ACTION CODE TABLE OFFSETS
         BNH   CONTINUE            --> OK CONTINUE
BADACTN  ABEND 2,DUMP              FAIL OFFSET GREATER THAN TABLE
*
CONTINUE EQU   *
         STM   14,12,12(13)        JUST FOR DEBUGGING (LEAVE FOOTPRINT)
         B     ACTIONT(3)          --> GO TO ACTION CODE JUMP TABLE
*
ISTERM   EQU   *
         WTO   'SMTPEXIT TERMINATING'      MOSTLY FOR DEBUG
         L     R13,4(13)           UNDO THIS NOW
         FREEMAIN R,LV=MYLEN,A=(4)
         LA    R15,EZBRACC         ACTUALLY DOESNT MATTER TOO MUCH!!!
         B     TERMEXIT            --> HOME
*
ISDATA   EQU   *                   NEXT COME THE DATA BUFFERS
         LA    R15,EZBRACC         LETS MOVE ON AND SKIP THE DATA
         B     EXIT                --> WE ARE DONE
*
ISHELO   EQU   *                   CHECK CONNECTION IDENTIFIER
         L     R8,EZBPCNID         LOAD CONNECTION ID INTO REG 8
         C     R8,SPOOLID          COMPARE CONNECTION ID WITH SPOOL ID
         BNE   CONNECT             IS A TCP/IP CONNECTION?
*
ISJES    EQU   *                   JES CONNECTION PROCESSING
         L     R9,EZBPTOKP         LOAD SAF TOKEN ADDRESS INTO REG 9
         LTR   R9,R9               CHECK IF SAF TOKEN AVAILABLE
         BZ    NOTOKEN
TOKENOK  EQU   *                   TOKEN INFORMATION AVAILABLE
         MVC   SAFTOKEN(80),0(R9)  SAVE TOKEN INFORMATION
         B     EXIT                --> CONTINUE
NOTOKEN  EQU   *
         XC    SAFTOKEN,SAFTOKEN   CLEAR TOKEN INFORMATION
* You probably want to remove this WTO if you configured in SMTP
* configuration file the following statement:
* EXITDIRECTION BOTH SAFNO
         WTO   'SMTPEXIT- NO SAF TOKEN'  NO TOKEN INFORMATION FROM JES
         B     EXIT                --> CONTINUE
*
CONNECT  EQU   *                   CONNECTING IP ADDRESS IS OK
         B     EXIT                --> CONTINUE
*
ISRCPT   EQU   *                   THIS IS THE RECIPIANT OF THE MAIL
         CLI   1(R5),C'@'          IS HE USING US FOR A ROUTER?
         BE    REJECT              Yes - REJECT IT
         B     EXIT                --> Continue
*
ISMAIL   EQU   *                   THIS IS THE SENDER OF THE MAIL
         CLI   0(R5),C'<'          FIND < PRECEDING THE ID
         BE    GOTID               --> GOT IT
         A     R5,F1               BUMP ADDR UP BY 1
         B     ISMAIL              --> LOOP
*
GOTID    EQU   *
         CLI   1(R5),C'@'          IS HE USING US FOR A ROUTER?
         BE    REJECT              Yes - REJECT IT
         LA    R8,WORKBUF          Point to our work buffer
         EX    R6,MVCBUF           Move the Buffer
         OC    WORKBUF,=256C' '    Upper Case it
CKID     EQU   *                   Check the ID for KP.ORG
         CLI   0(R8),C'>'          End of Address ?
         BE    REJECT              Yes so Reject
         LA    R10,IDTABLE         -> Domain ID Table
DOMLOOP  EQU   *
         LH    R1,0(R10)           Load length of Domain
         S     R1,F1               Less 1 for compare
         EX    R1,CLCDOM           Compare Domains
         BE    EXIT                Yes - we like it so keep it
         AR    R10,R1              Add Domain length
         A     R10,F2              Now add 2 for length field
         A     R10,F1              And add the 1 back we removed
         CLC   0(2,R10),=H'00'     End of table
         BNE   DOMLOOP             No - get next Domain
         A     R8,F1               - Bump Buffer by 1
         B     CKID               --> and continue
*
REJECT   EQU   *                  ROUTED MAIL
         LA    R15,EZBRREJ         REJECT IT
         B     EXIT                --> AND WE ARE ALL DONE
*
ISDBUF   EQU   *                   WORD CHECKER LOGIC HERE MAYBE
*                                  THIS MAY AFFECT PERFORMANCE
         B     EXIT                --> CONTINUE
*
ISEODB   EQU   *                   LAST CHANCE REJECT THIS MESSAGE
         B     EXIT                --> CONTINUE
*
ISINIT   EQU   *
         LR    R15,R4              THIS IS MY RETURN CODE (GETMAIN @)
EXIT     EQU   *
         L     R13,4(R13)          GET ORIG SAVE AREA BACK
TERMEXIT EQU   *
         RETURN (14,12),T,RC=(15)
*
         CNOP  0,8                 LINE THEM UP
*        THE TABLE ORDER IS VERY IMPORTANT HERE
ACTIONT  B     ISINIT              --> INIT
         B     ISTERM              --> TERM
         B     ISDATA              --> DATA
         B     EXIT                EXPN SMTP COMMAND PLACE HOLDER
         B     ISHELO              --> HELO
         B     EXIT                HELP SMTP COMMAND PLACE HOLDER
         B     ISMAIL              --> MAIL
         B     EXIT                NOOP SMTP COMMAND PLACE HOLDER
         B     EXIT                QUEU SMTP COMMAND PLACE HOLDER
         B     EXIT                QUIT SMTP COMMAND PLACE HOLDER
         B     ISRCPT              --> RCPT
         B     EXIT                RSET SMTP COMMAND PLACE HOLDER
         B     EXIT                TICK SMTP COMMAND PLACE HOLDER
         B     EXIT                VERB SMTP COMMAND PLACE HOLDER
         B     EXIT                VRFY SMTP COMMAND PLACE HOLDER
         B     ISDBUF              --> DBUF
         B     ISEODB              --> EODB
         B     EXIT                END OF CONNECTION PLACE HOLDER
*
F1       DC    F'1'
F2       DC    F'2'
SPOOLID  DC    F'257'              CONNECTION DATA FROM JES SPOOL FILE
*
MVCBUF   MVC   0(0,R8),0(R5)       Move to work buffer  * executed
CLCDOM   CLC   0(0,R8),2(R10)      Compare Domains ** Executed
*
* --------------------------------------------------------- *
* The IDTABLE contains the list of valid Domain names.      *
*                                                           *
* The format is:                                            *
*    XL2     length of the domain name (in hex)             *
*    C       the domain name                                *
*                                                           *
* The length is the full length (e.g. IBM.COM is XL2'07'    *
*                                                           *
* The last entry is XL2'00'                                 *
* --------------------------------------------------------- *
*
IDTABLE  DS    0F                  Domain Table
         DC    XL2'6',C'KP.ORG'
         DC    XL2'0B',C'KAIPERM.ORG'
         DC    XL2'00'             End of Table
*
         CNOP  0,8
         LTORG ,
         CNOP  0,8
         EZBZSMTP ,
MYAREA   DSECT
         DC    9D'0'               SAVE AREA
WORKAREA DC    CL256' '            WORK AREA
SAFTOKEN DC    CL80' '             SAF TOKEN SAVE AREA
WORKBUF  DC    CL256' '            My Work Buffer
MYLEN    EQU   *-MYAREA            LENGTH
         END
