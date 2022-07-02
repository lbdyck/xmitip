//* -------------------------------------------------------------------
//* Specify load library
//* -------------------------------------------------------------------
//LOADLIB  SET  LOADLIB='your.load.library'
//*
//* -------------------------------------------------------------------
//* Assemble
//* -------------------------------------------------------------------
//ASMINIT  EXEC  PGM=ASMA90,
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
*| Function : Preload T2P load modules.
*|
*| Rent     : Yes (can be placed in LPA if used frequently)
*|
*| Amode    : Must run in 31-bit addressing mode
*|
*| Rmode    : Above or below...
*|
*| Return   : If no errors are encountered, the return value will be
*|            the empty string.
*|
*|            In the event of an error, a SYNTAX condition is forced
*|            and one of the following values will be placed in the
*|            T2PRC return code variable.
*|
*|                    1 = No arguments allowed
*|                    2 = LOAD of T2PARC4 failed
*|                    3 = LOAD of T2PMD5 failed
*|                    4 = LOAD of T2PCOMP failed
*|
*| Descript : This external REXX function, along with T2PTERM manage
*|            the loading and unloading of other modules used by the
*|            TXT2PDF Rexx EXEC.  This is done to enhance performance.
*|
*| Usage    : CALL T2PInit
*|
*| Example  :
*|
*|            CALL T2PInit
*|
*| Author   : Leland Lucius <rexxfunc@homerow.net>
*|
*| License  : This routine is released under terms of the Q Public
*|            License.  Please refer to the LICENSE file for more
*|            information.  Or for the latest license text go to:
*|
*|            http://www.trolltech.com/developer/licensing/qpl.html
*|
*| Changes  : 2002/08/30 - LLL - Initial version
*|            2002/10/06 - LLL - Added T2PCOMP
*|
*| ====================================================================
T2PINIT  CSECT                                Section
T2PINIT  AMODE    31                          Must be 31
T2PINIT  RMODE    ANY                         Could be 24, but why?
* ---------------------------------------------------------------------
* Setup base registers and addressability
*
* NOTE:  We do not use a savearea unless we detect an error.  If that
*        occurs, we use the 250 byte EVDATA field in the EVALBLOCK as
*        our savearea.
*
* ---------------------------------------------------------------------
         SAVE     (14,12),,*                  Save caller's registers
         LR       R12,R15                     Get base
         USING    T2PINIT,R12                 Map CSECT
         USING    EFPL,R1                     Map EFPL
* ---------------------------------------------------------------------
* Get addressability to EVALBLOCK
* ---------------------------------------------------------------------
         L        R11,EFPLEVAL                Get ptr to eval addr
         L        R11,0(R11)                  Get EVAL addr
         USING    EVALBLOCK,R11               Map EVAL
         LA       R10,EVALBLOCK_EVDATA        Ptr to returned context
         LR       R9,R0                       Save ENVB
* ---------------------------------------------------------------------
* Error if there are any arguments
* ---------------------------------------------------------------------
         L        R1,EFPLARG                  Get ptr to arguments
         DROP     R1                          Done with EFPL
         USING    ARGTABLE_ENTRY,R1           Map ARGTABLE
         CLC      ARGTABLE_END,ARGTABLE_ENTRY Last argument?
         BNE      ERR1                        No, error
         DROP     R1                          Done with ARGTABLE
* ---------------------------------------------------------------------
* Load other modules
* ---------------------------------------------------------------------
         LOAD     EP=T2PARC4,ERRET=ERR2       ARC4 processor
         LOAD     EP=T2PMD5,ERRET=ERR3        MD5 processor
         LOAD     EP=T2PCOMP,ERRET=ERR4       Compression processor
         XC       EVALBLOCK_EVLEN,EVALBLOCK_EVLEN Nothing to return
         XR       R15,R15                     Good RC
* ---------------------------------------------------------------------
* Return to caller
* ---------------------------------------------------------------------
RETURN   L        R14,12(,R13)                Get return address
         LM       R0,R12,20(R13)              Restore registers
         BSM      0,R14                       Return to caller
* ---------------------------------------------------------------------
* Error routines
* ---------------------------------------------------------------------
ERR4     LA       R15,4                       COMP LOAD failed
         B        ERR
