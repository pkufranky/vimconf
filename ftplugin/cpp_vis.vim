" FTPlugin for cpp.
" Author : Ravi Shankar & Madan
" Version : 1.3
" Look for latest version at http://insenvim.freeservers.com
" You are free to change this file, provided you leave this header intact.
" This file should go to $VIMRUNTIME\ftplugin
if exists("b:cpp_vis")
  finish
endif
if !exists("g:loaded_intellisence")
  finish
endif
if IN_StartIntelliSense() == -1
    finish
endif
let b:ignorekeys      = "_"
let b:dochelpdelay    = "2000"
let b:delimiterkey    = "("
let b:tooltipclosekey = ")"
let b:helpwindowsize  = "0x0"
"0 is no ignore case
let b:ignorecase = 0 
imap <silent><buffer> . .<C-R>=IN_ShowVISDialog("showMethodList")<CR>
imap <silent><buffer> > ><C-R>=IN_ShowVISDialog("showMethodList")<CR>
imap <silent><buffer> : :<C-R>=IN_ShowVISDialog("showMethodList")<CR>
imap <silent><buffer> <C-Space> <C-R>=IN_ShowVISDialog("showGenList")<CR>
imap <silent><buffer> ( (<C-R>=IN_ShowVISDialog("showTooltip")<CR>
imap <silent><buffer> <C-S-Space> <C-R>=IN_ShowVISDialog("showTooltip")<CR>

