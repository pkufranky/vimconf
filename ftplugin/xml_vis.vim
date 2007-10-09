" FTPlugin for XML.
" Version : 1.3
" 
" Author : Madan Ganesh & Ravi Shankar
" Website: http://insenvim.sourceforge.net
" Date : October 20 2003
" 
"Copyright (C) 2004  Madan Ganesh & Ravi Shankar
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

if exists("b:xml_vis")
  finish
endif
if !exists("g:loaded_intellisence")
  finish
endif
if IN_StartIntelliSense() == -1
    finish
endif
let b:ignorekeys      = ":/_\""
let b:dochelpdelay    = "-1"
let b:delimiterkey    = ""
let b:tooltipclosekey = ""
let b:helpwindowsize  = "0x0"
"0 is no ignore case
let b:ignorecase      = 0
imap <silent><buffer> < <<C-R>=IN_ShowVISDialog("showMethodList")<CR>
imap <silent><buffer> <C-Space> <C-R>=IN_ShowVISDialog("showGenList")<CR>
imap <silent><buffer> = =<C-R>=IN_ShowVISDialog("showGenList")<CR>
"imap <silent><buffer> <Space> <Space><C-R>=IN_ShowVISDialog("showGenList")<CR>
