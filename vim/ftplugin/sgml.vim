" Vim filetype plugin file
" Language:		SGML (DocBook)
" Maintainer:	Ondrej Jombík <nepto@pobox.sk>
" License:		GNU GPL
" Version:		$Platon: vimconfig/vim/ftplugin/sgml.vim,v 1.3 2003-02-28 04:05:23 rajo Exp $


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

" Set window width to 80
setlocal tw=78
setlocal autoindent

" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
" }}}

