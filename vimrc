" Vim configuration file
" Language:		Vim 6.0 script
" Maintainer:	Lubomir Host <host8@kepler.fmph.uniba.sk>
" Bugs Reports:	Lubomir Host <host8@kepler.fmph.uniba.sk>
" License:		GNU GPL
" Version:		2002.02.05
" 
" Please don't hesitate to correct my english :)
" Send corrections to <host8@kepler.fmph.uniba.sk>

" $Id: vimrc,v 1.51 2002/04/19 16:23:12 host8 Exp $

" Settings {{{
" To be secure & Vi nocompatible
:set secure nocompatible
:if version < 600
:	echo "Please update your vim to 6.0 version (version 6.1 already available!)"
:	finish
:endif

:if version >= 600 
	syntax enable
	filetype on
	filetype plugin on
	filetype indent on
:endif

function! Source(File)
	silent! execute "source " . a:File
endfunction

let VIMRC_EXTRA="~/.vim/vimrc-local"
if executable("uname") && executable("awk")
	let machine = system("uname -n | awk 'BEGIN {ORS=\"\"} {print; }'")
else
	let machine = ""
endif
if executable("awk")
	let user = system("echo $USER | awk 'BEGIN {ORS=\"\"} {print; }'")
else
	let user = $USER
endif

call Source(VIMRC_EXTRA.".pre")
call Source(VIMRC_EXTRA."-".user.".pre")
call Source(VIMRC_EXTRA."-".machine.".pre")
call Source(VIMRC_EXTRA."-".machine."-".user.".pre")
call Source(VIMRC_EXTRA."")
call Source(VIMRC_EXTRA."-".user)
call Source(VIMRC_EXTRA."-".machine)
call Source(VIMRC_EXTRA."-".machine."-".user)

" Settings for C language {{{
let c_gnu=1
let c_comment_strings=1
let c_space_errors=1
" }}}

" History and viminfo settings {{{
if has("history") 
	set history=10000
endif
if has("viminfo")
	if filewritable(expand("$HOME/.vim/viminfo")) == 1 || 
				\ filewritable(expand("$HOME/.vim/")) == 2
		set viminfo=!,%,'5000,\"10000,:10000,/10000,n~/.vim/viminfo
	else
		set viminfo=
	endif
endif
" Don't save backups of files.
set nobackup
" }}}

" Status line settings {{{
":set ruler
" Display a status-bar.
set laststatus=2
if has("statusline")
	set statusline=%5*%{GetID()}%0*%<%f\ %3*%m%1*%r%0*\ %2*%y%4*%w%0*%=[%b\ 0x%B]\ \ %8l,%10([%c%V/%{strlen(getline(line('.')))}]%)\ %P
endif
" }}}

" Settings for Explorer script {{{
let g:explDetailedHelp=1
let g:explDetailedList=1
let g:explDateFormat="%d %b %Y %H:%M"
"}}}
" Settings for gcc & make {{{
let g:cflags="-Wall -pedantic"
let g:c_debug_flags="-ggdb -DDEBUG"
let g:makeflags=""
"}}}
" Settings for AutoLastMod {{{
" Set this to 1 if you will automaticaly change date of modification of file.
let g:autolastmod=1
" Modification is made on line like this variable (regular expression!):
let g:autolastmodtext="^\\([ 	]*Last modified: \\)"
" }}}


" Priority between files for file name completion (suffixes) {{{
" Do not give .h low priority in command-line filename completion.
set suffixes-=.h
set suffixes+=.aux
set suffixes+=.bbl
set suffixes+=.blg
set suffixes+=.log
set wildignore+=*.dvi
" }}}

" The cursor is kept in the same column (if possible).  This applies to the
" commands: CTRL-D, CTRL-U, CTRL-B, CTRL-F, "G", "H", "M", "L", , and to the
" commands "d", "<<" and ">>" with a linewise operator, with "%" with a count
" and to buffer changing commands (CTRL-^, :bnext, :bNext, etc.).  Also for an
" Ex command that only has a line number, e.g., ":25" or ":+".
set nostartofline

