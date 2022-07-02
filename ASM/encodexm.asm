//TSSLLLX  JOB (TSSLLL-61218,S04),
//             'S04 LELAND LUCIUS',
//             CLASS=A,MSGCLASS=T,
//             MSGLEVEL=(1,1),
//             COND=(0,NE)
//*
//* -------------------------------------------------------------------
//* Specify load library
//* -------------------------------------------------------------------
//LOADLIB  SET  LOADLIB='TSSLLL.LOADLIB'
//*
//* -------------------------------------------------------------------
//* Assemble
//* -------------------------------------------------------------------
//ASM      EXEC  PGM=ASMA90,
//             PARM='NODECK,OBJECT,XREF(SHORT),RENT'
//SYSLIB   DD  DSN=SYS1.MACLIB,
//             DISP=SHR
//SYSUT1   DD  SPACE=(CYL,1),
//             UNIT=SYSDA
//SYSPUNCH DD  DUMMY
//SYSPRINT DD  SYSOUT=*
//SYSLIN   DD  DISP=(,PASS),
//             SPACE=(CYL,1),
//             UNIT=SYSDA
//SYSIN    DD  *
*| ====================================================================
*| Function : Transform input data to base64 encoding.
*|
*| Rent     : Yes (can be placed in LPA if used frequently)
*|
*| Amode    : Must run in 31-bit addressing mode
*|
*| Rmode    : Above or below...
*|
*| Return   : If no errors are encountered, the return value will be
*|            0 and the target set will contain the encoded data.  The
*|            0th member will contain the number of members in the set.
*|
*|            All errors are indicated with non-zero return code:
*|
*|                    1 = No parameters passed
*|                    2 = Source stem too long
*|                    3 = Destination argument missing
*|                    4 = Destination stem too long
*|                    5 = Too many arguments
*|                    6 = Source count not numeric (stem.0)
*|                    7 = Source compound variable name too long
*|                    8 = Destination compound variable name too long
*|             998-1255 = IRXEXCOM Fetch return code - 1000
*|            1998-2255 = IRXEXCOM Store return code - 2000
*|
*| Descript : This external REXX function implements the base64
*|            encoding scheme described in RFC2045.  Please refer to
*|            http://www.faqs.org/rfcs/rfc2045.html for the full
*|            description of the scheme.
*|
*| Usage    : ENCODEXM( stem1, stem2 )
*|
*|            stem1
*|                The stem or prefix of the set of variables whose
*|                contents will be converted.  Stem.0 (Prefix0) must
*|                contain the number of members in the set.
*|
*|            stem2
*|                The stem or prefix of the set of variables where
*|                the encoded data will be stored.
*|
*| Example  :
*|            istem.0 = 3
*|            istem.1 = "This is #1"
*|            istem.2 = "And here we have #2"
*|            istem.3 = "#3 will be the last one"
*|
*|            res = ENCODEXM( "istem.", "ostem." )
*|
*|            SAY "Encoding result:" res
*|            SAY "Output count:" ostem.0
*|            DO i = 1 TO ostem.0
*|              SAY "ostem." || i || ":" ostem.i
*|            END
*|
*| Author   : Leland Lucius <leland.lucius@ecolab.com>
*|
*| Changes  : 2002/02/17 - LLL - Initial version
*|            2002/04/01 - LLL - Corrected storage release during
*|                               buffer expansion
*|                             - Needed to clear workare storage
*|            2002/08/01 - LLL - Fixed problem with short (1 or 2 byte)
*|                               input records.
*|            2002/10/12 - LLL - Handle null variables
*|            2016/04/26 - LBD - Name change to avoid confusion with
*| encode64 from other sources
*|
*| ====================================================================
ENCODEXM CSECT                                Section
ENCODEXM AMODE    31                          Must be 31
ENCODEXM RMODE    ANY                         Could be 24, but why?
* ---------------------------------------------------------------------
* Setup base registers and addressability
* ---------------------------------------------------------------------
         SAVE     (14,12),,*                  Save caller's registers
         LR       R12,R15                     Get base
         USING    ENCODEXM,R12                Map CSECT
         LR       R3,R1                       Save EFPL ptr
         USING    EFPL,R3                     Map EFPL
         LR       R2,R0                       Save ENVB ptr
         USING    ENVBLOCK,R2                 Map ENVB
