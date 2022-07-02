//*
//* -------------------------------------------------------------------
//* Specify load library
//* -------------------------------------------------------------------
//LOADLIB  SET  LOADLIB='your.load.library'
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
*| Function : "Alleged RC4" or ARC4.
*|
*| Rent     : Yes (SHOULD be placed in LPA if used frequently)
*|
*| Amode    : Must run in 31-bit addressing mode
*|
*| Rmode    : Above or below...
*|
*| Return   : If no errors are encountered, the return value depends
*|            on the parameters passed.  (See below)
*|
*|            In the event of an error, a SYNTAX condition is forced
*|            and one of the following values will be placed in the
*|            ARC4RC return code variable.
*|
*|                    1 = No arguments specified
*|                    2 = CTX variable name missing
*|                    3 = Missing Key or Data argument
*|                    4 = Key not within bounds
*|                    5 = Failed to get the CTX variable
*|                    6 = CTX value is invalid
*|                    7 = Too many arguments
*|                    8 = Failed to get larger result block
*|                    9 = Failed to store the CTX variable
*|
*| Descript : This external REXX function implements the "Alleged RC4"
*|            (or ARC4) algorithm as posted to sci.crypt in 1994.  This
*|            algorithm may or may not produce similar results to the
*|            real RC4 algorithm and no claim is made otherwise. UAYOR
*|
*|            Since the ARC4 algorithm is symmetrical, this function
*|            is used to both encrypt and decrypt data.
*|
*| Usage    :                ---- Multi-Shot ----
*|
*|            Use this method when you want to encrypt multiple data
*|            items using the same key.  This allows you to generate
*|            the key once and feed in smaller chucks of data.  But,
*|            you can decrypt the data using any size chuck or even
*|            all at once.
*|
*|            First, generate the key by specifying the Key argument.
*|            Then make as many calls as is needed eithout the key
*|            argument.
*|
*|            Anytime you want to reinitialize the state just make a
*|            call with the Key argument again.
*|
*|            CALL T2Parc4( "Ctx", Key )
*|
*|            Data = T2Parc4( "Ctx", , Data )
*|
*|            "Ctx"
*|                This is the name (NOT value) of a variable where the
*|                ARC4 context is maintained.
*|
*|            Key
*|                The key that will be used to en/decrypt the data.  It
*|                can be any length between 1 and 256, but the defaults
*|                below limit it to 5 and 16.  This provides for 40-bit
*|                (5*8) to 128-bit (16*8) encryption keys.
*|
*|            Data
*|                The data that you wish to en/decrypt.
*|
*| Example  :
*|
*|            Key    = "The 128-bit key."
*|            Data   = "Something to encrypt"
*|            More   = " and even more."
*|
*|            CALL T2Parc4( "Ctx", Key )
*|            EData = T2Parc4( "Ctx", , Data )
*|            EMore = T2Parc4( "Ctx", , More )
*|
*|            SAY "Using the a key of '" || Key || "' to encrypt:"
*|            SAY " " Data
*|            SAY "And:"
*|            SAY " " More
*|            SAY "Produces:"
*|            SAY " " C2x( EData )
*|            SAY "And:"
*|            SAY " " C2x( EMore )
*|
*| Usage    :                 ---- One-Shot ----
*|
*|            When all you need is to encrypt one data item, using this
*|            method will be easier.  You specify all three arguments
*|            in one call to generate the key AND encrypt the data.
*|
*|            This method may also be used as the first call in the
*|            multi-shot method above since the context is initialized
*|            the same for both.
*|
*|            Data = T2Parc4( "Ctx", Key, Data )
*|
*|            "Ctx"
*|                This is the name (NOT value) of a variable where the
*|                ARC4 context is maintained.
*|
*|            Key
*|                The key that will be used to en/decrypt the data.  It
*|                can be any length between 1 and 256, but the defaults
*|                below limit it to 5 and 16.  This provides for 40-bit
*|                (5*8) to 128-bit (16*8) encryption keys.
*|
*|            Data
*|                The data that you wish to en/decrypt.
*|
*| Example  :
*|
*|            Key    = "The 128-bit key."
*|            Data   = "Something to encrypt"
*|            More   = " and even more."
*|
*|            EData = T2Parc4( "Ctx", Key , Data || More )
*|
*|            SAY "Using the a key of '" || Key || "' to encrypt:"
*|            SAY " " Data || More
*|            SAY "Produces:"
*|            SAY " " C2x( EData )
*|
*| Note     : The following 2 examples are NOT the same since each
*|            call to this function in the second example reinitializes
*|            the context rather than continuing from the previous
*|            state.
*|
*|            1:  Data = T2Parc4( "Ctx", "40bit", Data )
*|                Data = T2Parc4( "Ctx", , Data )
*|                Data = T2Parc4( "Ctx", , Data )
*|
*|            2:  Data = T2Parc4( "Ctx", "40bit", Data )
*|                Data = T2Parc4( "Ctx", "40Bit", Data )
*|                Data = T2Parc4( "Ctx", "40Bit", Data )
*|
*| Export   : Pursuant to Section 740.13(e) of the United States
*|            Export Administration Regulations, this source code was
*|            submitted to the ENC and BIS for License Exception TSU
*|            on August 11th, 2002.
*|
*|            It may not knowingly be exported to the countries and
*|            foreign nationals of Cuba, Iran, Iraq, Libya, Syria,
*|            North Korea and Sudan.  Refer to sections 740.17(b)(1)
*|            and 742.15(b)(3)(i) of the EAR for more information.
*|
*|            URL:  http://w3.access.gpo.gov/bis/index.html
*|
*| Author   : Leland Lucius <rexxfunc@homerow.net>
*|
*| License  : This routine is released under terms of the Q Public
*|            License.  Please refer to the LICENSE file for more
*|            information.  Or for the latest license text go to:
*|
*|            http://www.trolltech.com/developer/licensing/qpl.html
*|
*| Changes  : 2002/08/09 - LLL - Initial version
*|
*| ====================================================================
T2PARC4  CSECT                                Section
T2PARC4  AMODE    31                          Must be 31
T2PARC4  RMODE    ANY                         Could be 24, but why?
MINLEN   EQU      5                           40-bit minimum length
MAXLEN   EQU      16                          128-bit maximum length
* ---------------------------------------------------------------------
* Setup base registers and addressability
* ---------------------------------------------------------------------
         SAVE     (14,12),,*                  Save caller's registers
         LR       R12,R15                     Get base
         USING    T2PARC4,R12                 Map CSECT
         LR       R9,R0                       Save ENVB ptr
         LR       R10,R1                      Save EFPL ptr
         USING    EFPL,R10                    Map EFPL
