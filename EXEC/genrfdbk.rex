        /* --------------------  rexx procedure  -------------------- *
         * Name:      genrfdbk                                        *
         *                                                            *
         * Function:  Generalized Feedback application to be used     *
         *            in any ISPF dialog using XMITIP to e-mail the   *
         *            feedback.                                       *
         *                                                            *
         * Syntax:    %genrfdbk app-name app-ver feedback-email       *
         *                                                            *
         *                      app-name is the name of the           *
         *                               application                  *
         *                      app-ver  is the version of the app    *
         *                      feedback-email is the e-mail address  *
         *                               where the feedback will be   *
         *                               sent                         *
         *                                                            *
         * Dependencies:  XMITIP and genrfdbe (edit macro)            *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            07/15/03 - Minor correction                     *
         *            07/14/03 - Verify user entered comments before  *
         *                       sending e-mail                       *
         *            12/09/02 - fix scrname                          *
         *            09/30/02 - creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         parse arg options

         Address ISPExec

         "VGET ZAPPLID"
           if zapplid <> "XMIT" then do
              cmd = sysvar('sysicmd')
              "Select CMD(%"cmd options ") Newappl(XMIT)" ,
                  "passlib scrname("cmd")"
              x_rc = rc
              if x_rc > 4 then do
                 smsg = zerrtype
                 lmsg = zerrlm
                "Setmsg Msg(xmit001)"
                 end
              Exit 0
              end

         parse value options with appname appver feedback_email .

         "Vget (from sigdsn)"

         if feedback_email = "" then do
            smsg = "Error!"
            lmsg = "No feedback e-mail address provided. Thus no",
                   "feedback could be generated. Report this if",
                   "you believe this to be an error."
            "Setmsg msg(xmit001)"
            exit 4
            end

         fbktext = "feedback.text"
         fbkdd   = "FB"random(999)
         call msg "off"
         Address TSO
         "Delete" fbktext
         "Alloc f("fbkdd") new spa(1,1) tr recfm(f b) lrecl(80)" ,
               "blksize(6160) ds("fbktext")"
         "Free  f("fbkdd")"
         Address ISPExec
         "Vput (appname appver) shared"
         "Edit dataset("fbktext") macro(genrfdbe)"
         if rc > 0 then do
            smsg = "Cancelled"
            lmsg = "Feedback has been cancelled."
            "Setmsg Msg(xmit001)"
            Address TSO ,
               "Delete" fbktext
            exit 0
            end

         Address TSO
         "Alloc f("fbkdd") shr ds("fbktext") reuse"
         "Execio * diskr" fbkdd "(finis stem fbk."
         "Free  f("fbkdd")"
         Address ISPExec
         "Vget (L) shared"
         lev = "L"
         t.0 = l
         do i = 1 to l
            interpret "Vget (lev||i) shared"
            interpret "t.i = value(lev||i)"
            end
         send = 0

         if t.0+1 <> fbk.0 then send = 1
         else do i = 1 to l
                 if t.i <> fbk.i then send = 1
                 end

         if send = 0 then do
            smsg = "Cancelled"
            lmsg = "Feedback not processed as no" ,
                   "comments were entered."
            "Setmsg Msg(xmit001)"
            Address TSO ,
               "Delete" fbktext
            exit 0
            end

         cmd = "%xmitip" feedback_email ,
               "msgds" fbktext ,
               "subject 'Feedback:" appname appver"'",
               "noconfirm"
         if from   <> null then cmd = cmd "From" from
         if sigdsn <> null then cmd = cmd "SIG" sigdsn
         call outtrap "trap."
         Address TSO
         cmd
         "Delete" fbktext
         Address ISPExec
         call outtrap "off"
         smsg = "Processed"
         lmsg = "Feedback has been processed to:" feedback_email
         "Setmsg Msg(xmit001)"
         Exit
