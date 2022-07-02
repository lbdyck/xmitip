        /* --------------------  rexx procedure  -------------------- *
         * Name:      mailedit ispf edit macro                        *
         *                                                            *
         * Function:  E-Mail the current/active edit dataset          *
         *                                                            *
         * Syntax:    %mailedit                                       *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            2004-03-29 - correction for sequential d/s      *
         *            2002-03-13 - creation                           *
         *                                                            *
         * ---------------------------------------------------------- */
         Address ISREdit
         "Macro"

         "(CHANGED) = DATA_CHANGED"
         IF changed = "YES"  THEN "Save"

         "(DSNAME) = DATASET"
         "(MEM) = MEMBER"

         if mem <> ""
            then dsname = "'"dsname"("mem")'"
            else dsname = "'"dsname"'"

         Address TSO,
           "%xmitipfe file("dsname")"
