" Vim filetype plugin file
" Language:		Template Toolkit (http://www.template-toolkit.org/)
"               template for HTML (WWW page) 
" Maintainer:	Lubomir Host 'rajo' <rajo AT platon.sk>
" License:		GNU GPL
" Version:		$Platon: vimconfig/vim/ftplugin/tt2.vim,v 1.5 2005-06-16 13:30:21 rajo Exp $

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1


" let b:input_method = "windows-1250"
let b:input_method = &encoding
call UseDiacritics()

" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3
" }}}

