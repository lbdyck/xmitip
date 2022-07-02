//*
//* -------------------------------------------------------------------
//* Specify load library and ZLIB pds
//* -------------------------------------------------------------------
//LOADLIB  SET  LOADLIB='your.load.library'
//ZLIB     SET  ZLIB='prefix.TXT2PDF.NEW.ZLIB'
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
*| Function : Deflate (ZLIB compress) data.
*|
*| Rent     : Yes (can be placed in LPA if used frequently)
*|
*| Amode    : Must run in 31-bit addressing mode
*|
*| Rmode    : Above or below...
*|
*| Return   : If no errors are encountered, the return value will be
*|            the compressed data.
*|
*|            In the event of an error, a SYNTAX condition is forced
*|            and one of the following values will be placed in the
*|            COMPRC return code variable.
*|
*|                    1 = No arguments specified
*|                    2 = Input data parameter missing
*|                    3 = Compression level invalid
*|                    4 = Too many arguments
*|                    5 = Failed to get larger result block
*|                    6 = Compression failed
*|
*| Descript : This external REXX function interfaces with the ZLIB
*|            compression library to provide simple compression of
*|            input data.
*|
*|            Please refer to the LICENSE member in the ZLIB PDS for
*|            additional copyright information.
*|
*| Usage    :
*|
*|            SmallData = T2Pcomp( BigData, Level )
*|
*|            BigData
*|                The data you wish to compress.
*|
*|            Level
*|                The compression level desired.  Specify 0 to disable
*|                compression and 1 through 9 for increasingly better
*|                (and slower) compression.
*|
*|            SmallData
*|                The compressed data.
*|
*| Example  :
*|
*|            IData = "Some data to compress."
*|            Level = 9
*|
*|            OData = T2PCOMP( IData, Level )
*|
*|            SAY "Using a" Level "compression level to encrypt:"
*|            SAY " " IData
*|            SAY "Produces:"
*|            SAY " " C2x( OData )
*|
*| Author   : Leland Lucius <rexxfunc@homerow.net>
*|
*| License  : This routine is released under terms of the Q Public
*|            License.  Please refer to the LICENSE file for more
*|            information.  Or for the latest license text go to:
*|
*|            http://www.trolltech.com/developer/licensing/qpl.html
*|
*| Changes  : 2002/10/06 - LLL - Initial version
*|          : 2002/10/07 - LLL - Make it reentrant
*|
*| ====================================================================
T2PCOMP  CSECT                                Section
T2PCOMP  AMODE    31                          Must be 31
T2PCOMP  RMODE    ANY                         Could be 24, but why?
STKLEN   EQU      8192                        Should be large enough
* ---------------------------------------------------------------------
* Setup base registers and addressability
* ---------------------------------------------------------------------
         SAVE     (14,12),,*                  Save caller's registers
         LR       R11,R15                     Get base
         USING    T2PCOMP,R11                 Map CSECT
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
         L        R8,EFPLEVAL                 Get ptr to eval addr
         L        R8,0(R8)                    Get EVAL addr
         USING    EVALBLOCK,R8                Map EVAL
         MVC      EVALBLOCK_EVLEN,=F'0'       Pre-init to null
* ---------------------------------------------------------------------
* Address and map the arguments
* ---------------------------------------------------------------------
         L        R9,EFPLARG                  Get ptr to arguments
         USING    ARGTABLE_ENTRY,R9           Map ARGTABLE
* ---------------------------------------------------------------------
* Error if there are no arguments
* ---------------------------------------------------------------------
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BE       ERR1                        Yes, need at least 1
* ---------------------------------------------------------------------
* Always need input data
* ---------------------------------------------------------------------
         LM       R4,R5,ARGTABLE_ARGSTRING_PTR Get ptr and length
         LTR      R5,R5                       Null or missing?
         BZ       ERR2                        Yes, error
* ---------------------------------------------------------------------
* Bump to next argument and verify it's there
* ---------------------------------------------------------------------
         L        R6,=F'-1'                   Default compression
         LA       R9,ARGTABLE_NEXT            Gen ptr to next arg
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BE       CALCOS                      Yes, need at least 1 more
* ---------------------------------------------------------------------
* Cache and validate compression level
* ---------------------------------------------------------------------
         LM       R2,R3,ARGTABLE_ARGSTRING_PTR Get ptr and length
         LTR      R3,R3                       Missing?
         BZ       CALCOS                      Yes, use default
         CL       R3,=F'1'                    Must be 1 digit
         BNE      ERR3                        Yes, error
         CLI      0(R2),C'0'                  Less than zero?
         BL       ERR3                        Yes, error
         CLI      0(R2),C'9'                  Greatter than 9?
         BH       ERR3                        Yes, error
         IC       R6,0(R2)                    Get character
         N        R6,=XL4'0F'                 Make into a number
* ---------------------------------------------------------------------
* Don't need anymore arguments
* ---------------------------------------------------------------------
         LA       R9,ARGTABLE_NEXT            Gen ptr to next arg
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BNE      ERR4                        No, don't need anymore
         DROP     R9                          Done with ARGTABLE
* ---------------------------------------------------------------------
* Calculate output buffer size
* ---------------------------------------------------------------------
CALCOS   XR       R2,R2                       Clear upper 32
         LR       R3,R5                       Get input length
         D        R2,=F'5'                    Spec says .1%...be safe
         AH       R3,=H'12'                   Space for header
         AR       R3,R5                       Re-add input length
