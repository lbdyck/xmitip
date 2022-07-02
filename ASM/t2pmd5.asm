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
*| Function : MD5 Message-Digest REXX function.
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
*|            MD5RC return code variable.
*|
*|                    1 = No arguments specified
*|                    2 = Failed to retrieve the CTX variable
*|                    3 = CTX variable is invalid
*|                    4 = Too many arguments
*|                    5 = Failed to store the CTX variable
*|                    6 = Failed to drop the CTX variable
*|
*| Descript : This external REXX function implements the MD5 Message
*|            Digest altorithm as documented in RFC1321.
*|
*|            This implementation is based on public domain source
*|            code from the Debian project.
*|
*| Usage    :                ---- Multi-Shot ----
*|
*|            Use this method when you need to pass multiple data items
*|            before generating the final digest.  Simply call this
*|            function with both arguments until you've processed all
*|            the data.  Then, make one more call while leaving off
*|            the data argument to get the digest.
*|
*|            CALL T2Pmd5( "Ctx", Data )
*|            Digest = T2Pmd5( "Ctx" )
*|
*|            "Ctx"
*|                This is the name (NOT value) of a variable where the
*|                MD5 context is maintained.
*|
*|            Data
*|                The data that you wish to digest.
*|
*|            Digest
*|                The 16-byte digest.
*|
*| Example  :
*|
*|            Data   = "Something to digest"
*|            More   = " and even more."
*|            CALL T2Pmd5( "Ctx", Data )
*|            CALL T2Pmd5( "Ctx", More )
*|            Digest = T2Pmd5( "Ctx" )
*|
*|            SAY "The MD5 digest for '" || Data || More || "' is:"
*|            SAY C2x( Digest )
*|
*| Usage    :                 ---- One-Shot ----
*|
*|            Use this method when all you need to process is one data
*|            item before generating the digest.  Just leave off the
*|            first argument (or specify a null value) and specify the
*|            second argument.
*|
*|            Digest = T2Pmd5( , Data )
*|                         or
*|            Digest = T2Pmd5( "", Data )
*|
*|            Data
*|                The data that you with to digest.
*|
*|            Digest
*|                The 16-byte digest.
*|
*| Example  :
*|
*|            Data   = "Something to digest"
*|            More   = " and even more."
*|            Digest = T2Pmd5( "", Data || More )
*|
*|            SAY "The MD5 digest for '" || Data || More || "' is:"
*|            SAY C2x( Digest )
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
* ---------------------------------------------------------------------
* Swap bytes to convert to little endian
* ---------------------------------------------------------------------
         MACRO
&LAB     SWAP     &PTR,&WORDS
&LAB     LA       R15,&WORDS/2
         LA       R14,&PTR
$&SYSNDX LM       R0,R1,0(R14)
         STCM     R0,B'0001',0(R14)
         STCM     R0,B'0010',1(R14)
         STCM     R0,B'0100',2(R14)
         STCM     R0,B'1000',3(R14)
         STCM     R1,B'0001',4(R14)
         STCM     R1,B'0010',5(R14)
         STCM     R1,B'0100',6(R14)
         STCM     R1,B'1000',7(R14)
         LA       R14,8(R14)
         BCT      R15,$&SYSNDX
         MEND
T2PMD5   CSECT                                Section
T2PMD5   AMODE    31                          Must be 31
T2PMD5   RMODE    ANY                         Could be 24, but why?
* ---------------------------------------------------------------------
* Setup base registers and addressability
* ---------------------------------------------------------------------
         SAVE     (14,12),,*                  Save caller's registers
         LR       R12,R15                     Get base
         USING    T2PMD5,R12                  Map CSECT
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
* Grab variable access routine ptr
* ---------------------------------------------------------------------
         ST       R9,ENVBA                    Save ENVB
         USING    ENVBLOCK,R9                 Map ENVB
         L        R1,ENVBLOCK_IRXEXTE         Get ptr to EXTE
         USING    IRXEXTE,R1                  Map EXTE
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
         DROP     R10                         Done with EFPL
* ---------------------------------------------------------------------
* Error if there are no arguments
* ---------------------------------------------------------------------
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BE       ERR1                        Yes, need at least 1
* ---------------------------------------------------------------------
* Have a context variable name?
* ---------------------------------------------------------------------
         LM       R7,R8,ARGTABLE_ARGSTRING_PTR Get ptr and length
         STM      R7,R8,CTXNAMEA              Save ptr and length
         LTR      R8,R8                       Null or missing?
         BZ       INIT                        Yes, must be one-shot
