        /* =============================================================
        || Procedure:     XMITB64     : Sends binary data after
        ||                            : converting to base64.
        || Author:       Leland.Lucius@ecolab.com
        ||               Borrowed with his permission
        ||               Modified to accept input and output files
        ||
        || Syntax:       xmitb64 -e input output
        ||               if output is not preallocated then it will be
        ||                  allocated
        ||  This exec may be used in place of the XMITB64 C program if
        ||  problems with the C program are encountered.  Note that
        ||  use of this exec will preclude the use of InfoZip which
        ||  creates RECFM=U files that rexx can not read.
        || =============================================================
        */
        do_Base64:
           arg de indsn outdsn

        ddni = "B64i"random(99)
        ddno = "B64o"random(99)

        /* ----------------------------------------------------- *
         * Test indsn to see if it exists                        */
         if sysdsn(indsn) <> "OK" then do
            say "Error: Input dsn:" indsn sysdsn(indsn)
            exit 8
            end

        /* ----------------------------------------------------- *
         * Test outdsn to see if it exists & alloc               */
         if sysdsn(outdsn) <> "OK" then do
            call listdsi indsn
            "Alloc ds("outdsn") new like("indsn") recfm(f b) lrecl(80)",
                  "blksize(23440) f("ddno") dsorg(ps)"
            end
         else "Alloc f("ddno") ds("outdsn") shr"

        /* ----------------------------------------------------- *
         * Alloc and read in the input file                      */
         "Alloc f("ddni") shr ds("indsn")"
         "Execio * diskr" ddni "(finis stem in."
         "Free  f("ddni")"

          /* ===========================================================
          || Define BASE64 character set
          */
          char_set =           'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
          char_set = char_set""'abcdefghijklmnopqrstuvwxyz'
          char_set = char_set""'0123456789+/'

          /* ===========================================================
          || Process until we get to EOF
          */
          null   = ""
          innum  = in.0
          out.0  = 0
          buffer = null
          recnum = 0
          eof = 0
          Do while \eof

            /* =========================================================
            || Try to get a buffers worth of input
            */
            Do while length( buffer ) < 57 & \eof
              recnum = recnum + 1
              IF recnum > innum THEN DO
                eof = 1
                LEAVE
              end
              rec = in.recnum
              buffer = buffer""rec
            end

            /* =========================================================
            || Convert the first 57 characters in the buffer to binary
            */
            sextets = X2b(C2x(Left(buffer,Min(57,Length(buffer)))))

            /* =========================================================
            || And remove 'em from the buffer
            */
            buffer = Substr(buffer, 58)

            /* =========================================================
            || Output the binary data
            */
            lout = null
            Do sextetoff = 1 to Length(sextets) by 6

              /* =======================================================
              || Grab 75 cents worth (padding if necessary)
              */
              sextet = Substr(sextets,sextetoff,6,"0")

              /* =======================================================
              || Convert it to a base64 character
              */
              lout = lout""Substr(char_set,X2d(B2x(sextet))+1,1)
            end

            /* =========================================================
            || Send the line (padding if necessary)
            */
            out.0 = out.0 + 1
            n     = out.0
            out.n = lout""Copies("=",(76-Length(lout))//4)
          end
          "Execio * diskw" ddno "(Finis stem out."
          "free f("ddno")"
        return
