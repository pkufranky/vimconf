" Vim indent file
" Language:		PHP
" Maintainer:	Lubomir Host 'rajo' <8host AT pauli.fmph.uniba.sk> 
" Created:		2002/06/22 
" Last Change:	
" Last Update:  
" Version:		0.1


" Only load this indent file when no other was loaded.
if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

" Is syntax highlighting active ?
let b:indent_use_syntax = has("syntax") && &syntax == "php"

let s:cpo_save = &cpo
set cpo-=C

setlocal cindent
"setlocal indentexpr=GetPhpIndent()
"setlocal indentkeys+=0=,0),0=or,0=and
if !b:indent_use_syntax
	setlocal indentkeys+=0=EO
endif

" Only define the function once.
if exists("*GetPhpIndent")
	finish
endif

function GetPhpIndent()

	" Get the line to be indented
	let cline = getline(v:lnum)

	" Don't reindent coments on first column
	if cline =~ '^//.'
		return 0
	endif

	" Get current syntax item at the line's first char
	let csynid = ''
	if b:indent_use_syntax
		let csynid = synIDattr(synID(v:lnum,1,0),"name")
	endif


	return ind

endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
" }}}