* ---------------------------------------------------------------------
* Retrieve the context variable
* ---------------------------------------------------------------------
         LA       R4,VREQ                     Get request ptr
         XC       VREQ,VREQ                   Clear request block
         USING    SHVBLOCK,R4                 Map SHVB
* ---------------------------------------------------------------------
* Initialize request block
* ---------------------------------------------------------------------
         MVI      SHVCODE,SHVSYFET            Function code
         LA       R6,M5LEN                    Get buffer len
         LA       R9,M5CTX                    Buffer ptr
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
         BE       CHKID                       Yes, go check id
         CLI      SHVRET,SHVNEWV              Execution OK?
         BNE      ERR2                        No, error
* =====================================================================
* MD5Init
* =====================================================================
* ---------------------------------------------------------------------
* Either a one-shot run or the first time using this CTX...
* ---------------------------------------------------------------------
INIT     XC       M5CTX(M5LEN),M5CTX          Clear context
         MVC      M5CTX(5*4),INITCTX          Initialize context
         B        GETDATA                     Go check data arg
* ---------------------------------------------------------------------
* Validate CTX
* ---------------------------------------------------------------------
CHKID    CLC      SHVVALL,=A(M5LEN)           Possibly one of ours?
         BNE      ERR3                        No, error
         CLC      M5CTX,INITCTX               One of ours?
         BNE      ERR3                        No, error
         DROP     R4                          No longer needed
* ---------------------------------------------------------------------
* Bump to next argument and verify it's there
* ---------------------------------------------------------------------
GETDATA  LA       R2,ARGTABLE_NEXT            Gen ptr to next arg
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BE       TERM                        Yes, return digest
* ---------------------------------------------------------------------
* Cache and validate "DATA" argument pointer and length
* ---------------------------------------------------------------------
         LM       R8,R9,ARGTABLE_ARGSTRING_PTR Get ptr and length
         LTR      R8,R8                       Missing?
         BZ       TERM                        Yes, get existing CTX
* ---------------------------------------------------------------------
* Don't need anymore arguments
* ---------------------------------------------------------------------
         LA       R2,ARGTABLE_NEXT            Gen ptr to next arg
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BNE      ERR4                        No, don't need anymore
         DROP     R2                          Done with ARGTABLE
* =====================================================================
* MD5Hash
*
* Update context to reflect the concatenation of another buffer full
* of bytes.
*
* (Even though they are destroyed in MD5Trans, it is okay to use R2
* and R3 here since they are reset after each call to MD5Trans.)
*
* =====================================================================
* ---------------------------------------------------------------------
* Update byte count
* ---------------------------------------------------------------------
HASH     L        R1,M5BYTES+(1*4)            RS = Bytes[ 1 ]
         LR       R14,R1                      T1 = RS
         ALR      R14,R9                      T1 += Len
         BC       12,L10                      Overflow? No, branch
* ---------------------------------------------------------------------
* Carry from low to high
* ---------------------------------------------------------------------
         L        R15,M5BYTES+(0*4)           T2 = Bytes[ 0 ]
         AL       R15,=F'1'                   T2++
         ST       R15,M5BYTES+(0*4)           Bytes[ 0 ] = T2
L10      ST       R14,M5BYTES+(1*4)           Bytes[ 1 ] = T1
* ---------------------------------------------------------------------
* Space available in ctx->in (at least 1)
* ---------------------------------------------------------------------
         LA       R10,64                      Cache
         N        R1,=A(X'3F')                RS &= 0x3f (mod 64)
         LR       R3,R10                      T = 64
         SLR      R3,R1                       T -= RS
         LR       R1,R10                      RS = 64
         SLR      R1,R3                       RS -= T
         LA       R1,M5IN(R1)                 RS = &In[ RS ]
* ---------------------------------------------------------------------
* Enough input to fill ctx->in?
* ---------------------------------------------------------------------
         CLR      R3,R9                       T > Len?
         BH       L40                         Yes, not enough to fill
* ---------------------------------------------------------------------
* First chunk is an odd size
* ---------------------------------------------------------------------
         LR       R14,R3                      T1 = T
         BCTR     R14,0                       T1-- (for execute)
         EX       R14,MEMCPY                  do MEMCPY for T bytes
* ---------------------------------------------------------------------
* Adjust buffer and len
* ---------------------------------------------------------------------
         ALR      R8,R3                       Buf += T
         SLR      R9,R3                       Len -= T
