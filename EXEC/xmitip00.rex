        /* --------------------  rexx procedure  -------------------- *
         * Name:      xmitip00                                        *
         *                                                            *
         * Function:  general interface to XMITIP package             *
         *                                                            *
         * Syntax:    %xmitip00 parms                                 *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            2005-05-13 - creation                           *
         *                                                            *
         * ---------------------------------------------------------- */

         _x_ = trace("r")
         _x_ = sub_init() ;

          _sysenv_   = SYSVAR("SYSENV")
          _sysispf_  = "NOT ACTIVE"
          _zispfrc_  = "NO"
          _editmac_  = "NOT ACTIVE"
          _hfs_env_  = "NOT ACTIVE"

         "SUBCOM ISPEXEC"
         rcode = rc
         if rcode = 0 ,
         then do ;
              _sysispf_ = "ACTIVE"
              if _sysenv_ = "FORE" ,
              then nop;
              else _zispfrc_  = "YES"
              end;

         if   _sysispf_ = "ACTIVE" ,
         then do ;
                 address ISPEXEC
                 "control errors return"
                 address ISREDIT
                 " MACRO (PARMS)"
                 rcode = rc
                 if rcode  = 0 ,
                 then do ;
                          _editmac_ = "ACTIVE"
                          "(dsn) = Dataset"
                          "(mem) = Member"
                          dsn = dsn
                          mem = mem
                          if dsn = _null_ ,
                          then do ;
                                 Address ISPEXEC
                                 "VGET (HFSCWD,HFSNAME)"
                                 fullPath = hfscwd""hfsname
                                 if fullpath = _null_ ,
                                 then nop ;
                                 else do ;
                                         _hfs_env_  = "ACTIVE"
                                      end;
                               end;
                      end;
              end;

         rcode = 0
         if _editmac_ = "ACTIVE" ,
         then    _parms_ = parms
         else do ;
                 parse arg _parms_
              end;

         /* dynalloc or not ... */

         /* what to do now  ... */
         select ;
           when ( _sysispf_ = "NOT ACTIVE" ) ,
             then do ;
                  end;
           when ( _hfs_env_  = "ACTIVE") ,
             then do ;
                     address ISREDIT
                     "MAILHFSE "_parms_
                     rcode = rc
                  end;
           when ( _editmac_ = "ACTIVE" ) ,
             then do ;
                     address ISREDIT
                     "XMITIPED "_parms_
                     rcode = rc
                  end;
           when ( translate(word(_parms_,1)) = "SDSF.LIST" ) ,
             then do ;
                     address ISPEXEC
                     "SELECT CMD(%XMITSDSF "_parms_")"
                     rcode = rc
                  end;
             otherwise do ;
                     address ISPEXEC
                     "SELECT CMD(%MAILFILE "_parms_")"
                     rcode = rc
                  end;
         end;
         if _zispfrc_  = "YES"
         then do ;
                 ZISPFRC = rcode
                     address ISPEXEC
                 " vput (ZISPFRC)"
              end;
         exit rcode

        sub_init:
          parse value "" with _null_
          parse source xenv xtype xmyname .
          _pref_xmitip_  = _null_
          _pref_txt2pdf_ = _null_
          _dynalloc_ = "YES"
         return 0

        /* ---------------------------------------------------------- *
         *  - check the environment                                   *
         *  -- ISPF active                                            *
         *  -- EDIT macro                                             *
         *  -- DSLIST    how ???                                      *
         *  - dynalloc/libdef   (check via DISPLAY PANEL XMITmmnn)    *
         * ---------------------------------------------------------- */

        /* ---------------------------------------------------------- *
         *  - mailfile / mailhfse                                     *
         *  - mailhfse                                                *
         *  - mailldap                                                *
         *  - sendfile                                                *
         *  - xmitsdsf                                                *
         *  - xmitiped                                                *
         *  - dynalloc/libdef   (check via DISPLAY PANEL XMITmmnn)    *
         * ---------------------------------------------------------- */