* ---------------------------------------------------------------------
* Grab some work area storage and map
* ---------------------------------------------------------------------
         STORAGE  OBTAIN,LENGTH=WORKLEN       Get storage
         ST       R13,4(,R1)                  Save callers savearea
         ST       R1,8(,R13)                  Store ours in callers
         LR       R13,R1                      Establish ours
         USING    WORKAREA,R13                Map WORK
* ---------------------------------------------------------------------
* Grab some REXX routine ptrs
* ---------------------------------------------------------------------
         ST       R9,ENVBA                    Save ENVB
         USING    ENVBLOCK,R9                 Map ENVB
         L        R1,ENVBLOCK_IRXEXTE         Get ptr to EXTE
         USING    IRXEXTE,R1                  Map EXTE
         L        R15,IRXRLT                  Get ptr to RLT
         ST       R15,RLTA                    Save it
         L        R15,IRXEXCOM                Get ptr to EXCOM
         ST       R15,EXCOMA                  Save it
         DROP     R1                          Done with EXTE
         DROP     R9                          Done with ENVB
* ---------------------------------------------------------------------
* Get addressability to EVALBLOCK
* ---------------------------------------------------------------------
         L        R11,EFPLEVAL                Get ptr to eval addr
         L        R11,0(R11)                  Get EVAL addr
         USING    EVALBLOCK,R11               Map EVAL
         MVC      EVALBLOCK_EVLEN,=F'0'       Pre-init to null
