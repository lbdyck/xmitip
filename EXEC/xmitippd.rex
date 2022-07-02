        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITIPPD                                        *
         *                                                            *
         * Function:  Front-end to TXT2PDF.                           *
         *            Formerly contained conversion code but replaced *
         *            by new TXT2PDF by Leland Lucius.                *
         *                                                            *
         * Syntax:    %XMITIPPD options                               *
         *                                                            *
         *            options are the options to pass to TXT2PDF      *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            10/06/03 - update to inform user to call        *
         *                       txt2pdf directly                     *
         *            03/12/02 - Creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         parse arg options

         Say "XMITIPPD: This exec has been replaced by TXT2PDF. Please"
         say "          change your usage from XMITIPPD to TXT2PDF as"
         say "          at some point in the future XMITIPPD will be"
         say "          removed from the system."
         say " "
         say "Calling %TXT2PDF now...."

         "%txt2pdf" options
