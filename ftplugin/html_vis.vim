" FTPlugin for HTML.
" Version : 1.3
" 
" Author : Ravi Shankar & Madan Ganesh
" Website: http://insenvim.sourceforge.net
" Date : October 20 2003
" 
"Copyright (C) 2004  Ravi Shankar & Madan Ganesh
"
"This program is free software; you can redistribute it and/or
"modify it under the terms of the GNU General Public License
"as published by the Free Software Foundation; either version 2
"of the License, or (at your option) any later version.
"
"This program is distributed in the hope that it will be useful,
"but WITHOUT ANY WARRANTY; without even the implied warranty of
"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"GNU General Public License for more details.
"
"You should have received a copy of the GNU General Public License
"along with this program; if not, write to the Free Software
"Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

if exists("b:html_vis")
  finish
endif
if !exists("g:loaded_intellisence")
  finish
endif
if IN_StartIntelliSense() == -1
    finish
endif
let b:ignorekeys      = ":/_&"
let b:dochelpdelay    = "2000"
let b:delimiterkey    = ";"
let b:tooltipclosekey = ""
let b:helpwindowsize  = "0x0"
"4 is retain case in the list, ignore case while typing
let b:ignorecase      = 4
imap <silent><buffer> < <<C-R>=IN_ShowVISDialog("showMethodList")<CR>
imap <silent><buffer> <C-Space> <Space><Left><C-R>=IN_ShowVISDialog("showGenList")<CR>
"imap <silent><buffer> <Space> <Space><C-R>=IN_ShowVISDialog("showGenList")<CR>