* ---------------------------------------------------------------------
* Address and map the arguments
* ---------------------------------------------------------------------
         L        R2,EFPLARG                  Get ptr to arguments
         USING    ARGTABLE_ENTRY,R2           Map ARGTABLE
* ---------------------------------------------------------------------
* Error if there are no arguments
* ---------------------------------------------------------------------
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BE       ERR1                        Yes, need at least 1
* ---------------------------------------------------------------------
* Always need a context variable name
* ---------------------------------------------------------------------
         LM       R8,R9,ARGTABLE_ARGSTRING_PTR Get ptr and length
         LTR      R9,R9                       Null or missing?
         BZ       ERR2                        Yes, error
         STM      R8,R9,CTXNAMEA              Save ptr and length
* ---------------------------------------------------------------------
* Bump to next argument and verify it's there
* ---------------------------------------------------------------------
         LA       R2,ARGTABLE_NEXT            Gen ptr to next arg
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BE       ERR3                        Yes, need at least 1 more
* ---------------------------------------------------------------------
* Cache and validate "KEY" argument pointer and length
* ---------------------------------------------------------------------
         LM       R8,R9,ARGTABLE_ARGSTRING_PTR Get ptr and length
         LTR      R8,R8                       Missing?
         BZ       GETCTX                      Yes, get existing CTX
         CL       R9,=A(MINLEN)               Key length to low?
         BL       ERR4                        Yes, error
         CL       R9,=A(MAXLEN)               Key length to high?
         BH       ERR4                        Yes, error
* ---------------------------------------------------------------------
* Initialize the ARC4 context
* ---------------------------------------------------------------------
         MVC      A4CTX,=A(A4ID)              Set ID
         MVC      A4STATE,STATEI              Quick init
         XC       A4I,A4I                     I = 0
         XC       A4J,A4J                     J = 0
* ---------------------------------------------------------------------
* Prepare to swap bytes
* ---------------------------------------------------------------------
         XR       R7,R7                       B = 0
         XR       R6,R6                       J = 0
         XR       R5,R5                       I = 0
         LA       R0,256                      256 iterations
SWAP     IC       R7,A4STATE(R5)              B = State[ I ]
* ---------------------------------------------------------------------
* J = J + B + Key[ I % KeyLen ]
* ---------------------------------------------------------------------
         LR       R15,R5                      T1 = I
         XR       R14,R14                     Clear remainder
         DR       R14,R9                      I % KeyLen
         IC       R15,0(R14,R8)               T2 = Key[ T1 ]
         ALR      R6,R15                      J = J + T2
         ALR      R6,R7                       J = J + B
         N        R6,=F'255'                  Byte Index
* ---------------------------------------------------------------------
* Swap 'em
* ---------------------------------------------------------------------
         IC       R15,A4STATE(R6)             T2 = State[ J ]
         STC      R15,A4STATE(R5)             State[ I ] = T2
         STC      R7,A4STATE(R6)              State[ J ] = B
* ---------------------------------------------------------------------
* Bump to next and loop
* ---------------------------------------------------------------------
         LA       R5,1(R5)                    I = I + 1
         BCT      R0,SWAP                     Decr and loop
         B        CHKDATA                     Go check data arg
* ---------------------------------------------------------------------
* Retrieve the context variable
* ---------------------------------------------------------------------
GETCTX   LA       R4,VREQ                     Get request ptr
         XC       VREQ,VREQ                   Clear request block
         USING    SHVBLOCK,R4                 Map SHVB
