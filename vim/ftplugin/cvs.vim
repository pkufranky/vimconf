" Vim filetype plugin file
" Language:		CVS
" Maintainer:	Lubomir Host 'rajo' <8host AT pauli.fmph.uniba.sk>
" License:		GNU GPL
" Version:		$Platon: vimconfig/vim/ftplugin/cvs.vim,v 1.4 2003-01-16 12:16:50 rajo Exp $


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

setlocal nomodeline

setlocal textwidth=72

setlocal formatoptions=crqt12

setlocal autoindent

" Replace <Tab> with 4 spaces
setlocal tabstop=4
setlocal shiftwidth=4
setlocal expandtab

" Comment lines:
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