* ---------------------------------------------------------------------
* Grab some work area storage, chain, and map
* ---------------------------------------------------------------------
         STORAGE  OBTAIN,LENGTH=WORKLEN       Get storage
         LR       R4,R1                       Save work addr
         LR       R14,R1                      Set dest addr
         L        R15,=A(WORKLEN)             Set dest len
         LR       R0,R1                       Set source addr
         SR       R1,R1                       Set source len + pad
         MVCL     R14,R0                      Clear it
         ST       R13,4(,R4)                  Save callers savearea
         ST       R4,8(,R13)                  Store ours in callers
         LR       R13,R4                      Establish ours
         USING    WORKAREA,R13                Map it
         ST       R2,ENVBA                    Store envblock ptr
         MVC      RESULT,=PL8'0'              Set RC to 0
* ---------------------------------------------------------------------
* Get default storage buffer for input values (with 3 pad bytes)
* ---------------------------------------------------------------------
         STORAGE  OBTAIN,LENGTH=256+3         Get storage
         ST       R1,IDATAP                   Store ptr
         MVC      IDATAL,=F'256'              And length
* ---------------------------------------------------------------------
* Initialize input controls
* ---------------------------------------------------------------------
         MVC      INAMEX,=PL8'0'              Set name index to 0
         XR       R1,R1                       Set...
         ST       R1,INAMEL                   ...Name length to 0
         ST       R1,ITAILP                   ...Tail ptr to 0
* ---------------------------------------------------------------------
* Initialize output controls
* ---------------------------------------------------------------------
         MVC      ONAMEX,=PL8'0'              Set name index to 0
         ST       R1,ONAMEL                   Set name length to 0
         ST       R1,OTAILP                   Set tail ptr to 0
         MVC      ODATAL,=F'76'               Assume full output value