* ---------------------------------------------------------------------
* Initialize request block
* ---------------------------------------------------------------------
         MVI      SHVCODE,SHVSYFET            Function code
         LA       R6,A4LEN                    Get buffer len
         LM       R7,R8,CTXNAMEA              Name ptr and length
         LA       R9,A4CTX                    Buffer ptr
         STM      R6,R9,SHVBUFL               Store the lot
* ---------------------------------------------------------------------
* Retrieve the value
* ---------------------------------------------------------------------
         L        R15,EXCOMA                  Get IRXEXCOM addr
         CALL     (15),(=C'IRXEXCOM',0,0,VREQ,ENVBA),VL,MF=(E,PLIST)
* ---------------------------------------------------------------------
* Good result?
* ---------------------------------------------------------------------
         CLI      SHVRET,SHVCLEAN             Execution OK?
         BNE      ERR5                        No, error
         CLC      SHVVALL,=A(A4LEN)           Possibly ours?
         BNE      ERR6                        No, error
         CLC      A4CTX,=A(A4ID)              One of ours?
         BNE      ERR6                        No, error
         DROP     R4                          No longer needed
* ---------------------------------------------------------------------
* Bump to next argument and verify it's there
* ---------------------------------------------------------------------
CHKDATA  LA       R2,ARGTABLE_NEXT            Gen ptr to next arg
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BE       PUTCTX                      Yes, go update the CTX
* ---------------------------------------------------------------------
* Cache "DATA" argument pointer and length
* ---------------------------------------------------------------------
         LM       R8,R9,ARGTABLE_ARGSTRING_PTR Get ptr and length
         LTR      R9,R9                       Null or missing?
         BZ       PUTCTX                      Yes, go update the CTX
* ---------------------------------------------------------------------
* Don't need anymore arguments
* ---------------------------------------------------------------------
         LA       R2,ARGTABLE_NEXT            Gen ptr to next arg
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BNE      ERR7                        No, don't need anymore
         DROP     R2                          Done with ARGTABLE
* ---------------------------------------------------------------------
* Current eval block have enough room?
* ---------------------------------------------------------------------
         L        R1,EVALBLOCK_EVSIZE         Get EVAL size
         SLL      R1,3                        Cvt to byte size
         S        R1,=A(EVALBLOCK_EVDATA-EVALBLOCK) Knock off CB
         CLR      R1,R9                       Big enough?
         BNL      LB01                        Yes, continue
* ---------------------------------------------------------------------
* Have to get new result block
* ---------------------------------------------------------------------
         ST       R9,EVALL                    Set required length
         L        R15,RLTA                    Get IRXRLTA ptr
         CALL     (15),(=C'GETBLOCK',EVALA,EVALL,ENVBA),VL,MF=(E,PLIST)
         LTR      R15,R15                     Success?
         BNZ      ERR8                        No, error
         L        R11,EVALA                   Get ptr to EVAL
         ST       R11,EFPLEVAL                Store in the EFPL
LB01     ST       R9,EVALBLOCK_EVLEN          Set length
         LA       R7,EVALBLOCK_EVDATA         Get output ptr
         DROP     R11                         Done with EVALBLOCK
         DROP     R10                         Done with EFPL
* ---------------------------------------------------------------------
* Initialize
* ---------------------------------------------------------------------
         LA       R4,255                      Byte index mask
         L        R6,A4J                      J = Ctx->J
         L        R5,A4I                      I = Ctx->I
         XR       R15,R15                     SI = 0
         XR       R14,R14                     SJ = 0
* ---------------------------------------------------------------------
* Swap bytes
* ---------------------------------------------------------------------
LOOP     LA       R5,1(R5)                    I = I + 1
         NR       R5,R4                       Byte Index
         IC       R14,A4STATE(R5)             SI = State[ I ]
         ALR      R6,R14                      J = J + SI
         NR       R6,R4                       Byte Index
         IC       R15,A4STATE(R6)             SJ = State[ J ]
         STC      R15,A4STATE(R5)             State[ I ] = SJ
         STC      R14,A4STATE(R6)             State[ J ] = SI
