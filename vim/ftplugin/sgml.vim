" Vim filetype plugin file
" Language:		SGML (DocBook)
" Maintainer:	Ondrej Jombík <nepto@pobox.sk>
" License:		GNU GPL
" Version:		$Id: sgml.vim,v 1.1 2002/05/18 18:17:52 jombik9 Exp $


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

" Set window width to 80
setlocal tw=80
setlocal autoindent

" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
" }}}

