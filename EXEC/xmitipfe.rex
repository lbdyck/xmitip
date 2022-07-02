        /* --------------------  rexx procedure  -------------------- *
         * Name:      xmitipfe                                        *
         *                                                            *
         * Function:  Front-end XMITIPI                               *
         *                                                            *
         * Syntax:    %xmitipfe keywords                              *
         *                                                            *
         *            Valid keywords:                                 *
         *             To(to-email-address)                           *
         *             msgde(ddname)                                  *
         *             msgds(* for edit or data set name)             *
         *             file(attachment data set name)                 *
         *             filedd(attachment ddname)                      *
         *             filename(attachment name)                      *
         *             format(format)                                 *
         *             subject(subject text)                          *
         *             noattr                                         *
         *                                                            *
         * Keywords:   all are self explanatory                       *
         *             noattr is used to tell XMITIPI not to display  *
         *             the file attributes popup unless the user      *
         *             requests it on the XMITIP panel                *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *          2008-05-23 - Add MSGDD keyword                    *
         *          2008-05-01 - Add FILEDD keyword                   *
         *          2004-05-03 - Remove cleanup of variables at end   *
         *          2004-04-22 - Changed pool to profile              *
         *          2002-05-29 - Don't overlay format if it matches   *
         *          2002-02-01 - added NOATTR keyword support         *
         *          2000-12-19 - keywords added                       *
         *          2000-12-15 - created                              *
         *                                                            *
         * ---------------------------------------------------------- */
         Parse arg options

         parse value "" with null to msgds file subject format,
                        filename noattr filedd msgdd

        /* ----------------------------------------------------- *
         * Test for ISPF Applid of XMIT and if not then recurse  *
         * with that Applid.                                     *
         * ----------------------------------------------------- */
        Address ISPEXEC
        "Control Errors Return"
        "VGET ZAPPLID"
          if zapplid <> "XMIT" then do
             "TBCreate xmitcmds names(zctverb zcttrunc zctact" ,
                       "zctdesc) replace share nowrite"
             zctverb = "RFIND"
             zcttrunc = 0
             zctact = "&XMTRFIND"
             zctdesc = "RFIND for XMITIP"
             "TBAdd xmitcmds"
             "Select CMD("sysvar('sysicmd') options ") Newappl(XMIT)" ,
                 "passlib scrname(XMITIP)"
              xrc = rc
             "TBEnd xmitcmds"
             Exit xrc
             end

        /* ----------------------------------------------------- *
         * Process Keywords                                      *
         * ----------------------------------------------------- */
         ou       = translate(options)
         sp       = pos("SUBJECT(",ou)
         if sp > 0 then do
            ol = left(options,sp-1)
            subject = substr(options,sp+8)
            rp      = pos(")",subject)
            subject = substr(options,sp+8,rp-1)
            or      = substr(options,sp+rp+8)
            options = strip(ol or)
            end

         keywords = words(options)
         do i = 1 to keywords
            kw = word(options,i)
            kwu = translate(kw)
            Select
              When kwu = "NOATTR" then
                   noattr = "NOATTR"
              When left(kwu,3) = "TO(" then
                   to    = substr(kw,4,length(kw)-4)
              When left(kwu,5) = "FILE(" then
                   file  = substr(kw,6,length(kw)-6)
              When left(kwu,7) = "FILEDD(" then
                   file  = "DD:"substr(kw,8,length(kw)-8)
              When left(kwu,9) = "FILENAME(" then
                   filename = substr(kw,10,length(kw)-10)
              When left(kwu,7) = "FORMAT(" then
                   format = substr(kw,8,length(kw)-8)
              When left(kwu,6) = "MSGDS(" then
                   msgds = substr(kw,7,length(kw)-7)
              When left(kwu,6) = "MSGDD(" then do
                   msgdd = substr(kw,7,length(kw)-7)
                   msgds = "DD:"msgdd
                   end
              Otherwise do
                        Say "Error: Keyword >"kw"< is invalid." ,
                            "Command terminating - try again."
                        Exit 16
                        end
              end
            end

        /* ----------------------------------------------------- *
         * Set up variables in the ISPF profile Pool             *
         * ----------------------------------------------------- */
         Address ISPExec
         if length(to) > 0 then
            "Vput (to) profile"
         if length(msgds) > 0 then
            "Vput (msgds) profile"
         if length(file) > 0 then
            "Vput (file) profile"
         if length(subject) > 0 then
            "Vput (subject) profile"
         if length(format) > 0 then do
            save_format = format
            "Vget (format) Profile"
            if left(translate(save_format),3) <> ,
               left(translate(format),3) then
               format = save_format
            "Vput (format) profile"
            end
         "Vput (filename) profile"

        /* ----------------------------------------------------- *
         * Call the XMITIP ISPF Interface                        *
         * ----------------------------------------------------- */
         "Select cmd(xmitipi)"
         xrc = rc

         exit xrc
