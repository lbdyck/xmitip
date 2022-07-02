        /* --------------------  rexx procedure  -------------------- *
         * Name:      xmitiof                                         *
         *                                                            *
         * Function:  Used to e-mail a file from IOF as RTF file      *
         *                                                            *
         * Syntax:    %xmitiof file                                   *
         *                                                            *
         * Usage:    Invoked by the %XMITIOFM exec                    *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Kaiser Permanente Information Technology        *
         *            Walnut Creek, CA 94598                          *
         *            (925) 926-5332                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            03/14/03 - Added Address IOF                    *
         *            01/18/01 - Created from XMITSDSF                *
         *            01/18/01 - Create filename with time            *
         *            12/19/00 - Creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
        parse arg file

        /* ----------------------------------------------------- *
         * Test for print data set name                          *
         * ----------------------------------------------------- */
        if length(file) = 0 then do
           say "Error: dataset name missing. Ending."
           exit 8
           end

        /* --------------------------------------------------------- *
         * Construct filename for XMITIP                             *
         * --------------------------------------------------------- */
         parse value time() with hh ":" mm ":" .
         filename = "IOF"hh""mm".rtf"

        /* ----------------------------------------------------- *
         * Call the XMITIP Front-End                             *
         * ----------------------------------------------------- */
         Address IOF
        "TSIEXEC SELECT CMD(%xmitipfe msgds() file("file")" ,
          "Subject(Report from IOF)" ,
          " Format(rtf/land/9/let) filename("filename")"

        /* ----------------------------------------------------- *
         * Now clean up after ourselves                          *
         * ----------------------------------------------------- */
        call msg "off"
        "del" file
