" Vim filetype plugin file
" Language:		markdown


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

set ai formatoptions=tcroqn2 comments=n:>

" Modeline {{{
" vim:set ts=4:
" vim600: fdm=marker fdl=0 fdc=3
" }}}

