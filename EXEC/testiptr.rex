/* rexx */
/*                                                                */
/* _x_ = TRACE("R")  */
/* check the tables  */
   _x_ = xmitiptr("-L CHECK")
   say ""
/* exit */
/* check sample text */
    languages = "ENGLISH SPANISH GERMAN DUTCH BRAZILIAN ITALIAN"
    str = "Note: e-mail test - Sent "DATE("N") "("DATE("W")")." ,
          "JOBNAME is masked."
    do i = 1 to words(languages)
       _x_ = do_it(""word(languages,i)" "str"")
    end
    say " "
exit
do_it:
    PARSE ARG lang .
    say ""
    say "lang: " lang
    ns = xmitiptr("-L "lang str)
    say 'str:  ' str
    say 'ns:   ' ns
  return 0
/* rexx */
str = "This e-mail is a test"
ns = xmitiptr("-L SPANISH" str)
say 'str:' str
say 'ns: ' ns
/* rexx */
str = "This e-mail is a test"
ns = xmitiptr("-L SPANISH" str)
say 'str:' str
say 'ns: ' ns
