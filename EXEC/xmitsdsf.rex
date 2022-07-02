        /* --------------------  rexx procedure  -------------------- *
         * Name:      xmitsdsf                                        *
         *                                                            *
         * Function:  Used to e-mail a file from sdsf as RTF file     *
         *                                                            *
         * Syntax:    %xmitsdsf data-set-name file-type               *
         *                                                            *
         *            data-set-name is the name of the to be          *
         *            created data set (which will be deleted upon    *
         *            exit from this exec)                            *
         *                                                            *
         *            file-type is one of the following:              *
         *               blank = RTF (default)                        *
         *               C = CSV                                      *
         *               H = HTML                                     *
         *               P = PDF                                      *
         *               R = RTF                                      *
         *               T = Text                                     *
         *               Z = ZIP the text                             *
         *                                                            *
         * Pre-req:   Must update a program function key in SDSF to   *
         *                                                            *
         * pt odsn sdsf.list * new;pt;pt close;tso %xmitsdsf sdsf.list*
         *                                                            *
         * Usage:    Then in sdsf just select the desired spool file  *
         *           and press that program function key              *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            2002-10-14 - support option of CSV              *
         *            2002-04-01 - support option of ZIP              *
         *            2002-02-07 - fix applid test for delete for iof *
         *            2001-12-07 - add option for html                *
         *            2001-03-20 - make file dsn unique to userid     *
         *            2001-02-28 - Add file type option               *
         *            2001-01-18 - Create filename with time          *
         *            2000-12-19 - Creation                           *
         *                                                            *
         * ---------------------------------------------------------- */
         arg file type

        /* ----------------------------------------------------- *
         * Test for print data set name                          *
         * ----------------------------------------------------- */
        if length(file) = 0 then do
           say "Error: dataset name missing. Ending."
           exit 8
           end

        /* -------------------------- *
         * Test for hlq and do rename *
         * -------------------------- */
         hlq = sysvar('syspref')
         if hlq <> sysvar('sysuid') then do
            "Rename" file "'"sysvar('sysuid')"."file"'"
            file = "'"sysvar('sysuid')"."file"'"
            end

        /* --------------------------------------------------------- *
         * Test for File Type and Set                                *
         * --------------------------------------------------------- */
        Select
          When type = "C" then do
               format = "csv"
               suf = "csv"
               end
          When type = "H" then do
               format = "html"
               suf = "html"
               end
          When type = "P" then do
               format = "pdf/land/9/let"
               suf = "pdf"
               end
          When type = "R" then do
               format = "rtf/land/9/let"
               suf = "rtf"
               end
          When type = "T" then do
               format = "txt"
               suf = "txt"
               end
          When type = "Z" then do
               format = "zip"
               suf = "zip"
               end
          Otherwise do
               format = "rtf/land/9/let"
               suf = "rtf"
               end
          End

        /* --------------------------------------------------------- *
         * Construct filename for XMITIP                             *
         * --------------------------------------------------------- */
         parse value time() with hh ":" mm ":" .
         filename = "SDSF"hh""mm"."suf

        /* ----------------------------------------------------- *
         * Call the XMITIP Front-End                             *
         * ----------------------------------------------------- */
        "%xmitipfe msgds() file("file") Subject(Report from SDSF)" ,
            " Format("format") filename("filename")"

        /* ----------------------------------------------------- *
         * Now clean up after ourselves                          *
         *    unless not called from applid ISF (SDSF)           *
         * ----------------------------------------------------- */
        call msg "off"
        Address ISPExec "Vget (zapplid)"
        if pos(zapplid,"ISF IOF") > 0 then
           "del" file