* ---------------------------------------------------------------------
* Convert to little endian
* ---------------------------------------------------------------------
         SWAP     M5IN,16                     byteSwap( In, 16 )
* ---------------------------------------------------------------------
* Add in the padding bytes
* ---------------------------------------------------------------------
         BAL      R6,MD5TRANS                 MD5Trans( Buf, In )
* ---------------------------------------------------------------------
* Process data in 64-byte chunks
* ---------------------------------------------------------------------
L20      CLR      R9,R10                      Len >= 64?
         BL       L30                         No, don't have a block
         MVC      M5IN(64),0(R8)              memcpy( In, Buf, 64 )
* ---------------------------------------------------------------------
* Adjust buffer and len
* ---------------------------------------------------------------------
         ALR      R8,R10                      Buf += 64
         SLR      R9,R10                      Len -= 64
* ---------------------------------------------------------------------
* Convert to little endian
* ---------------------------------------------------------------------
         SWAP     M5IN,16                     byteSwap( In, 16 )
* ---------------------------------------------------------------------
* Add in 64 more bytes
* ---------------------------------------------------------------------
         BAL      R6,MD5TRANS                 MD5Trans( Buf, In )
         B        L20                         Continue loop
* ---------------------------------------------------------------------
* Handle any remaining bytes of data.
* ---------------------------------------------------------------------
L30      LA       R1,M5IN                     RS = &In[ 0 ]
L40      LTR      R9,R9                       Len == 0?
         BZ       PUTCTX                      Yes, nothing to do
         BCTR     R9,0                        Len-- (for execute)
         EX       R9,MEMCPY                   do MEMCPY for Len bytes
* ---------------------------------------------------------------------
* Store the updated context variable
* ---------------------------------------------------------------------
PUTCTX   LM       R6,R7,CTXNAMEA              Get name ptr and length
         LTR      R7,R7                       Have a Ctx name?
         BZ       TERM                        No, return digest
         LA       R4,VREQ                     Get request ptr
         XC       VREQ,VREQ                   Clear request block
         USING    SHVBLOCK,R4                 Map SHVB
* ---------------------------------------------------------------------
* Initialize request block
* ---------------------------------------------------------------------
         MVI      SHVCODE,SHVSYSET            Function code
         LA       R8,M5CTX                    Get CTX ptr
         LA       R9,M5LEN                    Get CTX len
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
         BNE      ERR5                        No, error
         DROP     R4                          No longer needed
         B        RETURN                      Done
* =====================================================================
* MD5Term
*
* Final wrapup...pad to 64-byte boundary with the bit pattern:
*     1 0* (64-bit count of bits processed, MSB-first)
*
* (Even though they are destroyed in MD5Trans, it is okay to use R2
* and R3 here since they are reset after each call to MD5Trans.)
*
* =====================================================================
* ---------------------------------------------------------------------
* Get number of bytes mod 64
* ---------------------------------------------------------------------
TERM     L        R3,M5BYTES+(1*4)            Cnt = Bytes[ 1 ]
         N        R3,=A(X'3F')                Cnt &= 0x3f
* ---------------------------------------------------------------------
* Set ptr to start of padding
* ---------------------------------------------------------------------
         LA       R2,M5IN(R3)                 Ptr = &In[ Cnt ]
* ---------------------------------------------------------------------
* Set the first byte of padding to 0x80.  There is always room.
* ---------------------------------------------------------------------
         MVI      0(R2),X'80'                 *Ptr = x'80'
         LA       R2,1(R2)                    Ptr++
* ---------------------------------------------------------------------
* Bytes of padding needed to make 56 bytes (-8..55)
* ---------------------------------------------------------------------
         LA       R1,56-1                     RS = 56 - 1
         SLR      R1,R3                       RS -= Cnt
* ---------------------------------------------------------------------
* Padding forces an extra block
* ---------------------------------------------------------------------
         LTR      R3,R1                       ( Cnt = RS ) == 0
         BZ       L60                         =0, no need to clear
         BNL      L50                         >0, no extra block
* ---------------------------------------------------------------------
* Clear the remaining bytes
* ---------------------------------------------------------------------
         LA       R3,(8-1)(R3)                Cnt += 8 (-1 for execute)
         EX       R3,MEMSET                   do MEMSET for Cnt bytes
* ---------------------------------------------------------------------
* Convert to little endian
* ---------------------------------------------------------------------
         SWAP     M5IN,16                     byteSwap( In, 16 )
