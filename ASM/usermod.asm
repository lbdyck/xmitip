//****   CHANGE THE JOB CARD, THE DATA SET IN UMODLIB TO POINT TO THE
//****   LIBRARY WHERE THE SOURCE MEMBER IS
//****   THE NAME OF YOUR GLOBAL CSI
//****   THE USERMOD ID
//USERMOD  JOB ...                                      <===== CHANGE
//         MSGCLASS=X,NOTIFY=&SYSUID,TIME=1439
//*****************************************************************
//* SMTP SERVER MAIL FILTER EXIT                                  *
//*****************************************************************
//PS100AA  EXEC SMPES
//UMODLIB   DD DISP=SHR,DSN=SMTPEXIT.SOURCE.LIBRARY   <====== CHANGE
//SMPCSI    DD DISP=SHR,DSN=GLOBAL.ZONE.CSI           <====== CHANGE
//SMPLOG    DD DUMMY
//SMPLOGA   DD DUMMY
//SMPCNTL   DD *
  SET BDY(S10DR30).
   UCLIN.
      DEL SRC(SMTPEXIT).
      DEL MOD(SMTPEXIT).
   ENDUCL.
   RESETRC.
  SET BDY(GLOBAL) .
    REJECT  SELECT(PS100AA) BYPASS(APPLYCHECK,ACCEPTCHECK) .
    RESETRC.
    RECEIVE SELECT(PS100AA) SYSMODS LIST.
  SET BDY(S10DR30).
    APPLY   SELECT(PS100AA) REDO.
/*
//SMPPTFIN  DD DATA,DLM=$$
++USERMOD(PS100AA) .
++VER(Z038) FMID(HBB7706) .
++JCLIN .
//PS100AA  JOB 'PS100AA',MSGLEVEL=(1,1)
//LKED01   EXEC PGM=IEWL,
//         PARM='MAP,LET,LIST,NCAL,RENT,REUS,AC(1)'
//SYSLMOD   DD DSN=SYS1.LINKLIB,DISP=SHR
//ALINKLIB  DD DSN=SYS1.ALINKLIB,DISP=SHR
//SYSPUNCH  DD DSN=*.ASM01.SYSPUNCH,DISP=(SHR,PASS)
//SYSLIN    DD *
  INCLUDE ALINKLIB(SMTPEXIT)
  SETCODE AC(1)
  NAME    SMTPEXIT(R)
/*
++SRC(SMTPEXIT) DISTLIB(ASAMPLIB) DISTMOD(ALINKLIB) TXLIB(UMODLIB).
$$
//