* ---------------------------------------------------------------------
* XOR Data
* ---------------------------------------------------------------------
         ALR      R15,R14                     SJ = SJ + SI
         NR       R15,R4                      Byte Index
         IC       R14,A4STATE(R15)            SI = State[ SJ ]
         IC       R15,0(R8)                   SJ = *(IData)
         XR       R15,R14                     SJ = SJ ^ SI
         STC      R15,0(R7)                   *(OData) = SJ
         LA       R8,1(R8)                    IData++
         LA       R7,1(R7)                    OData++
         BCT      R9,LOOP                     While( --Len )
         ST       R5,A4I                      Ctx->I = I
         ST       R6,A4J                      Ctx->J = J
* ---------------------------------------------------------------------
* Store the context variable
* ---------------------------------------------------------------------
PUTCTX   LA       R4,VREQ                     Get request ptr
         XC       VREQ,VREQ                   Clear request block
         USING    SHVBLOCK,R4                 Map SHVB
* ---------------------------------------------------------------------
* Initialize request block
* ---------------------------------------------------------------------
         MVI      SHVCODE,SHVSYSET            Function code
         LM       R6,R7,CTXNAMEA              Get name ptr and length
         LA       R8,A4CTX                    Get CTX ptr
         LA       R9,A4LEN                    Get CTX len
         STM      R6,R9,SHVNAMA               Store the lot
* ---------------------------------------------------------------------
* Store the value
* ---------------------------------------------------------------------
         L        R15,EXCOMA                  Get IRXEXCOM ptr
         CALL     (15),(=C'IRXEXCOM',0,0,VREQ,ENVBA),VL,MF=(E,PLIST)
* ---------------------------------------------------------------------
* Good result?
* ---------------------------------------------------------------------
         XR       R15,R15                     Good RC
         CLI      SHVRET,SHVNEWV              Execution OK?
         BE       RETURN                      Yes, return
         CLI      SHVRET,SHVCLEAN             Execution OK?
         BNE      ERR9                        No, error
         DROP     R4                          No longer needed
* ---------------------------------------------------------------------
* Return to caller
* ---------------------------------------------------------------------
RETURN   LR       R2,R15                      Save RC
         LR       R1,R13                      Get workarea ptr
         L        R13,4(,R13)                 Restore callers savearea
         STORAGE  RELEASE,LENGTH=WORKLEN,ADDR=(R1) Release workarea
         LR       R15,R2                      Restore RC
         L        R14,12(,R13)                Get return address
         LM       R0,R12,20(R13)              Restore registers
         BSM      0,R14                       Return to caller
* ---------------------------------------------------------------------
* Error routines
* ---------------------------------------------------------------------
ERR9     LA       R15,C'9'                    CTX store failed
         B        ERR
ERR8     LA       R15,C'8'                    Get result block failed
         B        ERR
ERR7     LA       R15,C'7'                    Too many arguments
         B        ERR
ERR6     LA       R15,C'6'                    CTX invalid
         B        ERR
ERR5     LA       R15,C'5'                    CTX retrieval failed
         B        ERR
ERR4     LA       R15,C'4'                    Key length invalid
         B        ERR
ERR3     LA       R15,C'3'                    Missing Key or Data arg
         B        ERR
ERR2     LA       R15,C'2'                    Missing CTX argument
         B        ERR
ERR1     LA       R15,C'1'                    No arguments
* ---------------------------------------------------------------------
* Fill in the request block
* ---------------------------------------------------------------------
ERR      STC      R15,RC                      Store the RC
         LA       R4,VREQ                     Get request ptr
         XC       VREQ,VREQ                   Clear request block
         USING    SHVBLOCK,R4                 Map SHVB