* ---------------------------------------------------------------------
* Add in the padding bytes
* ---------------------------------------------------------------------
         BAL      R6,MD5TRANS                 MD5Trans( Buf, In )
         LA       R2,M5IN                     Ptr = &In[ 0 ]
         LA       R3,(15*4)                   Cnt = 56
* ---------------------------------------------------------------------
* Clear padding bytes
* ---------------------------------------------------------------------
L50      BCTR     R3,0                        Cnt-- (for execute)
         EX       R3,MEMSET                   do MEMSET for Cnt bytes
* ---------------------------------------------------------------------
* Convert to little endian
* ---------------------------------------------------------------------
L60      SWAP     M5IN,14                     byteSwap( In, 14 )
* ---------------------------------------------------------------------
* Append length in bits and transform
* ---------------------------------------------------------------------
         LM       R14,R15,M5BYTES+(0*4)       Get longlong byte count
         SLDL     R14,3                       Calc number of bits
         ST       R15,M5IN+(14*4)             Little...
         ST       R14,M5IN+(15*4)             ...endian
         BAL      R6,MD5TRANS                 MD5Trans( Buf, In )
* ---------------------------------------------------------------------
* Convert to little endian
* ---------------------------------------------------------------------
         SWAP     M5BUF,4                     byteSwap( Buf, 4 )
* ---------------------------------------------------------------------
* Final transform is the digest
* ---------------------------------------------------------------------
         MVC      EVALBLOCK_EVLEN,=F'16'      Length of digest
         MVC      EVALBLOCK_EVDATA(16),M5BUF  memcpy( digest, buf, 16 )
         DROP     R11                         Done with EVAL
         XR       R15,R15                     Assume good RC
* ---------------------------------------------------------------------
* Drop the context variable if one was specified
* ---------------------------------------------------------------------
         LM       R6,R7,CTXNAMEA              Get name ptr and length
         LTR      R7,R7                       Have a Ctx name?
         BZ       RETURN                      No, return digest
         LA       R4,VREQ                     Get request ptr
         XC       VREQ,VREQ                   Clear request block
         USING    SHVBLOCK,R4                 Map SHVB
* ---------------------------------------------------------------------
* Initialize request block
* ---------------------------------------------------------------------
         MVI      SHVCODE,SHVSYDRO            Function code
         STM      R6,R7,SHVNAMA               Store the lot
* ---------------------------------------------------------------------
* Drop the variable
* ---------------------------------------------------------------------
         L        R15,EXCOMA                  Get IRXEXCOM ptr
         CALL     (15),(=C'IRXEXCOM',0,0,VREQ,ENVBA),VL,MF=(E,PLIST)
         LTR      R15,R15                     Success?
         BNZ      ERR6                        No, error
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
* =====================================================================
* MD5Trans
*
* The core of the MD5 algorithm, this alters an existing MD5 hash to
* reflect the addition of 16 longwords of new data.  MD5Update blocks
* the data and converts bytes into longwords for this routine.
*
* =====================================================================
RS       EQU      R1
A        EQU      R2  <--------------------\
B        EQU      R3                        | Must be sequential since
C        EQU      R4                        | we use LM/STM opcodes
D        EQU      R5  <--------------------/
T1       EQU      R14
T2       EQU      R15
* ---------------------------------------------------------------------
*        F1(x, y, z) \
*           (z ^ (x & (y ^ z)))
* ---------------------------------------------------------------------
         MACRO
         F1       &X,&Y,&Z
.*
         LR       T1,&Y                       T1 = y
         XR       T1,&Z                       T1 ^= z
         LR       T2,&X                       T2 = x
         NR       T2,T1                       T2 &= T1
         LR       RS,&Z                       RS = z
         XR       RS,T2                       RS ^= T2
.*
         MEND
* ---------------------------------------------------------------------
*        F2(x, y, z) \
*            F1(z, x, y)
* ---------------------------------------------------------------------
         MACRO
         F2       &X,&Y,&Z
.*
         F1       &Z,&X,&Y                    RS = F1(z,x,y)
.*
         MEND
* ---------------------------------------------------------------------
*        F3(x, y, z) \
*            (x ^ y ^ z)
* ---------------------------------------------------------------------
         MACRO
         F3       &X,&Y,&Z
.*
         LR       RS,&X                       RS = x
         XR       RS,&Y                       RS ^= y
         XR       RS,&Z                       RS ^= z
.*
         MEND
* ---------------------------------------------------------------------
*        F4(x, y, z) \
*            (y ^ (x | ~z))
* ---------------------------------------------------------------------
         MACRO
         F4       &X,&Y,&Z
