"=============================================================================
" File: calendar.vim
" Author: Yasuhiro Matsumoto <mattn_jp@hotmail.com>
" Last Change:  Fri, 10 Jan 2003
" Version: 1.3r
" Thanks:
"     Vikas Agnihotri     : bug report
"     Steve Hall          : gave a hint for 1.3q
"     James Devenish      : bug fix
"     Carl Mueller        : gave a hint for 1.3o
"     Klaus Fabritius     : bug fix
"     Stucki              : gave a hint for 1.3m
"     Rosta               : bug report
"     Richard Bair        : bug report
"     Yin Hao Liew        : bug report
"     Bill McCarthy       : bug fix and gave a hint
"     Srinath Avadhanula  : bug fix
"     Ronald Hoellwarth   : few advices
"     Juan Orlandini      : added higlighting of days with data
"     Ray                 : bug fix
"     Ralf.Schandl        : gave a hint for 1.3
"     Bhaskar Karambelkar : bug fix
"     Suresh Govindachar  : gave a hint for 1.2
"     Michael Geddes      : bug fix
"     Leif Wickland       : bug fix
" Usage:
"     :Calendar
"       show calendar at this year and this month
"     :Calendar 8
"       show calendar at this year and given month
"     :Calendar 2001 8
"       show calendar at given year and given month
"     :CalendarH ...
"       show horizontal calendar ...
"
"     <Leader>ca
"       show calendar in normal mode
"     <Leader>ch
"       show horizontal calendar ...
" ChangeLog:
"     1.3r : bug fix
"            if clicked navigator, cursor go to strange position.
"     1.3q : bug fix
"             coundn't set calendar_navi
"              in its horizontal direction
"     1.3p : bug fix
"             coundn't edit diary when the calendar is
"              in its horizontal direction
"     1.3o : add option calendar_mark, and delete calendar_rmark
"             see Additional:
"            add option calendar_navi
"             see Additional:
"     1.3n : bug fix
"             s:CalendarSign() should use filereadable(expand(sfile)).
"     1.3m : tuning
"             using topleft or botright for opening Calendar.
"            use filereadable for s:CalendarSign().
"     1.3l : bug fix
"             if set calendar_monday, it can see that Sep 1st is Sat
"               as well as Aug 31st.
"     1.3k : bug fix
"             it didn't escape the file name on calendar.
"     1.3j : support for fixed Gregorian
"             added the part of Sep 1752.
"     1.3i : bug fix
"             Calculation mistake for week number.
"     1.3h : add option for position of displaying '*' or '+'.
"             see Additional:
"     1.3g : centering header
"            add option for show name of era.
"             see Additional:
"            bug fix
"             <Leader>ca didn't show current month.
"     1.3f : bug fix
"            there was yet another bug of today's sign.
"     1.3e : added usage for <Leader>
"            support handler for sign.
"            see Additional:
"     1.3d : added higlighting of days that have calendar data associated
"             with it.
"            bug fix for calculates date.
"     1.3c : bug fix for MakeDir()
"            if CalendarMakeDir(sfile) != 0
"               v 
"            if s:CalendarMakeDir(sfile) != 0
"     1.3b : bug fix for calendar_monday.
"            it didn't work g:calendar_monday correctly.
"            add g:calendar_version.
"            add argument on action handler.
"            see Additional:
"     1.3a : bug fix for MakeDir().
"            it was not able to make directory.
"     1.3  : support handler for action.
"            see Additional:
"     1.2g : bug fix for today's sign.
"            it could not display today's sign correctly.
"     1.2f : bug fix for current Date.
"            vtoday variable calculates date as 'YYYYMMDD'
"            while the loop calculates date as 'YYYYMMD' i.e just 1 digit
"            for date if < 10 so if current date is < 10 , the if condiction
"            to check for current date fails and current date is not
"            highlighted.
"            simple solution changed vtoday calculation line divide the
"            current-date by 1 so as to get 1 digit date.
"     1.2e : change the way for setting title.
"            auto configuration for g:calendar_wruler with g:calendar_monday
"     1.2d : add option for show week number.
"              let g:calendar_weeknm = 1
"            add separator if horizontal.
"            change all option's name
"              g:calendar_mnth -> g:calendar_mruler
"              g:calendar_week -> g:calendar_wruler
"              g:calendar_smnd -> g:calendar_monday
"     1.2c : add option for that the week starts with monday.
"              let g:calendar_smnd = 1
"     1.2b : bug fix for modifiable.
"            setlocal nomodifiable (was set)
"     1.2a : add default options.
"            nonumber,foldcolumn=0,nowrap... as making gap
"     1.2  : support wide display.
"            add a command CalendarH
"            add map <s-left> <s-right>
"     1.1c : extra.
"            add a titlestring for today.
"     1.1b : bug fix by Michael Geddes.
"            it happend when do ':Calender' twice
"     1.1a : fix misspell.
"            Calender -> Calendar
"     1.1  : bug fix.
"            it"s about strftime("%m")
"     1.0a : bug fix by Leif Wickland.
"            it"s about strftime("%w")
"     1.0  : first release.
" Additional:
"     *if you want to place the mark('*' or '+') after the day,
"       add the following to your .vimrc:
"
"       let g:calendar_mark = 'right'
"
"       NOTE:you can set 'left', 'left-fit', 'right' for this option.
"
"     *if you want to use navigator,
"       add the following to your .vimrc:
"
"       let g:calendar_navi = ''
"
"       NOTE:you can set 'top', 'bottom', 'both' for this option.
"
"     *if you want to replace calendar header,
"       add the following in your favorite language to your .vimrc:
"
"       let g:calendar_erafmt = 'Heisei,-1988'   " for Japanese
"       (name of era and diff with A.D.)
"
"     *if you want to replace calendar ruler,
"       add the following in your favorite language to your .vimrc:
"
"       let g:calendar_mruler = 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec'
"       let g:calendar_wruler = 'Su Mo Tu We Th Fr Sa'
"
"     *if you want the week to start with monday, add below to your .vimrc:
"
"       let g:calendar_monday = 1
"       (You don't have to to change g:calendar_wruler!)
"
"     *if you want to show week number, add this to your .vimrc:
"
"       set g:calendar_weeknm as below
"       (Can't be used together with g:calendar_monday.)
"
"       let g:calendar_weeknm = 1 " WK01
"       let g:calendar_weeknm = 2 " WK 1
"       let g:calendar_weeknm = 3 " KW01
"       let g:calendar_weeknm = 4 " KW 1
"
"     *if you want to hook calender when pressing enter,
"       add this to your .vimrc:
"
"       function MyCalAction(day,month,year,week,dir)
"         " day   : day you actioned
"         " month : month you actioned
"         " year  : year you actioned
"         " week  : day of week (Mo=1 ... Su=7)
"         " dir   : direction of calendar
"       endfunction
"       let calendar_action = 'MyCalAction'
"
"     *if you want to show sign in calender,
"       add this to your .vimrc:
"
"       function MyCalSign(day,month,year)
"         " day   : day you actioned
"         " month : month you actioned
"         " year  : year you actioned
"         if a:day == 1 && a:month == 1
"           return 1 " happy new year
"         else
"           return 0 " or not
"         endif
"       endfunction
"       let calendar_sign = 'MyCalSign'
"
"     *if you want to get the version of this.
"       type below.
"
"       :echo calendar_version