" Automatically setting options in various files
set modeline

" Available TAGS files
set tags=./TAGS,./tags,tags

" Don't add EOF at end of file
set noendofline

" Do case insensitive matching
set noignorecase

set showfulltag 

set ch=2 bs=2
set incsearch report=0
set showcmd showmatch showmode

" Set title of the window to Platon's copyright
	set titleold=
	set titlestring=ViMconfig\ (c)\ 2000-2002\ Platon\ SDG
	set title
 
" Indent of 1 tab with size of 4 spaces
set tabstop=4 
set shiftwidth=4 

" Need more undolevels ??
" (default 100, 1000 for Unix, VMS, Win32 and OS/2)
set undolevels=10000

" Use an indent of 4 spaces, with no tabs. This setting is recommended by PEAR
" (PHP Extension and Application Repository) Conding Standarts. If you want
" this setting uncomment the expandtab setting below.
":set expandtab 

" Settings for mouse (gvim under Xwindows)
set nomousefocus mousehide

" Cursor always in the middle of the screen
set scrolloff=999

" Make window maximalized
set winheight=100

" The screen will not be redrawn while executing macros, registers
" and other commands that have not been typed. To force an updates use |:redraw|.
set lazyredraw

" time out on mapping after one second, time out on key codes after
" a tenth of a second
set timeout timeoutlen=1000 ttimeoutlen=100

" Vim beeping go to the hell...
" With very little patch Vim(gvim) doesn't beep! To dissable beeping patch
" source and set ':set noerrorbells' (default).
" Here is patch for version 6.0.193:
" Note: file src/misc1.c was modified with theses patches:
"       6.0.024 6.0.089 6.0.113 6.0.178 6.0.180
"       but patch (probably) also work!
" Patch:
"*** vim60.193/src/misc1.c.orig	Sat Feb  9 01:49:54 2002
"--- vim60.193/src/misc1.c	Sat Feb  9 02:17:16 2002
"***************
"*** 2721,2727 ****
"      void
"  vim_beep()
"  {
"!     if (emsg_silent == 0)
"      {
"  	if (p_vb)
"  	{
"--- 2721,2727 ----
"      void
"  vim_beep()
"  {
"!     if (emsg_silent == 0 && p_eb)
"      {
"  	if (p_vb)
"  	{
set noerrorbells
set visualbell
set t_vb=

" Set this, if you will open all windows for files specified
" on the commandline at vim startup.
let g:open_all_win=1

" Settings for folding long lines
let g:fold_long_lines=300

" }}}

" Keybord mappings {{{
"
" start of line
"noremap <C-A>		i<Home>
inoremap <C-A>		<Home>
cnoremap <C-A>		<Home>
" end of line
noremap <C-E>		i<End>
inoremap <C-E>		<End>
" back one word
inoremap <C-B>	<S-Left>
" forward one word
"inoremap <C-F>	<S-Right>

" Switching between windows by pressing one time CTRL-X keys.
noremap <C-X> <C-W><C-W>

" Tip from http://vim.sourceforge.net/tips/tip.php?tip_id=173
noremap <C-J> <C-W>j<C-W>_
noremap <C-K> <C-W>k<C-W>_

" Make Insert-mode completion more convenient:
imap <C-L> <C-X><C-L>

set remap
map <C-O><C-O> :split 
imap <C-O><C-O> <Esc>:split 

" diakritika 
":map <C-D><C-D> :so ~/.vim/diakritika.vim
":imap <C-D><C-D> <Esc>:so ~/.vim/diakritika.vim

" Open new window with the file ~/.tcshrc (my shell configuration file)
map <C-O><C-T> :split ~/.tcshrc<CR>
imap <C-O><C-T> <Esc>:split ~/.tcshrc<CR>

