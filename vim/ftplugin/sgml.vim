" Vim filetype plugin file
" Language:		SGML (DocBook)
" Maintainer:	Ondrej Jombík <jombik9@kepler.fmph.uniba.sk>
" License:		GNU GPL
" Version:		$Id: perl.vim,v 1.4 2002/02/17 01:03:58 host8 Exp $


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

" Set window width to 80
setlocal tw=80
setlocal autoindent

" External program to format Perl code source.
if executable("perltidy")
	setlocal equalprg=perltidy\ -q\ -se\ -fnl
endif


" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
" }}}