let g:calendar_version = "1.3r"
if !exists("g:calendar_action")
  let g:calendar_action = "<SID>CalendarDiary"
endif
if !exists("g:calendar_diary")
  let g:calendar_diary = "~/diary"
endif
if !exists("g:calendar_sign")
  let g:calendar_sign = "<SID>CalendarSign"
endif
if !exists("g:calendar_mark")
 \|| (g:calendar_mark != 'left'
 \&& g:calendar_mark != 'left-fit'
 \&& g:calendar_mark != 'right')
  let g:calendar_mark = 'left'
endif
if !exists("g:calendar_navi")
 \|| (g:calendar_navi != 'top'
 \&& g:calendar_navi != 'bottom'
 \&& g:calendar_navi != 'both')
  let g:calendar_navi = 'top'
endif

"*****************************************************************
"* Calendar commands
"*****************************************************************
:command! -nargs=* Calendar  call Calendar(0,<f-args>)
:command! -nargs=* CalendarH call Calendar(1,<f-args>)

if !hasmapto("<Plug>Calendar")
  nmap <unique> <Leader>ca <Plug>Calendar
endif
if !hasmapto("<Plug>CalendarH")
  nmap <unique> <Leader>ch <Plug>CalendarH
endif
nmap <silent> <Plug>Calendar  :cal Calendar(0)<CR>
nmap <silent> <Plug>CalendarH :cal Calendar(1)<CR>

