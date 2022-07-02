        /* --------------------  rexx procedure  -------------------- *
         * Name:      XMITIPTR                                        *
         *                                                            *
         * Function:  XMITIP Month and Day Translation Routine        *
         *                                                            *
         *            ****************************************        *
         *            * To Be Customized by Each Site        *        *
         *            ****************************************        *
         *                                                            *
         * Syntax:    newdate=xmitiptr(opt old_date_string)           *
         *                                                            *
         *            opt is optional and if used the syntax is:      *
         *                -L language                                 *
         *            e.g. -L GERMAN                                  *
         *                                                            *
         *            old_date is either a mmm (month)                *
         *                     or                                     *
         *                     is a full month                        *
         *                     or                                     *
         *                     is a ddd (day)                         *
         *                     or                                     *
         *                     is a full day                          *
         *                     or                                     *
         *                     is a string (e.g. day month year)      *
         *                                                            *
         *            newdate will be the translated field            *
         *                                                            *
         * Author:    Lionel B. Dyck                                  *
         *            Internet: lbdyck@gmail.com                      *
         *                                                            *
         * Recognition: Thanks to Hartmut Beckmann who encouraged     *
         *              this code and who provided the sample NLS     *
         *              tables.                                       *
         *              To Horst Mademann for the Portuguese Brazil   *
         *              table.                                        *
         *                                                            *
         * History:                                                   *
         *          2009-09-28 - support phrases                      *
         *                       <PHRASE>.</PHRASE>                   *
         *                       If there is no special translation   *
         *                       for the complete phrase the routine  *
         *                       works as usual (words)               *
         *          2008-02-25 - Fix Septembre (French) capitalization*
         *          2007-08-23 - Danish thx to Frank Allan Rasmussen  *
         *          2005-10-08 - French thx to Francois Bourgois      *
         *          2004-07-19 - Enhancements by Hartmut for xlates   *
         *          2004-07-13 - Add option -L CHECK to compare       *
         *                       the word tables                      *
         *          2004-07-12 - Add Italian thx to Maurizio Violi    *
         *          2004-07-12 - supports trailing dot and colon      *
         *                       supports parenthesis around the word *
         *          2004-06-15 - Remove default_lang (now in xmitipcu)*
         *                     - Add words for translate              *
         *                       and updated all tables (mostly)      *
         *          2004-06-09 - Correction to Spanish table thx      *
         *                       from Vicente Zafra Ruiz              *
         *          2004-05-13 - Added Dutch language from            *
         *                       Alain Janssens                       *
         *          2004-04-27 - Renamed from XMITIPDT                *
         *                     - Add optional language specification  *
         *                       and support any char string          *
         *          2004-04-26 - Bug fix (missing call to set_tables) *
         *                       and now translate entire passed opt  *
         *          2004-03-30 - Generalization                       *
         *          2004-03-29 - Correction to the German table       *
         *                       and addition of Spanish thanks       *
         *                       to Hartmut Beckmann                  *
         *          2004-03-22 - Creation                             *
         *                                                            *
         * ---------------------------------------------------------- */
         parse arg opt

        /* -------------- *
         * Setup defaults *
         * -------------- */
         _junk_ = sub_init() ;

        /* -------------------------------- *
         * Test for and process any option. *
         *                                  *
         * Option is -L for language        *
         *                                  *
         * syntax:   -L language            *
         * -------------------------------- */
         opt = strip(opt)
         if left(opt,1) = "-"
            then do
                 parse value opt with l1 l2 opt
                 l1 = translate(l1)
                 if l1 = "-L" then lang = l2
                 end
         if lang = null then lang = default_lang
         lang = translate(lang)
         opt = strip(opt)
        /* ---------------------------------------------- *
         * The format for the table and the nls_table is: *
         *                                                *
         *    List of 3 character days of the week        *
         *    List of full days of the week names         *
         *    List of full month names                    *
         *    list of short month names                   *
         * ---------------------------------------------- */

        /* ----------------------------- *
         * Define the translation Tables *
         * ----------------------------- */
         table = "Mon Tue Wed Thu Fri Sat Sun" ,
                 "Monday Tuesday Wednesday Thursday Friday" ,
                 "Saturday Sunday" ,
                 "January February March April May June July" ,
                 "August September October November December" ,
                 "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec" ,
                 "E-Mail Originated From Sent Note On at",
                 "and are is masked" ,
                 "Date Time "
         utable = translate(table)

        /* -------------------------------------- *
         * Now Define the National Language Table *
         * -------------------------------------- */
         call set_tables
         Select
           When ( lang = "ENGLISH"   ) ,
                then return opt
           When ( lang = "GERMAN"    ) ,
                then do;
                        nls_table = german
                     end;
           When ( lang = "SPANISH" ) ,
                then do;
                        nls_table = spanish
                     end;
           When ( lang = "DUTCH"     ) ,
                then do;
                        nls_table = dutch
                     end;
           When ( lang = "ITALIAN"   ) ,
                then do;
                        nls_table = italian
                     end;
           When ( lang = "BRAZILIAN" ) ,
                then do;
                        nls_table = brazilian
                     end;
           When ( lang = "FRENCH"    ) ,
                then do;
                        nls_table = french
                     end;
           When ( lang = "DANISH"    ) ,
                then do;
                        nls_table = danish
                     end;
           When ( lang = "CHECK"   ) ,
                then do;
                        call check_tables
                        return 0
                     end;
           Otherwise return 12
           end
           nls_phrase.0 = value(lang".phrase.0")
           do idx = 1 to nls_phrase.0
               nls_phrase.idx = value(lang".phrase."idx)
           end

        newopt = ""
        process_phrase = "NO"
        /* -------------------------------------------- *
         * Now process phrase if requested              *
         * -------------------------------------------- */
         if abbrev(opt,"<PHRASE>") = 1 ,
         then do;
                  process_phrase = "YES"
                  parse var opt 1 "<PHRASE>" ,
                                   opt         ,
                                 "</PHRASE>" .
                  opt = strip(opt)
                  if opt = "." ,
                  then opt = "E-Mail originated from"
                  opt_nls = sub_phrase(opt)
                  if opt_nls = opt ,
                  then nop
                  else newopt = opt_nls
              end;

        /* -------------------------------------------- */
        /* Now process through all the 'words' provided */
        /* -------------------------------------------- */
         if newopt = "" ,
         then do;
                 do w = 1 to words(opt)
                    uopt = translate(word(opt,w))
                    nopt = null
                    if datatype(uopt) <> "NUM" then
                       call test_opt
                       if nopt <> null then do
                          newopt = strip(newopt nopt)
                          end
                          else newopt = strip(newopt word(opt,w) )
                    end
              end;

        if process_phrase = "YES" ,
        then do;
                 newopt = "<PHRASE>"newopt"</PHRASE>"
             end;
        if call_type = "COMMAND" ,
        then do;
                 say newopt
                 exit
             end;
        else do;
                 return newopt
             end;