* ---------------------------------------------------------------------
* Initialize request block
* ---------------------------------------------------------------------
         MVI      SHVCODE,SHVSTORE            Function code
         LA       R6,ARC4RC                   Get name ptr
         LA       R7,L'ARC4RC                 Get name length
         LA       R8,RC                       Get RC ptr
         LA       R9,1                        Get RC length
         STM      R6,R9,SHVNAMA               Store the lot
* ---------------------------------------------------------------------
* Store the value
* ---------------------------------------------------------------------
         L        R15,EXCOMA                  Get IRXEXCOM ptr
         CALL     (15),(=C'IRXEXCOM',0,0,VREQ,ENVBA),VL,MF=(E,PLIST)
         LA       R15,1                       Bad RC
         B        RETURN                      Go exit
         DROP     R4                          Done with SHVB
         DROP     R12                         Done with BASE
         DROP     R13                         Done with WORK
* ---------------------------------------------------------------------
* Static data area
* ---------------------------------------------------------------------
ARC4RC   DC       C'ARC4RC'                   Return code variable name
* ---------------------------------------------------------------------
* ARC4 initial state
* ---------------------------------------------------------------------
STATEI   DC       X'000102030405060708090A0B0C0D0E0F'
         DC       X'101112131415161718191A1B1C1D1E1F'
         DC       X'202122232425262728292A2B2C2D2E2F'
         DC       X'303132333435363738393A3B3C3D3E3F'
         DC       X'404142434445464748494A4B4C4D4E4F'
         DC       X'505152535455565758595A5B5C5D5E5F'
         DC       X'606162636465666768696A6B6C6D6E6F'
         DC       X'707172737475767778797A7B7C7D7E7F'
         DC       X'808182838485868788898A8B8C8D8E8F'
         DC       X'909192939495969798999A9B9C9D9E9F'
         DC       X'A0A1A2A3A4A5A6A7A8A9AAABACADAEAF'
         DC       X'B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF'
         DC       X'C0C1C2C3C4C5C6C7C8C9CACBCCCDCECF'
         DC       X'D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF'
         DC       X'E0E1E2E3E4E5E6E7E8E9EAEBECEDEEEF'
         DC       X'F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF'
* ---------------------------------------------------------------------
* Literals
* ---------------------------------------------------------------------
         LTORG                                Literals
* ---------------------------------------------------------------------
* Put argument list here to get access to constant data
* ---------------------------------------------------------------------
         IRXARGTB DECLARE=YES                 Argument Table
* ---------------------------------------------------------------------
* Workarea DSECT with embedded ARC4 context
* ---------------------------------------------------------------------
WORKAREA DSECT
SAVEAREA DS       18F                         Must be at start
* ---------------------------------------------------------------------
* ARC4 Context
* ---------------------------------------------------------------------
A4CTX    DS       A
A4ID     EQU      C'ARC4'
A4STATE  DS       XL256
A4I      DS       F
A4J      DS       F
A4LEN    EQU      *-A4CTX
* ---------------------------------------------------------------------
* Remaining work fields
* ---------------------------------------------------------------------
CTXNAMEA DS       A
CTXNAMEL DS       F
EVALA    DS       A
EVALL    DS       F
ENVBA    DS       A
EXCOMA   DS       A
RLTA     DS       A
PLIST    CALL     ,(,,,,),MF=L
VREQ     DS       XL(SHVBLEN)
RC       DS       C
*
WORKLEN  EQU      *-WORKAREA
* ---------------------------------------------------------------------
* Register equates
* ---------------------------------------------------------------------
         YREGS                                Register equates
* ---------------------------------------------------------------------
* Rest of REXX control blocks
* ---------------------------------------------------------------------
         IRXEFPL                              Function Parameter List
         IRXEVALB                             Evaluation Block
         IRXENVB                              Environment Block
         IRXSHVB                              Variable Request
         IRXEXTE                              External Entry Points
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
  ENTRY T2PARC4
  NAME T2PARC4(R)
/*