" Open new window with file ~/.vimrc (ViM configuration file)
map <C-O><C-K> :split ~/.vimrc<CR>
imap <C-O><C-K> <Esc>:split ~/.vimrc<CR>
" Open new window with dir ~/.vim (ViM configuration dir)
map <C-O><C-V> :split ~/.vim<CR>
imap <C-O><C-V> <Esc>:split ~/.vim<CR>

" Safe delete line (don't add line to registers)
":imap <C-D> <Esc>"_ddi
imap <C-D> <Esc>:call SafeLineDelete()<CR>i

" Search for the current Visual selection.
vmap S y/<C-R>=escape(@",'/\')<CR>

" Mappings for folding {{{
" Open one foldlevel of folds in whole file
" Note: 'Z' works like 'z' but for all lines in file
noremap Zo mzggvGzo'z
noremap ZO mzggvGzO'z " same as 'zR' 
noremap Zc mzggvGzc'z
noremap ZC mzggvGzC'z
noremap Zd mzggvGzd'z
noremap ZD mzggvGzD'z
noremap Za mzggvGza'z
noremap ZA mzggvGzA'z
noremap Zx mzggvGzx'z
noremap ZX mzggvGzX'z
" }}}

" }}}

" New commands {{{
command! -nargs=1 Printf call libcallnr("/lib/libc.so.6", "printf", <args>)
command! -nargs=0 FoldLongLines call FoldLongLines()
command! -nargs=0 Indent call Indent()
command! -nargs=0 CallProg call CallProg()
command! -nargs=0 OpenAllWin call OpenAllWin()
command! -nargs=0 UnquoteMailBody call UnquoteMailBody()
command! -nargs=* ReadFileAboveCursor call ReadFileAboveCursor(<f-args>)
command! -nargs=* R call ReadFileAboveCursor(<f-args>)
" }}}

" Autocomands {{{
if has("autocmd")

	" Autocomands for PlatonCopyright {{{
	augroup PlatonCopyright
	autocmd!
		autocmd WinEnter * set titlestring=
		autocmd WinEnter * silent! call RemoveAutogroup("PlatonCopyright")
	augroup END
	" }}}

	" Autocomands for GUIEnter {{{
	augroup GUIEnter
	autocmd!
	"	autocmd GUIEnter * set t_vb=
	if has("gui_win32")
		autocmd GUIEnter * simalt ~x
	endif
	augroup END
	" }}}

	" Autocomands for ~/.vimrc {{{
	augroup VimConfig
	autocmd!
	" Reread configuration of ViM if file ~/.vimrc is saved
	autocmd BufWritePost ~/.vimrc	so ~/.vimrc | exec "normal zv"
	autocmd BufWritePost vimrc   	so ~/.vimrc | exec "normal zv"
	augroup END
	" }}}

	" Autocommands for *.c, *.h, *.cc *.cpp {{{
	augroup C
	autocmd!
	"formatovanie C-zdrojakov
	autocmd BufEnter     *.c,*.h,*.cc,*.cpp	map  <buffer> <C-F> mfggvG$='f
	autocmd BufEnter     *.c,*.h,*.cc,*.cpp	imap <buffer> <C-F> <Esc>mfggvG$='fi
	autocmd BufEnter     *.c,*.h,*.cc,*.cpp	map <buffer> yii yyp3wdwi
	autocmd BufEnter     *.c,*.h,*.cc,*.cpp	map <buffer> <C-K> :call CallProg()<CR>
	autocmd BufRead,BufNewFile  *.c,*.h,*.cc,*.cpp	setlocal cindent
	autocmd BufRead,BufNewFile  *.c,*.h,*.cc,*.cpp	setlocal cinoptions=>4,e0,n0,f0,{0,}0,^0,:4,=4,p4,t4,c3,+4,(2s,u1s,)20,*30,g4,h4
	autocmd BufRead,BufNewFile  *.c,*.h,*.cc,*.cpp	setlocal cinkeys=0{,0},:,0#,!<C-F>,o,O,e
	augroup END
	" }}}

	" Autocommands for *.html *.cgi {{{
	" Automatic updates date of last modification in HTML files. File must
	" contain line "^\([<space><Tab>]*\)Last modified: ",
	" else will be date writtend on the current " line.
	augroup HtmlCgiPHP
	autocmd!
	" Appending right part of tag in HTML files.
	autocmd BufEnter                 *.html	imap <buffer> QQ </><Esc>2F<lywf>f/pF<i
	autocmd BufWritePre,FileWritePre *.html	call AutoLastMod()
	autocmd BufEnter                 *.cgi	imap <buffer> QQ </><Esc>2F<lywf>f/pF<i
	autocmd BufWritePre,FileWritePre *.cgi	call AutoLastMod()
	autocmd BufEnter                 *.php	imap <buffer> QQ </><Esc>2F<lywf>f/pF<i
	autocmd BufWritePre,FileWritePre *.php	call AutoLastMod()
	autocmd BufEnter                 *.php3	imap <buffer> QQ </><Esc>2F<lywf>f/pF<i
	autocmd BufWritePre,FileWritePre *.php3	call AutoLastMod()
	augroup END
	" }}}

	" Autocomands for *.tcl {{{
	augroup Tcl
	autocmd!
	autocmd WinEnter            *.tcl	map <buffer> <C-K> :call CallProg()<CR>
	autocmd BufRead,BufNewFile  *.tcl	setlocal autoindent
	augroup END
	" }}}

	" Autocomands for Makefile {{{
	augroup Makefile
	autocmd!
	autocmd BufEnter            [Mm]akefile*	map <buffer> <C-K> :call CallProg()<CR>
	augroup END
	" }}}

endif " if has("autocmd")
" }}} Autocomands

" Functions {{{
" Function ChangeFoldMethod() {{{
" Function for changing folding method.
"
if version >= 600
	function! ChangeFoldMethod()
		let choice = confirm("Which folde method?", "&manual\n&indent\n&expr\nma&rker\n&syntax", 2)
		if choice == 1
			set foldmethod=manual
		elseif choice == 2
			set foldmethod=indent
		elseif choice == 3
			set foldmethod=expr
		elseif choice == 4
			set foldmethod=marker
		elseif choice == 5
			set foldmethod=syntax
		else
		endif
	endfunction
endif
" ChangeFoldMethod() }}}

" Function FoldLongLines() {{{
"
if version >= 600
	fun! FoldLongLines()
"		Get screen size:
		let lines = system("`which tcsh` -f -c telltc | " .
				\ "grep lines | awk '{print \$6-1}'")
		let info = "<Esc>[" . lines . ";0HProcessing line "
"		Set mark for return back
		exec "normal mF"
"		Delete line
		Printf(&t_dl)
		exec "1go"
		let lnum = line(".")
		let lend = line("$")
		while lnum <= lend
			Printf(info . lnum)
"			Skip closed folds
			if foldclosed(lnum) != -1
				let lnum = foldclosedend(lnum) + 1
				continue
			endif
			let dlzka = strlen(getline("."))
			if dlzka >= g:fold_long_lines
"				Create fold for one line
				exec "normal zfl"
			endif
			let lnum = line(".")
"			Move one line down
			exec "normal j"
			if lnum == lend
				break
			endif
		endwhile
		Printf("  --  OK\n")
"		Skip back to the mark
		exec "normal 'F"
		redraw!
	endfunction
endif
" FoldLongLines() }}}

" Function AutoLastMod() {{{
" Provides atomatic change of date in files, if it is set via
" modeline variable autolastmod to appropriate value.
"
function! AutoLastMod()
if exists("g:autolastmod")
	if g:autolastmod < 0
		return 0;
	elseif g:autolastmod == 1
		call LastMod(g:autolastmodtext)
	endif
endif
endfunction
" AutoLastMod() }}}

" Function LastMod() {{{
" Automatic change date in *.html files.
"
function! LastMod(text, ...)
	mark d
	let line = "\\1" . strftime("%Y %b %d %X") " text of changed line
	let find = "g/" . a:text           " regexpr to find line
	let matx = a:text . ".*"            " ...if line was found
	exec find
	let curr_line = getline(".")
	if match(curr_line, matx) == 0
		" call setline(line("."), line)
		call setline(line("."), substitute(getline("."), matx, line, ""))
		exec "'d"
	endif
endfunction
" LastMod() }}}

" Function OpenAllWin() {{{
" Opens windows for all files in the command line.
" Variable "opened" is used for testing, if window for file was already opened
" or not. This is prevention for repeat window opening after ViM config file
" reload.
"
function! OpenAllWin()
	" save Vim option to variable
	let s:save_split = &splitbelow
	set splitbelow

	let s:i = 1
	if g:open_all_win == 1
		while s:i < argc()
			if bufwinnr(argv(s:i)) == -1	" buffer doesn't exists or doesn't have window
				exec ":split " . argv(s:i)
			endif
			let s:i = s:i + 1
		endwhile
	endif

	" restore Vim option from variable
	if s:save_split
		set splitbelow
	else
		set nosplitbelow
	endif
endfunction

if exists("g:open_all_win")
	if g:open_all_win == 1
		call OpenAllWin()
		" turn g:open_all_win off after opening all windows
		" it prevents reopen windows after 2nd sourcing .vimrc
		let g:open_all_win = 0
	endif
endif
" OpenAllWin() }}}

" Function CallProg() {{{
function! CallProg()
	let choice = confirm("Call:", "&make\nm&ake in cwd\n" .
						\ "&compile\nc&ompile in cwd\n" .
						\ "&run\nr&un in cwd")
	if choice == 1
		exec ":wall"
		exec "! cd %:p:h; pwd; make " . g:makeflags
	elseif choice == 2
		exec ":wall"
		exec "! cd " .
				\ getcwd() . "; pwd; make " . g:makeflags
	elseif choice == 3
		:call Compile(1)
	elseif choice == 4
		:call Compile(0)
	elseif choice == 5
		exec "! cd %:p:h; pwd; ./%:t:r"
	elseif choice == 6
		exec "! cd " . getcwd() . "; pwd; ./%<"
	endif
endfunction
" CallProg() }}}

" Function Compile() {{{
function! Compile(do_chdir)
	let cmd = ""
	let filename = ""
	let filename_ext = ""

	if a:do_chdir == 1
		let cmd = "! cd %:p:h; pwd; "
		let filename = "%:t:r"
		let filename_ext = "%:t"
	else
		let cmd = "! cd " . getcwd() . "; pwd; "
		let filename = "%<"
		let filename_ext = "%"
	endif

	let choice = confirm("Call:", 
		\ "&compile\n" .
		\ "compile and &debug\n" .
		\ "compile and &run\n" .
		\ "compile using first &line")

	if choice != 0
		exec ":wall"
	endif

	if choice == 1
		exec cmd . "gcc " . g:cflags . 
			\ " -o " . filename . " " . filename_ext
	elseif choice == 2
		exec cmd . "gcc " . g:cflags . " " . g:c_debug_flags . 
			\ " -o " . filename . " " . filename_ext " && gdb " . filename
	elseif choice == 3
		exec cmd . "gcc " . g:cflags . 
			\ " -o " . filename . " " . filename_ext " && ./" . filename
	elseif choice == 4
		exec cmd . "gcc " . g:cflags . 
			\ " -o " . filename . " " . filename_ext . 
			\ substitute(getline(2), "VIMGCC", "", "g")
	endif
endfunction
" Compile() }}}

" Function Indent() {{{
" Indents source code.
function! Indent()
" If there is set equalprg to source indenting (ie. perltidy for perl sources)
" we have not to executes "'f" at the end, else we will got "Mark not set"
" error message.
	if &equalprg == ""
		exec "normal mfggvG$='f"
	else
		exec "normal mfggvG$="
	endif
endfunction
" Indent() }}}

" Function UnquoteMailBody() {{{
"
function! UnquoteMailBody()
" Every backslash character must be escaped in function -- Nepto
	exec "normal :%s/^\\([ ]*>[ ]*\\)*\\(\\|[^>].*\\)$/\\2/g<CR>"
endfunction
" UnquoteMailBody() }}}

" Function SafeLineDelete() {{{
"
function! SafeLineDelete()
	exec "normal \"_dd"
endfunction
" SafeLineDelete() }}}

" Function GetID() {{{
" - used in statusline.
" If you are root, function return "# " string --> it is showed at begin of
"                                                  statusline
" If you aren't root, function return empty string --> nothing is visible
let g:get_id=""
" Check for your name ID
let g:get_id = $USER
" If you are root, set to '#', else set to ''
if g:get_id == "root"
	let g:get_id = "# "
else
	let g:get_id = ""
endif
function! GetID()
	return g:get_id
endfunction
" GetID() }}}

" Function ReadFileAboveCursor() {{{
"
function! ReadFileAboveCursor(file, ...)
	let str = ":" . (v:lnum - 1) . "read " . a:file
	let idx = 1
	while idx <= a:0
		exec "let str = str . \" \" . a:" . idx
		let idx = idx + 1
	endwhile
	exec str
endfunction
" ReadFileAboveCursor() }}}

" Function RemoveAutogroup() {{{
"
silent! function! RemoveAutogroup(group)
	silent exec "augroup! ". a:group
endfunction
" RemoveAutogroup() }}}
" }}}

" Gvim settings {{{
if &t_Co > 2 || has("gui_running")
	hi Normal guibg=Black guifg=White
	hi Cursor guibg=Green guifg=NONE
	hi NonText guibg=Black
	hi Constant gui=NONE 
	hi Special gui=NONE
endif
" }}}

" Colors {{{
set background=dark
hi StatusLine   term=bold,reverse cterm=bold,reverse
hi StatusLineNC term=reverse      cterm=reverse
hi StatusLine   gui=bold          guifg=Black guibg=White
hi StatusLineNC gui=bold,reverse  guifg=White guibg=Black
hi User1 term=inverse,bold  cterm=inverse,bold ctermfg=Red
hi User2 term=bold          cterm=bold         ctermfg=Yellow
hi User3 term=inverse,bold  cterm=inverse,bold ctermfg=Blue
hi User4 term=inverse,bold  cterm=inverse,bold ctermfg=LightBlue
hi User5 term=inverse,bold  cterm=inverse,bold ctermfg=Red ctermbg=Green
hi User1 gui=bold guifg=White     guibg=Red
hi User2 gui=bold guifg=Yellow    guibg=Black
hi User3 gui=bold guifg=Blue      guibg=White
hi User4 gui=bold guifg=LightBlue guibg=White
hi User5 gui=bold guifg=Green     guibg=Red
hi Folded     term=standout cterm=bold ctermfg=4        ctermbg=Black
hi FoldColumn term=standout            ctermfg=DarkBlue ctermbg=Black 
hi Folded     gui=bold guibg=Black guifg=Blue
hi FoldColumn          guibg=Black guifg=Blue

" }}}

call Source(VIMRC_EXTRA.".post")
call Source(VIMRC_EXTRA."-".user.".post")
call Source(VIMRC_EXTRA."-".machine.".post")
call Source(VIMRC_EXTRA."-".machine."-".user.".post")

" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
" }}}