ERR3     LA       R15,3                       MD5 LOAD failed
         B        ERR
ERR2     LA       R15,2                       ARC4 LOAD failed
         B        ERR
ERR1     LA       R15,1                       No arguments allowed
* ---------------------------------------------------------------------
* Setup workarea using 250 byte EVDATA kindly provided by TSO
* ---------------------------------------------------------------------
ERR      LR       R1,R13                      Save callers savearea
         LR       R13,R10                     Establish our savearea
         USING    WORKAREA,R13                Map WORK
         ST       R1,SAVEAREA+4               Save callers in ours
         ST       R13,8(R1)                   Store ours in callers
* ---------------------------------------------------------------------
* Fill in the request block
* ---------------------------------------------------------------------
         MVC      VARREQ,INITVR               Initialize SHVB
         STC      R15,RC                      Store RC
         OI       RC,X'F0'                    Make is a number
         LA       R1,RC                       Get ptr to RC
         ST       R1,VARREQ+(SHVVALA-SHVBLOCK) Store variable ptr
* ---------------------------------------------------------------------
* Store the value
* ---------------------------------------------------------------------
         ST       R9,ENVBA                    Save ENVB
         USING    ENVBLOCK,R9                 Map ENVB
         L        R15,ENVBLOCK_IRXEXTE        Get ptr to EXTE
         DROP     R9                          Done with ENVB
         USING    IRXEXTE,R15                 Map EXTE
         L        R15,IRXEXCOM                Get ptr to EXCOM
         DROP     R15                         Done with EXTE
         CALL     (15),(EXCOM,,,VARREQ,ENVBA),VL,MF=(E,EXCOMPL)
* ---------------------------------------------------------------------
* Set a NULL result
* ---------------------------------------------------------------------
         L        R13,SAVEAREA+4              Restore callers savearea
         DROP     R13                         Done with WORK
         LA       R15,1                       Bad RC
         MVC      EVALBLOCK_EVLEN,=F'0'       Not returning anything
         B        RETURN                      Go exit
         DROP     R11                         Done with EVALBLOCK
         DROP     R12                         Done with BASE
* ---------------------------------------------------------------------
* Static data area
* ---------------------------------------------------------------------
T2PRC    DC       C'T2PRC'                    Return code variable name
EXCOM    DC       CL8'IRXEXCOM'               IRXEXCOM Name
* ---------------------------------------------------------------------
* Pre-initialized SHVB for setting T2PRC
* ---------------------------------------------------------------------
INITVR   DC       0F,XL(SHVBLEN)'00'
         ORG      INITVR+(SHVCODE-SHVBLOCK)
         DC       AL1(SHVSTORE)
         ORG      INITVR+(SHVNAMA-SHVBLOCK)
         DC       A(T2PRC)
         ORG      INITVR+(SHVNAML-SHVBLOCK)
         DC       A(L'T2PRC)
         ORG      INITVR+(SHVVALL-SHVBLOCK)
         DC       F'1'
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
* Our very own workarea DSECT
* ---------------------------------------------------------------------
WORKAREA DSECT
SAVEAREA DS       18F                         Standard save area
ENVBA    DS       A                           REXX ENVB ptr
EXCOMPL  CALL     ,(IRXEXCOM,,,VARREQ,ENVBA),MF=L REXX EXCOM plist
VARREQ   DS       XL(SHVBLEN)                 Variable request block
RC       DS       C                           Execution result
WORKLEN  EQU      *-WORKAREA                  Length of workarea
         DS       0XL(250-WORKLEN)            Force error if over 250
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
//LINKINIT EXEC  PGM=IEWL,
//             PARM='MAP,LET,LIST,NCAL,RENT,REUS'
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  DSN=&SYSUT1,
//             SPACE=(CYL,(3,2)),
//             UNIT=VIO
//SYSLMOD  DD  DSN=&LOADLIB,
//             DISP=SHR
//SYSLIN   DD  DSN=*.ASMINIT.SYSLIN,
//             DISP=(OLD,DELETE)
//         DD  *
  ENTRY T2PINIT
  NAME T2PINIT(R)
/*
