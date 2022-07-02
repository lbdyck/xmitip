/* REXX */
parse arg parms
_cmd_ = "_val_ = "parms""
interpret _cmd_
return _val_

/******************************************************************/
/* Generic Object Rexx date arithmetic routines                   */
/*                                Toby Thurston ---  2 Dec 2002   */
/*                                                                */
/* Version 1.1 - 2008-09-01 - remove never executed "exit"s       */
/* Version 1.0 - 2007-09-20 - adapted to HOST by Hartmut          */
/******************************************************************/
/* For comprehensive theory and implementation suggestions see    */
/* "Calendrical Calculations", by Edward Reingold & Nachum        */
/* Dershowitz, Cambridge University Press 2001.                   */
/******************************************************************/
/* These date routines are based around translating to and from   */
/* the Rexx "base day number", that is the number of complete     */
/* days that have elapsed since the theoretical date midnight on  */
/* 1 Jan 0001 in the Gregorian calendar.  Thus base day number 0  */
/* would be represented as 1 Jan 0001 in the Gregorian calendar,  */
/* and 1 Jan 2001 is base day 730485.                             */
/*                                                                */
/* Routines are provided to translate from base day number to     */
/* Gregorian dates, to Julian dates, or to ISO week number dates. */
/*                                                                */
/* Routines are also provided to translate between the various    */
/* Rexx formats for Gregorian dates.                              */
/*                                                                */
/* The range of dates representable is restricted by the default  */
/* setting of numeric digits.  Negative year numbers represent    */
/* years before the Gregorian "common era", and are normally      */
/* written with "B.C.E" after them.                               */
/*                                                                */
/* There is very little range checking of any arguments.  This is */
/* deliberate.  This allows you to have month 13 to mean January  */
/* in the next year, etc.  It also speeds things up.              */
/*                                                                */
/******************************************************************/
/*::requires "maths.rex" */          /* for mod() and floor() etc */

/******************************************************************/
/* Routines that calculate a base day number                      */
/*                                                                */
/******************************************************************/

/******************************************************************/
/* Base: returns base day number from (y,m,d) assuming the normal */
/* Gregorian calendar                                             */
/******************************************************************/
 base: procedure
parse arg y, m, d
m = m-3; if m < 0 then do; m = m + 12; y = y - 1; end
_val_ = 365*y + floor(y/4) - floor(y/100) + floor(y/400) ,
              + floor((2+3*m)/5) + 30*m + d - 307
return _val_

/******************************************************************/
/* Base_from_julian: like Base(), but (y,m,d) are assumed to      */
/* represent a date in the old Julian calendar, also known as     */
/* "old style".                                                   */
/******************************************************************/
 base_from_julian: procedure
parse arg y, m, d
m = m-3; if m < 0 then do; m = m + 12; y = y - 1; end;
_val_ = 365*y + floor(y/4) + floor((2+3*m)/5) + 30*m + d - 307 - 2
return _val_

/******************************************************************/
/* Base_from_iso_week: like Base() but the arguments are year,    */
/* week number, and day of week number, following ISO week        */
/* numbering rules.                                               */
/******************************************************************/
 base_from_iso_week: procedure
parse arg y, w, d
dec28 = base(y-1,12,28)
dow = mod(dec28,7)
sunday_before = dec28 - 1 - dow
return sunday_before + w*7 + d

/******************************************************************/
/* Easter: returns the base date of Easter Sunday given a year    */
/* This uses the modern Gregaorian calendar rules                 */
/******************************************************************/
 easter: procedure
arg y
g = y//19                        /* position in the 19 year cycle */
c = y%100+1                            /* century number          */
a = c*3%4-12                     /* non-leap days at century ends */
b = (c*8+5)%25                 /* extra day every 3rd/4th century */
e = (11*g + 2 - a + b) // 30        /* age of the moon on 5 April */
if e=0 | e=1&g>10 then e=e+1           /* avoid Passover          */
e = e - 7 + (y*5%4-a+5-e)//7                 /* advance to Sunday */
return base(y,4,19-e)

