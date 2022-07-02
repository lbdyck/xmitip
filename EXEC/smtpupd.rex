/*  REXX  */
/* Update the SMTP security table with the    */
/* userid and nodename passed as args         */
/*                                            */
/*Author:     Kent Garrett                    */
/*            Technical Services Bureau       */
/*            GSD                             */
/*            State of New Mexico             */
TRACE N

/* declare the dsn for the smtp security table */
SECFILE = "SYS2.SMTP.SECURITY.TABLE"

/* receive args, userid and nodename */
PARSE UPPER ARG USERID NJENODE GARBAGE
USERID = STRIP(USERID)
NJENODE = STRIP(NJENODE)

/* allocate the dsn for the smtp security table */
"ALLOC DSN('"SECFILE"') SHR FI(SECTAB)"

/* Update the smtp security table dataset       */
/* adding the new userid and nodename.          */
/* This does not disrupt SMTP who only          */
/* processes this dataset at startup.           */
"MAKEBUF"
"EXECIO * DISKR SECTAB (FINIS "
NEWLINE = "  U              N       "
NEWLINE = OVERLAY(USERID,NEWLINE,3)
NEWLINE = OVERLAY(NJENODE,NEWLINE,18)
QUEUE NEWLINE
"EXECIO * DISKW SECTAB (FINIS "
"DROPBUF"
"FREE FI(SECTAB)"

/* Now invoke the clist to stop SMTP.  SMTP     */
/* will automatically restart and process the   */
/* updated security table.                      */
"%PSMTP"