"*****************************************************************
"* GetToken : get token from source with count
"*----------------------------------------------------------------
"*   src : source
"*   dlm : delimiter
"*   cnt : skip count
"*****************************************************************
function! s:GetToken(src,dlm,cnt)
  let tokn_hit=0     " flag of found
  let tokn_fnd=''    " found path
  let tokn_spl=''    " token
  let tokn_all=a:src " all source

  " safe for end
  let tokn_all = tokn_all.a:dlm
  while 1
    let tokn_spl = strpart(tokn_all,0,match(tokn_all,a:dlm))
    let tokn_hit = tokn_hit + 1
    if tokn_hit == a:cnt
      return tokn_spl
    endif
    let tokn_all = strpart(tokn_all,strlen(tokn_spl.a:dlm))
    if tokn_all == ''
      break
    endif
  endwhile
  return ''
endfunction

"*****************************************************************
"* CalendarDoAction : call the action handler function
"*----------------------------------------------------------------
"*****************************************************************
function! s:CalendarDoAction()
  " if no action defined return
  if !exists("g:calendar_action")
    return
  endif

  " for navi
  if exists('g:calendar_navi')
    let navi = expand("<cword>")
    let curl = line(".")
    if navi == 'Prev'
      exec substitute(maparg('<s-left>', 'n'), '<CR>', '', '')
    elseif navi == 'Next'
      exec substitute(maparg('<s-right>', 'n'), '<CR>', '', '')
    elseif navi == 'Today'
      call Calendar(b:CalendarDir)
    else
      let navi = ''
    endif
    if navi != ''
      if curl < line('$')/2
        silent execute "normal! gg/".navi."\<cr>"
      else
        silent execute "normal! gg?".navi."\<cr>"
      endif
      return
    endif
  endif

  if b:CalendarDir
    let dir = 'H'
    if !exists('g:calendar_monday') && exists('g:calendar_weeknm')
      let cnr = col('.') - (col('.')%(24+5)) + 1
    else
      let cnr = col('.') - (col('.')%(24)) + 1
    endif
    let week = ((col(".") - cnr - 1 + cnr/49) / 3)
  else
    let dir = 'V'
    let cnr = 1
    let week = ((col(".")+1) / 3) - 1
  endif
  let lnr = 1
  let hdr = 1
  while 1
    if lnr > line('.')
      break
    endif
    let sline = getline(lnr)
    if sline =~ '^\s*$'
      let hdr = lnr + 1
    endif
    let lnr = lnr + 1
  endwhile
  let lnr = line('.')
  if(exists('g:calendar_monday'))
      let week = week + 1
  elseif(week == 0)
      let week = 7
  endif
  if lnr-hdr < 2
    return
  endif
  let sline = substitute(strpart(getline(hdr),cnr,21),'\s*\(.*\)\s*','\1','')
  if (col(".")-cnr) > 20
    return
  endif

  " extracr day
  let day = matchstr(expand("<cword>"), '[^0].*')
  if day == 0
    return
  endif
  " extracr year and month
  if exists('g:calendar_erafmt') && g:calendar_erafmt !~ "^\s*$"
    let year = matchstr(substitute(sline, '/.*', '', ''), '\d\+')
    let month = matchstr(substitute(sline, '.*/\(\d\d\=\).*', '\1', ""), '[^0].*')
    if g:calendar_erafmt =~ '.*,[+-]*\d\+'
      let veranum=substitute(g:calendar_erafmt,'.*,\([+-]*\d\+\)','\1','')
      if year-veranum > 0
        let year=year-veranum
      endif
    endif
  else
    let year = matchstr(substitute(sline, '/.*', '', ''), '[^0].*')
    let month = matchstr(substitute(sline, '\d*/\(\d\d\=\).*', '\1', ""), '[^0].*')
  endif
  " call the action function
  exe "call " . g:calendar_action . "(day, month, year, week, dir)"
endfunc