/******************************************************************/
/* Routines that convert a base number to a date in a specific    */
/* calendar system                                                */
/******************************************************************/

/******************************************************************/
/* Gregorian: returns "y m d" from a base number according to     */
/* "normal" Gregorian calendar rules.                             */
/*                                                                */
/* For those interested in the approach:  we need to find s, c,   */
/* o, y, m, and d where:                                          */
/*       s is the 400 year cycle we are in (146097 days long)     */
/*       c is the century (36524 days long)                       */
/*       o is the 4 year cycle (Olympiad) (1461 days long)        */
/*       y is the year in that cycle                              */
/*   and m and d are the month and day                            */
/*                                                                */
/* This is done essentially as a mixed radix base conversion.     */
/*                                                                */
/* There are a couple of special cases for the last day of the    */
/* 400 and 4 year cycles.                                         */
/*                                                                */
/* The argument can be positive or negative.                      */
/******************************************************************/
 gregorian: procedure
parse arg d
if datatype(d,'w') = 0 then d = date('b')
s=floor(d/146097); d=d-s*146097
if d=146096 then return s*400+400 12 31/* special case 1          */
c=d%36524; d=d-c*36524; o=d%1461; d=d-o*1461
if d=1460 then return s*400+c*100+o*4+4 12 31  /* special case 2  */
y=d%365; d=d-y*365+1                   /* d is now in range 1-365 */
if (y=3 & (o<24|c=3))                  /* leap year?              */
  then prior_days='0 31 60 91 121 152 182 213 244 274 305 335'
  else prior_days='0 31 59 90 120 151 181 212 243 273 304 334'
do m=1 to 12 while word(prior_days,m) < d
end
m=m-1
d=d-word(prior_days,m)
return s*400+c*100+o*4+y+1 m d

/******************************************************************/
/* Julian:  returns "y m d" from a base number according to       */
/* Julian calendar rules.                                         */
/*                                                                */
/* Note if you wanted the day of year number (some times called a */
/* Julian date), then you want "base(y,m,d)-base(y,1,0)" or use   */
/* the iso_day_of_year function                                   */
/******************************************************************/
 julian: procedure
parse arg d
if datatype(d,'w') = 0 then d = date('b')
d=d+2
o=floor(d/1461)
d=d-o*1461
if d=1460 then return o*4+4 12 31
y=floor(d/365)
d=d-y*365+1
if y=3                                 /* leap year?              */
  then prior_days='0 31 60 91 121 152 182 213 244 274 305 335'
  else prior_days='0 31 59 90 120 151 181 212 243 273 304 334'
do m=1 to 12 while word(prior_days,m) < d
end
m=m-1
d=d-word(prior_days,m)
return o*4+y+1 m d

/******************************************************************/
/* ISO_week: returns "year week day_of_week" from a base number   */
/* according to the ISO week numbering rules; week 1 of a year is */
/* the week that contains Jan 4. (Puzzled? read the standard...)  */
/*                                                                */
/* If you pass "-" as a second arg, then you get "yyyy-Www-d"     */
/* form.                                                          */
/******************************************************************/
 iso_week: procedure
parse arg d, sep
if datatype(d,'w') = 0 then d = date('b')
parse value gregorian(d-3) with y .
start=base_from_iso_week(y+1,1,1)
if d < start
  then start=base_from_iso_week(y,1,1)
  else y=y+1
w = (d-start)%7+1
d = d//7+1
if sep='-'
  then return y'-W'right(w,2,0)'-'d
  else return y w d

/******************************************************************/
/* ISO_day_of_year:  returns "year day_of_year" from a base       */
/* number according to the ISO Gregorian calendar rules.          */
/*                                                                */
/* If you pass "-" as a second arg, then you get "yyyy-ddd" form. */
/******************************************************************/
 iso_day_of_year: procedure