.*
         LR       T1,&Z                       T1 = z
         X        T1,=A(X'FFFFFFFF')          T1 ^= -1
         LR       T2,&X                       T2 = x
         OR       T2,T1                       T2 |= T2
         LR       RS,&Y                       RS = y
         XR       RS,T2                       RS ^= T2
.*
         MEND
* ---------------------------------------------------------------------
*        MD5STEP(f,w,x,y,z,in,ac,s) \
*            (w += f(x,y,z) + in + ac, w = (w<<s | w>>(32-s)) + x)
* ---------------------------------------------------------------------
         MACRO
         MD5STEP  &F,&W,&X,&Y,&Z,&IN,&AC,&S
.*
         &F       &X,&Y,&Z                    RS = f(x,y,z)
         AL       RS,M5IN+(&IN*4)             RS += In[ in ]
         AL       RS,=A(x'&AC')               RS += ac
         ALR      &W,RS                       w += RS
         LR       T1,&W                       T1 = w
         SLL      &W,&S                       w << s
         SRL      T1,32-&S                    T1 >> (32-s)
         OR       &W,T1                       w |= T1
         ALR      &W,&X                       w += x
.*
         MEND
MD5TRANS LM       A,D,M5BUF
* ---------------------------------------------------------------------
* Round 1
* ---------------------------------------------------------------------
         MD5STEP  F1,A,B,C,D,00,D76AA478,07
         MD5STEP  F1,D,A,B,C,01,E8C7B756,12
         MD5STEP  F1,C,D,A,B,02,242070DB,17
         MD5STEP  F1,B,C,D,A,03,C1BDCEEE,22
         MD5STEP  F1,A,B,C,D,04,F57C0FAF,07
         MD5STEP  F1,D,A,B,C,05,4787C62A,12
         MD5STEP  F1,C,D,A,B,06,A8304613,17
         MD5STEP  F1,B,C,D,A,07,FD469501,22
         MD5STEP  F1,A,B,C,D,08,698098D8,07
         MD5STEP  F1,D,A,B,C,09,8B44F7AF,12
         MD5STEP  F1,C,D,A,B,10,FFFF5BB1,17
         MD5STEP  F1,B,C,D,A,11,895CD7BE,22
         MD5STEP  F1,A,B,C,D,12,6B901122,07
         MD5STEP  F1,D,A,B,C,13,FD987193,12
         MD5STEP  F1,C,D,A,B,14,A679438E,17
         MD5STEP  F1,B,C,D,A,15,49B40821,22
* ---------------------------------------------------------------------
* Round 2
* ---------------------------------------------------------------------
         MD5STEP  F2,A,B,C,D,01,F61E2562,05
         MD5STEP  F2,D,A,B,C,06,C040B340,09
         MD5STEP  F2,C,D,A,B,11,265E5A51,14
         MD5STEP  F2,B,C,D,A,00,E9B6C7AA,20
         MD5STEP  F2,A,B,C,D,05,D62F105D,05
         MD5STEP  F2,D,A,B,C,10,02441453,09
         MD5STEP  F2,C,D,A,B,15,D8A1E681,14
         MD5STEP  F2,B,C,D,A,04,E7D3FBC8,20
         MD5STEP  F2,A,B,C,D,09,21E1CDE6,05
         MD5STEP  F2,D,A,B,C,14,C33707D6,09
         MD5STEP  F2,C,D,A,B,03,F4D50D87,14
         MD5STEP  F2,B,C,D,A,08,455A14ED,20
         MD5STEP  F2,A,B,C,D,13,A9E3E905,05
         MD5STEP  F2,D,A,B,C,02,FCEFA3F8,09
         MD5STEP  F2,C,D,A,B,07,676F02D9,14
         MD5STEP  F2,B,C,D,A,12,8D2A4C8A,20
