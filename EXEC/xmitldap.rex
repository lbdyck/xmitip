        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITLDAP                                        *
         *                                                            *
         * Function:  Local customizations for ldap queries           *
         *                                                            *
         * Syntax:    x=xmitldap()                                    *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * History:                                                   *
         *          2009-03-20 - Update to generalize name & mail     *
         *          2009-03-05 - Correct local_nodes                  *
         *          2008-11-10 - Change ldap_server                   *
         *                     - add ldap_d and ldap_w                *
         *          2008-09-01 - remove never executed "exit"         *
         *          2000-11-22 - add examples                         *
         *          2000-13-11 - creation                             *
         * ---------------------------------------------------------- */

        /* ----------------------------------------------------- *
         * Set defaults                                          *
         *                                                       *
         *  ldap_server is ZERO (0) to disable all ldap access   *
         *              or the host name of the ldap server      *
         *  ldap_o is the o= and u= for your installation        *
         *  local_nodes defines the valid domains (after the @)  *
         *     which will be verified.  Others will be ignored.  *
         * ----------------------------------------------------- *
         * Examples:                                             *
         * ldap_server = "mailhub.host.com"                      *
         * ldap_o      = "o=Company,c=US"                        *
         * local_nodes = "host.com hostnode.com"                 *
         * ----------------------------------------------------- */
         ldap_server = "ed.host.com"
         ldap_o      = "o=Company,c=US"
         local_nodes = "host.com hostnode.com"

         /* define the ldap bind userid */
         ldap_d      = '-D userid'

         /* define the ldap bind password */
         ldap_w      = '-w password'

         /* ----------------------- *
          * Define the site fields: *
          *      Name field (cn=)   *
          *      Mail field (mail=) *
          * ----------------------- */
          ldap_name = 'cn='
          ldap_mail = 'mail='


         return ldap_server "/" ldap_o "/" ldap_d "/" ,
                ldap_w "/"local_nodes "/" ldap_name ldap_mail