parse arg d, sep
if datatype(d,'w') = 0 then d = date('b')
parse value gregorian(d) with y .
d = d-base(y,1,0)
if sep='-'
  then return y'-'right(d,3,0)
  else return y d

/******************************************************************/
/* ISO_sorted:  returns "yyyymmdd" or "yyyy-mm-dd" from a base    */
/* number according to the ISO Gregorian calendar rules.          */
/*                                                                */
/* Pass "-" as a second arg to get "yyyy-mm-dd" form.             */
/******************************************************************/
 iso_sorted: procedure
parse arg d, sep
if datatype(d,'w') = 0 then d = date('b')
if sep='-'
  then return b2i(d)
  else return b2s(d)

/******************************************************************/
/* Routines to go from Base form to other forms                   */
/******************************************************************/
 b2s: procedure
parse value gregorian(arg(1)) with y m d .
return y''right(m,2,0)right(d,2,0)

 b2i: procedure
parse value gregorian(arg(1)) with y m d .
return y'-'right(m,2,0)'-'right(d,2,0)

 b2d: procedure
parse arg base
parse value gregorian(base) with y .
return base-base(y,1,0)

 b2e: procedure
parse value gregorian(arg(1)) with y m d
return right(d,2,0)'/'right(m,2,0)'/'right(y,2,0)

 b2o: procedure
parse value gregorian(arg(1)) with y m d
return right(y,2,0)'/'right(m,2,0)'/'right(d,2,0)

 b2u: procedure
parse value gregorian(arg(1)) with y m d
return right(m,2,0)'/'right(d,2,0)'/'right(y,2,0)

 b2m: procedure
parse value gregorian(arg(1)) with . m .
return month(m)

 b2n: procedure
parse value gregorian(arg(1)) with y m d
return d left(month(m),3) y

 b2w: procedure
parse arg base
if datatype(base,'w') = 0 then base = date('b')
dow = mod(base,7) + 1
return word('Monday Tuesday Wednesday ' ,
            'Thursday Friday Saturday Sunday',dow)

/******************************************************************/
/* Routines to go from Standard form to other forms               */
/******************************************************************/
 s2b: procedure
parse arg date
return base(date%10000, left(right(date,4),2), right(date,2))
 s2d: procedure ; return b2d(s2b(arg(1)))
 s2e: procedure ; return b2e(s2b(arg(1)))
 s2o: procedure ; return b2o(s2b(arg(1)))
 s2u: procedure ; return b2u(s2b(arg(1)))
 s2n: procedure ; return b2n(s2b(arg(1)))
 s2w: procedure ; return b2w(s2b(arg(1)))
/******************************************************************/
/* Routines to go from Normal form to other forms                 */
/******************************************************************/
 n2b: procedure
parse arg d mmm y .
do m = 12 to 1 by -1
  if left(month(m),3) = mmm then leave
end
if m = 0 then m = mmm        /* let base cope with this non-month */
return base(y,m,d)
 n2d: procedure ; return b2d(n2b(arg(1)))
 n2e: procedure ; return b2e(n2b(arg(1)))
 n2o: procedure ; return b2o(n2b(arg(1)))
 n2u: procedure ; return b2u(n2b(arg(1)))
 n2s: procedure ; return b2s(n2b(arg(1)))
 n2w: procedure ; return b2w(n2b(arg(1)))

/******************************************************************/
/* Window a yy to a yyyy                                          */
/******************************************************************/
 window: procedure
parse arg y
if y > 199 then return y
year=left(date('s'),4)
cut=(year-50)
if y > cut//100 then return 1900+y
return 2000+y
/******************************************************************/
/* Lookup routines                                                */
/******************************************************************/
 month: procedure
return word('January February March April ',
            'May June July August September ',
            'October November December',arg(1))

