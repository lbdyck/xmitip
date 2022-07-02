        /* --------------------  rexx procedure  -------------------- *
         * Name:      xmitipfb                                        *
         *                                                            *
         * Function:  Feedback ISPF Edit Command used by XMITIPI      *
         *            to prompt user for information.                 *
         *                                                            *
         * Syntax:    %xmitipfb                                       *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Kaiser Permanente Information Technology        *
         *            Walnut Creek, CA 94598                          *
         *            (925) 926-5332                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            09/27/02 - creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         Address ISREdit
         "Macro"
         "nonum"
         "caps off"
         Address ISPExec
         "Vget (ver) shared"
         "Vget (zenvir zos390rl)"
         Address ISREdit
         parse value zenvir with ispf_ver "MVS" .
         os_ver = zos390rl
         dest = -1
         call add_line "XMITIP Feedback Form."
         call add_line " "
         call add_line "Environment:" ,
                       "XMITIP" ver "   " ispf_ver "   " os_ver
         call add_line "Date:" date() "Time:" time() "System:" ,
                       mvsvar('sysname') "on Node:" sysvar('sysnode')
         call add_line " "
         call add_line "Enter comments and feedback about XMITIP below:"
         call add_line " "
         call add_line "Is this a problem __  a suggestion __" ,
                       "a comment __"
         call add_line " "
         call add_line "Enter a description of your problem with as much",
                       "information as you can."
         save_line = dest
         call add_line "Include the XMITIP command syntax used and any",
                       "error messages."
         call add_line "If a suggestion or comment please be as specific",
                       "as possible."
         "Tflow" dest "72"
         call add_line " "
         exit

        /* --------------------------- *
         * Common Add Line sub-routine *
         * --------------------------- */
         Add_Line:
         parse arg data
         dest = dest + 1
         "Line_After" dest "= (data)"
         return