* ---------------------------------------------------------------------
* Round 3
* ---------------------------------------------------------------------
         MD5STEP  F3,A,B,C,D,05,FFFA3942,04
         MD5STEP  F3,D,A,B,C,08,8771F681,11
         MD5STEP  F3,C,D,A,B,11,6D9D6122,16
         MD5STEP  F3,B,C,D,A,14,FDE5380C,23
         MD5STEP  F3,A,B,C,D,01,A4BEEA44,04
         MD5STEP  F3,D,A,B,C,04,4BDECFA9,11
         MD5STEP  F3,C,D,A,B,07,F6BB4B60,16
         MD5STEP  F3,B,C,D,A,10,BEBFBC70,23
         MD5STEP  F3,A,B,C,D,13,289B7EC6,04
         MD5STEP  F3,D,A,B,C,00,EAA127FA,11
         MD5STEP  F3,C,D,A,B,03,D4EF3085,16
         MD5STEP  F3,B,C,D,A,06,04881D05,23
         MD5STEP  F3,A,B,C,D,09,D9D4D039,04
         MD5STEP  F3,D,A,B,C,12,E6DB99E5,11
         MD5STEP  F3,C,D,A,B,15,1FA27CF8,16
         MD5STEP  F3,B,C,D,A,02,C4AC5665,23
* ---------------------------------------------------------------------
* Round 4
* ---------------------------------------------------------------------
         MD5STEP  F4,A,B,C,D,00,F4292244,06
         MD5STEP  F4,D,A,B,C,07,432AFF97,10
         MD5STEP  F4,C,D,A,B,14,AB9423A7,15
         MD5STEP  F4,B,C,D,A,05,FC93A039,21
         MD5STEP  F4,A,B,C,D,12,655B59C3,06
         MD5STEP  F4,D,A,B,C,03,8F0CCC92,10
         MD5STEP  F4,C,D,A,B,10,FFEFF47D,15
         MD5STEP  F4,B,C,D,A,01,85845DD1,21
         MD5STEP  F4,A,B,C,D,08,6FA87E4F,06
         MD5STEP  F4,D,A,B,C,15,FE2CE6E0,10
         MD5STEP  F4,C,D,A,B,06,A3014314,15
         MD5STEP  F4,B,C,D,A,13,4E0811A1,21
         MD5STEP  F4,A,B,C,D,04,F7537E82,06
         MD5STEP  F4,D,A,B,C,11,BD3AF235,10
         MD5STEP  F4,C,D,A,B,02,2AD7D2BB,15
         MD5STEP  F4,B,C,D,A,09,EB86D391,21
* ---------------------------------------------------------------------
* Add back into state and return
* ---------------------------------------------------------------------
         AL       A,M5BUF+(0*4)
         AL       B,M5BUF+(1*4)
         AL       C,M5BUF+(2*4)
         AL       D,M5BUF+(3*4)
         STM      A,D,M5BUF
         BR       R6
* ---------------------------------------------------------------------
* Error routines
* ---------------------------------------------------------------------
ERR6     LA       R15,C'6'                    Drop CTX failed
         B        ERR
ERR5     LA       R15,C'5'                    Put CTX failed
         B        ERR
ERR4     LA       R15,C'4'                    Too many arguments
         B        ERR
ERR3     LA       R15,C'3'                    CTX Invalid
         B        ERR
ERR2     LA       R15,C'2'                    Get CTX failed
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
         LA       R6,MD5RC                    Get name ptr
         LA       R7,L'MD5RC                  Get name length
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
* Executed instructions
* ---------------------------------------------------------------------
MEMCPY   MVC      0(0,R1),0(R8)               memcpy( RS, Buf, Len )
MEMSET   XC       0(0,R2),0(R2)               Ptr[...] ^= Ptr[...]
* ---------------------------------------------------------------------
* Pre-initialized CTX
* ---------------------------------------------------------------------
INITCTX  DC       A(M5ID),X'67452301,EFCDAB89,98BADCFE,10325476'
* ---------------------------------------------------------------------
* Static data area
* ---------------------------------------------------------------------
MD5RC    DC       C'MD5RC'                    Return code variable name
         ORG
* ---------------------------------------------------------------------
* Literals
* ---------------------------------------------------------------------
         LTORG                                Literals
* ---------------------------------------------------------------------
* Put argument list here to get access to constant data
* ---------------------------------------------------------------------
         IRXARGTB DECLARE=YES                 Argument Table
* ---------------------------------------------------------------------
* Workarea DSECT with embedded MD5 context
* ---------------------------------------------------------------------
WORKAREA DSECT
SAVEAREA DS       18F                         Must be at start
* ---------------------------------------------------------------------
* MD5 Context
* ---------------------------------------------------------------------
M5CTX    DS       A                           Control block ID
M5ID     EQU      C'MD5X'                     And the ID itself
M5BUF    DS       4F                          Accumulation buffer
M5BYTES  DS       2F                          # of bytes processed
M5IN     DS       16F                         Input buffer
M5LEN    EQU      *-M5CTX                     Length of context
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
  ENTRY T2PMD5
  NAME T2PMD5(R)
/*
