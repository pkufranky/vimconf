" Vim configuration file
" Language:		Vim 5.6 script    (with Vim 6.0 features)
" Maintainer:	Lubomir Host <host8@kepler.fmph.uniba.sk>
" Bugs Reports:	Lubomir Host <host8@kepler.fmph.uniba.sk>
" License:		GNU GPL
" Version:		01.09.08
" Language Of Comments:	English

" $Id: vimrc,v 1.31 2002/01/25 21:43:59 host8 Exp $

" Settings {{{
" To be secure & Vi nocompatible
set secure nocompatible
if version >= 600 
	syntax enable
	filetype on
	filetype plugin on
	filetype indent on
else
	syntax on
endif

" Settings for C language {{{
let c_gnu=1
let c_comment_strings=1
let c_space_errors=1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" History and viminfo settings {{{
set history=10000
if filewritable(expand("$HOME/.vim/viminfo")) == 1 || 
			\ filewritable(expand("$HOME/.vim/")) == 2
	set viminfo=!,%,'5000,\"10000,:10000,/10000,n~/.vim/viminfo
else
	set viminfo=
endif
" Don't save backups of files.
set nobackup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Status line settings {{{
":set ruler
" Display a status-bar.
set laststatus=2
set statusline=%<%f%h\ %3*%m%1*%r%0*\ %2*%y%4*%w%0*%=[%b\ 0x%B]\ \ %8l,%10([%c%V/%{strlen(getline(line('.')))}]%)\ %P
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
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
" Settings for folding long lines {{{
let g:fold_long_lines=300
" }}}
" Settings for AutoLastMod {{{
" Set this to 1 if you will automaticaly change date of modification of file.
let g:autolastmod=1
" Modification is made on line like this variable:
let g:autolastmodtext="Last modified: "
" }}}

" Automatically setting options in various files
set modeline

" Available TAGS files
set tags=./TAGS,./tags,tags

" Don't add EOF at end of file
set noendofline
" Do case insensitive matching
set noignorecase

set showfulltag 

set ch=2 bs=2 tabstop=4
set incsearch report=0 title
set showcmd showmatch showmode

" Indent of 1 tab with size of 4 spaces
set tabstop=4 
set shiftwidth=4 

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

" Vim beeping go to the hell...
set vb t_vb=

" Set this, if you will open all windows for files specified
" on the commandline at vim startup.
let g:open_all_win=1

"################################################################# }}}
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
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
"################################################################# }}}
" New commands {{{
command! -nargs=1 Printf call libcallnr("/lib/libc.so.6", "printf", <args>)
command! -nargs=0 FoldLongLines call FoldLongLines()
command! -nargs=0 Indent call Indent()
command! -nargs=0 CallProg call CallProg()
command! -nargs=0 OpenAllWin call OpenAllWin()
command! -nargs=0 UnquoteMailBody call UnquoteMailBody()
command! -nargs=* ReadFileAboveCursor call ReadFileAboveCursor(<f-args>)
command! -nargs=* R call ReadFileAboveCursor(<f-args>)
"################################################################# }}}
" Autocomands {{{
if has("autocmd")
" Autocomands for ~/.vimrc {{{
augroup VimConfig
	autocmd!
" Reread configuration of ViM if file ~/.vimrc is saved
	autocmd BufWritePost ~/.vimrc	so ~/.vimrc
	autocmd BufWritePost vimrc	so ~/.vimrc
augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
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
" vytvaranie hlaviciek novych *.c, *.h suborov
	autocmd BufNewFile  *.c,*.cc,*.cpp	0r ~/.vim/skelet.c
	autocmd BufNewFile	 *.h	call MakeHeader()
augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Autocommands for *.html *.cgi {{{
" Automatic updates date of last modification in HTML files. File must
" contain line "^Last modified: ", else will be date writtend on the current
" line.
augroup HtmlCgi
	autocmd!
" Appending right part of tag in HTML files.
	autocmd BufEnter                 *.html	imap <buffer> QQ </><Esc>2F<lywf>f/pF<i
	autocmd BufWritePre,FileWritePre *.html	call AutoLastMod()
	autocmd BufEnter                 *.cgi	imap <buffer> QQ </><Esc>2F<lywf>f/pF<i
	autocmd BufWritePre,FileWritePre *.cgi	call AutoLastMod()
augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Autocomands for *.tcl {{{
augroup Tcl
	autocmd!
	autocmd WinEnter            *.tcl	map <buffer> <C-K> :call CallProg()<CR>
	autocmd BufRead,BufNewFile  *.tcl	setlocal autoindent
augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Autocomands for Makefile {{{
augroup Makefile
	autocmd!
	autocmd BufEnter            [Mm]akefile*	map <buffer> <C-K> :call CallProg()<CR>
augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Autocomands on Win32 {{{
if has("gui_win32")
	au GUIEnter * simalt ~x
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
endif " if has("autocmd")
"################################################################# }}}
" Functions {{{
" Function ChangeFoldMethod() {{{
" Function for changing folding method.
"
if version >= 600
	fun! ChangeFoldMethod()
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
	endfun
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
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
			exec "normal OB"
			if lnum == lend
				break
			endif
		endwhile
		Printf("  --  OK\n")
"		Skip back to the mark
		exec "normal 'F"
		redraw!
	endfun
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Function SetVimVar() {{{
" Functions set appropriate values in variables according to line in
" 'modelines' VIM_VAR: var1=value1 var2=value2
" 
"fun! SetVimVar()
":$-5,$ call SetVimVarFromLine()
"endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Function SetVimVarFromLine() {{{
" 
"fun! SetVimVarFromLine()
":let matx = ".* VIM_VAR: "
":let curr_line = getline(".")
":if match(curr_line, matx) == 0
":	echo "Match on line " . "|" . curr_line
":	exec ":let " . substitute(curr_line, matx, "", "")
":endif
"endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Function AutoLastMod() {{{
" Provides atomatic change of date in files, if it is set via
" modeline variable autolastmod to appropriate value.
"
fun! AutoLastMod()
if exists("g:autolastmod")
	if g:autolastmod < 0
		return 0;
	elseif g:autolastmod == 1
		call LastMod(g:autolastmodtext)
	endif
endif
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Function LastMod() {{{
" Automatic change date in *.html files.
"
fun! LastMod(text, ...)
	mark d
	let line = a:text . strftime("%Y %b %d %X") " text of changed line
	let find = "g/^" . a:text                   " regexpr to find line
	let matx = "^" . a:text                     " ...if line was found
	exec find
	let curr_line = getline(".")
	if match(curr_line, matx) == 0
		call setline(line("."), line)
		exec "'d"
	endif
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Function MakeHeader() {{{
" Prepare header in *.h files.
"
fun! MakeHeader() 
" Line look variables.
let line = "" . bufname("%")
let line = substitute(line, "\\\.", "_\0", "")
let line1 = substitute(line, ".*", "#ifndef _\\U\\0", "")
let line2 = substitute(line, ".*", "#define _\\U\\0", "")
let line6 = "#endif /* " . line1 . " */"
" Writeout of sets variebles.
":echo line
" ...
" Setting appropriate lines according to the prepared variables.
" In target file there must be sufficient number of lines, else setline() will
" fails. Function append() appends next line into file, see :help append
call setline(1, line1)
call append(1, line2)
call append(2, "")
call append(3, "")
call append(4, "")
call append(5, "")
call setline(6, line6)
call append(6, "")
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Function OpenAllWin() {{{
" Opens windows for all files in the command line.
" Variable "opened" is used for testing, if window for file was already opened
" or not. This is prevention for repeat window opening after ViM config file
" reload.
"
fun! OpenAllWin()
	let i = 0
	if !exists("opened")
		while i < argc() - 1
			split
			n
			let i = i + 1
		endwhile
	endif
	let opened = 1
endfun

if exists("g:open_all_win")
	call OpenAllWin()
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Function CallProg() {{{
fun! CallProg()
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
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Function Compile() {{{
fun! Compile(do_chdir)
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
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Function Indent() {{{
" Indents source code.
fun! Indent()
" If there is set equalprg to source indenting (ie. perltidy for perl sources)
" we have not to executes "'f" at the end, else we will got "Mark not set"
" error message.
	if &equalprg == ""
		exec "normal mfggvG$='f"
	else
		exec "normal mfggvG$="
	endif
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Function UnquoteMailBody() {{{
"
fun! UnquoteMailBody()
" Every backslash character must be escaped in function -- Nepto
	exec "normal :%s/^\\([ ]*>[ ]*\\)*\\(\\|[^>].*\\)$/\\2/g<CR>"
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Function SafeLineDelete() {{{
"
fun! SafeLineDelete()
	exec "normal \"_dd"
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
" Function ReadFileAboveCursor() {{{
"
fun! ReadFileAboveCursor(file, ...)
	let str = ":" . (v:lnum - 1) . "read " . a:file
	let idx = 1
	while idx <= a:0
		exec "let str = str . \" \" . a:" . idx
		let idx = idx + 1
	endwhile
	exec str
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}
"################################################################# }}}
" Gvim settings {{{
if &t_Co > 2 || has("gui_running")
	hi Normal guibg=Black guifg=White
	hi Cursor guibg=Green guifg=NONE
	hi NonText guibg=Black
	hi Constant gui=NONE 
	hi Special gui=NONE
endif
"################################################################# }}}
" Colors {{{
set background=dark
hi User1 term=inverse,bold  cterm=inverse,bold ctermfg=red
hi User2 term=bold          cterm=bold         ctermfg=yellow
hi User3 term=inverse,bold  cterm=inverse,bold ctermfg=blue
hi User4 term=inverse,bold  cterm=inverse,bold ctermfg=lightblue
hi Folded term=standout   ctermbg=black ctermfg=Blue guifg=DarkBlue
hi FoldColumn term=standout ctermbg=black ctermfg=DarkBlue guibg=Grey guifg=DarkBlue
" }}}
" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
"################################################################# }}}