/* test:      s2b(20010101) = 730485                    */
/* test:      s2b(20010100) = 730484                    */
/* test:      s2b(20010102) = 730486                    */
/* test:      b2s(730485) = 20010101                    */
/* test:      b2d(730485) = 1                           */
/* test:      b2e(730485) = '01/01/01'                  */
/* test:      b2o(730485) = '01/01/01'                  */
/* test:      b2u(730485) = '01/01/01'                  */
/* test:      b2m(730485) = 'January'                   */
/* test:      b2n(730485) = '1 Jan 2001'                */
/* test:      b2w(730485) = 'Monday'                    */

/* test:      s2b(21000229) = 766703                    */
/* test:      b2s(766703) = 21000301                    */
/* test:      b2i(766703) = '2100-03-01'                */
/* test:      b2d(766703) = 60                          */
/* test:      b2e(766703) = '01/03/00'                  */
/* test:      b2o(766703) = '00/03/01'                  */
/* test:      b2u(766703) = '03/01/00'                  */
/* test:      b2m(766703) = 'March'                     */
/* test:      b2n(766703) = '1 Mar 2100'                */
/* test:      b2w(766703) = 'Monday'                    */

/* test:      b2s(0) = 10101                            */
/* test:      s2b(10101) = 0                            */
/* test:      b2s(-1) = 01231                           */
/* test:      s2b(01231) = -1                           */
/* test:      b2s(-366) = 00101                         */
/* test:      s2b(00101) = -366                         */

/* test:      s2b(-1000508) = -36763                    */
/* test:      b2s(-36763) = -1000508                    */
/* test:      b2d(-36763) = 128                         */
/* test:      b2e(-36763) = '08/05/00'                  */
/* test:      b2o(-36763) = '00/05/08'                  */
/* test:      b2u(-36763) = '05/08/00'                  */
/* test:      b2m(-36763) = 'May'                       */
/* test:      b2n(-36763) = '8 May -100'                */
/* test:      b2w(-36763) = 'Tuesday'                   */

/* test:      base(1900,2,29) = base(1900,3,1)          */
/* test:      base(1,1,1) = base_from_julian(1,1,3)     */
/* test:      base(1752,9,15) = 639797                  */
/* test:      base_from_julian(1752,9,4) = 639797       */
/* test:      julian(639797) = '1752 9 4'               */

/* test:      base(1996,2,25) = 728713                  */
/* test:      base_from_julian(1996,2,12) = 728713      */
/* test:      julian(728713) = '1996 2 12'              */
/* test:      gregorian(728713) = '1996 2 25'           */

/* test:      base_from_iso_week(2002,46,4) = 731167    */
/* test:      base_from_iso_week(2001,1,1) = 730485     */

/* test:      iso_week(base(2005,1,1)) = '2004 53 6'    */
/* test:      iso_week(731167) = '2002 46 4'            */
/* test:      iso_week(731167,'-') = '2002-W46-4'       */

/* test:      iso_day_of_year(731165) = '2002 316'      */
/* test:      iso_day_of_year(731215,'-') = '2003-001'  */

/* test:      n2w('18 Nov 2002') = 'Monday'             */
/* test:      n2u('31 Nov 2002') = '12/01/02'           */

/* test:      b2n(easter(1999)) = '4 Apr 1999'          */
/* test:      b2n(easter(2000)) = '23 Apr 2000'         */
/* test:      b2n(easter(2001)) = '15 Apr 2001'         */
/* test:      b2n(easter(2002)) = '31 Mar 2002'         */
/* test:      b2n(easter(2003)) = '20 Apr 2003'         */
/* test:      b2n(easter(2004)) = '11 Apr 2004'         */


 /* mathematical sub routines ------------------------------------- */
mod: procedure
  arg x, y; return x - y * floor(x/y)

floor: procedure
  arg x; s = 1 + trunc(abs(x)); return trunc(x+s)-s
