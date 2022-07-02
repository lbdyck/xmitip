/* rexx  */
/* Email from IOF Browse screen                                     */
/* EMAIL    ( Or EM ) parms                                         */
/*   where parms are: ALL  ( Default )     Email the whole sysout   */
/*                    SCREEN               Email the current screen */
/*                    nnn LINES or PAGES   mail the next nnn lines  */
/*               or pages starting at the top of the current screen */
parse upper arg var1 var2
" PROFILE PROMPT "
 address IOF
 " SD DA(IOFMAIL)   "
 if var1 = 'ALL'| var1 ="" then do
 " SNAP ALL"
 end
 else do
  if var1 = "SCREEN" then do
   " SNAP "
  end
  if datatype(var1) = "NUM" then do
   if var2 = "LINES" then do
   " SNAP " var1 "LINES"
   end
   if var2  = "PAGES" then do
   " SNAP " var1 "PAGES"
   end
  end
 end
 " SNAPCLOS "
  call  'XMITIOF' IOFMAIL
  dummy = msg("off")
  "tso del" iofmail
   exit 0