"*****************************************************************
"* Calendar : build calendar
"*----------------------------------------------------------------
"*   a1 : direction
"*   a2 : month(if given a3, it's year)
"*   a3 : if given, it's month
"*****************************************************************
function! Calendar(...)

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ ready for build
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  " remember today
  " divide strftime('%d') by 1 so as to get "1, 2,3 .. 9" instead of "01, 02, 03 .. 09"
  let vtoday = strftime('%Y').
    \matchstr(strftime('%m'), '[^0].*').matchstr(strftime('%d'), '[^0].*')

  " get arguments
  if a:0 == 0
    let dir = 0
    let vyear = strftime('%Y')
    let vmnth = matchstr(strftime('%m'), '[^0].*')
  elseif a:0 == 1
    let dir = a:1
    let vyear = strftime('%Y')
    let vmnth = matchstr(strftime('%m'), '[^0].*')
  elseif a:0 == 2
    let dir = a:1
    let vyear = strftime('%Y')
    let vmnth = matchstr(a:2, '^[^0].*')
  else
    let dir = a:1
    let vyear = a:2
    let vmnth = matchstr(a:3, '^[^0].*')
  endif

  " remember constant
  let vmnth_org = vmnth
  let vyear_org = vyear

  " start with last month
  let vmnth = vmnth - 1
  if vmnth < 1
    let vmnth = 12
    let vyear = vyear - 1
  endif

  " reset display variables
  let vdisplay1 = ''
  let vheight = 1
  let vmcnt = 0

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ build display
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  while vmcnt < 3
    let vcolumn = 22
    let vnweek = -1
    "--------------------------------------------------------------
    "--- calculating
    "--------------------------------------------------------------
    " set boundary of the month
    if vmnth == 1
      let vmdays = 31
      let vparam = 0
      let vsmnth = 'Jan'
    elseif vmnth == 2
      let vmdays = 28
      let vparam = 31
      let vsmnth = 'Feb'
    elseif vmnth == 3
      let vmdays = 31
      let vparam = 59
      let vsmnth = 'Mar'
    elseif vmnth == 4
      let vmdays = 30
      let vparam = 90
      let vsmnth = 'Apr'
    elseif vmnth == 5
      let vmdays = 31
      let vparam = 120
      let vsmnth = 'May'
    elseif vmnth == 6
      let vmdays = 30
      let vparam = 151
      let vsmnth = 'Jun'
    elseif vmnth == 7
      let vmdays = 31
      let vparam = 181
      let vsmnth = 'Jul'
    elseif vmnth == 8
      let vmdays = 31
      let vparam = 212
      let vsmnth = 'Aug'
    elseif vmnth == 9
      let vmdays = 30
      let vparam = 243
      let vsmnth = 'Sep'
    elseif vmnth == 10
      let vmdays = 31
      let vparam = 273
      let vsmnth = 'Oct'
    elseif vmnth == 11
      let vmdays = 30
      let vparam = 304
      let vsmnth = 'Nov'
    elseif vmnth == 12
      let vmdays = 31
      let vparam = 334
      let vsmnth = 'Dec'
    else
      echo 'Invalid Year or Month'
      return
    endif

    " calc vnweek of the day
    if vnweek == -1
      let vnweek = ( vyear * 365 ) + vparam + 1
      let vnweek = vnweek + ( vyear/4 ) - ( vyear/100 ) + ( vyear/400 )
      if vmnth < 3 && vyear % 4 == 0
        if vyear % 100 != 0 || vyear % 400 == 0
          let vnweek = vnweek - 1
        endif
      endif
      let vnweek = vnweek - 1
    endif
    if vmnth == 2
      if vyear % 400 == 0
        let vmdays = 29
      elseif vyear % 100 == 0
        let vmdays = 28
      elseif vyear % 4 == 0
        let vmdays = 29
      endif
    endif

    " fix Gregorian
    if vyear <= 1752
      let vnweek = vnweek - 3
    endif

    let vnweek = vnweek % 7

    if exists('g:calendar_monday')
      " if given g:calendar_monday, the week start with monday
      if vnweek == 0
        let vnweek = 7
      endif
      let vnweek = vnweek - 1
    elseif exists('g:calendar_weeknm')
      " if given g:calendar_weeknm, show week number(ref:ISO8601)
      let viweek = (vparam + 1) / 7
      let vfweek = (vparam + 1) % 7
      if vnweek == 0
        let vfweek = vfweek - 7
        let viweek = viweek + 1
      else
        let vfweek = vfweek - vnweek
      endif
      if vfweek <= 0 && viweek > 0
        let viweek = viweek - 1
        let vfweek = vfweek + 7
      endif
      if vfweek > -4
        let viweek = viweek + 1
      endif
      if vfweek > 3
        let viweek = viweek + 1
      endif
      if viweek == 0
        let viweek = '??'
      elseif viweek > 52
        if vnweek != 0 && vnweek < 4
          let viweek = 1
        endif
      endif
      let vcolumn = vcolumn + 5
    endif

    "--------------------------------------------------------------
    "--- displaying
    "--------------------------------------------------------------
    " build header
    if exists('g:calendar_erafmt') && g:calendar_erafmt !~ "^\s*$"
      if g:calendar_erafmt =~ '.*,[+-]*\d\+'
        let veranum=substitute(g:calendar_erafmt,'.*,\([+-]*\d\+\)','\1','')
        if vyear+veranum > 0
          let vdisplay2=substitute(g:calendar_erafmt,'\(.*\),.*','\1','') 
          let vdisplay2=vdisplay2.(vyear+veranum).'/'.vmnth.'('
        else
          let vdisplay2=vyear.'/'.vmnth.'('
        endif
      else
        let vdisplay2=vyear.'/'.vmnth.'('
      endif
      let vdisplay2=strpart("                           ",
        \ 1,(vcolumn-strlen(vdisplay2))/2-2).vdisplay2
    else
      let vdisplay2=vyear.'/'.vmnth.'('
      let vdisplay2=strpart("                           ",
        \ 1,(vcolumn-strlen(vdisplay2))/2-2).vdisplay2
    endif
    if exists('g:calendar_mruler') && g:calendar_mruler !~ "^\s*$"
      let vdisplay2=vdisplay2.s:GetToken(g:calendar_mruler,',',vmnth).')'."\n"
    else
      let vdisplay2=vdisplay2.vsmnth.')'."\n"
    endif
    let vwruler = "Su Mo Tu We Th Fr Sa"
    if exists('g:calendar_wruler') && g:calendar_wruler !~ "^\s*$"
      let vwruler = g:calendar_wruler
    endif
    if exists('g:calendar_monday')
      let vwruler = strpart(vwruler,3).' '.strpart(vwruler,0,2)
    endif
    let vdisplay2 = vdisplay2.' '.vwruler."\n"
    if g:calendar_mark == 'right'
      let vdisplay2 = vdisplay2.' '
    endif

    " build calendar
    let vinpcur = 0
    while (vinpcur < vnweek)
      let vdisplay2=vdisplay2.'   '
      let vinpcur = vinpcur + 1
    endwhile
    let vdaycur = 1
    while (vdaycur <= vmdays)
      let vtarget = vyear.vmnth.vdaycur
      if exists("g:calendar_sign")
        exe "let vsign = " . g:calendar_sign . "(vdaycur, vmnth, vyear)"
        if vsign != ""
          let vsign = vsign[0]
          if vsign !~ "[+!#$%&@?]"
            let vsign = "+"
          endif
        endif
      else
        let vsign = ''
      endif

      " show mark
      if g:calendar_mark == 'right'
        if vdaycur < 10
          let vdisplay2=vdisplay2.' '
        endif
        let vdisplay2=vdisplay2.vdaycur
      endif
      if g:calendar_mark == 'left-fit'
        if vdaycur < 10
          let vdisplay2=vdisplay2.' '
        endif
      endif
      if vtarget == vtoday
        let vdisplay2=vdisplay2.'*'
      elseif vsign != ''
        let vdisplay2=vdisplay2.vsign
      else
        let vdisplay2=vdisplay2.' '
      endif
      if g:calendar_mark == 'left'
        if vdaycur < 10
          let vdisplay2=vdisplay2.' '
        endif
        let vdisplay2=vdisplay2.vdaycur
      endif
      if g:calendar_mark == 'left-fit'
        let vdisplay2=vdisplay2.vdaycur
      endif
      let vdaycur = vdaycur + 1

      " fix Gregorian
      if vyear == 1752 && vmnth == 9 && vdaycur == 3
        let vdaycur = 14
      endif

      let vinpcur = vinpcur + 1
      if vinpcur % 7 == 0
        if !exists('g:calendar_monday') && exists('g:calendar_weeknm')
          if g:calendar_mark != 'right'
            let vdisplay2=vdisplay2.' '
          endif
          " if given g:calendar_weeknm, show week number
          if viweek < 10
            if g:calendar_weeknm == 1
              let vdisplay2=vdisplay2.'WK0'.viweek
            elseif g:calendar_weeknm == 2
              let vdisplay2=vdisplay2.'WK '.viweek
            elseif g:calendar_weeknm == 3
              let vdisplay2=vdisplay2.'KW0'.viweek
            elseif g:calendar_weeknm == 4
              let vdisplay2=vdisplay2.'KW '.viweek
            endif
          else
            if g:calendar_weeknm <= 2
              let vdisplay2=vdisplay2.'WK'.viweek
            else
              let vdisplay2=vdisplay2.'KW'.viweek
            endif
          endif
          let viweek = viweek + 1
        endif
        let vdisplay2=vdisplay2."\n"
        if g:calendar_mark == 'right'
          let vdisplay2 = vdisplay2.' '
        endif
      endif
    endwhile

    " if it is needed, fill with space
    if vinpcur % 7 
      while (vinpcur % 7 != 0)
        let vdisplay2=vdisplay2.'   '
        let vinpcur = vinpcur + 1
      endwhile
      if !exists('g:calendar_monday') && exists('g:calendar_weeknm')
        if g:calendar_mark != 'right'
          let vdisplay2=vdisplay2.' '
        endif
        if viweek < 10
          if g:calendar_weeknm == 1
            let vdisplay2=vdisplay2.'WK0'.viweek
          elseif g:calendar_weeknm == 2
            let vdisplay2=vdisplay2.'WK '.viweek
          elseif g:calendar_weeknm == 3
            let vdisplay2=vdisplay2.'KW0'.viweek
          elseif g:calendar_weeknm == 4
            let vdisplay2=vdisplay2.'KW '.viweek
          endif
        else
          if g:calendar_weeknm <= 2
            let vdisplay2=vdisplay2.'WK'.viweek
          else
            let vdisplay2=vdisplay2.'KW'.viweek
          endif
        endif
      endif
    endif

    " build display
    let vstrline = ''
    if dir
      " for horizontal
      "--------------------------------------------------------------
      " +---+   +---+   +------+
      " |   |   |   |   |      |
      " | 1 | + | 2 | = |  1'  |
      " |   |   |   |   |      |
      " +---+   +---+   +------+
      "--------------------------------------------------------------
      let vtokline = 1
      while 1
        let vtoken1 = s:GetToken(vdisplay1,"\n",vtokline)
        let vtoken2 = s:GetToken(vdisplay2,"\n",vtokline)
        if vtoken1 == '' && vtoken2 == ''
          break
        endif
        while strlen(vtoken1) < (vcolumn+1)*vmcnt
          if strlen(vtoken1) % (vcolumn+1) == 0
            let vtoken1 = vtoken1.'|'
          else
            let vtoken1 = vtoken1.' '
          endif
        endwhile
        let vstrline = vstrline.vtoken1.'|'.vtoken2.' '."\n"
        let vtokline = vtokline + 1
      endwhile
      let vdisplay1 = vstrline
      let vheight = vtokline-1
    else
      " for virtical
      "--------------------------------------------------------------
      " +---+   +---+   +---+
      " | 1 | + | 2 | = |   |
      " +---+   +---+   | 1'|
      "                 |   |
      "                 +---+
      "--------------------------------------------------------------
      let vtokline = 1
      while 1
        let vtoken1 = s:GetToken(vdisplay1,"\n",vtokline)
        if vtoken1 == ''
          break
        endif
        let vstrline = vstrline.vtoken1."\n"
        let vtokline = vtokline + 1
        let vheight = vheight + 1
      endwhile
      if vstrline != ''
        let vstrline = vstrline.' '."\n"
        let vheight = vheight + 1
      endif
      let vtokline = 1
      while 1
        let vtoken2 = s:GetToken(vdisplay2,"\n",vtokline)
        if vtoken2 == ''
          break
        endif
        while strlen(vtoken2) < vcolumn
          let vtoken2 = vtoken2.' '
        endwhile
        let vstrline = vstrline.vtoken2."\n"
        let vtokline = vtokline + 1
        let vheight = vtokline + 1
      endwhile
      let vdisplay1 = vstrline
    endif
    let vmnth = vmnth + 1
    let vmcnt = vmcnt + 1
    if vmnth > 12
      let vmnth = 1
      let vyear = vyear + 1
    endif
  endwhile
  if a:0 == 0
    return vdisplay1
  endif

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ build window
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  " make window
  let vwinnum=bufnr('__Calendar')
  if getbufvar(vwinnum, 'Calendar')=='Calendar'
    let vwinnum=bufwinnr(vwinnum)
  else
    let vwinnum=-1
  endif

  if vwinnum >= 0
    " if already exist
    if vwinnum != bufwinnr('%')
      exe "normal \<c-w>".vwinnum."w"
    endif
    setlocal modifiable
    silent %d _
  else
    " make title
    auto BufEnter *Calendar let &titlestring = strftime('%c')
    auto BufLeave *Calendar let &titlestring = ''

    if exists('g:calendar_navi') && dir
      if g:calendar_navi == 'both'
        let vheight = vheight + 4
      else
        let vheight = vheight + 2
      endif
    endif

    " or not
    if dir
      execute 'bo '.vheight.'split __Calendar'
    else
      execute 'to '.vcolumn.'vsplit __Calendar'
    endif
    setlocal noswapfile
    setlocal buftype=nowrite
    setlocal bufhidden=delete
    setlocal nonumber
    setlocal nowrap
    setlocal norightleft
    setlocal foldcolumn=0
    setlocal modifiable
    let b:Calendar='Calendar'
    " is this a vertical (0) or a horizontal (1) split?
  endif
  let b:CalendarDir=dir

  " navi
  if exists('g:calendar_navi')
    if dir
      let navcol = ((vcolumn/2)*3-8)
    else
      let navcol = ((vcolumn/2)-8)
    endif

    if g:calendar_navi == 'top'
      execute "normal gg".navcol."i "
      silent exec "normal! i<Prev Today Next>\<cr>\<cr>"
      silent put! =vdisplay1
    endif
    if g:calendar_navi == 'bottom'
      silent put! =vdisplay1
      silent exec "normal! Gi\<cr>"
      execute "normal ".navcol."i "
      silent exec "normal! i<Prev Today Next>"
    endif
    if g:calendar_navi == 'both'
      execute "normal gg".navcol."i "
      silent exec "normal! i<Prev Today Next>\<cr>\<cr>"
      silent put! =vdisplay1
      silent exec "normal! Gi\<cr>"
      execute "normal ".navcol."i "
      silent exec "normal! i<Prev Today Next>"
    endif
  else
    silent put! =vdisplay1
  endif

  setlocal nomodifiable

  let vyear = vyear_org
  let vmnth = vmnth_org

  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ build keymap
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  " make keymap
  if vmnth > 1
    execute 'nnoremap <silent> <buffer> <s-left> '
      \.':call Calendar('.dir.','.vyear.','.(vmnth-1).')<cr>'
  else
    execute 'nnoremap <silent> <buffer> <s-left> '
      \.':call Calendar('.dir.','.(vyear-1).',12)<cr>'
  endif
  if vmnth < 12
    execute 'nnoremap <silent> <buffer> <s-right> '
      \.':call Calendar('.dir.','.vyear.','.(vmnth+1).')<cr>'
  else
    execute 'nnoremap <silent> <buffer> <s-right> '
      \.':call Calendar('.dir.','.(vyear+1).',1)<cr>'
  endif
  execute 'nnoremap <silent> <buffer> q :close<cr>'

  execute 'nnoremap <silent> <buffer> <cr> :call <SID>CalendarDoAction()<cr>'
  execute 'nnoremap <silent> <buffer> <2-LeftMouse> :call <SID>CalendarDoAction()<cr>'
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  "+++ build highlight
  "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  " today
  syn clear
  if g:calendar_mark =~ 'left'
    syn match Directory display "\*\s*\d*"
    syn match Identifier display "[+!#$%&@?]\s*\d*"
  endif
  if g:calendar_mark =~ 'left-fit'
    syn match Directory display "\s*\*\d*"
    syn match Identifier display "\s*[+!#$%&@?]\d*"
  endif
  if g:calendar_mark =~ 'right'
    syn match Directory display "\d*\*\s*"
    syn match Identifier display "\d*[+!#$%&@?]\s*"
  endif
  " header
  syn match Special display "[^ ]*\d\+\/\d\+([^)]*)"

  " navi
  if exists('g:calendar_navi')
    syn match Search display "\(<Prev\|Next>\)"
    syn match Search display "\sToday\s"hs=s+1,he=e-1
  endif

  " saturday, sunday
  let dayorspace = '\(\*\|\s\)\(\s\|\d\)\(\s\|\d\)'
  if !exists('g:calendar_weeknm') || g:calendar_weeknm <= 2
    let wknmstring = '\(\sWK[0-9\ ]\d\)*'
  else
    let wknmstring = '\(\sKW[0-9\ ]\d\)*'
  endif
  let eolnstring = '\s\(|\|$\)'
  if exists('g:calendar_monday')
    execute "syn match Statement display \'"
      \.dayorspace.dayorspace.wknmstring.eolnstring."\'ms=s+1,me=s+3"
    execute "syn match Type display \'"
      \.dayorspace.wknmstring.eolnstring."\'ms=s+1,me=s+3"
  else
    if dir
      execute "syn match Statement display \'"
        \.dayorspace.wknmstring.eolnstring."\'ms=s+1,me=s+3"
      execute "syn match Type display \'\|"
        \.dayorspace."\'ms=s+2,me=s+4"
    else
      execute "syn match Statement display \'"
        \.dayorspace.wknmstring.eolnstring."\'ms=s+1,me=s+3"
      execute "syn match Type display \'^"
        \.dayorspace."\'ms=s+1,me=s+3"
    endif
  endif

  " week number
  if !exists('g:calendar_weeknm') || g:calendar_weeknm <= 2
    syn match Comment display "WK[0-9\ ]\d"
  else
    syn match Comment display "KW[0-9\ ]\d"
  endif

  " ruler
  execute 'syn match StatusLine "'.vwruler.'"'

  if search("\*","w") > 0
    silent execute "normal! gg/*\<cr>"
  endif

  return ''
