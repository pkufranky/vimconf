" hdf filetype plugin file
" Language:		HDF (Hierarchical Data Format)
" Maintainer:	franky (pkufranky@gmail.com)
" License:		GNU GPL
" Version:		1.0


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

setlocal autoindent

" Replace <Tab> with 4 spaces
setlocal tabstop=2
setlocal shiftwidth=2
setlocal expandtab


" Modeline {{{
" vim:set ts=4:
" vim600: fdm=marker fdl=0 fdc=3
" }}}

