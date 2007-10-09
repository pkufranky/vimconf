" vim:ff=unix ts=4 ss=4 
" vim60:fdm=marker 
" \file outlinetoggle.vim 
" 
" \brief VIM-Tip #333: Syntax-based folding for c/c++/java 
" 
" \author author:   Kartik Agaram as of Vim:   6.0 
" \author Mangled by Feral@FireTop.Com 
" \date Tue, 24 Sep 2002 05:44 Pacific Daylight Time 
" \version $Id$ 
" Version: 0.03 
" History: 
" [Feral:267/02@05:43] v0.03: 
" saves the old marker method now. 
" stoped trying to be clever (just do the command twice heh) 
" v0.02 
" trys to be cleaver and start in the proper outline mode based on if it 
" finds a "{>>" in the file. 


"if exists("loaded_outlinetoggle") 
" finish 
"endif 
"let loaded_outlinetoggle = 1 


" Tip #333: Syntax-based folding for c/c++/java 
" tip karma Rating 0/0, Viewed by 88 
" 
"created:   September 23, 2002 18:32 complexity:   intermediate 
"author:   Kartik Agaram as of Vim:   6.0 
" 
"Here's a function to toggle the use of syntax-based folding for a c/c++/java file. It also handles folding markers. 

function! <SID>OutlineToggle() 
let OldLine = line(".") 
let OldCol = virtcol(".") 
if (! exists ("b:outline_mode")) 
let b:outline_mode = 0 
let b:OldMarker = &foldmarker 
" :echo confirm(b:OldMarker) 
" if search("{>>", 'w') == 0 
" " no modifed marker found, must be normal marker mode 
" let b:outline_mode = 0 
" else 
" let b:outline_mode = 1 
" endif 
endif 


if (b:outline_mode == 0) 
let b:outline_mode = 1 
" syn region myFold start="{" end="}" transparent fold 
" syn sync fromstart 
" set foldmethod=syntax 
" set foldmethod=indent 

set foldmethod=marker 
set foldmarker={,} 

silent! exec "%s/{{{/{<</" 
silent! exec "%s/}}}/}>>/" 
else 
let b:outline_mode = 0 
set foldmethod=marker 
let &foldmarker=b:OldMarker 
" set foldmarker={{{,}}} 

silent! exec "%s/{<</{{{/" 
silent! exec "%s/}>>/}}}/" 
endif 

execute "normal! ".OldLine."G" 
execute "normal! ".OldCol."|" 
unlet OldLine 
unlet OldCol 
execute "normal! zv" 
endfunction 

"***************************************************************** 
"* Commands 
"***************************************************************** 
:command! -nargs=0 OUTLINE call <SID>OutlineToggle() 

" 
"EOF 
<<<