* ---------------------------------------------------------------------
* Current eval block have enough room?
* ---------------------------------------------------------------------
         L        R1,EVALBLOCK_EVSIZE         Get EVAL size
         SLL      R1,3                        Cvt to byte size
         S        R1,=A(EVALBLOCK_EVDATA-EVALBLOCK) Knock off CB
         CLR      R1,R3                       Big enough?
         BNL      LB01                        Yes, continue
* ---------------------------------------------------------------------
* Have to get new result block
* ---------------------------------------------------------------------
         ST       R3,EVALL                    Set required length
         L        R15,RLTA                    Get IRXRLTA ptr
         CALL     (15),(=C'GETBLOCK',EVALA,EVALL,ENVBA),VL,MF=(E,PLIST)
         LTR      R15,R15                     Success?
         BNZ      ERR5                        No, error
         L        R8,EVALA                    Get ptr to EVAL
         ST       R8,EFPLEVAL                 Store in the EFPL
LB01     ST       R3,EVALBLOCK_EVLEN          Set length
         LA       R3,EVALBLOCK_EVLEN          Get length ptr
         LA       R2,EVALBLOCK_EVDATA         Get output ptr
         DROP     R8                          Done with EVALBLOCK
         DROP     R10                         Done with EFPL
* ---------------------------------------------------------------------
* Compress input data
* ---------------------------------------------------------------------
         XC       PFWD,PFWD                   Clear private fullword
         LA       R12,PFWD                    And set ptr
         LA       R15,STACK                   Get stack ptr
         AL       R15,=A(STKLEN-96)           Stack top minus 1st frame
         L        R1,=V(ZCMP2)                Get rtn addr
         BASR     R14,R1                      Do it
         LTR      R15,R2                      Good result?
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
* ---------------------------------------------------------------------
* Error routines
* ---------------------------------------------------------------------
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
         LA       R6,COMPRC                   Get name ptr
         LA       R7,L'COMPRC                 Get name length
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
         DROP     R11                         Done with BASE
         DROP     R13                         Done with WORK
* ---------------------------------------------------------------------
* Static data area
* ---------------------------------------------------------------------
COMPRC   DC       C'COMPRC'                   Return code variable name
* ---------------------------------------------------------------------
* Literals
* ---------------------------------------------------------------------
         LTORG                                Literals
* ---------------------------------------------------------------------
* Put argument list here to get access to constant data
* ---------------------------------------------------------------------
         IRXARGTB DECLARE=YES                 Argument Table
* ---------------------------------------------------------------------
* Workarea DSECT
* ---------------------------------------------------------------------
WORKAREA DSECT
SAVEAREA DS       18F                         Must be at start
* ---------------------------------------------------------------------
* Remaining work fields
* ---------------------------------------------------------------------
PFWD     DS       F
EVALA    DS       A
EVALL    DS       F
ENVBA    DS       A
EXCOMA   DS       A
RLTA     DS       A
PLIST    CALL     ,(,,,,),MF=L
VREQ     DS       XL(SHVBLEN)
RC       DS       C
* ---------------------------------------------------------------------
* Stack for compression routines
* ---------------------------------------------------------------------
         DS       0D
STACK    DS       (STKLEN)X
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
//             PARM='XREF,MAP,LET,LIST,NCAL,RENT,REUS,CASE=MIXED'
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  DSN=&SYSUT1,
//             SPACE=(CYL,(3,2)),
//             UNIT=VIO
//ZLIB     DD  DSN=&ZLIB,
//             DISP=SHR
//SYSLMOD  DD  DSN=&LOADLIB,
//             DISP=SHR
//SYSLIN   DD  DSN=*.ASM.SYSLIN,
//             DISP=(OLD,DELETE)
//         DD  *
  CHANGE adler32.c.text(ZTEXT001)
  INCLUDE ZLIB(ADLER32)
  CHANGE compress.c.text(ZTEXT002)
  CHANGE compress2(ZCMP2)
  CHANGE deflateInit_(dfinit)
  CHANGE deflate(dflate)
  CHANGE deflateEnd(dfend)
  INCLUDE ZLIB(COMPRESS)
  CHANGE deflate.c.text(ZTEXT003)
  CHANGE deflate.c.data(ZDATA003)
  CHANGE _dist_code(distcode)
  CHANGE _length_code(lencode)
  CHANGE _tr_align(tralign)
  CHANGE _tr_flush_block(trflblk)
  CHANGE _tr_init(trinit)
  CHANGE _tr_stored_block(trstrblk)
  CHANGE deflate_copyright(dfright)
  CHANGE deflate(dflate)
  CHANGE deflateCopy(dfcopy)
  CHANGE deflateEnd(dfend)
  CHANGE deflateInit_(dfinit)
  CHANGE deflateInit2_(dfinit2)
  CHANGE deflateParams(dfparms)
  CHANGE deflateReset(dfreset)
  CHANGE deflateSetDictionary(dfsetdic)
  INCLUDE ZLIB(DEFLATE)
  CHANGE trees.c.text(ZTEXT004)
  CHANGE trees.c.data(ZDATA004)
  CHANGE _dist_code(distcode)
  CHANGE _length_code(lencode)
  CHANGE _tr_align(tralign)
  CHANGE _tr_flush_block(trflblk)
  CHANGE _tr_init(trinit)
  CHANGE _tr_stored_block(trstrblk)
  CHANGE _tr_tally(trtally)
  INCLUDE ZLIB(TREES)
  CHANGE zutil.c.text(ZTEXT005)
  CHANGE zutil.c.data(ZDATA005)
  CHANGE zlibVersion(zlibver)
  INCLUDE ZLIB(ZUTIL)
  INCLUDE ZLIB($ZSUP$)
  ENTRY T2PCOMP
  NAME T2PCOMP(R)
/*