sub_init:
  parse source xenv call_type myname ddname dsname .
  parse value "" with null newopt nopt lang
 return 0

        /* ---------------------------------------- */
        /* Now find the passed option and translate */
        /* ---------------------------------------- */
         Test_opt:
         /* trailing char */
         char_lead  = null
         char_trail = null
         special_chars=". : ( )"
         uopt = uopt
         do forever
             pos = length(uopt)
             if pos = 0 then leave
             char_find = find(special_chars,substr(uopt,pos,1) )
             if char_find > 0 then do
                uopt = substr(uopt,1,pos-1)
                char_trail = word(special_chars,char_find)""char_trail
                  end
             else do
                leave
                  end
         end
         do forever
             pos = 1
             char_find = find(special_chars,substr(uopt,pos,1) )
             if char_find > 0 then do
                uopt = substr(uopt,2)
                char_lead  = char_lead""word(special_chars,char_find)
                  end
             else do
                leave
                  end
         end
         if wordpos(uopt,utable) = 0 then return

        /* ----------------------------- *
         * Now find the opt in the table *
         * ----------------------------- */
         p = wordpos(uopt,utable)
         nopt = word(nls_table,p)
         nopt = char_lead""nopt""char_trail
         return

        /* ---------------------------------------------------- *
         * This section of code contains the tables for various *
         * languages. If one does not exist for your language   *
         * please create one and then please share it with the  *
         * author of this code so others may have the benefit   *
         * of your efforts.                                     *
         * ---------------------------------------------------- */
         Set_Tables:
         /* German                                                */
         german    = "Mon Die Mit Don Fre Sam Son" ,
                     "Montag Dienstag Mittwoch Donnerstag Freitag" ,
                     "Samstag Sonntag" ,
                     "Januar Februar M"'c0'x"r April Mai Juni ",
                     "Juli August September Oktober November Dezember" ,
                     "Jan Feb M"'c0'x"rz Apr Mai Jun Jul Aug Sep" ,
                     "Okt Nov Dez" ,
                     "E-Mail erzeugt durch Gesendet Anm Am um" ,
                     "und sind ist maskiert"     ,
                     "Datum   Zeit " ,
                     ""
         German.phrase.0      = 1
         German.phrase.1      = "E-Mail erzeugt durch"

         /* Spanish                                               */
         spanish   = "Lun Mar Mie Jue Vie Sab Dom" ,
                     "Lunes Martes Miercoles Jueves Viernes" ,
                     "Sabado Domingo" ,
                     "Enero Febrero Marzo Abril Mayo Junio Julio ",
                     "Agosto Septiembre Octubre Noviembre Diciembre" ,
                     "Ene Feb Mar Abr May Jun Jul Ago Sep" ,
                     "Oct Nov Dic" ,
                     "E-Mail Originado de Enviado Note On at" ,
                     "and are  is  masked"       ,
                     "Date    Time " ,
                     ""
         Spanish.phrase.0     = 0

         /* Portuguese: Brazil (without accents)                  */
         brazilian = "Seg Ter Qua Qui Sex Sab Dom" ,
                     "Segunda-feira Terca-feira Quarta-feira" ,
                     "Quinta-feira Sexta-feira Sabado Domingo" ,
                     "Janeiro Fevereiro Marco Abril Maio Junho Julho ",
                     "Agosto Setembro Outubro Novembro Dezembro" ,
                     "Jan Fev Mar Abr Mai Jun Jul Ago Set" ,
                     "Out Nov Dez" ,
                     "E-Mail Originado de Emitido Note On at" ,
                     "and are  is  masked"       ,
                     "Date    Time " ,
                     ""
         Brazilian.phrase.0 = 0

         /* Italian (without accents)                             */
         italian   = "Lun Mar Mer Gio Ven Sab Dom" ,
                     "Lunedi Martedi Mercoledi Giovedi Venerdi" ,
                     "Sabato Domenica" ,
                     "gennaio febbraio marzo aprile maggio giugno luglio ",
                     "agosto settembre ottobre novembre dicembre" ,
                     "Gen Feb Mar Apr Mag Giu Lug Ago Set" ,
                     "Ott Nov Dic" ,
                     "E-mail creato dal Trasmessa Nota Il alle   " ,
                     "e sono e' mascherato"      ,
                     "Date    Time " ,
                     ""
         Italian.phrase.0     = 0

         /* Dutch                                                 */
         dutch     = "Maa Din Woe Don Vri Zat Zon" ,
                     "Maandag Dinsdag Woensdag Donderdag Vrijdag" ,
                     "Zaterdag Zondag" ,
                     "Januari Februari Maart April Mei Juni Juli",
                     "Augustus September Oktober November December" ,
                     "Jan Feb Maa Apr Mei Jun Jul Aug Sep" ,
                     "Okt Nov Dec" ,
                     "E-Mail Originated From Sent Note On at" ,
                     "en worden is gemaskeerd "  ,
                     "Date    Time " ,
                     ""
         Dutch.phrase.0       = 0

          /* French                                               */
         french    = "Lun Mar Mer Jeu Ven Sam Dim " ,
                     "Lundi  Mardi Mercredi Jeudi Vendredi " ,
                     "Samedi Dimanche " ,
                     "Janvier Fevrier Mars Avril Mai Juin Juillet " ,
                     "Aout Septembre Octobre Novembre Decembre  " ,
                     "Jan Fev Mar Avr Mai Jun Jui Aou Sep Oct Nov Dec" ,
                     "E-Mail Originated From Sent Note On at",
                     "and are is masked" ,
                     "Date Time " ,
                     ""

         French.phrase.0      = 1
         French.phrase.1      = "Origine de cet E-Mail"

          /* Danish                                               */
         Danish    = "Man Tir Ons Tor Fre Loe Soe " ,
                 "Mandag Tirsdag Onsdag Torsdag Fredag " ,
                 "Loerdag Soendag " ,
                 "Januar Februar Marts April Maj Juni Juli " ,
                 "August September Oktober November December  " ,
                 "Jan Fev Mar Apr Maj Jun Jul Aug Sep Okt Nov Dec" ,
                 "E-Mail Originated From Sent Note On at",
                 "and are is masked" ,
                 "Dato Tid "
         Danish.phrase.0      = 0
         return

    /* check the number of words in the tables    */
    /* with master table English                  */
       Check_Tables:
       languages = "german spanish brazilian italian dutch french" ,
                   "danish" ,
                   ""
       info = "Check of languages tables.           "
       say info
       say copies("=",length(info))
       say " "
       do langx = 1 to words(languages)
          lang = word(languages,langx)
          langwords = words(value(lang))
          Select
             when ( words(utable) = langwords ) then info = "O.K."
             when ( words(utable) < langwords ) then info = "WARN"
             when ( words(utable) > langwords ) then info = "ERR."
             otherwise                               info = "GRRR"
          end
          say info ":" words(utable) "- " left(lang,12) ":" langwords
       end
       say " "
         return

sub_phrase: procedure expose original.phrase.      ,
                             nls_phrase.
  parse arg _data_
  new_string = strip(_data_)
  original.phrase.0    = 1
  original.phrase.1    = "E-Mail originated from"

  do idx = 1 to original.phrase.0
     if _data_ = original.phrase.idx ,
     then do;
             if nls_phrase.0 < idx ,
             then nop
             else new_string = nls_phrase.idx
          end;
  end
 return new_string
