" Vim filetype plugin file
" Language:		CVS
" Maintainer:	Lubomir Host <host8@kepler.fmph.uniba.sk>
" License:		GNU GPL
" Version:		$Id: $


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

setlocal nomodeline

setlocal textwidth=72

setlocal formatoptions=crqt12

setlocal autoindent

setlocal comments+=:CVS\:\ 

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_cvs_maps")
	" Ctrl-F reformat paragraph
	if !hasmapto('<Plug>CVSFormat')
		imap <buffer> <C-F> <Plug>CVSFormat
		map  <buffer> <C-F> <Plug>CVSFormat
	endif
	inoremap <buffer> <Plug>CVSFormat <Esc>mfggvG$='fi
	noremap  <buffer> <Plug>CVSFormat <Esc>mfggvG$='f
	vnoremap <buffer> <Plug>CVSFormat <Esc>mfggvG$='f
  
endif


" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
" }}}

