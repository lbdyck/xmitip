        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITIPEX Sample User Exit                       *
         *                                                            *
         * Function:  XMITIP User Exit                                *
         *                                                            *
         * Syntax:    x = xmitipex()                                  *
         *                                                            *
         *            parameters may be passed within the parens      *
         *            and must be processed by this code              *
         *                                                            *
         *            The first parm if any should be the msgid       *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            01/30/04 - Creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         parse arg msgid parms
         /* Process the parms here */

         /* Set the return code */
         exitrc = 0

         return exitrc
