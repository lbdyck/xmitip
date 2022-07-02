        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITIPZP                                        *
         *                                                            *
         * Function:  Invoked by XMITIP to the ZIP utility for the    *
         *            input file before e-mailing.                    *
         *                                                            *
         * Syntax:    %xmitipzp  indsn zipdsn ,                       *
         *                       zip_type zip_load ,                  *
         *                       z_type zip_nia password              *
         *                       method unit hlq debug                *
         *                                                            *
         *            where:                                          *
         *            indsn     input file to be ZIP'd                *
         *            zipdsn    output zip file                       *
         *            zip_type  zip package                           *
         *            zip_load  load library and program              *
         *                      e.g. sys1.zip.load(zip)               *
         *            z_type    ZIP for text                          *
         *                      ZIPBIN for binary                     *
         *            zip_nia   is the file name of the input file    *
         *                      as record in the ZIP file             *
         *                      (PKZIP NIA - name in archive)         *
         *                      * if not used                         *
         *            password  optional encryption password          *
         *                      * if not used                         *
         *                      PKZIP: if xxx:password then xxx is    *
         *                             used for the bits of encrypt   *
         *                             (128, 192 or 256)              *
         *                             PKZIP 5.6 and newer            *
         *            method    optional compression format           *
         *                      * if not used                         *
         *            unit      defines default dasd to use (3390)    *
         *                      * if not used                         *
         *            hlq       optional defines hlq to use for all   *
         *                      allocations if not fully qualified.   *
         *                      * if not used                         *
         *            debug     optional - display all messages       *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *          2017-11-21 - Update from Bot Atton to resolve an  *
         *                       issue with ZIP390                    *
         *          2010-03-31 - Update from Brian Walker to resolve  *
         *                       possible zip outdsn > 44 chars &     *
         *                       confirm hlq <= 8 (for infozip)       *
         *          2009-12-02 - Change TR to sysunits for sysut1     *
         *                       thx to Neil Eames                    *
         *          2008-07-28 - Change RC of 4096 to 4095            *
         *          2008-07-08 - Correction for InfoZip bug           *
         *                       thx to Werner Tomek                  *
         *          2008-05-04 - Correction for InfoZip bug           *
         *          2008-03-25 - Update if InfoZip temp out dsn is    *
         *                       > 44 characters when created         *
         *          2007-01-22 - More updates for SLIKZIP PDS support *
         *          2007-01-15 - Update for SLIKZIP thanks to         *
         *                       Peter Standfield <peter@ase.com.au>  *
         *          2004-09-23 - More updates from Barry Gilder       *
         *          2004-07-25 - Updates for ISPZIP from Barry Gilder *
         *          2004-02-03 - Add support for PKZIP Encryption     *
         *                       on the password field                *
         *          2003-07-18 - Add ALLOC for InfoZip output DSN     *
         *                       thx to Alain Janssens                *
         *          2003-04-07 - Use dynamic DD's for IEBGENER        *
         *                       thx to Staaf Sivert                  *
         *          2002-12-10 - Support pkzip passwords up to 80     *
         *                       characters (thx to John Kamp)        *
         *                     - change sysda to sysallda for allocs  *
         *          2002-08-06 - Change sysprint to dummy for infozip *
         *          2002-06-02 - Fix lrecl for infozip                *
         *          2002-04-05 - Fix support for InfoZip              *
         *                       - broken with new encode64           *
         *          2002-04-02 - Support Data21's ZIP390              *
         *          2001-10-12 - Change PKZIP method to uppercase     *
         *          2001-10-01 - add -text if not zipbin              *
         *          2001-07-23 - fix ISPZIP for sequential d/s        *
         *          2001-05-09 - fix zipdsn for ISPZIP                *
         *          2000-11-21 - fit cols 1-72                        *
         *          2000-11-13 - Remove echo of infozip command       *
         *          2000-10-16 - Add hlq option                       *
         *          2000-10-12 - Support INFOZIP                      *
         *          2000-09-01 - Display any messages from zip prog   *
         *          2000-06-08 - delete zipdsn (output) if zip n/f    *
         *          2000-05-23 - change test for rc after zip for 0<  *
         *          2000-05-19 - add warning if rc=4 but continue     *
         *          2000-05-18 - add rc to zip error message          *
         *          2000-04-17 - add method                           *
         *          2000-04-16 - cleanup and finalize                 *
         *          2000-04-07 - created                              *
         *                                                            *
         * ---------------------------------------------------------- */

         parse arg indsn zipdsn zip_type zip_load z_type ,
                   zip_nia password method unit hlq debug

         if zip_type = "" then return 4095

         indsn    = translate(indsn)
         zipdsn   = translate(zipdsn)
         zip_type = translate(zip_type)
         z_type   = translate(z_type)

         if hlq = "*" then zppref = sysvar('syspref')
                      else zppref = hlq

        /* ----------------------------------------------------- *
         * Set up defaults as necessary                          *
         * ----------------------------------------------------- */
         parse value "" with null parm

         rr = random(99999)

         msgid = sysvar("sysicmd")":"
         if length(msgid) = 0 then
            msgid = sysvar("syspcmd")":"

         if zip_load <> "*" then
            if sysdsn(zip_load) <> "OK" then do
               say msgid "ERROR: ZIP is not supported in this" ,
                         "environment"
               say msgid " load library" zip_load
               say msgid " Reason:" sysdsn(zip_load)
               exit 16
               end

        /* ----------------------------------------------------- *
         * Test input dataset name                               *
         * ----------------------------------------------------- */
         if sysdsn(indsn) <> "OK" then do
            say msgid "ERROR: The Input DSN was not found."
            say msgid " INPUT: " indsn
            say msgid " Reason:" sysdsn(indsn)
            exit 16
            end

        /* ----------------------------------------------------- *
         * If Method specified then verify                       *
         * ----------------------------------------------------- */
         if zip_type = "PKZIP" then do
            if method <> "*" then
               Select
                 When abbrev("NORMAL",translate(method),2) then
                      method = "Normal"
                 When abbrev("MAXIMUM",translate(method),2) then
                      method = "Maximum"
                 When abbrev("FAST",translate(method),2) then
                      method = "Fast"
                 When abbrev("SUPERFAST",translate(method),2) then
                      method = "Superfast"
                 When abbrev("STORE",translate(method),2) then
                      method = "Store"
                 otherwise do
                           say msgid "ZIP Error: The specified" ,
                               "compression method" method
                           say msgid "     is not a supported method."
                           say msgid "ZIP Terminating."
                           exit 16
                           end
                 End
            end
         if zip_type = "ZIP390" then do
            if method <> "*" then
               Select
                 When abbrev("NORMAL",translate(method),2) then
                      method = "Normal"
                 When abbrev("MAXIMUM",translate(method),2) then
                      method = "Maximum"
                 When abbrev("FAST",translate(method),2) then
                      method = "Fast"
                 When abbrev("SUPERFAST",translate(method),2) then
                      method = "Superfast"
                 When abbrev("HIGH",translate(method),2) then
                      method = "High"
                 otherwise do
                           say msgid "ZIP Error: The specified" ,
                               "compression method" method
                           say msgid "     is not a supported method."
                           say msgid "ZIP Terminating."
                           exit 16
                           end
                 End
            end
         if zip_type = "INFOZIP" then do
            if method = "*" then method = 5
            else if datatype(method) <> "NUM"
                 then do
                      say msgid "Invalid ZipMethod:" method
                      say msgid "ZipMethod reset to 5."
                      method = 5
                      end
            end
         if wordpos(zip_type,"ISPZIP SLIKZIP") > 0 then
            if method <> "*"
               then do
                    say msgid "ZIP Error:" zip_type "does not " ,
                         "support a compression method."
                    say msgid "ZIP Terminating."
                    exit 16
               end

        /* ----------------------------------------------------- *
         * fixup dataset names                                   *
         * ----------------------------------------------------- */
         if zip_type = "ISPZIP" then
            if pos("(",indsn) > 0 then do
               parse value indsn with ldsn "(" mem ")" rdsn
               indsn = ldsn""rdsn
               if zip_nia = "*"
                  then zip_nia = translate(mem)".txt"
               end

         if left(indsn,1) <> "'" then
            indsn = zppref"."indsn
            else parse value indsn with "'" indsn "'"
         if left(zipdsn,1) <> "'" then
            zipdsn = zppref"."zipdsn

        /* ----------------------------------------------------- *
         * Get rough space allocations                           *
         * ----------------------------------------------------- */
         call listdsi "'"indsn"' dir"
         if zip_type = "PKZIP" then do
            if sysadirblk = "NO_LIM" then do
               say msgid "ZIP Error: Input dataset is a PDSE Library" ,
                   "which is not supported by PKZIP/MVS."
               exit 16
               end
            end

        Select
          When zip_type = "PKZIP" then call build_pkzip
          When zip_type = "INFOZIP" then call build_infozip
          When zip_type = "ISPZIP" then call build_ispzip
          When zip_type = "ZIP390" then call build_zip390
          When zip_type = "SLIKZIP" then call build_slikzip
          otherwise do
            say msgid "ZIP Error: An unsupported zip was requested:" ,
                      zip_type
            say msgid "ZIP processing terminating."
            exit 16
            end
          end

        /* ----------------------------------------------------- *
         * Setup the SYSIN Work dataset and write cards out      *
         * ----------------------------------------------------- */
         if wordpos(zip_type,"PKZIP ZIP390 SLIKZIP") > 0 then do
            sysin = "'"zppref".zipwork.sysin.r"rr"'"
            "Alloc f(sysin) unit(sysallda) spa(1,1) tr recfm(f b) " ,
                   "lrecl(80) blksize(6160) reuse ds("sysin") new"
            "Execio * diskw sysin (finis stem card."
            end

        /* ----------------------------------------------------- *
         * Setup the ISPZCNTL dataset and write out              *
         * ----------------------------------------------------- */
         if zip_type = "ISPZIP" then do
            ispzcntl = "'"zppref".zipwork.zcntl.r"rr"'"
            "Alloc f(ISPZCNTL) unit(sysallda) spa(1,1) tr recfm(f b) " ,
                   "lrecl(80) blksize(6160) reuse ds("ispzcntl") new"
            "Execio * diskw ISPZCNTL (finis stem card."
            end

        /* ----------------------------------------------------- *
         * Alloc SYSPRINT                                        *
         * ----------------------------------------------------- */
         sysprint = "'"zppref".zipwork.sysprint.r"rr"'"
         call msg 'off'
         if zip_type = "INFOZIP" then prnt_dd = null
         if wordpos(zip_type,"PKZIP ZIP390") > 0 then do
            prnt_dd = "sysprint"
            "Free  f(sysprint)"
            "Alloc f(sysprint) unit(sysallda) spa(1,1) tr" ,
                   "recfm(f b) lrecl(132) blksize(27984)" ,
                   "reuse ds("sysprint") new"
            end
         if zip_type = "SLIKZIP" then do
            prnt_dd = "sysprint"
            "Free  f(sysprint)"
            "Alloc f(sysprint) unit(sysallda) spa(1,1) tr" ,
                   "recfm(v b a) lrecl(133) blksize(0)" ,
                   "reuse ds("sysprint") new"
            end
         if zip_type = "ISPZIP" then do
            prnt_dd = "ispzprnt"
            "Free  f(ispzprnt)"
            "Alloc f(ispzprnt) unit(sysallda) spa(1,1) tr" ,
                   "blksize(0) reuse ds("sysprint") new"
            end
         call msg 'on'

        /* ----------------------------------------------------- *
         * Now call ZIP Utility                                  *
         * ----------------------------------------------------- */
         call outtrap "zip."
         if zip_type = "INFOZIP" then do
            call listdsi "'"indsn"'"
            "Alloc f(sysut1) ds("zipdsn") new reuse" ,
                  "spa("sysprimary","sysseconds")" sysunits ,
                  "recfm(v b) lrecl(23734) blksize(32738)" ,
                  "unit(sysallda)"
            infozip_cmd
            end
         else do
            if zip_load = "*" then
               Address Link zip_type
            else do
               if parm <> null
                  then "Call" zip_load "'"parm"'"
                  else "Call" zip_load
               end
            end
         src = rc
         if src = 4 then src = 0
         erc = src
         call outtrap "off"

        /* ----------------------------------------------------- *
         * Display any messages generated by the ZIP program     *
         * ----------------------------------------------------- */
        if zip.0 > 0 then
          do zipm = 1 to zip.0
             say msgid "ZIP Msg:" zip.zipm
             end

        /* ----------------------------------------------------- *
         * If return non-zero then display zip messages          *
         * ----------------------------------------------------- */
         if src = 4 then do
            say msgid " "
            say msgid "Warning: Zip processing returned a return" ,
                      "code of 4."
            say msgid "   Processing continues but you should check "
            say msgid "   the zip report."
            say msgid " "
            debug = "DEBUG"
            src   = 0
            erc   = 0
            end
         if src > 4 | src < 0 then do
            say msgid " "
            say msgid "Error encountered during ZIP processing rc:" erc
            say msgid " "
            debug = "DEBUG"
            src   = 0
            call msg 'off'
            "Delete" zipdsn
            end

        /* ----------------------------------------------------- *
         * If Debug set and return is 0 then display zip msgs    *
         * ----------------------------------------------------- */
         if debug <> null
            then if src = 0
            then if zip_type = "INFOZIP" then
               say msgid "InfoZip return code:" src
            else do
                "Execio * diskr" prnt_dd "(finis stem zip."
                 say msgid "ZIP Messages:"
                 do i = 1 to zip.0
                    say msgid zip.i
                    end
                    say msgid " "
                 end

        /* ----------------------------------------------------- *
         * Free/Delete the SYSIN work dataset and reallocate     *
         * sysin and sysprint dd's                               *
         * ----------------------------------------------------- */
         call free_alloc

        /* ---------------------------------------- *
         * If InfoZip copy from recfm=u to recfm=vb *
         * ---------------------------------------- */
         if zip_type = "INFOZIP" then do

            drop x
            zipout = substr(zipdsn,2,length(zipdsn)-2)"O"
            if length(zipout) > 44 then
               x = 'error'
            zipout = translate(zipout," ",".")
            zw     = words(zipout)
            if length(subword(zipout,zw)) > 8 then
               x = 'error'
            if x = 'error' then do
               zw     = words(zipout)
               zipout = subword(zipout,1,zw-1)".O"
               end
            zipout = translate(zipout,"."," ")

            "Alloc f(msgsysin) dummy reuse"
            "Alloc f(msgprint) dummy reuse"
            v0 = '0000000000000000'x
            v1 = ''
            v2 = v0''v0''v0''v0"MSGSYSINMSGPRINT"

            "Alloc f(sysut1) ds("zipdsn") shr reuse"
            call listdsi zipdsn
            "Alloc f(sysut2) ds('"zipout"') new reuse" ,
              "spa("sysprimary","sysseconds") Tr" ,
              "recfm(v b) lrecl(23734) blksize(23738)"
            ADDRESS LINKMVS "IEBGENER v1 v2"
            "Free  f(sysut1 sysut2)"
            "Free  f(msgsysin msgprint)"
            call msg "off"
            "Delete" zipdsn
            "rename '"zipout"'" zipdsn
            end

        /* ----------------------------------- *
         * Now return with highest return code *
         * ----------------------------------- */
         return erc

        /* ----------------------------------------------------- *
         * Free Allocations                                      *
         * ----------------------------------------------------- */
         Free_alloc:
         if wordpos(zip_type,"PKZIP ZIP390 SLIKZIP") > 0 then
            "Free  f(sysin) Delete"
         if prnt_dd <> null then
            "Free  f("prnt_dd") Delete"
         "Alloc f(sysin)    ds(*) reuse"
         "Alloc f(sysprint) ds(*) reuse"
         if wordpos(zip_type,"ISPZIP SLIKZIP") > 0 then
            "Free  f("zip_dd zip_dda")"
         if zip_type = "ISPZIP" then do
            "Free  f(ispzcntl) delete"
            end
         return

        /* ----------------------------------------------------- *
         * Now build the InfoZip Command                         *
         * ----------------------------------------------------- */
        Build_InfoZip:
           infozip_cmd = "ZIP -v"
           if z_type = "ZIPBIN" then
              infozip_cmd = infozip_cmd"B"method
           else
              infozip_cmd = infozip_cmd"al"method
           if password <> "*" then
              infozip_cmd = infozip_cmd"P" password
           infozip_cmd = infozip_cmd zipdsn "'"indsn"'"
           return

        /* ----------------------------------------------------- *
         * Now build the PKZIP control statements                *
         * ----------------------------------------------------- */
        Build_PKZIP:
         if left(zipdsn,1) = "'" then
            zipdsnp = substr(zipdsn,2,length(zipdsn)-2)
         else zipdsnp = zipdsn
         card.1  = "-Echo"
         card.2  = "-Archive("zipdsnp")"
         card.3  = "-Add"
         card.4  = "-Archspace(TRK)"
         card.5  = "-Archprimary("sysprimary")"
         card.6  = "-Archsecondary("sysseconds")"
         card.7  = "-Archtype(FB)"
         card.8  = "-Archlrl(512)"
         card.9  = "-Archblksiz(0)"
         card.10 = "-NoPath"
         card.11 = "-Archrlse"
         i = 11

         method = translate(strip(method))
         i = i + 1
         if method <> "*"
            then card.i = "-Method("method")"
            else card.i = "-Method(NORMAL)"

         password = strip(password)
         if password <> "*" then do
            aes = null
            Select
              When left(password,4) = "128:" then
                   parse value password with aes":"password
              When left(password,4) = "192:" then
                   parse value password with aes":"password
              When left(password,4) = "256:" then
                   parse value password with aes":"password
              Otherwise nop
              end
            if aes <> null then do
               i = i + 1
               card.i = "-AES"aes
               end
            if length(password) > 50 then do
               passwordchunk1 = left(password,50)
               passwordchunk2 = right(password,length(password) -50)
               i = i + 1
               card.i = "-Password("passwordchunk1||"-"
               i = i + 1
               card.i = passwordchunk2||")"
               end
            else do
               i = i + 1
               card.i = "-Password("password")"
               end
         end

         if z_type = "ZIPBIN" then do
            i = i + 1
            card.i = "-Binary"
            end
         else do
            i = i + 1
            card.i = "-Text"
            end

         if unit <> "*" then do
            i = i + 1
            card.i = "-Archunit("unit")"
            end

         zip_nia    = strip(zip_nia)
         if zip_nia <> "*" then do
            i = i + 1
            card.i = "-NIA(*,"zip_nia")"
            end

         i = i + 1
         card.i = indsn
         card.0 = i
         return

        /* ----------------------------------------------------- *
         * Now build the ZIP/390 control statements              *
         * ----------------------------------------------------- */
        Build_ZIP390:
          /* allocate the output archive to a dd*/
          call msg 'off'
          "Delete" zipdsn
          call msg 'on'
          zip_dd = "D"rr
          "Alloc f("zip_dd") ds("zipdsn") new tracks" ,
             "spa("sysprimary","sysseconds")"   ,
             "recfm(v b) lrecl(23738) blksize(23738)"

         Select
            When sysunits = "BLOCK"    then spx = "sysblksize"
            When sysunits = "CYLINDER" then spx = (15 * 56664)
            When sysunits = "TRACK"    then spx = "56664"
            otherwise nop
            end
         obuff = ((sysprimary * spx) % 1024) + 100

         card.1  = "ECHO=YES"
         card.2  = "ACTION=ZIP"
         card.3  = "OBUFF="obuff"K"
         card.4  = "ARCHIVE=SEQ/"zip_dd"/23738/23738/VB"
         i = 4

         method = translate(strip(method))
         i = i + 1
         if method <> "*"
            then card.i = "CMPRLVL="method
            else card.i = "CMPRLVL=NORMAL"

         password = strip(password)
         if password <> "*" then do
            i = i + 1
            card.i = "PASSWORD="password
            end

         if z_type = "ZIPBIN" then do
            i = i + 1
            card.i = "MODE=BINARY"
            end
         else do
            i = i + 1
            card.i = "MODE=TEXT"
            end

         /* strip indsn of quotes */
         if left(indsn,1) = "'" then
            indsn = substr(indsn,2,length(indsn)-2)
         indsn = translate(indsn)
         /* now build input dsn control card */
         zip_nia    = strip(zip_nia)
         if zip_nia <> "*" then do
            i = i + 1
            card.i = "IFILE=DSN/"indsn";+"
            i = i + 1
            card.i = zip_nia
            end
         else card.i = "IFILE=DSN/"indsn

         card.0 = i
         return

        /* ----------------------------------------------------- *
         * Now build the ISPZIP control statements               *
         * ----------------------------------------------------- */
        Build_ISPZIP:
          if left(zipdsn,1) = "'" then
             parse value zipdsn with "'"zipdsn"'"
          if password <> "*" then do
             say msgid "ZIP Error: ISP/ZIP does not support a password"
             say msgid "at this time. ZIP process terminating."
             exit 16
             end
          call msg 'off'
          /* allocate the output archive to a dd*/
          "Delete '"zipdsn"'"
          call msg 'on'
          zip_dd = "d"rr
          "Alloc f("zip_dd") ds('"zipdsn"') new tracks" ,
             "spa("sysprimary","sysseconds")"   ,
             "recfm(v b) lrecl(4096) blksize(0)"
          parm = "COMP"
          /* allocate the data to be zipped to a dd*/
          rr = rr""a
          zip_dda = "d"rr
          zip_dda = translate(zip_dda)
          "Alloc f("zip_dda") ds('"indsn"') shr"
          if zip_nia <> "*" then parm = parm "FROMDD(*)"
          else parm = parm "FROMDS(''"indsn"'')"
          parm = parm "TODS(''"zipdsn"'')"
          parm = parm "NOLOG ZIP"
          dot = pos(".",zip_nia)
          ext = zip_nia
          do while dot > 0
             ext = substr(ext,pos(".",ext)+1)
             dot = pos(".",ext)
             end
          /* build the ispzcntl dd card images */
          card.1  = "EXT BIN"
          card.2  = "EXT CSV ASCII CRLF"
          card.3  = "EXT GIF"
          card.4  = "EXT HTML ASCII CRLF"
          card.5  = "EXT PDF"
          card.6  = "EXT RTF ASCII CRLF"
          card.7  = "EXT TXT ASCII CRLF"
          card.8  = "EXT XMIT"
          card.9  = "FROMDD "zip_dda
          card.10 = "S ZIPFILE."translate(EXT)" PCFN='"zip_nia"'"
          i = 10

         return

        /* ----------------------------------------------------- *
         * Now build the SLIKZIP control statements              *
         * ----------------------------------------------------- */
        Build_SLIKZIP:
          if left(zipdsn,1) = "'" then
             parse value zipdsn with "'"zipdsn"'"
          call msg 'off'
          /* allocate the output archive to a dd*/
          "Delete '"zipdsn"'"
          call msg 'on'
          zip_dd = "d"rr
          "Alloc f("zip_dd") ds('"zipdsn"') new tracks" ,
             "spa("sysprimary","sysseconds")"   ,
             "recfm(v b) lrecl(4096) blksize(0)"
          /* allocate the data to be zipped to a dd*/
          rr = rr""a
          zip_dda = "d"rr
          zip_dda = translate(zip_dda)
          "Alloc f("zip_dda") ds('"indsn"') shr"
          parm = "ZIP"
          /* build the slikzip control statements */
          card.1 = "todd "zip_dd
          card.2 = "fromdd "zip_dda" +"
          i = 2
          if zip_nia <> "*" then do
             i = i + 1
             card.i = " mname("zip_nia") +"
             end
          if password <> "*" then do
             if translate(left(password,4)) = "AES:" then do
                password = substr(password,5)
                i = i + 1
                card.i = " aes +"
                end
             if length(password) > 50 then do
                passwordchunk1 = left(password,50)
                passwordchunk2 = right(password,length(password) -50)
                i = i + 1
                card.i = " password("passwordchunk1"+"
                i = i + 1
                card.i = "          "passwordchunk2") +"
                end
             else do
                i = i + 1
                card.i = " password("password") +"
                end
             end
          i = i + 1
          if z_type = "ZIPBIN" then
             card.i = " binary"
          else
             card.i = " text"
        /*i = i + 1*/
        /*card.i = "Demokey=634CD1F4C55028AE6A4B7B8A5449147A89"*/

         return
