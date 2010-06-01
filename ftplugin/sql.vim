" Vim filetype plugin file
" Language:		sql


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" Replace <Tab> with 4 spaces
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal fdm=marker
setlocal fdl=0
setlocal fdc=0

" Modeline {{{
" vim:set ts=4:
" vim600: fdm=marker fdl=0 fdc=3
" }}}

