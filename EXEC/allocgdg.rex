        /* --------------------  rexx procedure  -------------------- *
         * Name:      allocgdg                                        *
         *                                                            *
         * Function:  Allocate a GDG (input only)                     *
         *                                                            *
         * Syntax:    %allocgdg ddn dsname(n)                         *
         *                                                            *
         *            if ddn is * then the dsname is returned to      *
         *            the caller:                                     *
         *                                                            *
         *            gdg_dsn = allocgdg("* 'hlq.dsname(n)'")         *
         *            (no comma between parameters)                   *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            02/03/03 - update comments above                *
         *            05/15/01 - fix if prefix ne userid              *
         *            05/14/01 - creation                             *
         *                                                            *
         * ---------------------------------------------------------- */

         arg ddn dsn

        /* --------------------------------------------------------- *
         * Validate input                                            *
         * --------------------------------------------------------- */
         if length(ddn) = 0 then call badinput 1
         if length(dsn) = 0 then call badinput 2
         if pos("(",dsn) = 0 then call badinput 3

        /* --------------------------------------------------------- *
         * Extract the GDG Base from the provided DSname as well as  *
         * extracting the relative GDG.                              *
         * --------------------------------------------------------- */
         if left(dsn,1) = "'" then
            parse value dsn with "'"dsn"'"
         else do
              if sysvar(syspref) <> sysvar(sysuid)
                 then dsn = sysvar(syspref)"."dsn
                 else dsn = sysvar(sysuid)"."dsn
                 end
         parse value dsn with dsn "("gdg")"
         if datatype(gdg) <> "NUM" then call badinput 3

        /* --------------------------------------------------------- *
         * Invoke LISTC Level(gdg-base) to Get List of all GDG's     *
         * --------------------------------------------------------- */
         call outtrap "listc."
         "listc level('"dsn"')"
         call outtrap "off"

        /* --------------------------------------------------------- *
         * Place each DSname into the GDG. stem                      *
         * --------------------------------------------------------- */
         base = 0
         do i = 1 to listc.0
            if word(listc.i,1) <> "NONVSAM" then iterate
            base = base + 1
            gdg.base = word(listc.i,3)
            end

        /* --------------------------------------------------------- *
         * If the gdg is >0 then it must have been created within    *
         * this batch job and the catalog is not updated yet. This   *
         * should not be an issue in current levels of OS/390 v2r7+  *
         * --------------------------------------------------------- */
         if gdg > 0 then do
            dsnw = gdg.base
            dsnw = translate(dsnw," ",".")
            goovoo = word(dsnw,words(dsnw))
            parse value goovoo with "G" gen "V" ver
            if gen = 9999 then do
               gen = 0
               ver = ver + 1
               gdg = gdg - 1
               end
            gen = gen + gdg
            dsnt = subword(dsnw,1,words(dsnw)-1)
            dsnt = dsnt".G"right(gen+10000,4)"V"right(ver+100,2)
            dsnt = translate(dsnt,"."," ")
            gdg.base = dsnt
            end
         else do
              base = base + gdg
              if base < 1 then call badinput 6
              end

        /* --------------------------------------------------------- *
         * Test GDG Dsname for validity                              *
         * --------------------------------------------------------- */
         if sysdsn("'"gdg.base"'") <> "OK" then call badinput 5

        /* --------------------------------------------------------- *
         * Now Allocate the Dataset to the specified DDN, or if      *
         * DDN = * then return the dsname to the caller              *
         * --------------------------------------------------------- */
         if ddn = "*" then return "'"gdg.base"'"
         else "Alloc f("ddn") ds('"gdg.base"') shr reuse"
         exit 0

        /* --------------------------------------------------------- *
         * Error routine to inform the user of the reason that we    *
         * are terminating this execution.                           *
         * --------------------------------------------------------- */
         BadInput:
            arg opt
            say "Error invoking" sysvar(sysicmd)
            Select
              When opt = 1 then
                   say "no parameters provided."
              When opt = 2 then
                   say "two parameters are required."
              When opt = 3 then
                   say dsn "is not an apparent gdg."
              When opt = 4 then
                   say "generation of",
                        gdg "must be 0 or negative."
              When opt = 5 then do
                   say "GDG DSname of" gdg.base ,
                        sysdsn("'"gdg.base"'")
                   exit 4
                   end
              When opt = 6 then do
                   say "Generation of" gdg ,
                        "is not within the range of generations",
                        "for GDG Base DSname" dsn
                   exit 4
                   end
              Otherwise nop
              End
            say "Correct syntax is:"
            say "%"sysvar(sysicmd) "ddname dsname(-n)"
            exit 4
