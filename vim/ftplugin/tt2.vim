" Vim filetype plugin file
" Language:		Template Toolkit (http://www.template-toolkit.org/)
" Maintainer:	Lubomir Host 'rajo' <rajo AT platon.sk>
" License:		GNU GPL
" Version:		$Platon: vimconfig/vim/ftplugin/tt2.vim,v 1.1 2003-09-03 08:03:13 rajo Exp $

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1


let b:input_method = "windows-1250"
call UseDiacritics()


" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
"
