        /* --------------------  rexx procedure  -------------------- *
         * Name:      xmitipfv                                        *
         *                                                            *
         * Function:  called by xmitipcu to find the current version  *
         *            of xmitip                                       *
         *                                                            *
         * Syntax:    %xmitipfv                                       *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            2008-06-18 - cleanup                            *
         *            2008-06-10 - creation                           *
         *                                                            *
         * ---------------------------------------------------------- */

         parse value "" with null dsn ver

        /* --------------------------------------- *
         * Find out the DD from which we came from *
         * and hopefully XMITIP will be in that    *
         * same DD.                                *
         * --------------------------------------- */
         parse source os type name dd rest

        /* -------------------------------- *
         * Find the DD and check for XMITIP *
         * -------------------------------- */
         call outtrap 'trap.'
         "lista status"
         call outtrap 'off'
         do i = 1 to trap.0
            if word(trap.i,2) = dd then do
               dsn = word(trap.i,1)
               end
            if dsn = null then do;
               if word(trap.i,1) = dd then do
                  j = i - 1
                  dsn = word(trap.j,1)
                  end
               end
            if dsn /= null then ver = check_dsn();
            if ver /= null then leave
            end
         if ver = null then ver = "99.99"
         if type = "COMMAND" ,
         then do ;
                  ver = return_ver() ;
                  exit   ver
              end;
         else do ;
                  return ver
              end;
         exit 12

         Return_ver:
            parse value ver with xx"."yy
            ver = (xx*100) + right(yy+100,2)
            ver = right(ver,4,0)
            return ver

        /* -------------------- *
         * Check DSN for XMITIP *
         * -------------------- */
         Check_DSN: procedure expose dsn
             dsn = "'"dsn"(XMITIP)'"
             if sysdsn(dsn) = "OK" then ver = get_ver() ;
            return ver

        /* ----------------------------------- *
         * Read in XMITIP and find the version *
         * ----------------------------------- */
         Get_Ver: procedure expose dsn
             dd = "txm"random(999)
             "Alloc f("dd") shr ds("dsn")"
             "Execio 2 diskr" dd "(finis stem xm."
             "Free  f("dd")"
             if word(xm.2,1) = "ver" then
                interpret xm.2
            return ver
