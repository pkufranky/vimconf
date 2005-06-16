" Vim filetype plugin file
" Language:		PO (gettext) files
" Maintainer:	Ondrej Jombík <nepto@platon.sk>
" License:		GNU GPL
" Version:		$Platon: vimconfig/vim/ftplugin/po.vim,v 1.2 2005-06-16 13:30:20 rajo Exp $


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

" let b:input_method = "iso8859-2"
let b:input_method = &encoding

" turn on IMAP() input method
call UseDiacritics()

" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3
" }}}

