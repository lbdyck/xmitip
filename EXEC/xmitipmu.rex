        /* REXX */
        /* ------------------------------------------------------------- *
         * Name:      XMITIPMU (Murphy)                                  *
         *            This name is used to interface with the XMITIP     *
         *            application.                                       *
         *                                                               *
         * Function:  REXX exec to output a Murphy Phrase. To be used    *
         *            either standalone, where the phrase is merely      *
         *            output using SAY, or as a called function, where   *
         *            the phrase is strung together as a single RETURN   *
         *            value.                                             *
         *                                                               *
         * Environment: Tested under TSO/REXX with OS/390 2.5 and under  *
         *            CA-OPS/MVS OPS/REXX at version 4.3.                *
         *            Should also work in other REXX environments.       *
         *                                                               *
         * Syntax:    %XMITIPMU Seed         (standalone)                *
         *            rtvl = xmitipmu(Seed)  (function call)             *
         *            rtvl = xmitipmu(Seed,"FUNC")                       *
         *                                   (function call in OPS/REXX) *
         *                                                               *
         *            Seed is an optional positive integer to receive    *
         *            a specific Murphy phrase.                          *
         *                                                               *
         * Examples:  %XMITIPMU       (standalone from TSO command line) *
         *            %XMITIPMU 321   (and with seed)                    *
         *                                                               *
         *            TSO %XMITIPMU  (standalone from ISPF command line) *
         *            TSO %XMITIPMU 321 (and with seed)                  *
         *                                                               *
         *            address TSO                                        *
         *            "%XMITIPMU"          (standalone within REXX exec) *
         *            "%XMITIPMU 321"      (and with seed)               *
         *                                                               *
         *            OI XMITIPMU          (standalone OPS/REXX)         *
         *            OI XMITIPMU 321      (and with seed)               *
         *                                                               *
         *            !OI XMITIPMU         (standalone OPS/REXX console, *
         *                                 ! is site OSFCHAR)            *
         *                                                               *
         *            The following code extract can be used to make     *
         *            a function call and 'deblock' the RETURN value.    *
         *                                                               *
         *            murph = xmitipmu(,"FUNC")                          *
         *            mur. = ""                                          *
         *            n = 1                                              *
         *            mur.0 = n                                          *
         *                                                               *
         *            do murpos = 1 to length(murph)                     *
         *              murchar = substr(murph,murpos,1)                 *
         *              if murchar = "0A"x then do                       *
         *                n = mur.0 + 1                                  *
         *                mur.n = ""                                     *
         *                mur.0 = n                                      *
         *              end                                              *
         *              else mur.n = mur.n""murchar                      *
         *            end                                                *
         *                                                               *
         *            do n = 1 to mur.0                                  *
         *              say mur.n                                        *
         *            end                                                *
         *                                                               *
         * Installation: On TSO, put it somewhere in your SYSEXEC or     *
         *            SYSPROC concatenation.                             *
         *                                                               *
         * Author:    Paul Wells                                         *
         *            Ladbroke Racing UK Ltd                             *
         *            Imperial House                                     *
         *            Imperial Drive                                     *
         *            Rayners Lane                                       *
         *            HARROW                                             *
         *            HA2 7JW                                            *
         *            UK                                                 *
         *                                                               *
         * Email:     PaulWells_Technogold@yahoo.co.uk                   *
         *         or Paul.Wells@Ladbrokes.co.uk                         *
         * Telephone: +44 7808 965188                                    *
         *                                                               *
         * History:                                                      *
         *            2008-08-28: compiled exec - fix calltype problem   *
         *            2008-07-07: add 1 quote                            *
         *            2008-06-13: add 1 quote                            *
         *            2008-04-28: add 5 quotes                           *
         *            2007-10-15: add 1 quote                            *
         *            2007-09-14: add 2 quotes                           *
         *            2007-05-25: add 1 quote                            *
         *            2007-03-21: add 1 quote                            *
         *            2007-01-22: add several new quotes                 *
         *            2006-03-20: add 1 new quote                        *
         *            2006-03-03: add 1 new quote                        *
         *            2005-10-08: add 1 new quote                        *
         *            2004-09-20: add 2 new quotes                       *
         *            2004-08-07: add 1 new quote                        *
         *            2004-05-15: add many new quotes                    *
         *            2004-03-24: add 2 new quotes                       *
         *            2004-02-02: add 29 new quotes                      *
         *            2004-01-23: add 1 new quote                        *
         *            2004-01-14: add 4 new quotes                       *
         *            2003-11-12: add 4 new quotes                       *
         *            2003-07-30: add several quotes                      *
         *            2003-07-17: add quote by Cooper                     *
         *            2003-03-07: add quote by Rumsfeld                   *
         *            2003-01-16: add several daffy definitions           *
         *            2003-01-01: add one new quote                       *
         *            2002-11-19: add one new quote                       *
         *            2001-11-30: add one new quote                       *
         *            2001-11-26: add two new quotes                      *
         *            2001-10-10: replace one more objectional quote      *
         *            2001-09-05: added 3 new quotes                      *
         *            2001-08-27: several minor changes                   *
         *            2001-07-24: replace saying 58 with cleaner quote    *
         *            2001-05-04: add comment/debug quote                 *
         *            2000-04-13: add pooh quote                          *
         *            2000-02-07: remove some tasteless quotes            *
         *            2000-01-04: add a few quotes                        *
         *            1999-11-02: Original with 949 phrases               *
         *                                                               *
         * Acknowledgements:                                             *
         *                                                               *
         *            Most of the phrases in this REXX version of        *
         *            Murphy originate from file 300 of the CBT tape     *
         *            at http://www.cbttape.org. This version of Murphy  *
         *            is the one which most sites seem to use. I then    *
         *            added some more from file 472.                     *
         *                                                               *
         *            After correcting some spelling errors, adding      *
         *            quotation marks, decapitalising some of them,      *
         *            and removing some which seemed 'tired', I added    *
         *            a few myself from the excellent web site           *
         *            of mainframer Thierry Falissard at                 *
         *            http://ourworld.compuserve.com/        ...continued*
         *            homepages/TFALISSARD/murphy.htm                    *
         *                                                               *
         *            If you want to know who 'Murphy' really was,       *
         *            try this link.                                     *
         *                                                               *
         *            http://wombat.doc.ic.ac.uk/foldoc/     ...continued*
         *            foldoc.cgi?query=murphy&action=Search              *
         *                                                               *
         * Disclaimer:                                                   *
         *                                                               *
         *            This program is provided on an "as is" basis       *
         *            without warranty of any kind, either express or    *
         *            implied, including, but not limited to, the implied*
         *            warranties of merchantability or fitness for       *
         *            a particular purpose. The use of this program or   *
         *            or the results therefrom is entirely at the risk   *
         *            of the user. This program is freeware and may be   *
         *            be freely copied, modified and distributed.        *
         *                                                               *
         * ------------------------------------------------------------- */

         parse arg seed,PARM
                       /* The 2nd parameter is a dummy which may be used
                             to identify whether we are being called
                             standalone or as a function. This is useful
                             in REXX environments for which PARSE SOURCE
                             does not return 'FUNCTION' e.g. OPS/REXX */

         if ^(datatype(seed,"W")) then seed = 0 /* no non-numeric seeds */

         call set_murph   /* load the murphys */

         do cnt = 1 to 9999 /* arbritrary max 9999 to guard against loop */

           varname = "M"right(cnt,5,"0")".1"

           if value(varname) = varname then do /* initialised variable ? */
                                /* if not, we've reached the and and we */
             nummurph = cnt - 1 /* set the number of Murphy phrases */
             leave

           end

         end

         if seed < 1 then ,               /* passed a valid seed ? */
          seed = random(1,nummurph)       /* if not, set random one */
         else ,
          if seed > nummurph then ,       /* seed > than max ? */
           seed = (seed // nummurph) + 1  /* if yes, set a valid one */

         lineout = ""

         do cnt = 1 to 10 /* max 10 lines for each murphy */

           varname = "M"right(seed,5,"0")"."cnt
           line.cnt = value(varname)

           if varname = line.cnt then do  /* past last line ? */
             line.0 = cnt - 1  /* if yes, set array count */
             leave             /* and finish */
           end
           else do
             if cnt = 1 then pad = "" /* if 1st line then no pad */
             else pad = "0A"x         /* else pad is a newline */
             lineout = lineout""pad""line.cnt
           end

         end

         parse source . called .

                                /* source is function ? */
                                /* non-blank parameter ? */
                                /* if either, return data */
                                /* else we are standalone */
         select;
           when ( parm  /= ""           ) then _action_ = "RETURN"
           when ( called = "FUNCTION"   ) then _action_ = "RETURN"
           when ( called = "SUBROUTINE" ) then _action_ = "RETURN"
           when ( called = "COMMAND"    ) then _action_ = "SAY"
           otherwise                           _action_ = "RETURN"
         end;

         if _action_ = "RETURN" ,
         then do;
                  return lineout
              end;
         else do;
                 do cnt = 1 to line.0
                    say line.cnt
                 end;
         end

        return 0


        set_murph:

        M00001.1 = ,
        '"When things are going well, someone will inevitably experiment det'||,
        'rimentally."'
        M00002.1 = ,
        '"If not controlled, work will flow to the competent man until he su'||,
        'bmerges."'
        M00003.1 = ,
        '"The deficiency will never show itself during the test runs."'
        M00004.1 = ,
        '"The lagging activity in a project will invariably be found'
        M00004.2 = ,
        ' in the area where the highest overtime rates lie waiting."'
        M00005.1 = ,
        '"It is impossible to build a fool-proof system, because fools are s'||,
        'o ingenious."'
        M00006.1 = ,
        '"Talent in staff work or sales will continually be'
        M00006.2 = ,
        ' interpreted as managerial ability."'
        M00007.1 = ,
        '"Information travels more surely to those with a lesser need to kno'||,
        'w."'
        M00008.1 = ,
        '"The ''think positive'' leader tends to listen to his'
        M00008.2 = ,
        ' subordinate''s premonitions only during the postmortems."'
        M00009.1 = ,
        '"An original idea can never emerge from committee in its original f'||,
        'orm."'
        M00010.1 = ,
        '"No good deed goes unpunished."'
        M00011.1 = ,
        '"When the product is destined to fail, the delivery system'
        M00011.2 = ,
        'will perform perfectly."'
        M00012.1 = ,
        '"Clearly stated instructions will consistently produce'
        M00012.2 = ,
        'multiple interpretations."'
        M00013.1 = ,
        '"The crucial memorandum will be snared in the out-basket by'
        M00013.2 = ,
        'the paper clip of the overlying memo and go to file."'
        M00014.1 = ,
        '"On successive charts of the same organization the number of'
        M00014.2 = ,
        'boxes will never decrease."'
        M00015.1 = ,
        '"It is okay to be ignorant in some areas, but some people abuse the'||,
        ' privilege."'
        M00016.1 = ,
        '"Every Titanic has its iceberg."'
        M00017.1 = ,
        '"Success can be ensured only by devising a defense against'
        M00017.2 = ,
        'failure of the contingency plan."'
        M00018.1 = ,
        '"Adding manpower to a late software product makes it later."'
        M00019.1 = ,
        '"Performance is directly affected by the perversity of inanimate ob'||,
        'jects."'
        M00020.1 = ,
        '"You can only live happily-ever-after one day at a time."'
        M00021.1 = ,
        '"Never offend people with style when you can offend them with subst'||,
        'ance."'
        M00022.1 = ,
        '"Our customers paperwork is profit; our own paperwork is loss."'
        M00023.1 = ,
        '"At any level of traffic, any delay is intolerable."'
        M00024.1 = ,
        '"As the economy gets better, everything else gets worse."'
        M00025.1 = ,
        '"This space for rent."'
        M00026.1 = ,
        '"The more directives you issue to solve a problem, the worse it get'||,
        's."'
        M00027.1 = ,
        '"Cop-out number 1:'
        M00027.2 = ,
        'You should have seen it when I got it."'
        M00028.1 = ,
        '"When you''re up to your ass in alligators, it is difficult to keep'||,
        ' your'
        M00028.2 = ,
        'mind on the fact that your primary objective was to drain the swam'||,
        'p."'
        M00029.1 = ,
        '"The road to hell is paved with good intentions'
        M00029.2 = ,
        'and littered with sloppy analyses!"'
        M00030.1 = ,
        '"In a democracy you can be respected though poor, but don''t count '||,
        'on it."'
        M00031.1 = ,
        '"If the assumptions are wrong, the conclusions aren''t likely to be'||,
        ' very good."'
        M00032.1 = ,
        '"The organization of any program reflects the organization'
        M00032.2 = ,
        'of the people who developed it."'
        M00033.1 = ,
        '"There is no such thing as a ''dirty capitalist'', only a capitalist."'
        M00034.1 = ,
        '"Anything is possible, but nothing is easy."'
        M00035.1 = ,
        '"The meek will inherit the earth after the rest of us go to the sta'||,
        'rs."'
        M00036.1 = ,
        '"History proves nothing."'
        M00037.1 = ,
        '"A lot of what appears to be progress is just so much technological'||,
        ' roccoco."'
        M00038.1 = ,
        '"A little humility is arrogance."'
        M00039.1 = ,
        'Ancient Chinese curse:'
        M00039.2 = ,
        '"May all your wishes be granted."'
        M00040.1 = ,
        '"Any time you wish to demonstrate something, the number of'
        M00040.2 = ,
        'faults is proportional to the number of viewers."'
        M00041.1 = ,
        '"A coup that is known in advance is a coup that does not take place'||,
        '."'
        M00042.1 = ,
        '"No experiment is ever a complete failure.'
        M00042.2 = ,
        'It can always be used as a bad example."'
        M00043.1 = ,
        '"Despite the sign that says ''wet paint'', please don''t."'
        M00044.1 = ,
        '"Everything tastes more or less like chicken."'
        M00045.1 = ,
        '"People don''t change; they only become more so."'
        M00046.1 = ,
        '"If your next pot of chili tastes better, it probably is'
        M00046.2 = ,
        'because of something left out, rather than added."'
        M00047.1 = ,
        '"There is always one more bug."'
        M00048.1 = ,
        '"The big guys always win."'
        M00049.1 = ,
        '"Nothing is ever accomplished by a reasonable man."'
        M00050.1 = ,
        '"Any sufficiently advanced technology is indistinguishable from mag'||,
        'ic."'
        M00051.1 = ,
        '"It''s always darkest just before the lights go out."'
        M00052.1 = ,
        '"It is better to be part of the idle rich class'
        M00052.2 = ,
        'than be part of the idle poor class."'
        M00053.1 = ,
        '"Each problem solved introduces a new unsolved problem."'
        M00054.1 = ,
        '"For every credibility gap there is a gullibility fill."'
        M00055.1 = ,
        '"If you have something to do, and you put it off long enough,'
        M00055.2 = ,
        'chances are someone else will do it for you."'
        M00056.1 = ,
        '"Everybody''s gotta be someplace."'
        M00057.1 = ,
        '"Nature is a mother."'
        M00058.1 = ,
        '"Goal setting starts with a pad of paper, a pen and you."'
        M00058.2 = ,
        " Gary Ryan Blair, Personal Coach"
        M00059.1 = ,
        '"People will accept your idea much more readily if you tell'
        M00059.2 = ,
        'them Benjamin Franklin said it first."'
        M00060.1 = ,
        '"!lanimret siht edisni deppart ma I !pleH"'
        M00061.1 = ,
        '"Any given program, when running, is obsolete."'
        M00062.1 = ,
        '"Any given program costs more and takes longer."'
        M00063.1 = ,
        '"If a program is useful, it will be changed."'
        M00064.1 = ,
        '"If a program is useless, it will be documented."'
        M00065.1 = ,
        '"Any given program will expand to fill all available memory."'
        M00066.1 = ,
        '"The value of a program is inversely proportional'
        M00066.2 = ,
        'to the weight of its output."'
        M00067.1 = ,
        '"In case of doubt, make it sound convincing."'
        M00068.1 = ,
        '"Program complexity grows until it exceeds the capability'
        M00068.2 = ,
        'of the programmer who must maintain it."'
        M00069.1 = ,
        '"Make it possible for programmers to write programs in English,'
        M00069.2 = ,
        'and you will find that programmers cannot write in English."'
        M00070.1 = ,
        'Zymurgy''s First Law of Evolving System Dynamics:'
        M00070.2 = ,
        '"Once you open a can of worms, the only way to recan them'
        M00070.3 = ,
        'is to use a larger can."'
        M00071.1 = ,
        '"If you can''t measure it, I''m not interested."'
        M00072.1 = ,
        '"The best way to lie is to tell the truth.....'
        M00072.2 = ,
        'carefully edited truth."'
        M00073.1 = ,
        '"There are three ways to get things done'
        M00073.2 = ,
        ' Do it yourself'
        M00073.3 = ,
        ' Hire someone to do it or'
        M00073.4 = ,
        ' Forbid your kids to do it."'
        M00074.1 = ,
        '"A fail-safe circuit will destroy others."'
        M00075.1 = ,
        '"History repeats itself.'
        M00075.2 = ,
        'That''s one of the things wrong with history."'
        M00076.1 = ,
        '"90% of everything is crud."'
        M00077.1 = ,
        '"Nature will tell you a direct lie if she can."'
        M00078.1 = ,
        '"Those with the best advice offer no advice."'
        M00079.1 = ,
        '"Speak softly and own a big, mean Doberman."'
        M00080.1 = ,
        '"Democracy is that form of government where'
        M00080.2 = ,
        'everybody gets what the majority deserves."'
        M00081.1 = ,
        '"If you''re worried about being crazy,'
        M00081.2 = ,
        'don''t be overly concerned:'
        M00081.3 = ,
        'if you were, you would think you were sane."'
        M00082.1 = ,
        '"Pills to be taken in twos always come out of the bottle in threes."'
        M00083.1 = ,
        '"Flynn is dead'
        M00083.2 = ,
        'Tron is dead'
        M00083.3 = ,
        'long live the MCP."'
        M00084.1 = ,
        '"Real programmers don''t number paragraph names consecutively."'
        M00085.1 = ,
        '"If you''re feeling good, don''t worry, you''ll get over it."'
        M00086.1 = ,
        '"Real programmers don''t grumble about the disadvantages'
        M00086.2 = ,
        'of COBOL when they don''t know any other language."'
        M00087.1 = ,
        '"Definition of an elephant:'
        M00087.2 = ,
        'A mouse built to government specifications."'
        M00088.1 = ,
        '"Real programmers are kind to rookies."'
        M00089.1 = ,
        '"Real programmers don''t notch their desks for each completed servi'||,
        'ce request."'
        M00090.1 = ,
        '"Real programmers don''t announce how many times the'
        M00090.2 = ,
        'operations department called them last night."'
        M00091.1 = ,
        '"A day without sunshine is like ... night!"'
        M00092.1 = ,
        '"Real programmers are secure enough to write readable code,'
        M00092.2 = ,
        'which they then self-righteously refuse to explain."'
        M00093.1 = ,
        '"Anything that can go wrong, will go wrong."'
        M00094.1 = ,
        '"Real programmers understand PASCAL."'
        M00095.1 = ,
        '"Real programmers know it''s not operations fault if their jobs go '||,
        'into ''hogs."'
        M00096.1 = ,
        '"Real programmers do not eat breakfast from the vending machines."'
        M00097.1 = ,
        '"Real programmers punch up their own programs."'
        M00098.1 = ,
        '"When life hands you a lemon, make lemonade."'
        M00099.1 = ,
        '"Real programmers have read the standards manual but won''t admit i'||,
        't."'
        M00100.1 = ,
        '"Real programmers don''t advertise their hangovers."'
        M00101.1 = ,
        '"Real programmers don''t dress for success unless they are'
        M00101.2 = ,
        'trying to convince others that they are going on interviews."'
        M00102.1 = ,
        '"Real programmers do not practice four-syllable words before walkth'||,
        'roughs."'
        M00103.1 = ,
        '"All warranties expire upon payment of invoice."'
        M00104.1 = ,
        '"Real programmers argue with the systems analyst as a matter of pri'||,
        'nciple."'
        M00105.1 = ,
        '"The final test is when it goes production ...'
        M00105.2 = ,
        'w h e n i t  g o e s   p r o d u c t i o n  ...'
        M00105.3 = ,
        'w h e n     i  t     g  o  e  s     p  r  o  d  u  c  t'
        M00105.4 = ,
        'w h  e   n       i   t       g   o   e   s       p   r   o"'
        M00106.1 = ,
        '"Real programmers drink too much coffee so that they will'
        M00106.2 = ,
        'always seem tense and overworked."'
        M00107.1 = ,
        '"Real programmers always have a better idea."'
        M00108.1 = ,
        '"Anyone who follows a crowd will never be followed by a crowd."'
        M00109.1 = ,
        '"Real programmers can do octal, hexadecimal and binary maths in the'||,
        'ir heads."'
        M00110.1 = ,
        '"Real programmers don''t write memos."'
        M00111.1 = ,
        '"Real programmers know what SAAD means."'
        M00112.1 = ,
        '"Real programmers do not utter profanities at an elevated decibel l'||,
        'evel."'
        M00113.1 = ,
        '"Where you stand on an issue depends on where you sit."'
        M00114.1 = ,
        '"Real programmers do not apply DP terminology to non-DP situations."'
        M00115.1 = ,
        '"186,000 miles per second - it''s not just a good idea, it''s the l'||,
        'aw."'
        M00116.1 = ,
        '"Real programmers do not read books like'
        M00116.2 = ,
        '''effective listening'' and ''communication skills''."'
        M00117.1 = ,
        '"Real programmers print only clean compiles,'
        M00117.2 = ,
        'fixing all errors through the terminal."'
        M00118.1 = ,
        '"The early worm deserves the bird."'
        M00119.1 = ,
        '"A diplomat is someone who can tell you to go to hell'
        M00119.2 = ,
        'in such a way that you look forward to the trip."'
        M00120.1 = ,
        '"Blessed are those who go around in circles, for they shall be know'||,
        'n as wheels."'
        M00121.1 = ,
        '"Never eat prunes when you are famished."'
        M00122.1 = ,
        '"Keep emotionally active, cater to your favorite neurosis."'
        M00123.1 = ,
        '"A RACF protected dataset is inaccessible."'
        M00124.1 = ,
        '"RACF is a four letter word."'
        M00125.1 = ,
        '"You may be recognized soon.'
        M00125.2 = ,
        'Hide!'
        M00125.3 = ,
        'If they find you, lie."'
        M00126.1 = ,
        'First Law of Advice:'
        M00126.2 = ,
        '"The correct advice is to give the advice that is desired."'
        M00127.1 = ,
        '"Avoid reality at all costs."'
        M00128.1 = ,
        'Program design philosophy:'
        M00128.2 = ,
        '"Start at the beginning and continue until the end, then stop."'
        M00128.3 = ,
        '            (Lewis Carroll)'
        M00129.1 = ,
        '"A closed mouth gathers no foot."'
        M00130.1 = ,
        '"Only mediocre people are always at their best."'
        M00131.1 = ,
        '"Friends come and go, but enemies accumulate."'
        M00132.1 = ,
        '"In a hierarchical organization,'
        M00132.2 = ,
        'the higher the level,'
        M00132.3 = ,
        'the greater the confusion."'
        M00133.1 = ,
        '"Anyone can hold the helm when the sea is calm."'
        M00133.2 = ,
        'Publilius Syrus (first century B.C.), Maxim 358'
        M00134.1 = ,
        '"Of two possible events, only the undesired one will occur."'
        M00135.1 = ,
        '"The faster the plane, the narrower the seats."'
        M00136.1 = ,
        '"The logical man has a shorter life expectancy than the practical m'||,
        'an,'
        M00136.2 = ,
        'because he refuses to look both ways on a one-way street."'
        M00137.1 = ,
        '"If on an actuarial basis there is a 50-50 chance that'
        M00137.2 = ,
        'something will go wrong,'
        M00137.3 = ,
        'it will actually go wrong nine times out of ten."'
        M00138.1 = ,
        '"A man of quality does not fear a woman seeking equality."'
        M00139.1 = ,
        '"The first rule of intelligent tinkering is to save all of the part'||,
        's."'
        M00140.1 = ,
        '"If you try to please everybody, nobody will like it."'
        M00141.1 = ,
        '"There is a solution to every problem; the only difficulty is findi'||,
        'ng it."'
        M00142.1 = ,
        '"Don''t make your doctor your heir."'
        M00143.1 = ,
        '"Don''t ask the barber if you need a haircut."'
        M00144.1 = ,
        '"If you don''t like the answer, you shouldn''t have asked the quest'||,
        'ion."'
        M00145.1 = ,
        '"Do not believe in miracles -- rely on them."'
        M00146.1 = ,
        '"You can''t expect to hit the jackpot'
        M00146.2 = ,
        'if you don''t put a few nickles in the machine."'
        M00147.1 = ,
        '"Unless you intend to kill him immediately, never kick a man'
        M00147.2 = ,
        'in the balls, not even symbolically, or perhaps especially'
        M00147.3 = ,
        'not symbolically."'
        M00148.1 = ,
        'Freud''s 23rd law: "Ideas endure and prosper in inverse'
        M00148.2 = ,
        'proportion to their soundness and validity."'
        M00149.1 = ,
        '"A short cut is the longest distance between two points."'
        M00150.1 = ,
        '"If you want to make an enemy, do someone a favor."'
        M00151.1 = ,
        '"A well-fed wastebasket will serve you better than the best compute'||,
        'r."'
        M00152.1 = ,
        '"The meek shall inherit the earth, but not its mineral rights."'
        M00153.1 = ,
        'The three laws of Thermodynamics in simple form:'
        M00153.2 = ,
        '1) "You can''t win"'
        M00153.3 = ,
        '2) "You can''t break even"'
        M00153.4 = ,
        '3) "You can''t even quit the game"'
        M00154.1 = ,
        '"When eating an elephant, take one bite at a time."'
        M00155.1 = ,
        '"Common sense is not so common."'
        M00156.1 = ,
        '"If we learn by our mistakes,'
        M00156.2 = ,
        'I''m getting one hell of an education!!"'
        M00157.1 = ,
        '"Fuzzy project objectives are used to avoid the'
        M00157.2 = ,
        'embarrassment of estimating the corresponding costs."'
        M00158.1 = ,
        '"Usefulness is inversely proportional to its reputation for being u'||,
        'seful."'
        M00159.1 = ,
        '"You will always find something in the last place you look."'
        M00160.1 = ,
        '"The probability of anything happening is in inverse ratio to its d'||,
        'esirability."'
        M00161.1 = ,
        '"The first myth of management is that it exists.'
        M00161.2 = ,
        'The second myth of management is that success equals skill."'
        M00162.1 = ,
        '"The trouble with computers is that they do what you tell'
        M00162.2 = ,
        'them to do, not what you want them to do."'
        M00162.3 = ,
        '        - A frustrated programmer'
        M00163.1 = ,
        '"Inside every large program is a small program struggling to get ou'||,
        't."'
        M00164.1 = ,
        '"A memorandum is written not to inform the reader but to protect th'||,
        'e writer."'
        M00165.1 = ,
        '"Never insult an alligator until after you have crossed the river."'
        M00166.1 = ,
        '"Anything hit with a big enough hammer will fall apart."'
        M00167.1 = ,
        '"The word ''dog'' does not bite."  --- William James'
        M00168.1 = ,
        '"The man who can smile when things go wrong has thought of'
        M00168.2 = ,
        'someone he can blame it on."'
        M00169.1 = ,
        '"The chance of a piece of bread falling with the buttered side'
        M00169.2 = ,
        'down is directly proportional to the cost of the carpet."'
        M00170.1 = ,
        '"In the fight between you and the world, back the world."'
        M00171.1 = ,
        '"Last guys don''t finish nice."'
        M00172.1 = ,
        '"Never admit anything.'
        M00172.2 = ,
        ' Never regret anything.'
        M00172.3 = ,
        ' Whatever it is, you''re not responsible."'
        M00173.1 = ,
        '"If you have always done it that way, it is probably wrong."'
        M00174.1 = ,
        '"When working toward the solution of a problem,'
        M00174.2 = ,
        'it always helps if you know the answer.'
        M00174.3 = ,
        'Provided of course you know there is a problem."'
        M00175.1 = ,
        '"The usefulness of any meeting is in inverse proportion to the atte'||,
        'ndance."'
        M00176.1 = ,
        '"The sun goes down just when you need it the most."'
        M00177.1 = ,
        '"Pure drivel tends to drive ordinary drivel off the TV screen."'
        M00178.1 = ,
        '"Whatever creates the greatest inconvenience for the largest'||,
        ' number must happen."'
        M00179.1 = ,
        '"No matter how long or hard you shop for an item, after'
        M00179.2 = ,
        'you have bought it, it will be on sale somewhere cheaper."'
        M00180.1 = ,
        '"Sanity and insanity overlap a fine gray line."'
        M00181.1 = ,
        '"A disagreeable task is its own reward."'
        M00182.1 = ,
        '"If things were left to chance, they''d be better."'
        M00183.1 = ,
        '"The phone will not ring until you leave your desk and walk'
        M00183.2 = ,
        'to the other end of the building."'
        M00184.1 = ,
        '"Anybody can win - unless there happens to be a second entry."'
        M00185.1 = ,
        '"A president of a democracy is a man who is always ready,'
        M00185.2 = ,
        'willing, and able to lay down your life for his country."'
        M00186.1 = ,
        '"If a thing is done wrong often enough it becomes right."'
        M00187.1 = ,
        '"People will buy anything that is one to a customer."'
        M00188.1 = ,
        '"If you just try long enough and hard enough, you can always'
        M00188.2 = ,
        'manage to boot yourself in the posterior."'
        M00189.1 = ,
        '"No one''s life, liberty, or property are safe'
        M00189.2 = ,
        'while the legislature is in session."'
        M00190.1 = ,
        '"Never say ''oops'' after you have submitted a job."'
        M00191.1 = ,
        '"Bad news drives good news out of the media."'
        M00192.1 = ,
        '"Just when you get really good at something, you don''t need to do '||,
        'it anymore."'
        M00193.1 = ,
        '"If facts do not conform to the theory, they must be disposed of."'
        M00194.1 = ,
        '"Almost anything is easier to get into than out of."'
        M00195.1 = ,
        '"When properly administered, vacations do not diminish productivity'||,
        '.'
        M00195.2 = ,
        'For every week you are away and get nothing done, there is another'
        M00195.3 = ,
        'week when your boss is away and you get twice as much done."'
        M00196.1 = ,
        '"No matter what happens, there is always somebody who knew that it '||,
        'would."'
        M00197.1 = ,
        '"The other line always moves faster."'
        M00198.1 = ,
        '"Never eat at a place called Moms, never play cards with a man name'||,
        'd Doc,'
        M00198.2 = ,
        'and never lie down with a woman who has got more troubles than you'||,
        '."'
        M00199.1 = ,
        '"To get a loan, you must first prove you don''t need it."'
        M00200.1 = ,
        '"When all else fails, read the instructions."'
        M00201.1 = ,
        '"Anything you try to fix will take longer and cost more than you th'||,
        'ought."'
        M00202.1 = ,
        '"''Close'' counts in horseshoes, handgrenades and thermonuclear dev'||,
        'ices."'
        M00203.1 = ,
        '"The lion and the lamb shall lie down together,'
        M00203.2 = ,
        'but the lamb won''t get much sleep."'
        M00204.1 = ,
        '"If you fool around with a thing for very long you will screw it up'||,
        '."'
        M00205.1 = ,
        'Third Law of Advice:  "Simple advice is the best advice."'
        M00206.1 = ,
        '"Justice always prevails...'
        M00206.2 = ,
        'three times out of seven."'
        M00207.1 = ,
        '"If it jams --- force it. If it breaks, it needed replacing anyway."'
        M00208.1 = ,
        '"I have yet to see any problem, however complicated, which,'
        M00208.2 = ,
        'when you looked at it in the right way, did not become'
        M00208.3 = ,
        'still more complicated." --- Poul Anderson'
        M00209.1 = ,
        '"Any tool dropped while repairing a car'
        M00209.2 = ,
        'will roll underneath to the exact center."'
        M00210.1 = ,
        '"No matter which direction you start, it''s always against the wind'||,
        ' coming back."'
        M00211.1 = ,
        '"The repairman will never have seen a model quite like yours before'||,
        '."'
        M00212.1 = ,
        '"Don''t force it, get a bigger hammer."'
        M00213.1 = ,
        '"When a broken appliance is demonstrated for the repairman,'
        M00213.2 = ,
        'it will work perfectly."'
        M00214.1 = ,
        "'If you want something done you'll find a way."
        M00214.2 = ,
        " If you don't want something done you'll find an excuse.'"
        M00214.3 = ,
        "    ---- Donald Trump "
        M00215.1 = ,
        '"An optimist is a person who looks forward to marriage.'
        M00215.2 = ,
        'A pessimist is a married optimist!"'
        M00216.1 = ,
        '"A pessimist is an optimist with experience."'
        M00217.1 = ,
        '"Old programmers never die - they just abend."'
        M00218.1 = ,
        '"The success of any venture will be helped by prayer,'
        M00218.2 = ,
        ' even in the wrong denomination."'
        M00219.1 = ,
        '"Just about the time when you think you can make ends meet,'
        M00219.2 = ,
        'somebody moves the ends!"'
        M00220.1 = ,
        '"Just because you are paranoid doesn''t mean ''they'' aren''t out '||,
        'to get you."'
        M00221.1 = ,
        '"An Irishman is not drunk as long as he can hang onto a single'
        M00221.2 = ,
        'blade of grass and not fall off the face of the earth."'
        M00222.1 = ,
        '"Beware of all enterprises that require new clothes."'
        M00222.2 = ,
        ' - Thoreau'
        M00223.1 = ,
        '"Some come to the fountain of knowledge to drink, some prefer to ju'||,
        'st gargle."'
        M00224.1 = ,
        '"Everything is revealed to he who turns over enough stones.'
        M00224.2 = ,
        '(including the snakes that he did not want to find.)"'
        M00225.1 = ,
        '"Everybody should believe in something;'
        M00225.2 = ,
        'I believe I''ll have another drink."'
        M00226.1 = ,
        '"Those whose approval you seek the most give you the least."'
        M00227.1 = ,
        '"Build a system that even a fool can use, and only a fool will use '||,
        'it."'
        M00228.1 = ,
        '"Be not so bigoted to any custom as to worship it at' ,
        'the expense of truth."'
        M00228.2 = ,
        'Johann Georg von Zimmermann'
        M00229.1 = ,
        '"Everyone has a scheme for getting rich that will not work."'
        M00230.1 = ,
        '"Being frustrated is disagreeable, but the real disasters'
        M00230.2 = ,
        'in life begin when you get what you want."'
        M00231.1 = ,
        '"In any hierarchy, each individual rises to his own level'
        M00231.2 = ,
        'of incompetence, and then remains there."'
        M00232.1 = ,
        '"It does not matter if you fall down as long as you pick'
        M00232.2 = ,
        'up something from the floor while you get up."'
        M00233.1 = ,
        '"You will remember that you forgot to take out the trash'
        M00233.2 = ,
        'when the garbage truck is two doors away."'
        M00234.1 = ,
        '"Misery no longer loves company; nowadays it insists on it."'
        M00235.1 = ,
        '"Some of it plus the rest of it is all of it."'
        M00236.1 = ,
        '"There''s never time to do it right, but there''s always time to do'||,
        ' it over."'
        M00237.1 = ,
        '"The more ridiculous a belief system, the higher the probability'||,
        ' of its success."'
        M00238.1 = ,
        '"Anything good in life is either illegal, immoral or fattening."'
        M00239.1 = ,
        '"Old age is always fifteen years older than I am."'
        M00240.1 = ,
        '"It is morally wrong to allow suckers to keep their money."'
        M00241.1 = ,
        '"When you''re up to your nose .......,'
        M00241.2 = ,
        'be sure to keep your mouth shut."'
        M00242.1 = ,
        '"One''s life tends to be like a beaver''s, one dam thing after anot'||,
        'her."'
        M00243.1 = ,
        '"A bird in hand is safer than one overhead."'
        M00244.1 = ,
        '"The ratio of time involved in work to time available for'
        M00244.2 = ,
        'work is usually about 0.6"'
        M00245.1 = ,
        '"Remember the golden rule:'
        M00245.2 = ,
        'Those that have the gold make the rules."'
        M00246.1 = ,
        '"Blessed is he who has reached the point of no return and'
        M00246.2 = ,
        'knows it, for he shall enjoy living."'
        M00247.1 = ,
        '"Everything east of the San Andreas fault will eventually'
        M00247.2 = ,
        ' plunge into the Atlantic Ocean."'
        M00248.1 = ,
        '"Some people have minds like a steel trap:'
        M00248.2 = ,
        ' whatever goes in gets crushed and mangled."'
        M00249.1 = ,
        '"Nature always sides with the hidden flaw."'
        M00250.1 = ,
        '"Blessed is he who expects no gratitude, for he shall not be disapp'||,
        'ointed."'
        M00251.1 = ,
        '"The light at the end of the tunnel is the headlamp of an oncoming '||,
        'train."'
        M00252.1 = ,
        '"Celibacy is not hereditary."'
        M00253.1 = ,
        '"You can observe a lot just by watching."'
        M00254.1 = ,
        '"Even the smallest candle burns brighter in the dark."'
        M00255.1 = ,
        '"Never sleep with anyone crazier than yourself."'
        M00256.1 = ,
        '"Live within your income, even if you have to borrow to do so."'
        M00257.1 = ,
        '"Beauty is only skin deep; ugly goes clear to the bone."'
        M00258.1 = ,
        '"Never go to a doctor whose office plants have died."'
        M00259.1 = ,
        '"To know yourself is the ultimate form of aggression."'
        M00260.1 = ,
        '"An ounce of application is worth a ton of abstraction."'
        M00261.1 = ,
        '"Never play leapfrog with a unicorn."'
        M00262.1 = ,
        '"A bird in the hand is dead."'
        M00263.1 = ,
        '"A Smith and Wesson beats four aces."'
        M00264.1 = ,
        '"Never put all your eggs in your pocket."'
        M00265.1 = ,
        '"If everything seems to be going well,'
        M00265.2 = ,
        'you obviously don''t know what the hell is going on."'
        M00266.1 = ,
        '"If at first you don''t succeed, blame it on your supervisor."'
        M00267.1 = ,
        '"If more than one person is responsible for a miscalculation,'
        M00267.2 = ,
        'no one will be at fault."'
        M00268.1 = ,
        '"Don''t bite the hand that has your pay check in it."'
        M00269.1 = ,
        ' DDD      OO     NN   N  TTTTTTT       PPPP    AA    NN   N  I    C'||,
        'CC'
        M00269.2 = ,
        ' D  D    O  O    N N  N     T          P   P  A  A   N N  N  I   C'
        M00269.3 = ,
        ' D   D  O    O   N  N N     T          PPPP   AAAA   N  N N  I  C'
        M00269.4 = ,
        ' D  D    O  O    N   NN     T          P     A    A  N   NN  I   C'
        M00269.5 = ,
        ' DDD      OO     N    N     T          P     A    A  N    N  I    C'||,
        'CC'
        M00269.6 = ,
        ' '
        M00270.1 = ,
        '"When in doubt, mumble.'
        M00270.2 = ,
        'When in trouble, delegate.'
        M00270.3 = ,
        'When in charge, ponder."'
        M00271.1 = ,
        '"Never argue with a fool, people might not know the difference."'
        M00272.1 = ,
        '"You can''t guard against the arbitrary."'
        M00273.1 = ,
        '"People can be divided into three groups:'
        M00273.2 = ,
        ' Those who make things happen,'
        M00273.3 = ,
        ' Those who watch things happen and'
        M00273.4 = ,
        ' Those who wonder what happened."'
        M00274.1 = ,
        '"The one thing that money cannot buy is poverty."'
        M00275.1 = ,
        '"You are not drunk if you can lay on the floor without holding on."'
        M00276.1 = ,
        '"In any household, junk accumulates to fill all the space'
        M00276.2 = ,
        'available for its storage."'
        M00277.1 = ,
        '"Don''t stop to stomp on ants when the elephants are stampeding."'
        M00278.1 = ,
        '"The longer the title the less important the job."'
        M00279.1 = ,
        '"Everything bows to success, even grammar."'
        M00280.1 = ,
        '"When you are right be logical,'
        M00280.2 = ,
        'when you are wrong be-fuddle."'
        M00281.1 = ,
        '"For every human problem, there is a neat, plain solution --'
        M00281.2 = ,
        'and it is always wrong."'
        M00282.1 = ,
        '"There are no winners in life: only survivors."'
        M00283.1 = ,
        '"When they want it bad (in a rush), they get it bad."'
        M00284.1 = ,
        '"You can''t tell how deep a puddle is until you step into it."'
        M00285.1 = ,
        '"The idea is to die young as late as possible."'
        M00286.1 = ,
        '"Misery loves company, but company does not reciprocate."'
        M00287.1 = ,
        '"It''s better to retire too soon than too late."'
        M00288.1 = ,
        '"A man should be greater than some of his parts."'
        M00289.1 = ,
        '"If you don''t say it, they can''t repeat it."'
        M00290.1 = ,
        '"Nothing is ever as simple as it seems."'
        M00291.1 = ,
        '"Everything takes longer than you expect."'
        M00292.1 = ,
        '"Left to themselves, all things go from bad to worse."'
        M00293.1 = ,
        '"If you see that there are four possible ways in which a'
        M00293.2 = ,
        'procedure can go wrong, and circumvent these, then a'
        M00293.3 = ,
        'fifth way, unprepared for, will promptly develop."'
        M00294.1 = ,
        '"Things get worse under pressure."'
        M00295.1 = ,
        '"Persons disagreeing with your facts are always emotional'
        M00295.2 = ,
        'and employ faulty reasoning."'
        M00296.1 = ,
        '"A consultant is an ordinary person a long way from home."'
        M00297.1 = ,
        '"Progress is made on alternate Fridays."'
        M00298.1 = ,
        '"The first 90 percent of the task takes 90 percent of the'
        M00298.2 = ,
        'time; the last 10 percent takes the other 90 percent."'
        M00299.1 = ,
        '"If two wrongs don''t make a right, try three."'
        M00300.1 = ,
        '"Don''t look back, something may be gaining on you."'
        M00301.1 = ,
        '"All things being equal, all things are never equal."'
        M00302.1 = ,
        '"Even paranoids have enemies."'
        M00303.1 = ,
        '"Incompetence knows no barriers of time or place."'
        M00304.1 = ,
        '"Work is accomplished by those employees who have not yet'
        M00304.2 = ,
        'reached their level of incompetence."'
        M00305.1 = ,
        '"If at first you don''t succeed, try something else."'
        M00306.1 = ,
        '"If you''re coasting, you''re going downhill."'
        M00307.1 = ,
        '"Never tell them what you wouldn''t do."'
        M00308.1 = ,
        '"The amount of flak received on any subject is inversely'
        M00308.2 = ,
        'proportional to the subject''s true value."'
        M00309.1 = ,
        'Jody Powell''s Second Law:'
        M00309.2 = ,
        ' "Indifference is the only sure defense."'
        M00310.1 = ,
        '"Whatever hits the fan will not be evenly distributed."'
        M00311.1 = ,
        '"Never needlessly disturb a thing at rest."'
        M00312.1 = ,
        '"In Leningrad, freezing point is called melting point."'
        M00313.1 = ,
        '"The easiest way to find something lost around the house'
        M00313.2 = ,
         'is to buy a replacement."'
        M00314.1 = ,
        '"Bare feet magnetize sharp metal objects so they always'
        M00314.2 = ,
        'point upward from the floor -- especially in the dark."'
        M00315.1 = ,
        '"Make three correct guesses consecutively and you will'
        M00315.2 = ,
        'establish yourself as an expert."'
        M00316.1 = ,
        '"It works better if you plug it in."'
        M00317.1 = ,
        '"Quit while you''re still behind."'
        M00318.1 = ,
        '"The difference between genius and stupidity is that genius has lim'||,
        'its."'
        M00319.1 = ,
        '"It''s always easier to go downhill, but the view is from the top."'
        M00320.1 = ,
        '"Any line, however short, is still too long."'
        M00321.1 = ,
        '"Laziness is the mother of nine inventions out of ten."'
        M00322.1 = ,
        '"If you can''t measure output, then you measure input."'
        M00323.1 = ,
        '"Any theory can be made to fit any facts by means of'
        M00323.2 = ,
        'appropriate, additional assumptions."'
        M00324.1 = ,
        'Old Scottish prayer: "O lord, grant that we may always be'
        M00324.2 = ,
        'right, for Thou knowest we will never change our minds."'
        M00325.1 = ,
        '"Never be first to do anything."'
        M00326.1 = ,
        '"The chief cause of problems is solutions."'
        M00327.1 = ,
        '"The only winner in the war of 1812 was Tchaikovsky."'
        M00328.1 = ,
        '"A little ignorance can go a long way."'
        M00329.1 = ,
        '"Learn to be sincere.  Even if you have to fake it."'
        M00330.1 = ,
        '"Entropy has us outnumbered."'
        M00331.1 = ,
        '"Do whatever your enemies don''t want you to do."'
        M00332.1 = ,
        '"A little ambiguity never hurt anyone."'
        M00333.1 = ,
        '"Don''t permit yourself to get between a dog and a lamppost."'
        M00334.1 = ,
        '"The universe doesn''t care what you think."'
        M00335.1 = ,
        '"Half of being smart is knowing what you''re dumb at."'
        M00336.1 = ,
        '"No man is an island so long as he is on at least one mailing list."'
        M00337.1 = ,
        '"Cant produces countercant."'
        M00338.1 = ,
        '"If you see a man approaching you with the obvious intent'
        M00338.2 = ,
        'of doing you good, you should run for your life."'
        M00339.1 = ,
        '"When you are sure you''re right, you have a moral duty'
        M00339.2 = ,
        'to impose your will upon anyone who disagrees with you."'
        M00340.1 = ,
        '"If you can''t convince them, confuse them."'
        M00341.1 = ,
        '"Assumption is the mother of all foul-ups."'
        M00342.1 = ,
        '"All general statements are false.  (think about it)"'
        M00343.1 = ,
        '"If it happens, it must be possible."'
        M00344.1 = ,
        '"Them what gets--has."'
        M00345.1 = ,
        '"If you are already in a hole, there''s no use to continue digging."'
        M00346.1 = ,
        '"If builders built buildings the way programmers wrote programs,'
        M00346.2 = ,
        'then the first woodpecker that came along would destroy civilizati'||,
        'on."'
        M00347.1 = ,
        '"People will believe anything if you whisper it."'
        M00348.1 = ,
        '"A pat on the back is only a few inches from a kick in the pants."'
        M00349.1 = ,
        '"Never leave hold of what you''ve got until you''ve got hold of '||,
        'something else."'
        M00349.2 = ,
        '  (Mountain climber''s law)'
        M00350.1 = ,
        '"A theory is better than its explanation."'
        M00351.1 = ,
        '"If you eat a live toad the first thing in the morning, nothing'
        M00351.2 = ,
        'worse will happen to either of you the rest of the day."'
        M00352.1 = ,
        '"Nobody notices when things go right."'
        M00353.1 = ,
        '"There is no safety in numbers, or in anything else."'
        M00354.1 = ,
        '"If anything can go wrong, it will."'
        M00355.1 = ,
        '"If anything can''t go wrong it will."'
        M00356.1 = ,
        '"If Murphy''s law can go wrong, it will."'
        M00357.1 = ,
        '"If a series of events can go wrong, it will do so in'
        M00357.2 = ,
        'the worst possible sequence."'
        M00358.1 = ,
        '"After things have gone from bad to worse, the cycle will repeat it'||,
        'self."'
        M00359.1 = ,
        '"An auditor enters the battlefield after the war is over'
        M00359.2 = ,
        'and attacks the wounded."'
        M00360.1 = ,
        '"Nothing is ever so bad that it can''t get worse."'
        M00361.1 = ,
        '"No matter what goes wrong, there is always somebody who knew it wo'||,
        'uld."'
        M00362.1 = ,
        '"Those whom the gods would destroy, they first teach BASIC."'
        M00363.1 = ,
        '"The hidden flaw never remains hidden."'
        M00364.1 = ,
        '1. "Everything depends"'
        M00364.2 = ,
        '2. "Nothing is always"'
        M00364.3 = ,
        '3. "Everything is sometimes"'
        M00365.1 = ,
        '"If you wait, it will go away'
        M00365.2 = ,
        '....having done its damage.'
        M00365.3 = ,
        'If it was bad, it''ll be back."'
        M00366.1 = ,
        '"Complex problems have simple, easy-to-understand wrong answers."'
        M00367.1 = ,
        '"Opportunity always knocks at the least opportune moment."'
        M00368.1 = ,
        '"When you need to knock on wood is when you realize the'
        M00368.2 = ,
        'world''s composed of aluminum and vinyl."'
        M00369.1 = ,
        '"In order for something to become clean, something else must become'||,
        ' dirty.'
        M00369.2 = ,
        '...But you can get everything dirty without getting anything clean'||,
        '."'
        M00370.1 = ,
        '"Things equal to nothing else are equal to each other."'
        M00371.1 = ,
        '"The first place to look for anything is the last place'
        M00371.2 = ,
        'you would expect to find it."'
        M00372.1 = ,
        '"You can always find what you''re not looking for."'
        M00373.1 = ,
        '"If you don''t care where you are, you ain''t lost."'
        M00374.1 = ,
        '"It is impossible for an optimist to be pleasantly surprised."'
        M00375.1 = ,
        '"A crisis is when you can''t say ''let''s forget the whole thing''."'
        M00376.1 = ,
        '"Washing your car to make it rain doesn''t work."'
        M00377.1 = ,
        '"When the going gets tough, everyone leaves."'
        M00378.1 = ,
        '"The time it takes to rectify a situation is inversely'
        M00378.2 = ,
        'proportional to the time it took to do the damage."'
        M00379.1 = ,
        '"An optimist believes we live in the best of all possible worlds.'
        M00379.2 = ,
        'A pessimist fears this is true."'
        M00380.1 = ,
        '"You can make it foolproof, but you can''t make it damnfoolproof."'
        M00381.1 = ,
        '"It takes longer to glue a vase together than to break one."'
        M00382.1 = ,
        '"It takes longer to lose ''x'' number of pounds than'
        M00382.2 = ,
        'to gain ''x'' number of pounds."'
        M00383.1 = ,
        '"The item you had your eye on the minute you walked in'
        M00383.2 = ,
        'will be taken by the person in front of you."'
        M00384.1 = ,
        '"If you change lines, the one you just left will start'
        M00384.2 = ,
        'to move faster than the one you are now in."'
        M00385.1 = ,
        '"The longer you wait in line, the greater the'
        M00385.2 = ,
        ' likelihood that you are standing in the wrong line."'
        M00386.1 = ,
        '"The slowest checker is always at the quick-check-out lane."'
        M00387.1 = ,
        '"Whenever you cut your fingernails you will find a need for them an'||,
        ' hour later."'
        M00388.1 = ,
        '"If a situation requires undivided attention, it will'
        M00388.2 = ,
        ' occur simultaneously with a compelling distraction."'
        M00389.1 = ,
        '"It''s bad luck to be superstitious."'
        M00390.1 = ,
        '"You simply MUST stop taking advice from other people."'
        M00390.2 = ,
        '                  --Melissa Timberman'
        M00391.1 = ,
        '"Next to surviving an earthquake, nothing is quite so satisfying'
        M00391.2 = ,
        ' as receiving a income tax refund."'
        M00392.1 = ,
        '"The best way to inspire fresh thoughts is to seal the letter."'
        M00393.1 = ,
        'Ancient Chinese curse:'
        M00393.2 = ,
        '"May you live in interesting times."'
        M00394.1 = ,
        '"Baseball is 90 per cent perspiration;'
        M00394.2 = ,
        ' the other half is mental."'
        M00394.3 = ,
        '                     --Yogi Berra'
        M00395.1 = ,
        '"THINK    If you are already thinking, please disregard this messag'||,
        'e."'
        M00396.1 = ,
        '1. "Never draw what you can copy."'
        M00396.2 = ,
        '2. "Never copy what you can trace."'
        M00396.3 = ,
        '3. "Never trace what you can cut out and paste down."'
        M00397.1 = ,
        '"Distributed data processing is a scatter-brained idea."'
        M00398.1 = ,
        '"When you don''t know what to do, walk fast and look worried."'
        M00399.1 = ,
        '"If you are the first to know about something bad, you are going t'||,
        'o be'
        M00399.2 = ,
        'held responsible for acting on it, regardless of your formal dutie'||,
        's."'
        M00400.1 = ,
        '"In a three-story building served by one elevator, nine times out'
        M00400.2 = ,
        'of ten, the elevator car will be on a floor where you are not."'
        M00401.1 = ,
        '"The tendency of smoke from a cigarette, barbeque,'
        M00401.2 = ,
        'campfire, etc. to drift into a person''s face varies'
        M00401.3 = ,
        'directly with that person''s sensitivity to smoke."'
        M00402.1 = ,
        '"The distance to the gate is inversely proportional'
        M00402.2 = ,
        'to the time available to catch your flight."'
        M00403.1 = ,
        '"As soon as the stewardess serves the coffee, the airliner encoun'||,
        'ters turbulence."'
        M00404.1 = ,
        '"Serving coffee on aircraft causes turbulence."'
        M00405.1 = ,
        '"Whatever carrousel you stand by, your baggage will come in on anot'||,
        'her one."'
        M00406.1 = ,
        '"When travelling overseas, the exchange rate improves'
        M00406.2 = ,
        'markedly the day after one has purchased foreign currency."'
        M00407.1 = ,
        '"300,000 kilometers/second - it''s not just a good idea, it''s the '||,
        'law."'
        M00408.1 = ,
        '"The bigger they are, the harder they hit."'
        M00409.1 = ,
        '"For every action, there is an equal and opposite criticism."'
        M00410.1 = ,
        '"Authorization for a project will be granted only when none of'
        M00410.2 = ,
        'the authorizers can be blamed if the project fails, but when'
        M00410.3 = ,
        'all of the authorizers can claim credit if it succeeds."'
        M00411.1 = ,
        '"If an idea can survive a bureacratic review and be'
        M00411.2 = ,
        'implemented, it wasn''t worth doing."'
        M00412.1 = ,
        '"The greater the cost of putting a plan into operation,'
        M00412.2 = ,
        'the less chance there is of abandoning the plan - even'
        M00412.3 = ,
        'if it subsequently becomes irrelevant."'
        M00413.1 = ,
        '"You can tune a piano, but you can''t tuna fish."'
        M00414.1 = ,
        '"In any organization there will always be one person who knows what'||,
        ' is going on.'
        M00414.2 = ,
        'This person must be fired."'
        M00415.1 = ,
        '"It is easier to get forgiveness than permission."'
        M00416.1 = ,
        '"Some people manage by the book, even though they'
        M00416.2 = ,
        'don''t know who wrote the book or even what book."'
        M00417.1 = ,
        '"Don''t let your superiors know you''re better than they are."'
        M00418.1 = ,
        '"You never know who''s right, but you always know who''s in charge."'
        M00419.1 = ,
        '1. "Anyone can make a decision given enough facts"'
        M00419.2 = ,
        '2. "A good manager can make a decision without enough facts"'
        M00419.3 = ,
        '3. "A perfect manager can operate in perfect ignorance"'
        M00420.1 = ,
        '"The boss who attempts to impress employees with his knowledge of'
        M00420.2 = ,
        'intricate details has lost sight of his final objective."'
        M00421.1 = ,
        '"You will save yourself a lot of needless worry if you'
        M00421.2 = ,
        'don''t burn your bridges until you come to them."'
        M00422.1 = ,
        '"In a hierarchical system, the rate of pay varies inversely with'
        M00422.2 = ,
        'the unpleasantness and difficulty of the task."'
        M00423.1 = ,
        '"The client who pays the least complains the most."'
        M00424.1 = ,
        '"A lack of planning on your part does not constitute an emergency o'||,
        'n my part."'
        M00425.1 = ,
        '"I know you believe you understand'
        M00425.2 = ,
        '   what you think I said,'
        M00425.3 = ,
        '      however, I am not sure you realize,'
        M00425.4 = ,
        '         that what I think you heard'
        M00425.5 = ,
        '            is not what I meant."'
        M00426.1 = ,
        '"Real programmers don''t eat muffins."'
        M00427.1 = ,
        '"In any bureaucracy, paperwork increases as you spend more and more'||,
        ' time'
        M00427.2 = ,
        'reporting on the less and less you are doing. Stability is achiev'||,
        'ed'
        M00427.3 = ,
        'when you spend all of your time reporting on the nothing you are d'||,
        'oing."'
        M00428.1 = ,
        '"Consultants are mystical people who ask a company for a number'
        M00428.2 = ,
        'and then give it back to them."'
        M00429.1 = ,
        '"The chances of anybody doing anything are inversely proportional t'||,
        'o'
        M00429.2 = ,
        'the number of other people who are in a position to do it instead."'
        M00430.1 = ,
        '"Never make a decision you can get someone else to make."'
        M00431.1 = ,
        '"No one keeps a record of decisions you could have made'
        M00431.2 = ,
        'but didn''t. Everyone keeps a record of your bad ones."'
        M00432.1 = ,
        '"For every vision, there is an equal and opposite revision."'
        M00433.1 = ,
        '"The inside contact that you have developed at great expense'
        M00433.2 = ,
        'is the first person to be let go in any reorganization."'
        M00434.1 = ,
        '"Time flies like an arrow.'
        M00434.2 = ,
        'Fruit flies like a banana."'
        M00435.1 = ,
        '"Democracy is four wolves and a lamb voting on what to have for lun'||,
        'ch."'
        M00436.1 = ,
        '"People generally don''t make the same mistake twice;"'
        M00436.2 = ,
        'they make it three, four, or five times."'
        M00437.1 = ,
        '"A meeting is an event at which the minutes are kept and the hours '||,
        'are lost."'
        M00438.1 = ,
        '"If you leave the room, you''re elected."'
        M00439.1 = ,
        '"The cream rises to the top.'
        M00439.2 = ,
        'So does the scum."'
        M00440.1 = ,
        '"You can never do just one thing."'
        M00441.1 = ,
        '"There''s no time like the present for postponing what you don''t w'||,
        'ant to do."'
        M00442.1 = ,
        '"Any task worth doing was worth doing yesterday."'
        M00443.1 = ,
        '"The more complicated and grandiose the plan, the greater the cha'||,
        'nce of failure."'
        M00444.1 = ,
        '"Simple jobs always get put off because there will be time to do th'||,
        'em later."'
        M00445.1 = ,
        '"Hollow chocolate has no calories."'
        M00446.1 = ,
        '"A work project expands to fill the space available."'
        M00447.1 = ,
        '"No matter how large the work space, if two projects must be done a'||,
        't the'
        M00447.2 = ,
        'same time, they will require the same part of the work space."'
        M00448.1 = ,
        '"The one wrench or drill bit you need will be the one'
        M00448.2 = ,
        'missing from the tool chest."'
        M00449.1 = ,
        '"Most projects require three hands."'
        M00450.1 = ,
        '"Leftover nuts never match leftover bolts."'
        M00451.1 = ,
        '"The more carefully you plan a project, the more'
        M00451.2 = ,
        'confusion there is when something goes wrong."'
        M00452.1 = ,
        'Murphy''s rule for precision:'
        M00452.2 = ,
        '   "Measure with a micrometer,'
        M00452.3 = ,
        '   mark with chalk,'
        M00452.4 = ,
        '   cut with an axe."'
        M00453.1 = ,
        '"You can''t fix it if it ain''t broke."'
        M00454.1 = ,
        'First rule of intelligent tinkering:'
        M00454.2 = ,
        '   "Save all the parts."'
        M00455.1 = ,
        '"If all you have is a hammer, everything looks like a nail."'
        M00456.1 = ,
        '"Software suppliers are trying to make their software packages mor'||,
        'e'
        M00456.2 = ,
        '''user-friendly''.... Their best approach, so far, has been to tak'||,
        'e all'
        M00456.3 = ,
        'the old brochures, and stamp the words ''user-friendly'' on the co'||,
        'ver."'
        M00456.4 = ,
        '       --Bill Gates'
        M00457.1 = ,
        'Bradley''s Bromide: "If computers get too powerful, we can'
        M00457.2 = ,
        'organize them into a committee... that will do them in."'
        M00458.1 = ,
        '"The solution to a problem changes the problem."'
        M00459.1 = ,
        '"Be yourself.  Who else is better qualified?"'
        M00460.1 = ,
        '"If you think nobody cares you''re alive, try missing a couple of '||,
        'payments!"'
        M00460.2 = ,
        '--Earl Wilson'
        M00461.1 = ,
        '"Important letters which contain no errors will develop errors in t'||,
        'he mail."'
        M00462.1 = ,
        '"Office machines which function perfectly during normal'
        M00462.2 = ,
        'business hours will break down when you return to the'
        M00462.3 = ,
        'office at night to use them for personal business."'
        M00463.1 = ,
        '"Machines that have broken down will work perfectly when the repair'||,
        'man arrives."'
        M00464.1 = ,
        '"Envelopes and stamps which don''t stick when you lick them will'
        M00464.2 = ,
        'stick to other things when you don''t want them to."'
        M00465.1 = ,
        '"Vital papers will demonstrate their vitality by spontaneously movi'||,
        'ng'
        M00465.2 = ,
        'from where you left them to where you can''t find them."'
        M00466.1 = ,
        '"The last person who quit or was fired will be held responsible for'
        M00466.2 = ,
        'everything that goes wrong -- until the next person quits or is fi'||,
        'red."'
        M00467.1 = ,
        '"If you hit two keys on the typewriter, the one you don''t want hit'||,
        's the paper."'
        M00468.1 = ,
        '"Hot glass looks exactly the same as cold glass."'
        M00469.1 = ,
        '"When you do not know what you are doing, do it neatly."'
        M00470.1 = ,
        '"Teamwork is essential. It allows you to blame someone else."'
        M00471.1 = ,
        '"Science is true. Don''t be misled by facts."'
        M00472.1 = ,
          '"Take time to deliberate, but when the time for action arrives,'
        M00472.2 = ,
          ' stop thinking and go in."'
        M00472.3 = ,
         "  --  Andrew Jackson, U.S. President"
        M00473.1 = ,
        '"Nothing improves an innovation like lack of controls."'
        M00474.1 = ,
        '"The quality of correlation is inversely proportional to the dens'||,
        'ity of control."'
        M00475.1 = ,
        '"If reproducibility may be a problem, conduct the test only once."'
        M00476.1 = ,
        '"If a straight line fit is required, obtain only two data points."'
        M00477.1 = ,
        '"Unless the results are known in advance, funding'
        M00477.2 = ,
        'agencies will reject the proposal."'
        M00478.1 = ,
        '"An easily-understood, workable falsehood is more useful'
        M00478.2 = ,
        'than a complete, incomprehensible truth."'
        M00479.1 = ,
        '"Anyone who makes a significant contribution to any field'
        M00479.2 = ,
        'of endeavor, and stays in that field long enough,'
        M00479.3 = ,
        'becomes an obstruction to its progress -- in direct'
        M00479.4 = ,
        'proportion to the importance of his original contribution."'
        M00480.1 = ,
        '"The more the name of a product promises, the less it delivers." ('||,
        'For example,'
        M00480.2 = ,
        'cheap stereo equipment often has the word ''super'' in its name, '||,
        'while the best'
        M00480.3 = ,
        'equipment is usually named like a consulting firm.)'
        M00481.1 = ,
        '"There is no such thing as a straight line."'
        M00482.1 = ,
        '"In any series of calculations, errors tend to occur at the opposit'||,
        'e end'
        M00482.2 = ,
        'to the end at which you begin checking for errors."'
        M00483.1 = ,
        '"Only errors exist."'
        M00484.1 = ,
        '"One man''s error is another man''s data."'
        M00485.1 = ,
        '"To err is human, but to really foul things up requires a computer."'
        M00486.1 = ,
        '"When putting it into memory, remember where you put it."'
        M00487.1 = ,
        '"Never test for an error condition you don''t know how to handle."'
        M00488.1 = ,
        '"Everybody lies; but it doesn''t matter, since nobody listens."'
        M00489.1 = ,
        '"People who love sausage and respect the law should never'
        M00489.2 = ,
        'watch either one being made."'
        M00490.1 = ,
        '"No matter what they''re talking about, they''re talking about mone'||,
        'y."'
        M00491.1 = ,
        '"In any dealings with a collective body of people, the'
        M00491.2 = ,
        'people will always be more tacky than originally expected."'
        M00492.1 = ,
        '"If you can keep your head when all about you are losing'
        M00492.2 = ,
        'theirs, then you just don''t understand the problem."'
        M00493.1 = ,
        '"Information deteriorates upward through the bureaucracies."'
        M00494.1 = ,
        '"When an exaggerated emphasis is placed upon delegation,'
        M00494.2 = ,
        'responsibility, like sediment, sinks to the bottom."'
        M00495.1 = ,
        '"When outrageous expenditures are divided finely enough, the public'
        M00495.2 = ,
        'will not have enough stake in any one expenditure to squelch it."'
        M00496.1 = ,
        '"You may know where the market is going, but you can''t'
        M00496.2 = ,
        'possibly know where it''s going after that."'
        M00497.1 = ,
        '"Among economists, the real world is often a special case."'
        M00498.1 = ,
        '"If everybody doesn''t want it, nobody gets it."'
        M00499.1 = ,
        '"Everything is contagious."'
        M00500.1 = ,
        '"Nothing is ever done for the right reasons."'
        M00501.1 = ,
        '"The secret of success is sincerity. Once you can fake that,'
        M00501.2 = ,
        'you''ve got it made."'
        M00502.1 = ,
        '"An expert is anyone from out of town."'
        M00503.1 = ,
        '"An expert is one who knows more and more about less and less'
        M00503.2 = ,
        'until he knows absolutely everything about nothing."'
        M00504.1 = ,
        '"To spot the expert, pick the one who predicts the job'
        M00504.2 = ,
        'will take the longest and cost the most."'
        M00505.1 = ,
        '"If it sits on your desk for 15 minutes, you''ve just become the ex'||,
        'pert."'
        M00506.1 = ,
        '"Anything is possible if you don''t know what you''re talking about'||,
        '."'
        M00507.1 = ,
        '"Never create a problem for which you do not have the answer."'
        M00508.1 = ,
        '"Create problems for which only you have the answer."'
        M00509.1 = ,
        '"A conclusion is the place where you got tired of thinking."'
        M00510.1 = ,
        '"Hindsight is an exact science."'
        M00511.1 = ,
        '"History doesn''t repeat itself -- historians merely repeat each ot'||,
        'her."'
        M00512.1 = ,
        '"Fact is solidified opinion."'
        M00513.1 = ,
        '"Facts may weaken under extreme heat and pressure."'
        M00514.1 = ,
        '"Truth is elastic."'
        M00515.1 = ,
        '"When in doubt, predict that the trend will continue."'
        M00516.1 = ,
        '"When in trouble, obfuscate."'
        M00517.1 = ,
        '"Progress does not consist of replacing a theory that is'
        M00517.2 = ,
        'wrong with one that is right. It consists of replacing'
        M00517.3 = ,
        'a theory that is wrong with one that is more subtly wrong."'
        M00518.1 = ,
        '"It is a simple task to make things complex, but a complex'
        M00518.2 = ,
        'task to make them simple."'
        M00519.1 = ,
        '"If you have a difficult task give it to a lazy man; he'
        M00519.2 = ,
        'will find an easier way to do it."'
        M00520.1 = ,
        '"Every great idea has a disadvantage equal to or'
        M00520.2 = ,
        'exceeding the greatness of the idea."'
        M00521.1 = ,
        '"Never attribute to malice that which is adequately explained by st'||,
        'upidity."'
        M00522.1 = ,
        '"New systems generate new problems."'
        M00523.1 = ,
        '"Systems tend to grow, and as they grow they encroach."'
        M00524.1 = ,
        '"The total behavior of large systems cannot be predicted."'
        M00525.1 = ,
        '"A large system, produced by expanding the dimensions of'
        M00525.2 = ,
        'a smaller system, does not behave like the smaller system."'
        M00526.1 = ,
        'Second law of Frisbee:'
        M00526.2 = ,
        '"Never precede any manoeuvre by a comment more predictive than ''W'||,
        'atch this!''"'
        M00527.1 = ,
        '"The system itself does not do what it says it is doing."'
        M00528.1 = ,
        '"A complex system that works is invariably found to have'
        M00528.2 = ,
        'evolved from a simple system that works."'
        M00529.1 = ,
        '"A complex system designed from scratch never works and'
        M00529.2 = ,
        'cannot be patched up to make it work. You have to start'
        M00529.3 = ,
        'over, beginning with a working simple system."'
        M00530.1 = ,
        '1. "Everything is a system."'
        M00530.2 = ,
        '2. "Everything is part of a larger system."'
        M00530.3 = ,
        '3. "The universe is infinitely systematized both upward'
        M00530.4 = ,
        '   (larger systems) and downward (smaller systems)."'
        M00530.5 = ,
        '4. "All systems are infinitely complex. (the illusion'
        M00530.6 = ,
        '   of simplicity comes from focusing attention on'
        M00530.7 = ,
        '   one or a few variables)."'
        M00531.1 = ,
        '"Complex systems tend to oppose their own proper function."'
        M00532.1 = ,
        '"If little else, the brain is an educational toy.'
        M00532.2 = ,
        '                                  Tom Robbins"'
        M00533.1 = ,
        '"Show me a person who''s never made a mistake and I''ll'
        M00533.2 = ,
        'show you somebody who''s never achieved much."'
        M00534.1 = ,
        '"Small change can often be found under seat cushions."'
        M00535.1 = ,
        '"Anything free is worth what you pay for it."'
        M00536.1 = ,
        '"Between two evils, I always pick the one I never tried before."'
        M00536.2 = ,
        '                           - Mae West'
        M00537.1 = ,
        '"Creditors have much better memories than debtors."'
        M00538.1 = ,
        '"Everyone complains of his memory, no one of his judgement."'
        M00539.1 = ,
        '"God gives us relatives; thank God we can choose our friends."'
        M00540.1 = ,
        '"He who falls in love with himself will have no rivals."'
        M00541.1 = ,
        '"If at first you don''t succeed, you''re doing about average."'
        M00542.1 = ,
        '"It is better to wear out than to rust out."'
        M00543.1 = ,
        '"Never call a man a fool; borrow from him."'
        M00544.1 = ,
        '"Often, statistics are used as a drunken man uses a'
        M00544.2 = ,
        'lamppost: for support rather than illumination."'
        M00545.1 = ,
        '"The average woman would rather have beauty than brains'
        M00545.2 = ,
        'because the average man can see better than he can think."'
        M00546.1 = ,
        '"Beware of and eschew pompous prolixity."'
        M00547.1 = ,
        '"Everything needs a little oil now and then."'
        M00548.1 = ,
        '"If you are worried about your drinking, you should be.'
        M00548.2 = ,
        'The converse is not true."'
        M00549.1 = ,
        'Astrology law: "It''s always the wrong time of the month."'
        M00550.1 = ,
        '"Just because your doctor has a name for your condition'
        M00550.2 = ,
        'doesn''t mean he knows what it is."'
        M00551.1 = ,
        '"The more boring and out-of-date the magazines in the waiting room,'
        M00551.2 = ,
        'the longer you will have to wait for your scheduled appointment."'
        M00552.1 = ,
        '"Only adults have difficulty with child-proof bottles."'
        M00553.1 = ,
        '"You never have the right number of pills left on the'
        M00553.2 = ,
        'last day of a prescription."'
        M00554.1 = ,
        '"The pills to be taken with meals will be the least appetizing ones'||,
        '."'
        M00555.1 = ,
        '"Beware of the physician who is great at getting out of trouble."'
        M00556.1 = ,
        '"It''s never too late to have a happy childhood."'
        M00557.1 = ,
        '"Before ordering a test, decide what you will do if it is 1) positi'||,
        've,'
        M00557.2 = ,
        'or 2) negative. If both answers are the same, don''t do the test."'
        M00558.1 = ,
        '"Don''t lose'
        M00558.2 = ,
        ' Your head'
        M00558.3 = ,
        ' To gain a minute'
        M00558.4 = ,
        ' You need your head'
        M00558.5 = ,
        ' Your brains are in it."'
        M00558.6 = ,
        '        - Burma Shave'
        M00559.1 = ,
        '"The feasibility of an operation is not the best'
        M00559.2 = ,
        'indication for its performance."'
        M00560.1 = ,
        '"A physician''s ability is inversely proportional to his availabili'||,
        'ty."'
        M00561.1 = ,
        '"There are two kinds of adhesive tape: that which won''t'
        M00561.2 = ,
        'stay on and that which won''t come off."'
        M00562.1 = ,
        '"Never decide to buy something while listening to the salesman."'
        M00563.1 = ,
        '"''C'' combines the flexibility of assembly language with the power'
        M00563.2 = ,
        'of assembly language."'
        M00564.1 = ,
        '"An alcoholic is a person who drinks more than his own physician."'
        M00565.1 = ,
        '"Fools rush in -- and get the best seats."'
        M00566.1 = ,
        '"At any event, the people whose seats are furthest from the aisle a'||,
        'rrive last."'
        M00567.1 = ,
        '"Nothing is ever so bad it can''t be made worse by firing the coach'||,
        '."'
        M00568.1 = ,
        '"A free agent is anything but."'
        M00569.1 = ,
        '"To do is to be" - Nietzsche'
        M00569.2 = ,
        '"To be is to do" - Sartre'
        M00569.3 = ,
        '"Do be do be do" - Sinatra'
        M00570.1 = ,
        '"What makes us so bitter against people who outwit us is'
        M00570.2 = ,
        'that they think themselves cleverer than we are."'
        M00571.1 = ,
        '"It''s always easy to see both sides of an issue'
        M00571.2 = ,
        'we are not particularly concerned about."'
        M00572.1 = ,
        '"Abandon all hope, ye who PRESS ENTER here."'
        M00573.1 = ,
        '"A mediocre player will sink to the level of his or her opposition."'
        M00574.1 = ,
        '"Pound for pound, the amoeba is the most vicious animal on earth."'
        M00575.1 = ,
        '"There are very few personal problems that can''t be'
        M00575.2 = ,
        'solved by a suitable application of high explosives."'
        M00576.1 = ,
        '"If you''ve see one Phoenix, you''ve seen them all."'
        M00577.1 = ,
        '"No matter how cynical you get, it''s impossible to keep up."'
        M00578.1 = ,
        '"The mountain gets steeper as you get closer."'
        M00579.1 = ,
        '"The mountain looks closer than it is."'
        M00580.1 = ,
        '"All trails have more uphill sections than they have level or dow'||,
        'nhill sections."'
        M00581.1 = ,
        '"All things being equal, you lose.'
        M00581.2 = ,
        'All things being in your favor, you still lose."'
        M00582.1 = ,
        '"43 percent of all statistics are useless."'
        M00583.1 = ,
        '"No matter where you go, there you are!"'
        M00584.1 = ,
        '"It always takes longer to get there than to get back."'
        M00585.1 = ,
        '"If everything is coming your way, you''re in the wrong lane."'
        M00586.1 = ,
        '"The only difference between the fool, and the criminal who attacks'||,
        ' a'
        M00586.2 = ,
        'system is that the fool attacks unpredictably and on a broader fro'||,
        'nt."'
        M00586.3 = ,
        '        - Tom Gilb'
        M00587.1 = ,
        '"When you''re not in a hurry, the traffic light will turn'
        M00587.2 = ,
        'green as soon as your vehicle comes to a complete stop."'
        M00588.1 = ,
        '"A car and a truck approaching each other on an otherwise'
        M00588.2 = ,
        'deserted road will meet at the narrow bridge."'
        M00589.1 = ,
        '"The speed of an oncoming vehicle is directly proportional'
        M00589.2 = ,
        'to the length of the passing zone."'
        M00590.1 = ,
        '"I don''t like to spread rumors, but what else can you do with them'||,
        '?"'
        M00591.1 = ,
        '"If you put tomfoolery into a computer, nothing comes out but'
        M00591.2 = ,
        'tomfoolery.  But this tomfoolery, having passed through a very'
        M00591.3 = ,
        'expensive machine, is somehow enobled, and no one dares to critici'||,
        'ze it."'
        M00592.1 = ,
        '"A verbal contract isn''t worth the paper it''s written on."'
        M00593.1 = ,
        '"When the need arises, any tool or object closest to you becomes a '||,
        'hammer."'
        M00594.1 = ,
        'Rule 1 of auto repair:'
        M00594.2 = ,
        '"No matter how minor the task, you will inevitably end up'
        M00594.3 = ,
        'covered with grease and motor oil."'
        M00595.1 = ,
        '"When necessary, metric and inch tools can be used interchangeably."'
        M00596.1 = ,
        'Automotive engine repairing law:'
        M00596.2 = ,
        '"If you drop something, it will never reach the ground."'
        M00597.1 = ,
        '"If you lived here you''d be home now."'
        M00598.1 = ,
        '"If the shoe fits, it''s ugly."'
        M00599.1 = ,
        '"Whoso diggeth a pit shall fall therein."'
        M00599.2 = ,
        '        - Book of Proverbs'
        M00600.1 = ,
        '"Anything labelled ''new'' and/or ''improved'' isn''t."'
        M00601.1 = ,
        '"The label ''new'' and/or ''improved'' means the price went up."'
        M00602.1 = ,
        '"The label ''all new'', ''completely new'' or ''great news'''
        M00602.2 = ,
        'means the price went way way up."'
        M00603.1 = ,
        '"If an item is advertised as ''under $50'', you can bet it''s not $'||,
        '19.95."'
        M00604.1 = ,
        '"ACF2 is a four letter word."'
        M00605.1 = ,
        '"If only one price can be obtained for any quotation,'
        M00605.2 = ,
        'the price will be unreasonable."'
        M00606.1 = ,
        '"A 60-day warranty guarantees that the product will'
        M00606.2 = ,
        'self-destruct on the 61st day."'
        M00607.1 = ,
        '"The ''consumer report'' on the item will come out a week'
        M00607.2 = ,
        'after you''ve made your purchase:'
        M00607.3 = ,
        ' '
        M00607.4 = ,
        "  1. The one you bought will be rated 'unacceptable'."
        M00607.5 = ,
        "  2. The one you almost bought will be rated 'best buy'."
        M00608.1 = ,
        '"If you don''t write to complain, you''ll never receive your order.'
        M00608.2 = ,
        'If you do write, you''ll receive the merchandise before your'
        M00608.3 = ,
        'angry letter reaches its destination."'
        M00609.1 = ,
        '"The most important item in an order will no longer be available."'
        M00610.1 = ,
        '"During the time an item is on back-order, it will be'
        M00610.2 = ,
        'available cheaper and quicker from many other sources."'
        M00611.1 = ,
        '"You are wise, witty and wonderful, but you spend too much of your'
        M00611.2 = ,
        'time reading silly messages."'
        M00612.1 = ,
        '"Security isn''t."'
        M00613.1 = ,
        '"Tell a man that there are 300 billion stars in the universe'
        M00613.2 = ,
        'and he''ll believe you....  Tell him that a bench has wet'
        M00613.3 = ,
        'paint upon it and he''ll have to touch it to be sure."'
        M00614.1 = ,
        '"Cleanliness is next to impossible."'
        M00615.1 = ,
        '"Multiple-function gadgets will not perform any single function ade'||,
        'quately."'
        M00616.1 = ,
        '"The more expensive the gadget, the less often you will use it."'
        M00617.1 = ,
        '"The simpler the instruction (e.g. ''press here''), the'
        M00617.2 = ,
        'more difficult it will be to open the package."'
        M00618.1 = ,
        '"In a family recipe you just discovered in an old book,'
        M00618.2 = ,
        'the most vital measurement will be illegible."'
        M00619.1 = ,
        '"Once a dish is fouled up, anything added to save it only makes it '||,
        'worse."'
        M00620.1 = ,
        '"You are always complimented on the item which took the'
        M00620.2 = ,
        'least effort to prepare.'
        M00620.3 = ,
        ' '
        M00620.4 = ,
        'example:'
        M00620.5 = ,
        ' If you make ''Duck a l''Orange'', you will be'
        M00620.6 = ,
        ' complimented on the baked potato."'
        M00621.1 = ,
        '"The one ingredient you made a special trip to the store to get'
        M00621.2 = ,
        'will be the one thing your guest is allergic to."'
        M00622.1 = ,
        '"The more time and energy you put into preparing a meal'
        M00622.2 = ,
        'the greater the chance you guests will spend the entire'
        M00622.3 = ,
        'meal discussing other meals they have had."'
        M00623.1 = ,
        '"Souffles rise and cream whips only for the family and'
        M00623.2 = ,
        'for guests you didn''t really want to invite anyway."'
        M00624.1 = ,
        '"The rotten egg will be the one you break into the cake batter."'
        M00625.1 = ,
        '"Any cooking utensil placed in the dishwasher will be'
        M00625.2 = ,
        'needed immediately thereafter for something else."'
        M00626.1 = ,
        '"Any measuring utensil used for liquid ingredients will'
        M00626.2 = ,
        'be needed immediately thereafter for dry ingredients."'
        M00627.1 = ,
        '"Time spent consuming a meal is in inverse proportion'
        M00627.2 = ,
        'to time spent preparing it."'
        M00628.1 = ,
        '"I used to be indecisive; now I''m not sure."'
        M00629.1 = ,
        '"If you''re wondering if you took the meat out to thaw, you didn''t'||,
        '."'
        M00630.1 = ,
        '"If you''re wondering if you left the coffee pot plugged in, you di'||,
        'd."'
        M00631.1 = ,
        '"If you''re wondering if you need to stop and pick up'
        M00631.2 = ,
        'bread and eggs on the way home, you do."'
        M00632.1 = ,
        '"If you''re wondering if you have enough money to take'
        M00632.2 = ,
        'the family out to eat tonight, you don''t."'
        M00633.1 = ,
        '"The spot you are scrubbing on glassware is always on the other sid'||,
        'e."'
        M00634.1 = ,
        '"Washing machines only break down during the wash cycle."'
        M00635.1 = ,
        '"There is always more dirty laundry then clean laundry."'
        M00636.1 = ,
        '"If it''s clean, it isn''t laundry."'
        M00637.1 = ,
        '"A child will not spill on a dirty floor."'
        M00638.1 = ,
        '"An unbreakable toy is useful for breaking other toys."'
        M00639.1 = ,
        '"Any child who chatters non-stop at home will adamantly refuse'
        M00639.2 = ,
        'to utter a word when requested to demonstrate for an audience."'
        M00640.1 = ,
        '"A shy, introverted child will choose a crowded public'
        M00640.2 = ,
        'area to loudly demonstrate newly acquired vocabulary."'
        M00641.1 = ,
        '"The probability of a cat eating its dinner has absolutely'
        M00641.2 = ,
        'nothing to do with the price of the food placed before it."'
        M00642.1 = ,
        '"The probability that a household pet will raise a fuss'
        M00642.2 = ,
        'to go in or out is directly proportional to the number'
        M00642.3 = ,
        'and importance of your dinner guests."'
        M00643.1 = ,
        '"How long a minute is depends on which side of the bathroom door yo'||,
        'u''re on."'
        M00644.1 = ,
        '"The life expectancy of a house plant varies inversely'
        M00644.2 = ,
        'with its price and directly with its ugliness."'
        M00645.1 = ,
        '"If there are only 2 shows worth watching, they will be on together'||,
        '."'
        M00646.1 = ,
        '"Most people deserve each other."'
        M00647.1 = ,
        '"Possessions increase to fill the space available for their storage'||,
        '."'
        M00648.1 = ,
        '"When you dial a wrong number, you never get a busy signal."'
        M00649.1 = ,
        '1. "The telephone will ring when you are outside the'
        M00649.2 = ,
        '   door, fumbling for your keys."'
        M00649.3 = ,
        '2. "You will reach it just in time to hear the click'
        M00649.4 = ,
        '   of the caller hanging up."'
        M00650.1 = ,
        '"People to whom you are attracted invariably think you'
        M00650.2 = ,
        'remind them of someone else."'
        M00651.1 = ,
        '"The one who snores will fall asleep first."'
        M00652.1 = ,
        '"Never get excited about a blind date because of how it sounds over'||,
        ' the phone."'
        M00653.1 = ,
        '"The length of a marriage is inversely proportional'
        M00653.2 = ,
        'to the amount spent on the wedding."'
        M00654.1 = ,
        '"All probabilities are 50%. Either a thing will happen or it won''t.'
        M00654.2 = ,
        'This is especially true when dealing with women.'
        M00654.3 = ,
        'Likelihoods, however, are 90% against you."'
        M00655.1 = ,
        '"Sow your wild oats on Saturday night - then on Sunday pray for cro'||,
        'p failure."'
        M00656.1 = ,
        '"The probability of meeting someone you know increases'
        M00656.2 = ,
        'when you are with someone you don''t want to be seen with."'
        M00657.1 = ,
        '"If you help a friend in need, he is sure to remember'
        M00657.2 = ,
        'you - the next time he''s in need."'
        M00658.1 = ,
        '"Virtue is its own punishment."'
        M00659.1 = ,
        '"If you do something right once, someone will ask you to do it agai'||,
        'n."'
        M00660.1 = ,
        '"The one day you''d sell your soul for something, souls are a glut."'
        M00661.1 = ,
        '"The scratch on the record is always through the song you like most'||,
        '."'
        M00662.1 = ,
        '"Superiority is recessive."'
        M00663.1 = ,
        '"Forgive and remember."'
        M00664.1 = ,
        '"COBOL is the next best thing to coding it in binary."'
        M00665.1 = ,
        '"Anything good in life either causes cancer in'
        M00665.2 = ,
        'laboratory mice or is taxed beyond reality."'
        M00666.1 = ,
        '"To err is human -- to blame it on someone else is even more human."'
        M00667.1 = ,
        '"Whatever happens to you, it will previously have'
        M00667.2 = ,
        'happened to everyone you know, only more so."'
        M00668.1 = ,
        '"He who laughs last -- probably didn''t get the joke."'
        M00669.1 = ,
        '"Don''t worry over what other people are thinking about'
        M00669.2 = ,
        'you. They''re too busy worrying over what you are'
        M00669.3 = ,
        'thinking about them."'
        M00670.1 = ,
        '"There are some things which are impossible to know -'
        M00670.2 = ,
        'but it is impossible to know these things."'
        M00671.1 = ,
        '"When we try to pick out anything by itself we find'
        M00671.2 = ,
        'it hitched to everything else in the universe."'
        M00672.1 = ,
        '"If one views his problem closely enough he will'
        M00672.2 = ,
        'recognize himself as part of the problem."'
        M00673.1 = ,
        '"Anything may be divided into as many parts as you please."'
        M00674.1 = ,
        '"Two things are universal: hydrogen and stupidity."'
        M00675.1 = ,
        '"If several things that could have gone wrong have not gone wrong,'
        M00675.2 = ,
        'it would have been ultimately beneficial for them to have gone wro'||,
        'ng."'
        M00676.1 = ,
        '"The quickest way to experiment with acupuncture is to try on a new'||,
        ' shirt."'
        M00677.1 = ,
        '"Absolutely nothing in the world is friendlier than a wet dog."'
        M00678.1 = ,
        '"The severity of an itch is inversely proportional to the reach."'
        M00679.1 = ,
        '"The only game that can''t be fixed is peek-a-boo."'
        M00680.1 = ,
        '"Ignorance should be painful."'
        M00681.1 = ,
        '"Magellan was the first strait man."'
        M00682.1 = ,
        '"If you smile when everything goes wrong, you are either'
        M00682.2 = ,
        'a nitwit or a repairman."'
        M00683.1 = ,
        '"No news is... impossible."'
        M00684.1 = ,
        '"Laugh and the world laughs with you. Cry and ...'
        M00684.2 = ,
        'you have to blow your nose."'
        M00685.1 = ,
        '"A penny saved is ...not much."'
        M00686.1 = ,
        '"He who marries for money...better be nice to his wife."'
        M00687.1 = ,
        '"It''s always darkest before ...daylight saving time."'
        M00688.1 = ,
        '"Double negatives are a no-no."'
        M00689.1 = ,
        '"There is nothing more frightening than ignorance in action."'
        M00690.1 = ,
        '"Life is like an ice-cream cone: you have to learn to lick it."'
        M00691.1 = ,
        '"One place where you''re sure to find the perfect driver is in the '||,
        'back seat."'
        M00692.1 = ,
        '"Nothing is indestructible, with the possible exception'
        M00692.2 = ,
        'of discount-priced fruitcakes."'
        M00693.1 = ,
        '"How do they know no two snowflakes are alike?"'
        M00694.1 = ,
        '"How did they measure hail before the golf ball was invented?"'
        M00695.1 = ,
        '"Never argue with an artist."'
        M00696.1 = ,
        '"You can''t achieve the impossible unless you attempt the absurd."'
        M00697.1 = ,
        '"A budget is trying to figure out how the family next door is doing'||,
        ' it."'
        M00698.1 = ,
        '"You sure have to borrow a lot of money these days to be an average'||,
        ' consumer."'
        M00699.1 = ,
        '"He who dies with the most toys wins."'
        M00700.1 = ,
        '"If his IQ were any lower he''d be a plant."'
        M00701.1 = ,
        '"Everybody is ignorant, only on different subjects."'
        M00702.1 = ,
        '"It is far better to do nothing than to do something efficiently."'
        M00702.2 = ,
        '                        Siezbo'
        M00703.1 = ,
        '"The man who has no more problems is out of the game."'
        M00704.1 = ,
        '"The race goes not always to the swift, nor the battle'
        M00704.2 = ,
        'to the strong, but that''s the way to bet."'
        M00705.1 = ,
        '"A fool and his money are invited places."'
        M00706.1 = ,
        '"All things come to he whose name is on a mailing list."'
        M00707.1 = ,
        '"After winning an argument with his wife,'
        M00707.2 = ,
        'the wisest thing a man can do is apologize."'
        M00708.1 = ,
        '"If opportunity came disguised as temptation, one knock would be en'||,
        'ough."'
        M00709.1 = ,
        '"Easy doesn''t do it."'
        M00710.1 = ,
        '"Most people want to be delivered from temptation but'
        M00710.2 = ,
        ' would like it to keep in touch."'
        M00711.1 = ,
        '"When a distinguished scientist states something is possible,'
        M00711.2 = ,
        'he is almost certainly right. When he states that'
        M00711.3 = ,
        'something is impossible, he is very probably wrong."'
        M00712.1 = ,
        '"Everyone gets away with something.'
        M00712.2 = ,
        'No one gets away with everything."'
        M00713.1 = ,
        '"Calm down .... It is only ones and zeros."'
        M00714.1 = ,
        '"Real programmers don''t write COBOL.'
        M00714.2 = ,
        'COBOL is for wimpy applications programmers."'
        M00715.1 = ,
        '"I have not lost my mind, it is backed up on tape somewhere."'
        M00716.1 = ,
        '"Real programmers do not document.'
        M00716.2 = ,
        'Documentation is for wimps who can''t read listings or'
        M00716.3 = ,
        'object code."'
        M00717.1 = ,
        '"Real programmers don''t write specs -- users should'
        M00717.2 = ,
        'consider themselves lucky to get any programs at all and'
        M00717.3 = ,
        'take what they get."'
        M00718.1 = ,
        '"Real programmers don''t comment their code. If it is hard'
        M00718.2 = ,
        'to write, it should be hard to understand."'
        M00719.1 = ,
        '"Real programmers don''t write applications programs; they'
        M00719.2 = ,
        'program right down on the bare metal.  Application'
        M00719.3 = ,
        'programming is for dwebs who can''t do systems programming."'
        M00720.1 = ,
        '"Real programmers don''t eat quiche.   In fact, real'
        M00720.2 = ,
        'programmers don''t know how to spell quiche. They eat'
        M00720.3 = ,
        'Twinkies and Szechwan food."'
        M00721.1 = ,
        '"Real programmer''s programs never work the first time. But'
        M00721.2 = ,
        'if you throw them on the machine, they can be patched into'
        M00721.3 = ,
        'working in ''only a few'' 30-hour debugging sessions."'
        M00722.1 = ,
        '"Real programmers don''t write in FORTRAN. FORTRAN is for'
        M00722.2 = ,
        'pipe stress freaks and crystallography weenies."'
        M00723.1 = ,
        '"Real programmers never work 9 to 5. If any real'
        M00723.2 = ,
        'programmers are around at 9 a.m., it''s because they'
        M00723.3 = ,
        'were up all night."'
        M00724.1 = ,
        '"Real programmers don''t write in BASIC. Actually, no'
        M00724.2 = ,
        'programmers write in BASIC after age 12."'
        M00725.1 = ,
        '"Real programmers don''t write in PL/1. PL/1 is for'
        M00725.2 = ,
        'programmers who can''t decide whether to write in'
        M00725.3 = ,
        'COBOL or FORTRAN."'
        M00726.1 = ,
        '"Real programmers don''t play tennis or any other sport'
        M00726.2 = ,
        'that requires you to change clothes. Mountain climbing is'
        M00726.3 = ,
        'OK, and real programmers wear their climbing boots to work'
        M00726.4 = ,
        'in case a mountain should suddenly spring up in the middle'
        M00726.5 = ,
        'of the machine room."'
        M00727.1 = ,
        '"Real programmers don''t write in PASCAL, BLISS, or ADA, or'
        M00727.2 = ,
        'any of those pinko computer science languages. Strong'
        M00727.3 = ,
        'typing is for people with weak memories."'
        M00728.1 = ,
        '"On a clear disk, you can seek forever."'
        M00729.1 = ,
        '"When things are going well, something will go wrong.'
        M00729.2 = ,
        'When things just can''t get any worse, they will.'
        M00729.3 = ,
        'When things appear to be going better you have overlooked someth'||,
        'ing."'
        M00730.1 = ,
        '"If project content is allowed to change freely, the rate of'
        M00730.2 = ,
        'change will exceed the rate of progress."'
        M00731.1 = ,
        '"No system is ever completely debugged: attempts to debug'
        M00731.2 = ,
        'a system will inevitably introduce new bugs that are even'
        M00731.3 = ,
        'harder to find."'
        M00732.1 = ,
        '"A carelessly planned project will take three times'
        M00732.2 = ,
        'longer than expected; a carefully planned project will'
        M00732.3 = ,
        'take only twice as long."'
        M00733.1 = ,
        '"After all is said and done, a hell of a lot more is said than done'||,
        '."'
        M00734.1 = ,
        '"If it''s not in the computer, it doesn''t exist."'
        M00735.1 = ,
        '"Never wrestle with a pig, you both get dirty, and the pig enjoys i'||,
        't!"'
        M00736.1 = ,
        '"Don''t fight with a bear in his own cage."'
        M00737.1 = ,
        '"An expert doesn''t know any more than you do. He or she is'
        M00737.2 = ,
        'merely better organized and uses slides."'
        M00738.1 = ,
        '"You can lead a horse to water, but if you can get him to'
        M00738.2 = ,
        'float on his back, you''ve really got something."'
        M00739.1 = ,
        '"People are promoted not by what they can do, but what people'||,
        ' think they can do."'
        M00740.1 = ,
        '"When the program is being tested, it is too late to make design ch'||,
        'anges."'
        M00741.1 = ,
        '"Matter can be neither created nor destroyed.  However, it can be l'||,
        'ost."'
        M00742.1 = ,
        '"There are two classes of travel in America: steerage, and'
        M00742.2 = ,
        'steerage with free drinks.  You pay a great deal extra for'
        M00742.3 = ,
        'the free drinks, of course."'
        M00743.1 = ,
        '"Experience is the worst teacher'
        M00743.2 = ,
        ' - it gives you the test before you''ve had a chance to study."'
        M00744.1 = ,
        '"If you can''t beat your computer at chess, try kickboxing."'
        M00745.1 = ,
        '"Eagles may soar, but weasels don''t get sucked into jet engines."'
        M00746.1 = ,
        '"If at first you don''t succeed, call it version 1.0"'
        M00747.1 = ,
        'The Law of Airplanes: "You will always get down..."'
        M00748.1 = ,
        '"Man will occasionally stumble over the truth, but most of the time'
        M00748.2 = ,
        'he will pick himself up and continue on."'
        M00749.1 = ,
        '"2 rules to success in life. 1. Don''t tell people everything you k'||,
        'now."'
        M00750.1 = ,
        '"A penny for your thoughts; $20 to act them out."'
        M00751.1 = ,
        '"All wiyht.  Rho sritched mg kegtops awound?"'
        M00752.1 = ,
        '"An effective way to deal with predators is to taste terrible."'
        M00753.1 = ,
        '"Fast, Cheap, Good:  Choose any two."'
        M00754.1 = ,
        '"Be civil to all; sociable to many; familiar with'
        M00754.2 = ,
          ' few; friend to one; enemy to none."'
        M00754.3 = ,
         "     Benjamin Franklin (1706 - 1790)"
        M00755.1 = ,
        '"Honesty is the best policy, but insanity is a better defense."'
        M00756.1 = ,
        '"If you can''t be replaced, you can''t be promoted."'
        M00757.1 = ,
        '"If ignorance is bliss, why aren''t there more happy people?"'
        M00758.1 = ,
        '"Make things as simple as possible, but not simpler." --Einstein'
        M00759.1 = ,
        '"Youth would be an ideal state if it came a little later in life."'
        M00759.2 = ,
        "   Herbert Henry Asquith"
        M00760.1 = ,
        '"We are each entitled to our own opinion,'
        M00760.2 = ,
        ' but no one is entitled to his own facts."'
        M00761.1 = ,
        '"Beware of people who know the answer before having understood the '||,
        'question."'
        M00762.1 = ,
        '"When things just can''t get any worse, they will."'
        M00763.1 = ,
        '"When things appear to be going better you have overlooked'
        M00763.2 = ,
        'something."'
        M00764.1 = ,
        '"I owe, I owe                                           '
        M00764.2 = ,
        'so it''s off to work I go."'
        M00765.1 = ,
        '"The three stages of being sick: Ill, pill, bill."'
        M00766.1 = ,
        '"Don''t try to teach a pig to sing.                    '
        M00766.2 = ,
        'It won''t work, and it annoys the pig."'
        M00767.1 = ,
        '"Only four things in life are certain:"               '
        M00767.2 = ,
        '    1.  Death                                          '
        M00767.3 = ,
        '    2.  Taxes                                          '
        M00767.4 = ,
        '    3.  IBM will dominate in mainframes                '
        M00767.5 = ,
        '    4.  IBM will once again jack up software prices    '
        M00768.1 = ,
        '"All the world loves a lover - except those who are     '
        M00768.2 = ,
        'waiting to use the phone."'
        M00769.1 = ,
        '"Talk is cheap - unless you hire a lawyer."'
        M00770.1 = ,
        '"In spite of the cost of living, it''s still popular."'
        M00771.1 = ,
        'In the approval cycle for an article:                 '
        M00771.2 = ,
        ' "The first  level of management will add a fact,      '
        M00771.3 = ,
        '  the second level of management will edit that fact,  '
        M00771.4 = ,
        '  the third  level of management will remove that fact."'
        M00772.1 = ,
        '"As soon as you sit down to a hot cup of coffee, your   '
        M00772.2 = ,
        'boss will ask you to do something that will last       '
        M00772.3 = ,
        'until the coffee is cold."'
        M00773.1 = ,
        'Murphy''s axiom of preventative divorce:              '
        M00773.2 = ,
        ' "An ounce of ''I don''t'' is worth                      '
        M00773.3 = ,
        '   megatons of ''I wish I didn''t''."'
        M00774.1 = ,
        '"If you''re not the lead dog the scenery never changes."'
        M00775.1 = ,
        '"A word to the wise is often enough to start an argument."'
        M00776.1 = ,
        '"A bird in the hand is bad table manners."'
        M00777.1 = ,
        '"Those who can, do. Those who can''t, write the instructions."'
        M00778.1 = ,
        '"Never serve meals on time; the starving eat anything."'
        M00779.1 = ,
        '"The time it takes to find something is directly.       '
        M00779.2 = ,
        'proportional to its importance."'
        M00780.1 = ,
        '"No major project is ever installed on time, within budgets,'
        M00780.2 = ,
        'or with the same staff that started it."'
        M00781.1 = ,
        ' "A door is what a dog is perpetually      '
        M00781.2 = ,
        '  on the wrong side of."                  '
        M00781.3 = ,
        '                                           '
        M00781.4 = ,
        '                                           '
        M00781.5 = ,
        '              Ogden Nash                   '
        M00782.1 = ,
        ' "Women are like elephants to me.          '
        M00782.2 = ,
        '  I like to look at them, but I           '
        M00782.3 = ,
        '  wouldn''t want to own one."             '
        M00782.4 = ,
        '                                           '
        M00782.5 = ,
        '              W.C. Fields.                 '
        M00783.1 = ,
        ' "The only grounds for divorce in          '
        M00783.2 = ,
        '  California are marriage."               '
        M00783.3 = ,
        '                                           '
        M00783.4 = ,
        '                                           '
        M00783.5 = ,
        '              Cher                         '
        M00784.1 = ,
        ' "Education is a method by which one       '
        M00784.2 = ,
        '  acquires a higher grade of              '
        M00784.3 = ,
        '  prejudices."                            '
        M00784.4 = ,
        '                                           '
        M00784.5 = ,
        '              Laurence J. Peter            '
        M00785.1 = ,
        ' "History is a set of lies                 '
        M00785.2 = ,
        '  agreed upon."                           '
        M00785.3 = ,
        '                                           '
        M00785.4 = ,
        '                                           '
        M00785.5 = ,
        '              Napoleon Bonaparte           '
        M00786.1 = ,
        ' "The best audience is one that is         '
        M00786.2 = ,
        '  intelligent, well-educated              '
        M00786.3 = ,
        '  -and a little drunk."                   '
        M00786.4 = ,
        '                                           '
        M00786.5 = ,
        '              Alben W. Barkley             '
        M00787.1 = ,
        ' "Beware of the man who goes to cocktail   '
        M00787.2 = ,
        '  parties not to drink but to listen."    '
        M00787.3 = ,
        '                                           '
        M00787.4 = ,
        '                                           '
        M00787.5 = ,
        '              Pierre Daninos               '
        M00788.1 = ,
        ' "One nice thing about egotists:           '
        M00788.2 = ,
        '  They don''t talk about other people."   '
        M00788.3 = ,
        '                                           '
        M00788.4 = ,
        '                                           '
        M00788.5 = ,
        '              Lucille S. Harper            '
        M00789.1 = ,
        ' "Everyone is a genius at least once a     '
        M00789.2 = ,
        '  year; a real genius has his original    '
        M00789.3 = ,
        '  ideas closer together."                 '
        M00789.4 = ,
        '                                           '
        M00789.5 = ,
        '              G.C. Lichtenberg             '
        M00790.1 = ,
        ' "Abraham Lincoln wrote the Gettysburg     '
        M00790.2 = ,
        '  address while travelling from           '
        M00790.3 = ,
        '  Washington to Gettysburg on the back    '
        M00790.4 = ,
        '  of an envelope." (Sic)                  '
        M00790.5 = ,
        '              Louis Untermeyer             '
        M00791.1 = ,
        ' "The difference between a politician and  '
        M00791.2 = ,
        '  a statesman is: A politician thinks     '
        M00791.3 = ,
        '  of the next election and a statesman    '
        M00791.4 = ,
        '  thinks of the next generation."         '
        M00791.5 = ,
        '              James Freeman Clarke         '
        M00792.1 = ,
        ' "Sanity is madness put to good use."      '
        M00792.2 = ,
        '                                           '
        M00792.3 = ,
        '                                           '
        M00792.4 = ,
        '                                           '
        M00792.5 = ,
        '              George Santayana             '
        M00793.1 = ,
        ' "The end move in politics is always       '
        M00793.2 = ,
        '  to pick up the gun."                    '
        M00793.3 = ,
        '                                           '
        M00793.4 = ,
        '                                           '
        M00793.5 = ,
        '               Buckminster Fuller          '
        M00794.1 = ,
        ' "To many people dramatic criticism must   '
        M00794.2 = ,
        '  be like trying to tattoo soap bubbles." '
        M00794.3 = ,
        '                                           '
        M00794.4 = ,
        '                                           '
        M00794.5 = ,
        '              John Mason Brown             '
        M00795.1 = ,
        ' "A fool and his money are soon parted."   '
        M00795.2 = ,
        '              James Howell                 '
        M00796.1 = ,
        ' "I know only two tunes: One of them is    '
        M00796.2 = ,
        '  ''Yankee Doodle'', and the other        '
        M00796.3 = ,
        '  isn''t."                                '
        M00796.4 = ,
        '                                           '
        M00796.5 = ,
        '              Ulysses S. Grant             '
        M00797.1 = ,
        'Umbrella law:                             '
        M00797.2 = ,
        '  "You will need three umbrellas:          '
        M00797.3 = ,
        '   One to leave at the office, one to     '
        M00797.4 = ,
        '   leave at home, and one to leave on the '
        M00797.5 = ,
        '   train."                                '
        M00798.1 = ,
        'Bell''s rule. "The average time between   '
        M00798.2 = ,
        '   throwing something away and needing it  '
        M00798.3 = ,
        '   badly is two weeks.  This time can be   '
        M00798.4 = ,
        '   reduced to one week by retaining the    '
        M00798.5 = ,
        '   thing for a long time first."           '
        M00799.1 = ,
        'Ogden''s law:                             '
        M00799.2 = ,
        '   "The sooner you fall behind, the more   '
        M00799.3 = ,
        '    time you have to catch up."      '
        M00799.4 = ,
        '                                           '
        M00799.5 = ,
        '                                           '
        M00800.1 = ,
        'Berra''s law:                             '
        M00800.2 = ,
        '  "You can observe a lot just by watching."'
        M00800.3 = ,
        '                                           '
        M00801.1 = ,
        ' "Gross ignorance: 144 Times worse than    '
        M00801.2 = ,
        '  ordinary ignorance."                     '
        M00801.3 = ,
        '               Bennett Cerf                '
        M00802.1 = ,
        ' "Oh, to be in England                     '
        M00802.2 = ,
        '  now that April''s there."               '
        M00802.3 = ,
        '                                           '
        M00802.4 = ,
        '                                           '
        M00802.5 = ,
        '               Robert Browning             '
        M00803.1 = ,
        ' "If a playwright is funny, the English    '
        M00803.2 = ,
        '  look for a serious message, and if he''s'
        M00803.3 = ,
        '  serious, they look for the joke."       '
        M00803.4 = ,
        '                                           '
        M00803.5 = ,
        '               Sacha Guitry                '
        M00804.1 = ,
        ' "At no time is freedom of speech more     '
        M00804.2 = ,
        '  precious than when a man hits his       '
        M00804.3 = ,
        '  thumb with a hammer."                   '
        M00804.4 = ,
        '                                           '
        M00804.5 = ,
        '               Marshall Lumsden            '
        M00805.1 = ,
        ' "I''m a great believer in luck,           '
        M00805.2 = ,
        '  and I find the harder I work the more   '
        M00805.3 = ,
        '  I have of it."                          '
        M00805.4 = ,
        '                                           '
        M00805.5 = ,
        '               Thomas Jefferson            '
        M00806.1 = ,
        ' "One fifth of the people are against      '
        M00806.2 = ,
        '  everything all the time."        R.F.K. '
        M00807.1 = ,
        ' "Is there such a thing as shoppers        '
        M00807.2 = ,
        '  anonymous?"                             '
        M00807.3 = ,
        '                                           '
        M00807.4 = ,
        '   John F. Kennedy, on receiving a $40,000 '
        M00807.5 = ,
        '             bill for his wife''s clothes. '
        M00808.1 = ,
        ' "Most people like hard work.              '
        M00808.2 = ,
        '  Particularly when they are              '
        M00808.3 = ,
        '  paying for it."                         '
        M00808.4 = ,
        '                                           '
        M00808.5 = ,
        '               Franklin P. Jones           '
        M00809.1 = ,
        ' "Computers can figure out all kinds of    '
        M00809.2 = ,
        '  problems, except the things that        '
        M00809.3 = ,
        '  just don''t add up."                    '
        M00809.4 = ,
        '                                           '
        M00809.5 = ,
        '               James Magary                '
        M00810.1 = ,
        ' "If all men knew what each said of the    '
        M00810.2 = ,
        '  other, there would not be four friends  '
        M00810.3 = ,
        '  in the world."                          '
        M00810.4 = ,
        '                                           '
        M00810.5 = ,
        '               Blaise Pascal               '
        M00811.1 = ,
        ' "It makes no difference who you vote for--'
        M00811.2 = ,
        '  the two parties are really one party    '
        M00811.3 = ,
        '  representing 4 percent of the people."  '
        M00811.4 = ,
        '                                           '
        M00811.5 = ,
        '               Gore Vidal                  '
        M00812.1 = ,
        '"Manufacturers rebate - company''s way of letting you   '
        M00812.2 = ,
        'know you''ve been overcharged."'
        M00813.1 = ,
        '"Trust everybody but cut the cards."'
        M00814.1 = ,
        '"The best helping hand I ever got '
        M00814.2 = ,
        'was at the end of my own arm."'
        M00815.1 = ,
        '"Never put off until tomorrow what you can do the       '
        M00815.2 = ,
        'day after."'
        M00816.1 = ,
        '"A cliche is only something well said in the first place."'
        M00817.1 = ,
        '"If you can''t be kind, at least be vague."'
        M00818.1 = ,
        '"All progress is based upon a universal innate desire on'
        M00818.2 = ,
        'the part of every organism to live beyond its income."'
        M00819.1 = ,
        '"One good reason why computers can do more work than    '
        M00819.2 = ,
        'people is that they never have to stop and answer      '
        M00819.3 = ,
        'the phone."'
        M00820.1 = ,
        '"VSAM is a four letter word."'
        M00821.1 = ,
        '"The likelihood of someone doing 50 mph in the fast     '
        M00821.2 = ,
        'lane is directly proportional to how late you are      '
        M00821.3 = ,
        'for work."'
        M00822.1 = ,
        '"The chances of someone making a right turn from the    '
        M00822.2 = ,
        'left-turn lane are a constant one in three."'
        M00823.1 = ,
        '"The chances of the individual making this turn while  '
        M00823.2 = ,
        'flashing his left turn signal are a constant one in six."'
        M00824.1 = ,
        '"If there is any possibility of installing a part       '
        M00824.2 = ,
        'backwards, that''s the only way it will look correct."'
        M00825.1 = ,
        '"The world is full of willing people, some willing to   '
        M00825.2 = ,
        'work, the rest willing to let them."'
        M00826.1 = ,
        '"My father taught me to work, he did not teach me to    '
        M00826.2 = ,
        'love it."'
        M00827.1 = ,
        '"Work is the greatest thing in the world, so we should  '
        M00827.2 = ,
        'always save some of it for tomorrow."'
        M00828.1 = ,
        '"If your project doesn''t work, look for the part you   '
        M00828.2 = ,
        'didn''t think was important."'
        M00829.1 = ,
        '"If you''re early, it will be cancelled. It you''re on  '
        M00829.2 = ,
        'time it will be over."'
        M00830.1 = ,
        '"Any bureaucracy reorganized to enhance efficiency is   '
        M00830.2 = ,
        'immediately indistinguishable from its predecessor."'
        M00831.1 = ,
        '"Any order that can be misunderstood has been           '
        M00831.2 = ,
        'misunderstood."'
        M00832.1 = ,
        '"There is always room at the top - after an investigation."'
        M00833.1 = ,
        '"There are two types of people :                        '
        M00833.2 = ,
        '    Those who divide people into two groups            '
        M00833.3 = ,
        '    and those who don''t."'
        M00834.1 = ,
        '"You are always complimented on the dish that took the  '
        M00834.2 = ,
        'least effort to prepare."'
        M00835.1 = ,
        '"The person with the least expertise has the most opinions."'
        M00836.1 = ,
        '"After you''ve mailed your last Christmas card, you     '
        M00836.2 = ,
        'will receive one from someone you''ve overlooked."'
        M00837.1 = ,
        '"If it weren''t for the last minute, nothing would      '
        M00837.2 = ,
        'ever get done."'
        M00838.1 = ,
        '"Unbreakable toys aren''t."'
        M00839.1 = ,
        '"Nothing is as inevitable as a mistake whose time       '
        M00839.2 = ,
        'has come."'
        M00840.1 = ,
        '"The most expensive component is the one that breaks."'
        M00841.1 = ,
        '"It requires less energy to take an object out of its   '
        M00841.2 = ,
        'proper place than to put it back."'
        M00842.1 = ,
        '"2 wrongs are only the beginning."'
        M00843.1 = ,
        '"Government corruption will be reported in the past tense."'
        M00844.1 = ,
        '"Nobody notices the big errors."'
        M00845.1 = ,
        '"The one time you relax is the one time the boss walks  '
        M00845.2 = ,
        'into your office."'
        M00846.1 = ,
        '"A dandelion from a lover means more than an orchid     '
        M00846.2 = ,
        'from a friend."'
        M00847.1 = ,
        '"No matter how often a lie is proven to be false, there '
        M00847.2 = ,
        'will be people who believe it to be true."'
        M00848.1 = ,
        '"Only God can make a random selection."'
        M00849.1 = ,
        '"Everything put together falls apart sooner or later."'
        M00850.1 = ,
        '"When people are free to do as they please, they        '
        M00850.2 = ,
        'usually imitate each other."'
        M00851.1 = ,
        'Iron law of distribution:                              '
        M00851.2 = ,
        ' "Them that has, gets."'
        M00852.1 = ,
        '"When parking, if you allow someone in front of you,    '
        M00852.2 = ,
        'that driver will take the last available parking space."'
        M00853.1 = ,
        '"Of two possible events, only the undesired one will occur."'
        M00854.1 = ,
        '"There is nothing so small that it can''t be blown      '
        M00854.2 = ,
        'out of proportion."'
        M00855.1 = ,
        '"As soon as you''re doing what you wanted to be doing,  '
        M00855.2 = ,
        'you want to be doing something else."'
        M00856.1 = ,
        '"Anything can happen, if it''s not covered by your      '
        M00856.2 = ,
        'insurance."'
        M00857.1 = ,
        '"The shopping cart with the worst wheels is the one     '
        M00857.2 = ,
        'you chose."'
        M00858.1 = ,
        '"Doing it the hard way is always easier."'
        M00859.1 = ,
        '"Wisdom consists of knowing when to avoid perfection."'
        M00860.1 = ,
        '"The driver behind you always wants to go faster        '
        M00860.2 = ,
        'than you do."'
        M00861.1 = ,
        '"If it looks easy, it''s tough, if it looks tough,      '
        M00861.2 = ,
        'it''s impossible."'
        M00862.1 = ,
        '"The lightest-colored fabric attracts the               '
        M00862.2 = ,
        ' darkest-colored stain."'
        M00863.1 = ,
        '"If you understand it, it''s obsolete."'
        M00864.1 = ,
        '"Every solution breeds new problems."'
        M00865.1 = ,
        '"When you try to prove to someone that a machine        '
        M00865.2 = ,
        'won''t work, it will."'
        M00866.1 = ,
        '"Whenever you set out to do something, something else   '
        M00866.2 = ,
        'must be done first."'
        M00867.1 = ,
        '"Any simple problem can be made insoluble if enough     '
        M00867.2 = ,
        'meetings are held to discuss it."'
        M00868.1 = ,
        '"Anything that can be changed will be changed until     '
        M00868.2 = ,
        'there is no time left to change anything."'
        M00869.1 = ,
        '"No post office ever loses your junk mail."'
        M00870.1 = ,
        '"No matter how well you perform your job, a superior    '
        M00870.2 = ,
        'will seek to modify the results."'
        M00871.1 = ,
        '"If something is confidential it will be left           '
        M00871.2 = ,
        'in the copier."'
        M00872.1 = ,
        '"Tall people have higher standards."'
        M00873.1 = ,
        '"What can you expect of a day that begins with getting  '
        M00873.2 = ,
        'up in the morning."'
        M00874.1 = ,
        '"Age is a state of mind.                                '
        M00874.2 = ,
        'Don''t ask me what state I''m in."'
        M00875.1 = ,
        '"I''m not deaf,                                         '
        M00875.2 = ,
        'l''m ignoring you."'
        M00876.1 = ,
        '"I refuse to have a battle of wits with an             '
        M00876.2 = ,
        'unarmed person."'
        M00877.1 = ,
        '"Age is not important unless you''re a bottle of wine."'
        M00878.1 = ,
        '"Life is too short to drink cheap wine."'
        M00879.1 = ,
        '"Neurotics build castles in the sky, '
        M00879.2 = ,
        'psychotics live in them,                               '
        M00879.3 = ,
        'psychologists collect the rent."'
        M00880.1 = ,
        '"Lindberg was the first man to fly the Atlantic alone   '
        M00880.2 = ,
        'and the last to arrive the same time as his luggage."'
        M00881.1 = ,
        '"Lightning is said to never strike twice in the same place'
        M00881.2 = ,
        'unless, of course, you let your insurance lapse."'
        M00882.1 = ,
        '"Always remember that we pass this way but once, unless '
        M00882.2 = ,
        'your spouse is reading the road map."'
        M00883.1 = ,
        '"The same work under the same conditions will be        '
        M00883.2 = ,
        'estimated differently by ten different estimators      '
        M00883.3 = ,
        'or by one estimator at ten different times."'
        M00884.1 = ,
        '"The most valuable and least used word in a project   '
        M00884.2 = ,
        'manager''s vocabulary is ''no''."'
        M00885.1 = ,
        '"You can con a sucker into committing to an unreasonable'
        M00885.2 = ,
        'deadline, but you can''t bully him into meeting it."'
        M00886.1 = ,
        '"The more ridiculous the deadline, the more it costs to '
        M00886.2 = ,
        'try to meet it."'
        M00887.1 = ,
        '"You can freeze the user''s specs but he won''t         '
        M00887.2 = ,
        'stop expecting."'
        M00888.1 = ,
        '"Frozen specs and the abominable snowman are alike:     '
        M00888.2 = ,
        'They are both myth and they both melt when sufficient  '
        M00888.3 = ,
        'heat is applied."'
        M00889.1 = ,
        '"The conditions attached to a promise are forgotten     '
        M00889.2 = ,
        'and the promise is remembered."'
        M00890.1 = ,
        '"A user will tell you anything you ask about, but nothing '
        M00890.2 = ,
        'more."'
        M00891.1 = ,
        '"Of several possible interpretations of a communication '
        M00891.2 = ,
        'the least convenient one is the only correct one."'
        M00892.1 = ,
        '"What is not on paper has not been said."'
        M00893.1 = ,
        '"Those who flee temptation generally leave a            '
        M00893.2 = ,
        'forwarding address."'
        M00894.1 = ,
        '"If one thing breaks, another thing mysteriously       '
        M00894.2 = ,
        'resumes working."'
        M00895.1 = ,
        '"One thing that''s good about procrastination is that   '
        M00895.2 = ,
        'you always have something planned for tomorrow."'
        M00896.1 = ,
        '"Every morning I get up and look through the Forbes    '
        M00896.2 = ,
        'list of the richest people in America. If I''m not     '
        M00896.3 = ,
        'there, I go to work."'
        M00897.1 = ,
        '"People who arrive late for the theater never have     '
        M00897.2 = ,
        'aisle seats."'
        M00898.1 = ,
        '"The nice thing about buying beer is that no one ever   '
        M00898.2 = ,
        'asks what year you want."'
        M00899.1 = ,
        '"He''s the kind of friend you can depend on - always    '
        M00899.2 = ,
        'around when he needs you."'
        M00900.1 = ,
        '"Anyone who says he can see through women is missing a lot."'
        M00901.1 = ,
        '"My program   - a gem of algoristic precision, offering '
        M00901.2 = ,
        'the most sublime balance between compact, efficient  '
        M00901.3 = ,
        'coding on the one hand, and fully commented legibility'
        M00901.4 = ,
        'for posterity on the other.                          '
        M00901.5 = ,
        'Your program - a maze of non sequiturs littered with   '
        M00901.6 = ,
        'clever-clever tricks and irrelevant comments."'
        M00902.1 = ,
        ' "Start every day off with a smile and     '
        M00902.2 = ,
        '  get it over with."                      '
        M00902.3 = ,
        '                                           '
        M00902.4 = ,
        '              W.C. Fields.                 '
        M00903.1 = ,
        '"Truth emerges more readily from error than from confusion."'
        M00904.1 = ,
        '"People will generally accept facts as truth only if    '
        M00904.2 = ,
        'the facts agree with what they already believe."'
        M00905.1 = ,
        '"Getting up early in the morning is a good way to gain  '
        M00905.2 = ,
        'respect without ever actually having to do anything."'
        M00906.1 = ,
        '"No matter how big the umbrella you carry or how good   '
        M00906.2 = ,
        'your raincoat is, if it rains you get wet."'
        M00907.1 = ,
        '"If dogs could talk, it would take a lot of fun out of  '
        M00907.2 = ,
        'owning one."'
        M00908.1 = ,
        '"We''re all proud of admitting little mistakes. It gives'
        M00908.2 = ,
        'us the feeling we don''t make any big ones."'
        M00909.1 = ,
        '"People who are wrong seem to talk louder than anyone else."'
        M00910.1 = ,
        '"There aren''t many times in your life when your body   '
        M00910.2 = ,
        'has absolutely nothing wrong with it."'
        M00911.1 = ,
        '"Vacations aren''t necessarily better than other times, '
        M00911.2 = ,
        'they''re just different."'
        M00912.1 = ,
        '"Key ring - a device for losing all your keys at once."'
        M00913.1 = ,
        '"A consultant is someone who borrows your watch, then   '
        M00913.2 = ,
        'gives you the time."'
        M00914.1 = ,
        '"People who write subsystems usually use four letter words."'
        M00915.1 = ,
        '"Hypocrisy is the homage that vice pays to virtue."'
        M00916.1 = ,
        '"He who laughs last probably has a backup."'
        M00917.1 = ,
        '"The worst way to make an argument is by reason and     '
        M00917.2 = ,
        'good information.  You must appeal to people''s       '
        M00917.3 = ,
        'emotions and to their fears of being made to          '
        M00917.4 = ,
        'look ridiculous."'
        M00918.1 = ,
        '"Few things are more satisfying than seeing your        '
        M00918.2 = ,
        'children have teenagers of their own."'
        M00919.1 = ,
        '"The optimist is the kind of person who believes a      '
        M00919.2 = ,
        'housefly is looking for a way out."'
        M00920.1 = ,
        '"With proper sleep, diet and care, a healthy body       '
        M00920.2 = ,
        'will last a lifetime."'
        M00921.1 = ,
        '"If you wait for a repairman, you''ll wait all day.     '
        M00921.2 = ,
        'If you go out for five minutes, he''ll arrive and     '
        M00921.3 = ,
        'leave while you''re gone."'
        M00922.1 = ,
        '"People who have the most birthdays live the longest."'
        M00923.1 = ,
        '"If a severe problem manifests itself, no solution is   '
        M00923.2 = ,
        'acceptable unless it is involved, expensive and       '
        M00923.3 = ,
        'time consuming."'
        M00924.1 = ,
        '"Everything takes longer than it takes."'
        M00925.1 = ,
        '"Nothing is impossible for the person who doesn''t      '
        M00925.2 = ,
        'have to do it."'
        M00926.1 = ,
        '"In God we trust. All others we polygraph."'
        M00927.1 = ,
        '"It''s the luck of the draw:                            '
        M00927.2 = ,
        '   Sometimes you get the elevator                      '
        M00927.3 = ,
        '   sometimes you get the shaft."'
        M00928.1 = ,
        '"If you don''t find me here look there.'
        M00928.2 = ,
        'If I''m not there then try somewhere else.'
        M00928.3 = ,
        'If you still can''t find me then I don''t want to be found."'
        M00929.1 = ,
        '"Management is where programmers go when'
        M00929.2 = ,
        'they have forgotten how to program."'
        M00930.1 = ,
        '"Programmers are the workers.'
        M00930.2 = ,
        'Management is what is left over."'
        M00931.1 = ,
        '"The day your ship comes in'
        M00931.2 = ,
        'you will probably be at the airport."'
        M00932.1 = ,
        '"Never argue with an idiot: People watching may not be  '
        M00932.2 = ,
        'able to tell the difference."'
        M00933.1 = ,
        '"The six steps of program management are:               '
        M00933.2 = ,
        '     1. Wild enthusiasm                                '
        M00933.3 = ,
        '     2. Disenchantment                                 '
        M00933.4 = ,
        '     3. Total confusion                                '
        M00933.5 = ,
        '     4. Search for the guilty                          '
        M00933.6 = ,
        '     5. Punishment of the innocent                     '
        M00933.7 = ,
        '     6. Promotion of the non-participants"'
        M00934.1 = ,
        '"The only thing we learn from history is that we learn  '
        M00934.2 = ,
        'nothing from history."'
        M00935.1 = ,
        '"Humpty Dumpty was pushed."'
        M00936.1 = ,
        '"Forgetfulness is a sign of genius,                    '
        M00936.2 = ,
        'but I forgot who said it."'
        M00937.1 = ,
        '"The great debugger is..........                       '
        M00937.2 = ,
        '   Methodical, persistent ''detective'' searching out    '
        M00937.3 = ,
        '   the guilty perpetrators of programming crimes."'
        M00938.1 = ,
        '"The great debugger is..........                       '
        M00938.2 = ,
        '   Looking for the proverbial needle-in-the-haystack;  '
        M00938.3 = ,
        '   a bug is only a few bits out of 100 million zeroes  '
        M00938.4 = ,
        '   and ones."'
        M00939.1 = ,
        '"Definition of an upgrade: take old bugs out, put new ones in."'
        M00940.1 = ,
        '"Don''t anthropomorphize machines. They hate that."'
        M00941.1 = ,
        '"The nice thing about standards is that there are so many to"'
        M00941.2 = ,
        '"choose from."'
        M00942.1 = ,
        '"Nobody is so busy as the one who has nothing to do."'
        M00943.1 = ,
        '"A leisure class exists at both ends of the economic spectrum."'
        M00944.1 = ,
        ' "Opportunity is missed by most people because'
        M00944.2 = ,
        '  it is dressed in overalls and looks like work."'
        M00944.3 = ,
        '                                           '
        M00944.4 = ,
        '              Thomas Edison                '
        M00945.1 = ,
        '"If at first you don''t succeed, redefine success."'
        M00946.1 = ,
        '"You cannot solve a problem with the tools that created it."'
        M00946.2 = ,
        '              Albert Einstein              '
        M00947.1 = ,
        '"It is a good rule not to put too much confidence in experimental'
        M00947.2 = ,
        'results until they have been confirmed by theory."'
        M00948.1 = ,
        '"It is not possible to awaken someone who is pretending to be asleep."'
        M00948.2 = ,
        '  (Navajo proverb)'
        M00949.1 = ,
        '"The customer has a choice...as long as he chooses." -- Henry Ford'
        M00950.1 = ,
        '"Well-timed silence hath more eloquence than speech."'
        M00950.2 = ,
        '   Martin Fraquhar Tupper'
        M00951.1 = ,
        '"If you don''t learn to laugh at trouble, you won''t'
        M00951.2 = ,
        ' have anything to laugh at when you''re old."'
        M00951.3 = ,
        '   Ed Howe'
        M00952.1 = ,
        '   "Oh, Bother!" said the Borg.  "We have assimilated Pooh...."'
        M00952.2 = ,
        '   Unknown'
        M00953.1 = ,
        "  Don't get suckered in by the comments -- they can be terribly"
        M00953.2 = ,
        "  misleading.  Debug only code. "
        M00953.3 = ,
        '                  -- Dave Storer'
        M00954.1 = ,
        '"Work expands so as to fill the time available for its completion."'
        M00954.2 = ,
        "                  -- C. Northcote Parkinson"
        M00955.1 = ,
        '"Transistor density on a manufactured semiconductor die'
        M00955.2 = ,
        ' doubles about every 18 months."'
        M00955.3 = ,
        "                  -- Gordon Moore"
        M00956.1 = ,
        '"Adding manpower to a late software project makes it later."'
        M00956.2 = ,
        "                  -- Frederick P. Brooks Jr."
        M00957.1 = ,
        '"When you make a mistake, admit it.'
        M00957.2 = ,
        ' If you don''t, you only make matters worse."'
        M00957.3 = ,
        "                     Ward Cleaver"
        M00958.1 = ,
        '"Never do today what you can put off till tomorrow.'
        M00958.2 = ,
        ' Delay may give clearer light as to what is best to be done."'
        M00958.3 = ,
        "                     Aaron Burr"
        M00959.1 = ,
        '"Eighty percent of success is showing up."'
        M00959.2 = ,
        "                 Woody Allen"
        M00960.1 = ,
        '"Many of life''s failures are people who did not realize'
        M00960.2 = ,
        ' how close they were to success when they gave up."'
        M00960.3 = ,
        "            -- Thomas A. Edison"
        m00961.1 = '"Those are my principles. If you don''t like'
        m00961.2 = ' them I have others."'
        m00961.3 = "        Groucho Marx"
        m00962.1 = "Never argue with an idiot."
        m00962.2 = "They drag you down to their level,"
        m00962.3 = "then beat you with experience."

        m00963.1 = '"Imagination was given to man to compensate him' ,
                   "for what he is not;"
        m00963.2 = ' a sense of humor to console him for what he is."'
        m00963.3 = "        Sir Francis Bacon (1561-1626)"

        m00964.1 = "Daffy Definition for Chickens:"
        m00964.2 = " The only animals you eat before they are born" ,
                   "and after they are dead."

        m00965.1 = "Daffy Definition for Budget:"
        m00965.2 = " A method for going broke methodically."

        m00966.1 = "Daffy Definition for Boat:"
        m00966.2 = " A hole in the water surrounded by wood into",
                   "which one pours money."

        m00967.1 = "Daffy Definition for Bachelor:"
        m00967.2 = " One who treats all women as sequels."

        m00968.1 = "Daffy Definition for Cigarette:"
        m00968.2 = " A pinch of tobacco, wrapped in paper, fire at",
                   "one end, fool at the other."

        m00969.1 = "Daffy Definition for Flashlight:"
        m00969.2 = " A case for holding dead batteries."

        m00970.1 = "Daffy Definition for Taxpayer:"
        m00970.2 = " Someone who doesn't have to take a public service",
                   "exam to work for the government."

        m00971.1 = "Daffy Definition for Consciousness:"
        m00971.2 = " That annoying time between naps."

        m00972.1 = "Daffy Definition for Stress:"
        m00972.2 = " The confusion created when ones mind overrides",
                   "the body's basic desire"
        m00972.3 = " to choke the living daylights out of some idiot",
                   "who desperately needs it."

        m00973.1 = "Daffy Definition for Adult:"
        m00973.2 = " A person who has stopped growing at both ends"
        m00973.3 = " and is now growing in the middle."

        m00974.1 = "'There are known knowns. These are things we know"
        m00974.2 = " that we know.  There are known unknowns. That is"
        m00974.3 = " to say, there are things that we know we don't"
        m00974.4 = " know. But there are also unknown unknowns. There"
        m00974.5 = " are things we don't know we don't know.'"
        m00974.6 = " "
        m00974.7 = "-- Secretary of Defense Donald Rumsfeld"

        m00975.1 = 'They who have reasoned ignorantly, or who have'
        m00975.2 = 'aimed at effecting their personal ends by'
        m00975.3 = 'flattering the popular feeling, have  boldly'
        m00975.4 = 'affirmed that "one man is as good as another"; a'
        m00975.5 = 'maxim that is true in neither nature, revealed'
        m00975.6 = 'morals, nor political theory.'
        m00975.7 = ' '
        m00975.8 = '-- James Fenimore Cooper'

        m00976.1 = '"Great Minds discuss ideas.  Average minds discuss'
        m00976.2 = 'events.  Small minds discuss people."'
        m00976.3 = ' '
        m00976.4 = '-- Admiral Hyman Rickover'

        m00977.1 = "Dog's have owners. Cat's have servants."

        m00978.1 = "If you find yourself in a hole, the" ,
                   "first thing to do is stop  diggin."
        m00978.2 = "-- Will Rogers"

        m00979.1 = "When you go home,"
        m00979.2 = "Tell them of us and say,"
        m00979.3 = "For their tomorrow,"
        m00979.4 = "We gave our today. "
        m00979.5 = "--The Kohima Epitaph"

        m00980.1 = "Some people wonder all their lives if they've"
        m00980.2 = "made a difference. The Marines don't have that"
        m00980.3 = "problem."
        m00980.4 = "-- President Ronald Reagan (1911 - 2004)"

        m00981.1 = "There was never a good war or a bad peace."
        m00981.2 = "-- Benjamin Franklin"

        m00982.1 = "Uncommon valor was a common virtue."
        m00982.2 = "-- Admiral Chester Nimitz"

        m00983.1 = "Snowmen fall from heaven unassembled."

        m00984.1 = "I don't approve of political jokes."
        m00984.2 = "I've seen too many of them get elected."

        m00985.1 = " I'm a great believer in luck, and I find"
        m00985.2 = " the harder I work the more I have of it. "
        m00985.3 = "           -- Thomas Jefferson"

        m00986.1 = "Thousands of years ago, cats were worshipped" ,
                   "as gods."
        m00986.2 = "Cats have never forgotten this."
        m00986.3 = "    ... Anonymous"

        m00987.1 = "He who asks is a fool for five minutes,"
        m00987.2 = "but he who does not ask remains a fool forever."
        m00987.3 = " ... Chinese Proverb"

        m00988.1 = "A bicycle can't stand alone because it is two-tired."

        m00989.1 = "What's the definition of a will?"
        m00989.2 = "(It's a dead giveaway)."

        m00990.1 = "Time flies like an arrow. Fruit flies like a banana."

        m00991.1 = "A backward poet writes inverse."

        m00992.1 = "In democracy it's your vote that counts;"
        m00992.2 = "In feudalism, it's your count that votes."

        m00993.1 = "A chicken crossing the road is poultry in motion."

        m00994.1 = "If you don't pay your exorcist you get repossessed."

        m00995.1 = "With her marriage she got a new name and a dress."

        m00996.1 = "Show me a piano falling down a mineshaft"
        m00996.2 = "and I'll show you A-flat minor."

        m00997.1 = "When a clock is hungry it goes back four seconds."

        m00998.1 = "The man who fell into an upholstery machine"
        m00998.2 = "is fully recovered."

        m00999.1 = "A grenade thrown into a kitchen in France"
        m00999.2 = "would result in Linoleum Blownapart."

        m01000.1 = "You feel stuck with your debt if you can't budge it."

        m01001.1 = "Local Area Network in Australia: the LAN down under. "

        m01002.1 = "He often broke into song because"
        m01002.2 = "he couldn't find the key."

        m01003.1 = "Every calendar's days are numbered."

        m01004.1 = "A lot of money is tainted."
        m01004.2 = "'Taint yours and 'taint mine."

        m01005.1 = "A boiled egg in the morning is hard to beat."

        m01006.1 = "He had a photographic memory which was never developed."

        m01007.1 = "A plateau is a high form of flattery."

        m01008.1 = "The short fortuneteller who escaped from prison"
        m01008.2 = "was a small medium at large."

        m01009.1 = "Those who get too big for their britches"
        m01009.2 = "will be exposed in the end."

        m01010.1 = "When you've seen one shopping center"
        m01010.2 = "you've seen a mall."

        m01011.1 = "Those who jump off a Paris bridge are in Seine."

        m01012.1 = "When an actress saw her first strands of gray hair"
        m01012.2 = "she thought she'd dye."

        m01013.1 = "Bakers trade bread recipes on a knead to know basis."

        m01014.1 = "Santa's helpers are subordinate clauses."

        m01015.1 = "Acupuncture is a jab well done."

        m01016.1 = "Marathon runners with bad footwear"
        m01016.2 = "suffer the agony of defeat."

        m01017.1 = "The only way to have a friend is to be one."
        m01017.2 = "... Ralph Waldo Emerson (1803 - 1882)"

        m01018.1 = "Experience is a hard teacher"
        m01018.2 = "because she gives the test first,"
        m01018.3 = "the lesson afterwards."
        m01018.4 = "... Vernon Sanders Law"

        m01019.1 = "'Never tell people how to do things. Tell"
        m01019.2 = " them what to do and they will surprise you"
        m01019.3 = " with their ingenuity.'"
        m01019.4 = " George S. Patton (1885 - 1945)"

        m01020.1 = "'Take calculated risks. That is quite"
        m01020.2 = " different from being rash.'"
        m01020.3 = " George S. Patton (1885 - 1945)"

        m01021.1 = "'Success is measured on how high you bounce"
        m01021.2 = " once you've hit rock bottom.'"
        m01021.3 = " George S. Patton (1885 - 1945)"

        m01022.1 = "'The only good is knowledge and"
        m01022.2 = " the only evil is ignorance.'"
        m01022.3 = " Socrates (469 BC - 399 BC)"

        m01023.1 = "'Fall seven times, stand up eight.'"
        m01023.2 = " Japanese Proverb"

        m01024.1 = "'Toil to make yourself remarkable by"
        m01024.2 = " some talent or other.'"
        m01024.3 = " Seneca (5 BC - 65 AD)"

        m01025.1 = "'An intellectual is a man who takes"
        m01025.2 = " more words than necessary to tell more"
        m01025.3 = " than he knows.'"
        m01025.4 = " Dwight D. Eisenhower (1890 - 1969)"

        m01026.1 = "'Things are more like they are now"
        m01026.2 = " than they ever were before.'"
        m01026.3 = " Dwight D. Eisenhower (1890 - 1969)"

        m01027.1 = "'Politics is supposed to be the second oldest"
        m01027.2 = " profession. I have come to realize that it"
        m01027.3 = " bears a very close resemblance to the first.'"
        m01027.4 =   "-- President Ronald Reagan (1911 - 2004)"

        m01028.1 = "'In my many years I have come to a conclusion"
        m01028.2 = " that one man is a shame, two is a lawfirm,"
        m01028.3 = " and three or more is a congress.'"
        m01028.4 = " John Adams (1735 - 1826)"

        m01029.1 = "'All men profess honesty as long as they can."
        m01029.2 = " To believe all men honest would be folly."
        m01029.3 = " To believe none so is something worse.'"
        m01029.4 = " John Quincy Adams (1767 - 1848)"

        m01030.1 = "'There is no security on this earth,"
        m01030.2 = " there is only opportunity.'"
        m01030.4 = " General Douglas MacArthur (1880 - 1964)"

        m01031.1 = "You can't get there from not here."

        m01032.1 = "Flexibility happens in wetwear not in hardware."

        m01033.1 = "Status quo, you know, that is Latin for" ,
                   '"the mess we'"'"'re in."'
        m01033.2 = " -- President Ronald Reagan (1911 - 2004)"

        m01034.1 = "There's no limit to what a man can do or where he"
        m01034.2 = "can go if he doesn't mind who gets the credit."
        m01034.3 = " -- President Ronald Reagan (1911 - 2004)"

        m01035.1 = "It ain't braggin' if you can back it up."
        m01035.2 = " -- Dizzy Dean, baseball player"

        m01036.1 = "If at first you don't succeed,"
        m01036.2 = "then perhaps skydiving is not for you."

        m01037.1 = 'Can it be a mistake that "STRESSED" is'
        m01037.2 = '"DESSERTS" spelled backwards?'

        m01038.1 = '"If you want it bad enough, you will get it bad."'

        m01039.1 = '"The perfect is the enemy of the good."'
        m01039.2 = '  --- sign seen in the Pentagon'

        m01040.1 = '"Hard things are put in our way, not to stop us,'
        m01040.2 = ' but to call out our courage and strength."'
        m01040.3 = ' --- Anonymous'

        m01041.1 = '"There are costs and risks to a program of action,'
        m01041.2 = ' but they are far less than the long-range risks'
        m01041.3 = ' and costs of comfortable inaction."'
        m01041.4 = ' --- John F. Kennedy'

        m01042.1 = '"If you want to make peace, you don''t talk to your'
        m01042.2 = ' friends. You talk to your enemies."'
        m01042.3 = '--- Moshe Dayan'

        m01043.1 = '"Any sufficiently advanced bureaucracy is'
        m01043.2 = ' indistinguishable from molasses."'

        m01044.1 = '"Each problem that I solved became a rule'
        m01044.2 = ' which served afterwards to solve other problems."'
        m01044.3 = '  - Rene Descartes'

        m01045.1 = '"It is our responsibilities, not ourselves,'
        m01045.2 = ' that we should take seriously."'
        m01045.3 = '   - Peter Ustinov'

        m01046.1 = 'Tomorrow is one of the greatest labor'
        m01046.2 = 'saving devices of today.'

        m01047.1 = 'A Yawn is an honest opinion openly expressed.'

        m01048.1 = 'A mosquito is an insect that makes you'
        m01048.2 = 'like flies better.'

        m01049.1 = 'Toothache is the pain that drives you to extraction.'

        m01050.1 = 'Dust is mud with the juice squeezed out.'

        m01051.1 = 'Chickens are the only animals you eat before they'
        m01051.2 = 'are born and after they are dead.'

        m01052.1 = 'An egotist is someone who is usually me-deep in' ,
                   'conversation.'

        m01053.1 = 'A Kleenex is cold storage.'

        m01054.1 = "Of all the things I've lost, I miss my mind the most."

        m01055.1 = "Some folks can tell what time it is by looking at" ,
                   "the sun."
        m01055.2 = "I've never been able to make out the numbers."

        m01056.1 = "Never attribute to malice what can be caused by" ,
                   "miscommunication."

        m01057.1 = "Light travels faster than sound, that's why people"
        m01057.2 = "seem bright until you hear them..."

        m01058.1 = "I may be schizophrenic, but at least I have each other."

        m01059.1 = "Don't believe the man who tells you there are two "
        m01059.2 = "sides to every question. There is only one side to "
        m01059.3 = "the truth."
        m01059.4 = "... William Peter Hamilton"

        m01060.1 = "The only reason some people get lost in thought is"
        m01060.2 = "because it's unfamiliar territory."
        m01060.3 = "... Paul Fix"

        m01061.1 = "If there are no stupid questions, then what kind"
        m01061.2 = "of questions do stupid people ask? Do they get"
        m01061.3 = "smart just in time to ask questions?"
        m01061.4 = "  - Scott Adams"

        m01062.1 = "Facts are the enemy of truth."
        m01062.2 = " - Miguel de Cervantes (1547 - 1616)"

        m01063.1 = "In theory, theory and practice are the"
        m01063.2 = "same, but in practice, theory and"
        m01063.3 = "practice are different."

        m01064.1 = "In theory there is no difference between theory"
        m01064.2 = "and practice.  In practice there is."
        m01064.3 = " --- Yogi Berra"

        m01065.1 = "Without theory, practice is but routine born of"
        m01065.2 = "habit.  Theory alone can bring forth and develop"
        m01065.3 = "the spirit of inventions."
        m01065.4 = " --- Louis Pasteur"

        m01066.1 = "The difference between theory and practice tends"
        m01066.2 = "to be very small in theory but in practice it is"
        m01066.3 = "very large indeed."

        m01067.1 = "In theory, there is no difference between theory"
        m01067.2 = "and practice.  In practice, there is no"
        m01067.3 = "relationship between theory and practice."

        m01068.1 = "The best way out is always through."
        m01068.2 = "  - Robert Frost"

        m01069.1 = "If it's stupid but it works, it's not stupid."

        m01070.1 = "Character is what you have left when"
        m01070.2 = "you've lost everything you can lose."
        m01070.3 = "   - Evan Esarar"

        m01071.1 = "How much easier it is to be critical"
        m01071.2 = "than to be correct."
        m01071.3 = "   - Benjamin Disraeli "

        m01072.1 = "Help - someone turned off the light at the end"
        m01072.2 = "of my tunnel."

        m01073.1 = "Adventure is just bad planning."
        m01073.2 = "  - Roald Amundsen  "

        m01073.1 = "Adventure is just bad planning."
        m01073.2 = "  - Roald Amundsen  "

        m01074.1 =" The only people who find what they are looking"
        m01074.2 =" for in life are the fault finders"
        m01074.3 =" - Foster's Law"

        m01075.1 ="In fact, no decision has been made unless"
        m01075.2 ="carrying it out in specific steps has become"
        m01075.3 ="someone's work assignment and responsibility."
        m01075.4 ="Until then there are only good intentions."
        m01075.5 =" --  Peter Drucker "

        m01076.1 = "The nice part about being a pessimist is that"
        m01076.1 = "you are constantly being either proven right or"
        m01076.1 = "pleasantly surprised."
        m01076.1 = " -- George F. Will"

        m01077.1 = "The most intolerant are those who demand tolerance."

        m01078.1 = "There is nothing so useless as doing efficiently"
        m01078.2 = "that which should not be done at all."
        m01078.3 = "  - Peter Drucker"


      m01079.1 = "If you don't read the newspaper, you are uninformed."
      m01079.2 = "If you do read the enwspaper you are misinformed."
      m01079.3 = "-- Mark Twain"

        return
