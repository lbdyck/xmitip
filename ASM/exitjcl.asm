//SMTPEXIT JOB ....
//* -------------------------------------------------------------------
//* Specify load library
//* -------------------------------------------------------------------
//LOADLIB  SET  LOADLIB='your.loadlib'
//SRC      SET  SRC='your.source(SMTPEXIT)'
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
//SYSIN    DD  DISP=SHR,DSN=&SRC
//* -------------------------------------------------------------------
//* Link
//* -------------------------------------------------------------------
//LINK     EXEC  PGM=IEWL,
//             COND=(5,LT,ASM),
//             PARM='MAP,LET,LIST,NCAL,RENT,REUS,AC(1)'
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  DSN=&SYSUT1,
//             SPACE=(CYL,(3,2)),
//             UNIT=VIO
//SYSLMOD  DD  DSN=&LOADLIB,
//             DISP=SHR
//SYSLIN   DD  DSN=*.ASM.SYSLIN,
//             DISP=(OLD,DELETE)
//         DD  *
  NAME SMTPEXIT(R)
/*
//
