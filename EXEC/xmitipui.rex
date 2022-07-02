        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITIPUI                                        *
         *                                                            *
         * Function:  Retrieve UserID from ACEE to allow for 8        *
         *            character IDs.                                  *
         *                                                            *
         * Syntax:    UID = xmitipui()                                *
         *                                                            *
         * Author:    Barry Gilder                                    *
         *            ANZ Bank                                        *
         *            Melbourne, Australia                            *
         *            Email: gilderb@anz.com                          *
         *                                                            *
         * NOTES:     Once XMITIP and TXT2PDF have been customized    *
         *            use EZYEDIT or similar and change (replace) all *
         *            of the following:                               *
         *                                                            *
         *            userid()                                        *
         *            sysvar(sysuid)                                  *
         *            sysvar('sysuid')                                *
         *            sysvar("sysuid")                                *
         *                                                            *
         *            with: xmitipui()                                *
         *                                                            *
         * History:                                                   *
         *            02/03/04 - Creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         PSAOLD   = storage(d2x(548),4)               /* ASCB Address */
         ASCBASXB = storage(d2x(c2d(PSAOLD)+108),4)   /* ASXB Address */
         ACEEADDR = storage(d2x(c2d(ASCBASXB)+200),4) /* ACEE Address */
         USERID   = storage(d2x(c2d(ACEEADDR)+21),8)  /* UserID       */
         return strip(USERID)
