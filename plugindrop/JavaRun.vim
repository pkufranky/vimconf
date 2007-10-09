" JavaRun.vim
" Version 0.2
" Kendrew Lau
"
" Script to save, compile, and run the Java program in current buffer.
" The saving and compilation are only done if necessary.
" Some abbreviations for Java programming are added, e.g.
"   psvm for "public static void main(String[] args) { }"
"   cl for class
"   fi for final
" (This is inspired by Netbeans)
" See the end of this script for the list of abbreviations.
"
" Also, save and run for Python, Perl, Ruby, Tcltk, and Clisp file.
"
" To use it, source this script and do the command :Run [arg...]
" where arg are optional arguments to the Java program to run
" Alternatively, just press <F5> to run without arguments.
"

function! JavaRun(...)
	update
	let e = 0
	if getftime(expand("%:r") . ".class") < getftime(expand("%"))
		make
		let e = v:shell_error
	endif
	if e == 0
		let idx = 1
		let arg = ""
		while idx <= a:0
			execute "let a = a:" . idx
			let arg = arg . ' ' . a
			let idx = idx + 1
		endwhile
		execute "!java " . expand("%:r") . " " . arg
	endif
endfunction

function! ProgRun(...)
	update
	let e = 0
	let ext = expand("%:e")
	if ext == "java" && getftime(expand("%:r") . ".class") < getftime(expand("%"))
		make
		let e = v:shell_error
	endif
	if e == 0
		if exists("g:runprogstring")
			execute "!" . g:runprogstring
		else
			let idx = 1
			let arg = ""
			while idx <= a:0
				execute "let a = a:" . idx
				let arg = arg . ' ' . a
				let idx = idx + 1
			endwhile
			cd %:p:h
			if ext == "java"
				execute "!java " . expand("%:r") . " " . arg
			elseif ext == "py"
				execute "!python " . expand("%") . " " . arg
			elseif ext == "pl"
				execute "!perl " . expand("%") . " " . arg
			elseif ext == "rb"
				execute "!ruby " . expand("%") . " " . arg
			elseif ext == "tcl"
				execute "!tclsh " . expand("%") . " " . arg
			elseif ext == "lisp"
				execute "!clisp " . expand("%") . " " . arg
			endif
			cd -
		endif
	endif
endfunction


set shellpipe=>\ %s\ 2>&1
" set makeprg=javac\ %
" set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
set makeprg=jikes\ +E\ %
set errorformat=%f:%l:%v:%*\\d:%*\\d:%*\\s%m

command! -nargs=* JavaRun call JavaRun(<f-args>)
command! -nargs=* Run call ProgRun(<f-args>)

if maparg("<F5>") == ""
	map <F5> :Run<CR>
endif

if maparg("<F9>") == ""
	map <F9> :make<CR>
endif

iab psvm public static void main(String[] args) { }<UP><END><BS><BS>
iab sout System.out.println();<LEFT><LEFT>
iab serr System.err.println();<LEFT><LEFT>
iab pr private
iab pe protected
iab pu public
iab ex extends
iab bo boolean
iab ab abstract
iab cl class
iab st static
iab fi final
iab ir import
iab re return
iab sw switch
iab Ob Object
iab Ex Exception
iab En Enumeration
iab Gr Graphics

