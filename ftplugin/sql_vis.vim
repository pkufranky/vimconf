" FTPlugin for SQL Intellisense
" Version : 1.30
" 
" Author : David Fishburn
" Website: http://insenvim.sourceforge.net
" Date : Sept 10 2004
" 
"Copyright (C) 2004  David Fishburn "
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

if exists("b:sql_vis")
  finish
endif
if !exists("g:loaded_intellisence")
  finish
endif
if IN_StartIntelliSense() == -1
    finish
endif
let b:sql_vis         = 125
let b:ignorekeys      = ":/_&"
let b:dochelpdelay    = "30000"
let b:delimiterkey    = ";"
let b:tooltipclosekey = ""
let b:helpwindowsize  = "0x0"
"4 is retain case in the list, ignore case while typing
let b:ignorecase      = 4 

"
" These maps rely solely on your syntax/sql.vim file
" to determine the contents of the popup
" 
" Statements - SELECT, UPDATE, DELETE ...
imap <silent><buffer> <C-Space>s <C-R>=IN_ShowVISDialog("GetStatementList")<CR>
" Functions - LENGTH, MOD, RIGHT, TRIM ...
imap <silent><buffer> <C-Space>f <C-R>=IN_ShowVISDialog("GetFunctionList")<CR>
" Keywords - FROM WHERE, all depends on your syntax file
imap <silent><buffer> <C-Space>k <C-R>=IN_ShowVISDialog("GetKeywordList")<CR>
" Types - INTEGER, CHAR, VARCHAR, ...
imap <silent><buffer> <C-Space>T <C-R>=IN_ShowVISDialog("GetTypeList")<CR>
" Operators - =, <>, 
imap <silent><buffer> <C-Space>O <C-R>=IN_ShowVISDialog("GetOperatorList")<CR>
" Database options - If your syntax file specifies them
imap <silent><buffer> <C-Space>P <C-R>=IN_ShowVISDialog("GetOptionList")<CR>
" All of the above for convience
imap <silent><buffer> <C-Space>a <C-R>=IN_ShowVISDialog("GetAllList")<CR>

"
" These maps rely on the dbext.vim plugin to be installed
" http://vim.sourceforge.net/script.php?script_id=356
" Authors:  Peter Bagyinszki 
"           David Fishburn 
          
" List of tables in the database 
imap <silent><buffer> <C-Space>t <C-R>=IN_ShowVISDialog("GetTableList")<CR>
" List of procedures in the database 
imap <silent><buffer> <C-Space>p <C-R>=IN_ShowVISDialog("GetProcedureList")<CR>
" List of views in the database 
imap <silent><buffer> <C-Space>v <C-R>=IN_ShowVISDialog("GetViewList")<CR>
" List of columns for a specific table in the database 
imap <silent><buffer> <C-Space>c <C-R>=IN_ShowVISDialog("GetColumnList")<CR>


" 
" Table Column Completion / Caching
"
" For speed up to 10 different tables column lists are cached.
" If you change a table's column list, you may want to remove the table 
" from the cache.  Simply place your cursor on the table name 
" and hit <C-Space>r
imap <silent><buffer> <C-Space>r <C-R>=IN_ShowVISDialog("ResetColumnCache")<CR>
" If you want to reset all cached objects
imap <silent><buffer> <C-Space>R <C-R>=IN_ShowVISDialog("ResetAllColumnCache")<CR>

" 
" Intellisense maps the <C-Space>. character to popup the column list for a
" table.  If the table is not already cached, there is a pause while the
" column list is retrieved from the database.  Once cached, the popup is
" nearly instant.
" Two mapping has been added for convience.
imap <silent><buffer> <C-Space>. .<C-R>=IN_ShowVISDialog("GetColumnList")<CR>
imap <silent><buffer> <C-Space><C-Space> .<C-R>=IN_ShowVISDialog("GetColumnList")<CR>