endfunction
 
"*****************************************************************
"* CalendarMakeDir : make directory
"*----------------------------------------------------------------
"*   dir : directory
"*****************************************************************
function! s:CalendarMakeDir(dir)
  if(has("unix"))
    call system("mkdir " . a:dir)
    let rc = v:shell_error
  elseif(has("win16") || has("win32") || has("win95") ||
              \has("dos16") || has("dos32") || has("os2"))
    call system("mkdir \"" . a:dir . "\"")
    let rc = v:shell_error
  else
    let rc = 1
  endif
  if rc != 0
    call confirm("can't create directory : " . a:dir, "&OK")
  endif
  return rc
endfunc

"*****************************************************************
"* CalendarDiary : calendar hook function
"*----------------------------------------------------------------
"*   day   : day you actioned
"*   month : month you actioned
"*   year  : year you actioned
"*****************************************************************
function! s:CalendarDiary(day, month, year, week, dir)
  " build the file name and create directories as needed
  if expand(g:calendar_diary) == ''
    call confirm("please create diary directory : ".g:calendar_diary, 'OK')
    return
  endif
  let sfile = expand(g:calendar_diary) . "/" . a:year
  if isdirectory(sfile) == 0
    if s:CalendarMakeDir(sfile) != 0
      return
    endif
  endif
  let sfile = sfile . "/" . a:month
  if isdirectory(sfile) == 0
    if s:CalendarMakeDir(sfile) != 0
      return
    endif
  endif
  let sfile = expand(sfile) . "/" . a:day . ".cal"
  let sfile = substitute(sfile, ' ', '\\ ', 'g')
  let vwinnum = bufwinnr('__Calendar')

  " load the file
  exe "sp " . sfile
  exe "auto BufLeave ".escape(sfile, ' \\')." normal! ".vwinnum."<c-w>w"
endfunc

"*****************************************************************
"* CalendarSign : calendar sign function
"*----------------------------------------------------------------
"*   day   : day of sign
"*   month : month of sign
"*   year  : year of sign
"*****************************************************************
function! s:CalendarSign(day, month, year)
  let sfile = g:calendar_diary."/".a:year."/".a:month."/".a:day.".cal"
  return filereadable(expand(sfile))
endfunction
