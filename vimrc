" Vim configuration file
" Language:		Vim 5.6 script    (with Vim 6.0 features)
" Maintainer:	Lubomir Host <host8@kepler.fmph.uniba.sk>
" Bugs Reports:	Lubomir Host <host8@kepler.fmph.uniba.sk>
" License:		GNU GPL
" Version:		01.09.08
" Language Of Comments:	English

" $Id: vimrc,v 1.25 2001/12/15 04:26:34 host8 Exp $

" Settings {{{1
" To be secure & Vi nocompatible
:set secure nocompatible
:if version >= 600 
:	syntax enable
:else
:	syntax on
:endif

" Settings for C language {{{2
:let c_gnu=1
:let c_comment_strings=1
:let c_space_errors=1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" History and viminfo settings {{{2
:set history=10000
:if filewritable(expand("$HOME/.vim/viminfo")) == 1 || 
			\ filewritable(expand("$HOME/.vim/")) == 2
:	set viminfo=!,%,'5000,\"10000,:10000,/10000,n~/.vim/viminfo
:else
:	set viminfo=
:endif
" Don't save backups of files.
:set nobackup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Status line settings {{{2
":set ruler
" Display a status-bar.
:set laststatus=2
:set statusline=%<%f%h\ %3*%m%1*%r%0*\ %2*%y%4*%w%0*%=[%b\ 0x%B]\ \ %8l,%10([%c%V/%{strlen(getline(line('.')))}]%)\ %P
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Settings for Explorer script {{{
:let g:explDetailedHelp=1
:let g:explDetailedList=1
:let g:explDateFormat="%d %b %Y %H:%M"
"}}}
" Settings for gcc & make {{{
:let g:cflags="-Wall -pedantic"
:let g:c_debug_flags="-ggdb -DDEBUG"
:let g:makeflags=""
"}}}
" Settings for folding long lines {{{
:let g:fold_long_lines=300
" }}}
" Settings for AutoLastMod {{{
" Set this to 1 if you will automaticaly change date of modification of file.
:let g:autolastmod=1
" Modification is made on line like this variable:
:let g:autolastmodtext="Last modified: "
" }}}

" Automatically setting options in various files
:set modeline

" Available TAGS files
:set tags=./TAGS,./tags,tags

" Don't add EOF at end of file
:set noendofline
" Do case insensitive matching
:set noignorecase

:set showfulltag 

:set ch=2 bs=2 tabstop=4
:set incsearch report=0 title
:set showcmd showmatch showmode

" Indent of 1 tab with size of 4 spaces
:set tabstop=4 
:set shiftwidth=4 

" Use an indent of 4 spaces, with no tabs. This setting is recommended by PEAR
" (PHP Extension and Application Repository) Conding Standarts. If you want
" this setting uncomment the expandtab setting below.
":set expandtab 

" Settings for mouse (gvim under Xwindows)
:set nomousefocus mousehide

" Cursor always in the middle of the screen
:set scrolloff=999

" Make window maximalized
:set winheight=100

" The screen will not be redrawn while executing macros, registers
" and other commands that have not been typed. To force an updates use |:redraw|.
:set lazyredraw

" Vim beeping go to the hell...
:set vb t_vb=

" Set this, if you will open all windows for files specified
" on the commandline at vim startup.
:let g:open_all_win=1

"################################################################# }}}1
" Keybord mappings {{{1
"
" start of line
":noremap <C-A>		i<Home>
:inoremap <C-A>		<Home>
" end of line
:noremap <C-E>		i<End>
:inoremap <C-E>		<End>
" back one word
:inoremap <C-B>	<S-Left>
" forward one word
":inoremap <C-F>	<S-Right>

" Switching between windows by pressing one time CTRL-X keys.
:noremap <C-X> <C-W><C-W>

:set remap
:map  :split 
:imap  :split 

" diakritika 
":map  :so ~/.vim/diakritika.vim
":imap  :so ~/.vim/diakritika.vim

" Open new window with the file ~/.tcshrc (my shell configuration file)
:map  :split ~/.tcshrc
:imap  :split ~/.tcshrc

" Open new window with file ~/.vimrc (ViM configuration file)
:map  :split ~/.vimrc
:imap  :split ~/.vimrc

" Safe delete line (don't add line to registers)
":imap  "_ddi
:imap  :call SafeLineDelete()i

" Mappings for folding {{{2
" Open one foldlevel of folds in whole file
" Note: 'Z' works like 'z' but for all lines in file
:noremap Zo mzggvGzo'z
:noremap ZO mzggvGzO'z " same as 'zR' 
:noremap Zc mzggvGzc'z
:noremap ZC mzggvGzC'z
:noremap Zd mzggvGzd'z
:noremap ZD mzggvGzD'z
:noremap Za mzggvGza'z
:noremap ZA mzggvGzA'z
:noremap Zx mzggvGzx'z
:noremap ZX mzggvGzX'z
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
"################################################################# }}}1
" New commands {{{1
:command! -nargs=1 Printf call libcallnr("/lib/libc.so.6", "printf", <args>)
:command! -nargs=0 FoldLongLines call FoldLongLines()
:command! -nargs=0 Indent call Indent()
:command! -nargs=0 CallProg call CallProg()
:command! -nargs=0 OpenAllWin call OpenAllWin()
:command! -nargs=0 UnquoteMailBody call UnquoteMailBody()
:command! -nargs=* ReadFileAboveCursor call ReadFileAboveCursor(<f-args>)
:command! -nargs=* R call ReadFileAboveCursor(<f-args>)
"################################################################# }}}1
" Filetype detect {{{
let s:line1 = getline(1)
if s:line1 =~ '^From [a-zA-Z][a-zA-Z_0-9\.=-]*\(@[^ ]*\)\= .*[12][09]\d\d$'
  set filetype=mail
endif
unlet s:line1
" }}}
" Filetypes settings {{{1
" Function SetsByFiletype() is defined as autocommand for each file and it is
" always called when new file is read or opened. There are settings which will
" be sets according to specific file type. Try to avoid of use 'set' command
" here. Use 'setlocal' command instead.
fun! SetsByFiletype()
" Mail {{{2
:if &filetype == "mail"
:	setlocal textwidth=72
:	setlocal noautoindent
:	setlocal formatoptions=croqt
:	map  <buffer>  gqap
:	imap <buffer>  gqapi
:endif
" }}}2
" Perl {{{2
:if &filetype == "perl"
:	if executable("perltidy")
:		setlocal equalprg=perltidy\ -q\ -se\ -fnl
:	endif
:endif
" }}}2
endfun
"################################################################# }}}1
" Autocomands {{{1
" Startup autocommands {{{2
:augroup VimStartup
:  autocmd!
":	autocmd VimEnter *	:syntax on
":	autocmd VimEnter *	call OpenAllWin()
":	autocmd BufReadPost *	call SetVimVar()
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocommands WinEnter * {{{2
:augroup VimEnter
:  autocmd!
":	autocmd WinEnter *	:set winheight=100
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocommands for * (all files) {{{2
:augroup AllFiles
:  autocmd!
:	autocmd BufRead,BufNewFile  *	call SetsByFiletype()
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocomands for ~/.vimrc {{{2
:augroup VimConfig
:  autocmd!
" Update line 'Last Change:'
:	autocmd BufWritePre,FileWritePre ~/.vimrc	call LastMod("\" Last Change:	")
:	autocmd BufWritePre,FileWritePre vimrc	call LastMod("\" Last Change:	")
" Reread configuration of ViM if file ~/.vimrc is saved
:	autocmd BufWritePost ~/.vimrc	so ~/.vimrc
:	autocmd BufWritePost vimrc	so ~/.vimrc
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocommands for *.c, *.h, *.cc *.cpp {{{2
:augroup C
:  autocmd!
"formatovanie C-zdrojakov
:	autocmd BufEnter            *.c,*.h,*.cc,*.cpp	map  <buffer>  mfggvG$='f
:	autocmd BufEnter            *.c,*.h,*.cc,*.cpp	imap <buffer>  mfggvG$='fi
:	autocmd BufEnter            *.c,*.h,*.cc,*.cpp	map <buffer> yii yyp3wdwi
:	autocmd BufEnter            *.c,*.h,*.cc,*.cpp	map <buffer>  :call CallProg()
:	autocmd BufRead,BufNewFile  *.c,*.h,*.cc,*.cpp	setlocal cindent
:	autocmd BufRead,BufNewFile  *.c,*.h,*.cc,*.cpp	setlocal cinoptions=>4,e0,n0,f0,{0,}0,^0,:4,=4,p4,t4,c3,+4,(2s,u1s,)20,*30,g4,h4
:	autocmd BufRead,BufNewFile  *.c,*.h,*.cc,*.cpp	setlocal cinkeys=0{,0},:,0#,!,o,O,e
" vytvaranie hlaviciek novych *.c, *.h suborov
:	autocmd BufNewFile  *.c,*.cc,*.cpp	0r ~/.vim/skelet.c
:	autocmd BufNewFile	 *.h	call MakeHeader()
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocommands for *.pl *.pm {{{2
:augroup Perl
:  autocmd!
:	autocmd BufEnter            *.p[lm]	map  <buffer>  mfggvG$='f
:	autocmd BufEnter            *.p[lm]	imap <buffer>  mfggvG$='fi
:	autocmd BufEnter            *.p[lm]	map  <buffer>  :call CallProg()
:	autocmd BufRead,BufNewFile  *.p[lm]	setlocal cindent
:	autocmd BufRead,BufNewFile  *.p[lm]	setlocal cinoptions=>4,e0,n0,f0,{0,}0,^0,:4,=4,p4,t4,c3,+4,(24,u4,)20,*30,g4,h4
:	autocmd BufRead,BufNewFile  *.p[lm]	setlocal cinkeys=0{,0},:,0#,!,o,O,e
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocommands for *.pinerc {{{2
:augroup Pine
:  autocmd!
:	autocmd BufRead .pinerc so ~/.vim/pine.vim
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocommands for *.php {{{2
:augroup PHP
:  autocmd!
":	autocmd BufRead *.php so /usr/share/vim/syntax/php3.vim
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocommands for *.html *.cgi {{{2
" Automatic updates date of last modification in HTML files. File must
" contain line "^Last modified: ", else will be date writtend on the current
" line.
:augroup HtmlCgi
:  autocmd!
" Appending right part of tag in HTML files.
:	autocmd BufEnter                 *.html	imap <buffer> QQ </>2F<lywf>f/pF<i
:	autocmd BufWritePre,FileWritePre *.html	call AutoLastMod()
:	autocmd BufEnter                 *.cgi	imap <buffer> QQ </>2F<lywf>f/pF<i
:	autocmd BufWritePre,FileWritePre *.cgi	call AutoLastMod()
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocommands for *.gz {{{2
:if version < 600
:  augroup gzip
:    autocmd!
:    autocmd BufReadPre,FileReadPre	*.gz set bin
:    autocmd BufReadPost,FileReadPost	*.gz '[,']!gunzip
:    autocmd BufReadPost,FileReadPost	*.gz setlocal nobin
:    autocmd BufReadPost,FileReadPost	*.gz execute ":doautocmd BufReadPost " . expand("%:r")
:    autocmd BufWritePost,FileWritePost	*.gz !mv <afile> <afile>:r
:    autocmd BufWritePost,FileWritePost	*.gz !gzip <afile>:r
:    autocmd FileAppendPre		*.gz !gunzip <afile>
:    autocmd FileAppendPre		*.gz !mv <afile>:r <afile>
:    autocmd FileAppendPost		*.gz !mv <afile> <afile>:r
:    autocmd FileAppendPost		*.gz !gzip <afile>:r
:  augroup END
:else
:  " empty
:endif
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocommands for *.bz2 {{{2
:augroup bzip2
:  autocmd!
:  autocmd BufReadPre,FileReadPre	*.bz2 setlocal bin
:  autocmd BufReadPost,FileReadPost	*.bz2 '[,']!bunzip2
:  autocmd BufReadPost,FileReadPost	*.bz2 setlocal nobin
:  autocmd BufReadPost,FileReadPost	*.bz2 execute ":doautocmd BufReadPost " . expand("%:r")
:  autocmd BufWritePost,FileWritePost	*.bz2 !mv <afile> <afile>:r
:  autocmd BufWritePost,FileWritePost	*.bz2 !bzip2 <afile>:r
:  autocmd FileAppendPre		*.bz2 !bunzip2 <afile>
:  autocmd FileAppendPre		*.bz2 !mv <afile>:r <afile>
:  autocmd FileAppendPost		*.bz2 !mv <afile> <afile>:r
:  autocmd FileAppendPost		*.bz2 !bzip2 <afile>:r
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocomands for *.tcl {{{2
:augroup Tcl
:  autocmd!
:	autocmd WinEnter            *.tcl	map <buffer>  :call CallProg()
:	autocmd BufRead,BufNewFile  *.tcl	setlocal autoindent
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocomands for *.tex {{{2
:augroup TeX
:  autocmd!
:	autocmd WinEnter            *.tex	
:	autocmd WinLeave            *.tex	
:	autocmd BufRead,BufNewFile  *.tex	  setlocal formatoptions=croqt
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocomands for Makefile {{{2
:augroup Makefile
:  autocmd!
:	autocmd BufEnter            [Mm]akefile*	map <buffer>  :call CallProg()
:augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Autocommands for "Diplomovka" {{{2
":augroup Diplomovka
":  autocmd!
":	autocmd BufWritePost,FileWritePost	~/dipl/xgrafix/src/* !make install
":augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
"################################################################# }}}1
" Functions {{{1
" Function ChangeFoldMethod() {{{2
" Function for changing folding method.
"
:if version >= 600
:	fun! ChangeFoldMethod()
:		let choice = confirm("Which folde method?", "&manual\n&indent\n&expr\nma&rker\n&syntax", 2)
:		if choice == 1
:			set foldmethod=manual
:		elseif choice == 2
:			set foldmethod=indent
:		elseif choice == 3
:			set foldmethod=expr
:		elseif choice == 4
:			set foldmethod=marker
:		elseif choice == 5
:			set foldmethod=syntax
:		else
:		endif
:	endfun
:endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function FoldLongLines() {{{2
"
:if version >= 600
:	fun! FoldLongLines()
"		Get screen size:
:		let lines = system("`which tcsh` -f -c telltc | " .
				\ "grep lines | awk '{print \$6-1}'")
:		let info = "[" . lines . ";0HProcessing line "
"		Set mark for return back
:		exec "normal mF"
"		Delete line
:		Printf(&t_dl)
:		exec "1go"
:		let lnum = line(".")
:		let lend = line("$")
:		while lnum <= lend
:			Printf(info . lnum)
"			Skip closed folds
:			if foldclosed(lnum) != -1
:				let lnum = foldclosedend(lnum) + 1
:				continue
:			endif
:			let dlzka = strlen(getline("."))
:			if dlzka >= g:fold_long_lines
"				Create fold for one line
:				exec "normal zfl"
:			endif
:			let lnum = line(".")
"			Move one line down
:			exec "normal OB"
:			if lnum == lend
:				break
:			endif
:		endwhile
:		Printf("  --  OK\n")
"		Skip back to the mark
:		exec "normal 'F"
:		redraw!
:	endfun
:endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function SetVimVar() {{{2
" Functions set appropriate values in variables according to line in
" 'modelines' VIM_VAR: var1=value1 var2=value2
" 
"fun! SetVimVar()
":$-5,$ call SetVimVarFromLine()
"endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function SetVimVarFromLine() {{{2
" 
"fun! SetVimVarFromLine()
":let matx = ".* VIM_VAR: "
":let curr_line = getline(".")
":if match(curr_line, matx) == 0
":	echo "Match on line " . "|" . curr_line
":	exec ":let " . substitute(curr_line, matx, "", "")
":endif
"endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function AutoLastMod() {{{2
" Provides atomatic change of date in files, if it is set via
" modeline variable autolastmod to appropriate value.
"
fun! AutoLastMod()
:if exists("g:autolastmod")
:	if g:autolastmod < 0
:		return 0;
:	elseif g:autolastmod == 1
:		call LastMod(g:autolastmodtext)
:	endif
:endif
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function LastMod() {{{2
" Automatic change date in *.html files.
"
fun! LastMod(text, ...)
:mark d
:let line = a:text . strftime("%Y %b %d %X") " text of changed line
:let find = "g/^" . a:text                   " regexpr to find line
:let matx = "^" . a:text                     " ...if line was found
:exec find
:let curr_line = getline(".")
:if match(curr_line, matx) == 0
:  call setline(line("."), line)
:  exec "'d"
:endif
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function MakeHeader() {{{2
" Prepare header in *.h files.
"
fun! MakeHeader() 
" Line look variables.
:let line = "" . bufname("%")
:let line = substitute(line, "\\\.", "_\0", "")
:let line1 = substitute(line, ".*", "#ifndef _\\U\\0", "")
:let line2 = substitute(line, ".*", "#define _\\U\\0", "")
:let line6 = "#endif /* " . line1 . " */"
" Writeout of sets variebles.
":echo line
" ...
" Setting appropriate lines according to the prepared variables.
" In target file there must be sufficient number of lines, else setline() will
" fails. Function append() appends next line into file, see :help append
:call setline(1, line1)
:call append(1, line2)
:call append(2, "")
:call append(3, "")
:call append(4, "")
:call append(5, "")
:call setline(6, line6)
:call append(6, "")
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function OpenAllWin() {{{2
" Opens windows for all files in the command line.
" Variable "opened" is used for testing, if window for file was already opened
" or not. This is prevention for repeat window opening after ViM config file
" reload.
"
:fun! OpenAllWin()
:let i = 0
:if !exists("opened")
:	while i < argc() - 1
:		split
:		n
:		let i = i + 1
:	endwhile
:endif
:let opened = 1
:endfun

:if exists("g:open_all_win")
:	call OpenAllWin()
:endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function CallProg() {{{2
:fun! CallProg()
:	let choice = confirm("Call:", "&make\nm&ake in cwd\n" .
						\ "&compile\nc&ompile in cwd\n" .
						\ "&run\nr&un in cwd")
:	if choice == 1
:		exec ":wall"
:		exec "! cd %:p:h; pwd; make " . g:makeflags
:	elseif choice == 2
:		exec ":wall"
:		exec "! cd " .
				\ getcwd() . "; pwd; make " . g:makeflags
:	elseif choice == 3
:		:call Compile(1)
:	elseif choice == 4
:		:call Compile(0)
:	elseif choice == 5
:		exec "! cd %:p:h; pwd; ./%:t:r"
:	elseif choice == 6
:		exec "! cd " . getcwd() . "; pwd; ./%<"
:	endif
:endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function Compile() {{{2
:fun! Compile(do_chdir)
:	let cmd = ""
:	let filename = ""
:	let filename_ext = ""
:
:	if a:do_chdir == 1
:		let cmd = "! cd %:p:h; pwd; "
:		let filename = "%:t:r"
:		let filename_ext = "%:t"
:	else
:		let cmd = "! cd " . getcwd() . "; pwd; "
:		let filename = "%<"
:		let filename_ext = "%"
:	endif
:
:	let choice = confirm("Call:", 
		\ "&compile\n" .
		\ "compile and &debug\n" .
		\ "compile and &run\n" .
		\ "compile using first &line")

:	if choice != 0
:		exec ":wall"
:	endif

:	if choice == 1
		exec cmd . "gcc " . g:cflags . 
			\ " -o " . filename . " " . filename_ext
:	elseif choice == 2
:		exec cmd . "gcc " . g:cflags . " " . g:c_debug_flags . 
			\ " -o " . filename . " " . filename_ext " && gdb " . filename
:	elseif choice == 3
:		exec cmd . "gcc " . g:cflags . 
			\ " -o " . filename . " " . filename_ext " && ./" . filename
:	elseif choice == 4
:		exec cmd . "gcc " . g:cflags . 
			\ " -o " . filename . " " . filename_ext . 
			\ substitute(getline(2), "VIMGCC", "", "g")
:	endif
:endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function Indent() {{{2
" Indents source code.
fun! Indent()
" If there is set equalprg to source indenting (ie. perltidy for perl sources)
" we have not to executes "'f" at the end, else we will got "Mark not set"
" error message.
:if &equalprg == ""
:	exec "normal mfggvG$='f"
:else
:	exec "normal mfggvG$="
:endif
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function UnquoteMailBody() {{{2
"
fun! UnquoteMailBody()
" Every backslash character must be escaped in function -- Nepto
:	exec "normal :%s/^\\([ ]*>[ ]*\\)*\\(\\|[^>].*\\)$/\\2/g"
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function SafeLineDelete() {{{2
"
fun! SafeLineDelete()
:	exec "normal \"_dd"
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
" Function ReadFileAboveCursor() {{{2
"
fun! ReadFileAboveCursor(file, ...)
:	let str = ":" . (v:lnum - 1) . "read " . a:file
:	let idx = 1
:	while idx <= a:0
:		exec "let str = str . \" \" . a:" . idx
:		let idx = idx + 1
:	endwhile
:	exec str
endfun
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" }}}2
"################################################################# }}}1
" Gvim settings {{{1
:if &t_Co > 2 || has("gui_running")
:	hi Normal guibg=Black guifg=White
:	hi Cursor guibg=Green guifg=NONE
:	hi NonText guibg=Black
:	hi Constant gui=NONE 
:	hi Special gui=NONE
:endif
"################################################################# }}}1
" Colors {{{1
:set background=dark
:hi User1 term=inverse,bold  cterm=inverse,bold ctermfg=red
:hi User2 term=bold          cterm=bold         ctermfg=yellow
:hi User3 term=inverse,bold  cterm=inverse,bold ctermfg=blue
:hi User4 term=inverse,bold  cterm=inverse,bold ctermfg=lightblue
:hi Folded term=standout   ctermbg=black ctermfg=Blue guifg=DarkBlue
:hi FoldColumn term=standout ctermbg=black ctermfg=DarkBlue guibg=Grey guifg=DarkBlue
" }}}1
" Modeline {{{1
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
"################################################################# }}}1
