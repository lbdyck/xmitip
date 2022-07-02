        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITIPM                                         *
         *                                                            *
         * Function:  return privacy message based upon input         *
         *            - called by XMITIP                              *
         *                                                            *
         * Syntax:    %xmitipm sensitivity-type                       *
         *                                                            *
         *            Sensitivity-type may be:                        *
         *            Personal                                        *
         *            Private                                         *
         *            Confidential                                    *
         *            Company-Confidential                            *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *            12/17/01 - Add Privileged to Confidential msg   *
         *            12/03/01 - creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         parse arg opt
         if opt = "" then return

         Select
           when opt = "Company-Confidential" then do
                text = "This E-Mail is Company Confidential" ,
                       "use appropriately."
                end
           when opt = "Confidential" then do
                text = "This E-Mail is Confidential and Privileged."
                end
           when opt = "Personal" then do
               text = "This E-Mail is Personal and is intended",
                      "for use by the recipient(s) only."
               end
           when opt = "Private" then do
               text = "This E-Mail is Private and is intended",
                      "for use by the recipient(s) only."
               end
           otherwise nop
           end

           Return text