* ---------------------------------------------------------------------
* Setup translate table for uppercase conversion
* ---------------------------------------------------------------------
         MVI      TRTAB,X'40'                 Set to...
         MVC      TRTAB+1(L'TRTAB-1),TRTAB    ...all invalid
* ---------------------------------------------------------------------
* Grab a pointer to the rexx variable access routine
* ---------------------------------------------------------------------
         L        R1,ENVBLOCK_IRXEXTE         Get ptr to EXTE
         USING    IRXEXTE,R1                  Map EXTE
         L        R1,IRXEXCOM                 Get ptr to EXCOM
         DROP     R1                          Done with EXTE
         ST       R1,EXCOMA                   Save it
         DROP     R2                          Done with ENVB
* ---------------------------------------------------------------------
* Get base of evaluation block and map
* ---------------------------------------------------------------------
         L        R1,EFPLEVAL                 Get ptr to ptr to EVAL
         L        R1,0(R1)                    Get ptr to EVAL
         ST       R1,EVALA                    Save it
         L        R10,EFPLARG                 Get ptr to arguments
         DROP     R3                          Done with EFPL
* ---------------------------------------------------------------------
* Address and map the arguments
* ---------------------------------------------------------------------
         USING    ARGTABLE_ENTRY,R10          Map ARGTABLE
* ---------------------------------------------------------------------
* Error if there are no arguments
* ---------------------------------------------------------------------
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BE       ERR1                        Yes, need at least 2
* ---------------------------------------------------------------------
* Validate "FROM" stem and copy to work area
* ---------------------------------------------------------------------
         L        R15,ARGTABLE_ARGSTRING_LENGTH Get stem length
         CL       R15,=A(L'INAMEB)            Too big for a var name?
         BH       ERR2                        Yes, error
         ST       R15,ISTEML                  Save it
         LA       R1,INAMEB(R15)              Ptr to start of tail
         ST       R1,ITAILP                   Save it
         L        R1,ARGTABLE_ARGSTRING_PTR   Get ptr to stem
         BCTR     R15,0                       Decr for execute
         LA       R2,INAMEB                   Get ptr to work area
         EX       R15,XMOVE                   Move stem to work area
         EX       R15,XUCASE                  Convert to uppercase
* ---------------------------------------------------------------------
* Bump to next argument and verify it's there
* ---------------------------------------------------------------------
         LA       R10,ARGTABLE_NEXT           Gen ptr to next arg
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BE       ERR3                        Yes, need at least 1 more
* ---------------------------------------------------------------------
* Validate "TO" stem and copy to work area
* ---------------------------------------------------------------------
         L        R15,ARGTABLE_ARGSTRING_LENGTH Get stem length
         CL       R15,=A(L'ONAMEB)            Too big for a var name?
         BH       ERR4                        Yes, error
         ST       R15,OSTEML                  Save it
         LA       R1,ONAMEB(R15)              Ptr to start of tail
         ST       R1,OTAILP                   Save it
         L        R1,ARGTABLE_ARGSTRING_PTR   Get ptr to stem
         BCTR     R15,0                       Decr for execute
         LA       R2,ONAMEB                   Get ptr to work area
         EX       R15,XMOVE                   Move stem to work area
         EX       R15,XUCASE                  Convert to uppercase
* ---------------------------------------------------------------------
* Don't need anymore arguments
* ---------------------------------------------------------------------
         LA       R10,ARGTABLE_NEXT           Gen ptr to next arg
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BNE      ERR5                        No, don't need anymore
         DROP     R10                         Unmap ARGTABLE
* ---------------------------------------------------------------------
* Setup translate table for numeric validation
* ---------------------------------------------------------------------
         XC       TRTAB+C'0'(10),TRTAB+C'0'   Numbers are okay
* ---------------------------------------------------------------------
* Get the src count
* ---------------------------------------------------------------------
         BAL      R11,GETVAR                  Get 0th tail
         BCTR     R2,0                        Decr for execute
         EX       R2,XISNUM                   All numeric?
         BNE      ERR6                        No, error or not??????
         EX       R2,XPACK                    Pack it
         CVB      R10,NUMWORK+8               Convert to binary
         LTR      R10,R10                     Anything to do?
         BZ       ML60                        No, skip everything
* ---------------------------------------------------------------------
* Setup for main processing
* ---------------------------------------------------------------------
         LA       R8,ODATAB                   Get dest ptr
         LA       R9,76(R8)                   Dest end ptr
         XR       R5,R5                       Tuple buffer
         XR       R3,R3                       Bytes in tuple buffer
         LA       R10,1(R10)                  Bump it for fall through
* ---------------------------------------------------------------------
* Variable processing loop
* ---------------------------------------------------------------------
MLOOP    SL       R10,=F'1'                   Decr src count
         BP       ML40                        Exit loop if zero
         BAL      R11,GETVAR                  Get another value
         LR       R6,R1                       Save input ptr
         LTR      R7,R2                       Load and test length
         BZ       MLOOP                       Zero?, skip it
* ---------------------------------------------------------------------
* Value processing loop
* ---------------------------------------------------------------------
         LTR      R3,R3                       Working on partial?
         BNZ      ML25                        Yes, go finish it
ML10     LTR      R7,R7                       Zero length?
         BZ       MLOOP                       Yes, need more input
         CL       R7,=F'3'                    Have at least a tuple?
         BL       ML25                        No, go handle partial
* ---------------------------------------------------------------------
* At this point we will always have at least 1 complete tuple to
* process so we just load 3 bytes directly.
* ---------------------------------------------------------------------
         ICM      R5,B'1110',0(R6)            Insert tuple bytes
* ---------------------------------------------------------------------
* Break down tuple and store in dest
* ---------------------------------------------------------------------
ML15     XR       R4,R4                       Clear quad
         SLDL     R4,6                        Shift in 6 bits
         SLL      R4,2                        Position for next 6
         SLDL     R4,6                        Shift in 6 bits
         SLL      R4,2                        Position for next 6
         SLDL     R4,6                        Shift in 6 bits
         SLL      R4,2                        Position for next 6
         SLDL     R4,6                        Shift in 6 bits
         ST       R4,0(R8)                    Store quad
         LA       R8,4(R8)                    Bump dest to next loc
* ---------------------------------------------------------------------
* If dest buffer is full, go store it and start over
* ---------------------------------------------------------------------
         CLR      R9,R8                       Reached the end?
         BNE      ML20                        No, don't store it
         TR       ODATAB(76),CSET             Translate all at once
         BAL      R11,PUTVAR                  Go store value
         LA       R8,ODATAB                   Reset dest ptr
* ---------------------------------------------------------------------
* Adjust input parameters
* ---------------------------------------------------------------------
ML20     LA       R6,3(R6)                    Bump to next tuple
         SL       R7,=F'3'                    Adjust length
         B        ML10                        Back up for more
* ---------------------------------------------------------------------
* We've come here because we don't have enough bytes left in an input
* value to construct a complete tuple, in which case we load up what's
* left as a partial.
*
* The other reason is that we already have a partial tuple due to the
* first case and we need to try to finish it off.
* ---------------------------------------------------------------------
ML25     IC       R1,MASKA(R3)                Get mask
         EX       R1,MLICM                    Insert 1 byte
         LA       R6,1(R6)                    Bump input ptr
         LA       R3,1(R3)                    Bump tuple cnt
         CL       R3,=F'3'                    Have a complete tuple?
         BE       ML30                        Yes, deal with it
         BCT      R7,ML25                     Decr and loop
         B        MLOOP                       EOD, go get more
* ---------------------------------------------------------------------
* While processing a partial tuple, we completed it before running out
* of input data, so we need to reenter the main loop to output it.
* But, we need to lie about how many input bytes we have left since it
* assumes that exactly 3 were processed.  That's not always the case
* down here, but we know we have 3 so everyone should be happy.
* ---------------------------------------------------------------------
ML30     SL       R7,=F'1'                    Adjust for last byte
         ALR      R7,R3                       Lie about input cnt
         SLR      R6,R3                       And input ptr
         XR       R3,R3                       Not more partial
         B        ML15                        Go output it
* ---------------------------------------------------------------------
* We've processed all src data so check for partial tuple
* ---------------------------------------------------------------------
ML40     LTR      R3,R3                       Have a partial?
         BZ       ML50                        No, we're done
* ---------------------------------------------------------------------
* Have a partial, so break down tuple and store in dest with padding
* ---------------------------------------------------------------------
         XR       R4,R4                       Clear quad
         SLDL     R4,6                        Shift in 6 bits
         SLL      R4,2                        Position for next 6
         SLDL     R4,6                        Shift in 6 bits
         SLL      R4,2                        Position for next 6
         SLDL     R4,6                        Shift in 6 bits
         SLL      R4,2                        Position for next 6
         SLDL     R4,6                        Shift in 6 bits
         MVC      0(4,R8),=X'40404040'        Store pad chars
         IC       R3,MASKP+1(R3)              Get mask
         EX       R3,XPART                    Start partial quad
         LA       R8,4(R8)                    Bump past pad chars
*
ML50     LA       R1,ODATAB                   Get ptr to dest buf
         SLR      R8,R1                       Calc number of bytes
         BP       ML60                        Zero?  Don't store it
         ST       R8,ODATAL                   Set final length
         BCTR     R8,0                        Decr for execute
         EX       R8,XTR                      Translate
         BAL      R11,PUTVAR                  Go store dest
* ---------------------------------------------------------------------
* Store dest count
* ---------------------------------------------------------------------
ML60     LA       R1,NUMWORK                  For 0 case
         UNPK     NUMWORK,ONAMEX              Unpack count
         OI       NUMWORK+(L'NUMWORK-1),X'F0' Kill sign
         TRT      NUMWORK,NUMTAB-C'0'         Look for 1st nzero
         LA       R15,1                       For 0 case
         BE       ML65                        All zeros
         LA       R15,NUMWORK+L'NUMWORK       Get len to end
         SR       R15,R1                      Calc len of move
ML65     ST       R15,ODATAL                  Set data len
         BCTR     R15,0                       -1 for execute
         EX       R15,XMVCNT                  Move to output
         MVC      ONAMEX,=PL8'-1'             Hack for 0th index
         BAL      R11,PUTVAR                  Go store the count
* ---------------------------------------------------------------------
* Routine exit
* ---------------------------------------------------------------------
REXIT    L        R3,EVALA                    Restore eval block ptr
         USING    EVALBLOCK,R3                Map it
         LA       R1,NUMWORK                  For 0 case
         UNPK     NUMWORK,RESULT              Unpack RESULT
         OI       NUMWORK+(L'NUMWORK-1),X'F0' Kill sign
         TRT      NUMWORK,NUMTAB-C'0'         Look for 1st nzero
         LA       R15,1                       For 0 case
         BE       RE10                        All zeros
         LA       R15,NUMWORK+L'NUMWORK       Get len to end
         SR       R15,R1                      Calc length of RESULT
RE10     ST       R15,EVALBLOCK_EVLEN         Store in eval block
         BCTR     R15,0                       Decr for execute
RE20     MVC      EVALBLOCK_EVDATA(0),0(R1)   Store result in EVAL
         EX       R15,RE20                    Move over result
         DROP     R3                          No longer needed
* ---------------------------------------------------------------------
* Free input buffer
* ---------------------------------------------------------------------
         L        R1,IDATAP                   Get ptr
         L        R2,IDATAL                   And length
         LA       R2,3(R2)                    Add in pad bytes
         STORAGE  RELEASE,ADDR=(R1),LENGTH=(R2) Release it
* ---------------------------------------------------------------------
* Free workarea and return to caller
* ---------------------------------------------------------------------
RETURN   LR       R1,R13                      Get workarea ptr
         L        R13,4(,R13)                 Restore callers savearea
         STORAGE  RELEASE,LENGTH=WORKLEN,ADDR=(R1) Release workarea
         L        R14,12(,R13)                Get return address
         LM       R0,R12,20(R13)              Restore registers
         XR       R15,R15                     Never gen a SYNTAX error
         BSM      0,R14                       Return to caller
* =====================================================================
* Retrieve the next src value
* =====================================================================
GETVAR   LA       R4,VARREQ                   -> Variable request
         USING    SHVBLOCK,R4                 Map it
* ---------------------------------------------------------------------
* Create compound variable name
* ---------------------------------------------------------------------
         LA       R1,NUMWORK                  For 0 case
         UNPK     NUMWORK,INAMEX              Unpack count
         OI       NUMWORK+(L'NUMWORK-1),X'F0' Kill sign
         TRT      NUMWORK,NUMTAB-C'0'         Look for 1st nzero
         LA       R15,1                       For 0 case
         BE       GV10                        All zeros
         LA       R15,NUMWORK+L'NUMWORK       Get len to end
         SR       R15,R1                      Calc len of tail
GV10     L        R2,ISTEML                   Get len of stem
         AR       R2,R15                      Calc len of name
         CL       R2,=A(L'INAMEB)             Enough room?
         BH       ERR7                        Name too long
         ST       R2,SHVNAML                  Set name len
         LA       R2,INAMEB                   -> Name buffer
         ST       R2,SHVNAMA                  Store it
         L        R2,ITAILP                   -> Start of tail
         BCTR     R15,0                       -1 for execute
         EX       R15,XMOVE                   Add tail to stem
* ---------------------------------------------------------------------
* Setup for next call
* ---------------------------------------------------------------------
         AP       INAMEX,=PL8'1'              Idx+1 for next time round
* ---------------------------------------------------------------------
* Complete the request block
* ---------------------------------------------------------------------
GV20     MVI      SHVCODE,SHVFETCH            Function code
         MVC      SHVBUFL,IDATAL              Value buf len
         MVC      SHVVALA,IDATAP              Value buf ptr
* ---------------------------------------------------------------------
* Retrieve the value
* ---------------------------------------------------------------------
         L        R15,EXCOMA                  -> Routine
         CALL     (15),(EXCOM,0,0,VARREQ,ENVBA),VL,MF=(E,EXCOMPL)
* ---------------------------------------------------------------------
* Good result?
* ---------------------------------------------------------------------
         L        R1,SHVVALA                  -> data buffer
         L        R2,SHVVALL                  Get data len
         LTR      R15,R15                     Good?
         BZR      R11                         Yes, return
* ---------------------------------------------------------------------
* Any error other than truncation?
* ---------------------------------------------------------------------
         TM       SHVRET,SHVTRUNC             Truncated?
         BNO      ERR1000                     No, go handle error
* ---------------------------------------------------------------------
* Value truncated so free original buffer and allocate a larger one
* ---------------------------------------------------------------------
         L        R2,IDATAL                   Len of data buffer
         LA       R2,3(R2)                    Add in pad bytes
         L        R1,IDATAP                   -> data buffer
         STORAGE  RELEASE,ADDR=(R1),LENGTH=(R2) Release prev buffer
         L        R2,SHVVALL                  Required length
         AL       R2,=F'256'                  A little fudge
         ST       R2,IDATAL                   Store len
         LA       R2,3(R2)                    Add in pad bytes
         STORAGE  OBTAIN,LENGTH=(R2)          Get new buffer
         ST       R1,IDATAP                   Store ptr
         B        GV20                        Retry
         DROP     R4                          No longer needed
* =====================================================================
* Store the next output value
* =====================================================================
PUTVAR   LA       R4,VARREQ                   -> Variable request
         USING    SHVBLOCK,R4                 Map it
* ---------------------------------------------------------------------
* Setup for next call
* ---------------------------------------------------------------------
         AP       ONAMEX,=PL8'1'              Idx+1 for next time round
* ---------------------------------------------------------------------
* Create compound variable name
* ---------------------------------------------------------------------
         LA       R1,NUMWORK                  For 0 case
         UNPK     NUMWORK,ONAMEX              Unpack count
         OI       NUMWORK+(L'NUMWORK-1),X'F0' Kill sign
         TRT      NUMWORK,NUMTAB-C'0'         Look for 1st nzero
         LA       R15,1                       For 0 case
         BE       PV10                        All zeros
         LA       R15,NUMWORK+L'NUMWORK       Get len to end
         SR       R15,R1                      Calc len of tail
PV10     L        R2,OSTEML                   Get len of stem
         AR       R2,R15                      Calc len of name
         CL       R2,=A(L'ONAMEB)             Enough room?
         BH       ERR8                        Name too long
         ST       R2,SHVNAML                  Set name len
         LA       R2,ONAMEB                   -> Name buffer
         ST       R2,SHVNAMA                  Store it
         L        R2,OTAILP                   -> Start of tail
         BCTR     R15,0                       -1 for execute
         EX       R15,XMOVE                   Add tail to stem
* ---------------------------------------------------------------------
* Complete the request block
* ---------------------------------------------------------------------
         MVI      SHVCODE,SHVSTORE            Function code
         XC       SHVBUFL,SHVBUFL             Clear buffer length
         MVC      SHVVALL,ODATAL              Value length
         LA       R1,ODATAB                   -> Output buffer
         ST       R1,SHVVALA                  Value ptr
* ---------------------------------------------------------------------
* Store the value
* ---------------------------------------------------------------------
         L        R15,EXCOMA                  -> Routine
         CALL     (15),(EXCOM,,,VARREQ,ENVBA),VL,MF=(E,EXCOMPL)
* ---------------------------------------------------------------------
* Good result?
* ---------------------------------------------------------------------
         LTR      R15,R15                     Good?
         BZR      R11                         Yes, return
         B        ERR2000                     Go report error
         DROP     R4                          No longer needed
* ---------------------------------------------------------------------
* Error routines
* ---------------------------------------------------------------------
ERR2000  AL       R15,=F'2000'                Failure putting variable
         B        REXIT                       Go cleanup
ERR1000  AL       R15,=F'1000'                Failure getting variable
         B        REXIT                       Go cleanup
ERR8     AP       RESULT,=PL8'1'              Dest name too long
ERR7     AP       RESULT,=PL8'1'              Src name too long
ERR6     AP       RESULT,=PL8'1'              Src stem.0 not numeric
ERR5     AP       RESULT,=PL8'1'              Too many arguments
ERR4     AP       RESULT,=PL8'1'              Dest stem too long
ERR3     AP       RESULT,=PL8'1'              Dest argument missing
ERR2     AP       RESULT,=PL8'1'              Src stem too long
ERR1     AP       RESULT,=PL8'1'              No parameters
         CVB      R15,RESULT                  Convert RC to binary
         B        REXIT                       Go cleanup
* ---------------------------------------------------------------------
* Executed instructions
* ---------------------------------------------------------------------
XMOVE    MVC      0(0,R2),0(R1)               Move data
XUCASE   OC       0(0,R2),TRTAB               Convert data to uppercase
XMVCNT   MVC      ODATAB(0),0(R1)             Executed
XPACK    PACK     NUMWORK,0(0,R1)             Executed
XPART    STCM     R4,B'0000',0(R8)            Executed
XTR      TR       ODATAB(0),CSET              Executed
XISNUM   TRT      0(0,R1),TRTAB               Executed
MLICM    ICM      R5,B'0000',0(R6)            Inserts tuple bytes
* ---------------------------------------------------------------------
* Static data area
* ---------------------------------------------------------------------
MASKC    DC       B'1110,0110,0010,0000'      Complete tuple masks
MASKA    DC       B'1000,0100,0010,0000'      Update tuple masks
MASKP    DC       B'0000,1000,1100,1110'      Partial tuple masks
EXCOM    DC       CL8'IRXEXCOM'               EXCOM Name
NUMTAB   DC       X'00',C'123456789'          Zero suppression table
CSET     DC       C'ABCDEFGHIJKLMNOPQRSTUVWXYZ' Base64...
         DC       C'abcdefghijklmnopqrstuvwxyz' ...character...
         DC       C'0123456789+/='              ...set
         LTORG                                Literals
* ---------------------------------------------------------------------
* Put argument list here to get access to constant data
* ---------------------------------------------------------------------
         IRXARGTB DECLARE=YES   REXX Argument Table DSECT (and lits)
* ---------------------------------------------------------------------
* Drop inactive usings
* ---------------------------------------------------------------------
         DROP     R12                         No longer needed
* ---------------------------------------------------------------------
* Our very own workarea DSECT
* ---------------------------------------------------------------------
WORKAREA DSECT
SAVEAREA DS       18F                         Standard save area
* ---------------------------------------------------------------------
* Misc. variables
* ---------------------------------------------------------------------
NUMWORK  DS       XL16                        Typical number work area
RESULT   DS       PL8                         Execution result
TRTAB    DS       XL256                       Translation table
EXCOMPL  CALL     ,(IRXEXCOM,,,VARREQ,ENVBA),MF=L REXX EXCOM plist
VARREQ   DS       XL(SHVBLEN)                 Variable request block
EXCOMA   DS       A                           REXX EXCOM rtn addr
ENVBA    DS       A                           REXX ENVB ptr
EVALA    DS       A                           REXX EVAL ptr
* ---------------------------------------------------------------------
* Source controls
* ---------------------------------------------------------------------
IDATAL   DS       F                           Buffer length
IDATAP   DS       A                           Buffer pointer
ISTEML   DS       F                           Stem length
ITAILP   DS       A                           Start of tail ptr
INAMEX   DS       PL8                         Tail index
INAMEL   DS       F                           Name length
INAMEB   DS       CL250                       Name buffer
* ---------------------------------------------------------------------
* Destination controls
* ---------------------------------------------------------------------
ODATAL   DS       F                           Buffer length
ODATAB   DS       CL80                        Buffer = 76 + 4 PAD bytes
OSTEML   DS       F                           Stem length
OTAILP   DS       A                           Start of tail ptr
ONAMEX   DS       PL8                         Tail index
ONAMEL   DS       F                           Name length
ONAMEB   DS       CL250                       Name buffer
*
WORKLEN  EQU      *-WORKAREA                  Length of workarea
* ---------------------------------------------------------------------
* Register equates
* ---------------------------------------------------------------------
         YREGS                                Register equates
* ---------------------------------------------------------------------
* Rest of REXX control blocks
* ---------------------------------------------------------------------
         IRXEFPL                REXX Function Parameter List DSECT
         IRXEVALB               REXX Evaluation Block DSECT
         IRXENVB                REXX Environment Block DSECT
         IRXSHVB                REXX Variable Request DSECT
         IRXEXTE                REXX External Entry Points DSECT
* ---------------------------------------------------------------------
* The world is square ya know...careful you don't fall off!
* ---------------------------------------------------------------------
         END
/*
//*
//* -------------------------------------------------------------------
//* Link
//* -------------------------------------------------------------------
//LINK     EXEC  PGM=IEWL,
//             COND=(5,LT,ASM),
//             PARM='MAP,LET,LIST,NCAL,RENT,REUS'
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  DSN=&SYSUT1,
//             SPACE=(CYL,(3,2)),
//             UNIT=VIO
//SYSLMOD  DD  DSN=&LOADLIB,
//             DISP=SHR
//SYSLIN   DD  DSN=*.ASM.SYSLIN,
//             DISP=(OLD,DELETE)
//         DD  *
  NAME ENCODEXM(R)
/*
//
