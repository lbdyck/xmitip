        /* --------------------  rexx procedure  -------------------- *
         * Name:      genrfdbe                                        *
         *                                                            *
         * Function:  Feedback ISPF Edit Command used by GENRFDBK     *
         *            to prompt user for information.                 *
         *                                                            *
         * Syntax:    EDIT Macro(genrfdbe)                            *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            07/14/03 - save text in ispf vars to test for   *
         *                       updates by user                      *
         *            12/09/02 - improve notes for cancel             *
         *            10/03/02 - add note lines                       *
         *            09/30/02 - created from xmitipfb                *
         *                                                            *
         * ---------------------------------------------------------- */
         Address ISREdit
         "Macro"
         "nonum"
         "caps off"
         Address ISPExec
         "Vget (appver appname) shared"
         "Vget (zenvir zos390rl)"
         Address ISREdit
         parse value zenvir with ispf_ver "MVS" .
         os_ver = zos390rl
         dest = -1
         call add_line appname "Feedback Form."
         call add_note " "
         call add_note "to submit this feedback."
         call add_note "Enter CANCEL in the command line if you do not wish"
         call add_line " "
         call add_line "Environment:" ,
                       appname appver "   " ispf_ver "   " os_ver
         call add_line "Date:" date() "Time:" time() "System:" ,
                       mvsvar('sysname') "on Node:" sysvar('sysnode')
         call add_line " "
         call add_line "Is this a problem __  a suggestion __" ,
                       "a comment __"
         call add_note "Please classify this feedback on the line below"
         call add_line " "
         call add_line "Enter a description of your issue with as much",
                       "information as you can."
         save_line = dest
         call add_line "If a suggestion or comment please be as specific"
         call add_line "as possible. Use as many lines as you need."
         call add_line " "
         call add_note "to submit this feedback."
         call add_note "Enter CANCEL in the command line if you do not wish"
         call add_note " "
         l = dest
         Address ISPExec "Vput (l) shared"
         "Insert" dest+1
         exit

        /* --------------------------- *
         * Common Add Line sub-routine *
         * --------------------------- */
         Add_Line:
         parse arg data
         dest = dest + 1
         "Line_After" dest "= (data)"
         lev  = "L"
         dlev = dest + 1
         interpret lev||dlev  "= data"
         interpret "Address ISPExec vput (lev||dlev) shared"
         return

        /* --------------------------------- *
         * Common Add Notes Line sub-routine *
         * --------------------------------- */
         Add_Note:
         parse arg data
         "Line_After" dest "= Noteline (data)"
         return
