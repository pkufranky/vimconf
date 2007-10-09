"===================================================================================
"
"         FILE:  doxygen-support.vim
"
"  DESCRIPTION:  Build a menu for inserting user defined doxygen templates.
"
"       AUTHOR:  Dr.-Ing. Fritz Mehner
"        EMAIL:  mehner@fh-swf.de
"      COMPANY:  Fachhochschule Südwestfalen, Iserlohn
"      VERSION:  see variable  g:DoxygenVersion  below
"      CREATED:  07.07.2007
"     REVISION:  $Id: doxygen-support.vim,v 1.8 2007/08/05 09:59:42 mehner Exp $
"      LICENSE:  Copyright (c) 2007, Fritz Mehner
"                This program is free software; you can redistribute it and/or
"                modify it under the terms of the GNU General Public License as
"                published by the Free Software Foundation, version 2 of the
"                License.
"                This program is distributed in the hope that it will be
"                useful, but WITHOUT ANY WARRANTY; without even the implied
"                warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                PURPOSE.
"                See the GNU General Public License version 2 for more details.
"
"===================================================================================
"
if v:version < 700
  echohl WarningMsg | echo 'plugin doxygen-support.vim needs Vim version >= 7'| echohl None
  finish
endif
"
" Prevent duplicate loading:
"
if exists("g:DoxygenVersion") || &cp
 finish
endif
"
let g:DoxygenVersion= "1.3"                   " version number of this script; do not change
"
"------------------------------------------------------------------------------
" Platform specific items
"------------------------------------------------------------------------------
let s:MSWIN =   has("win16") || has("win32")     || has("win64") || 
              \ has("win95") || has("win32unix")
" 
if  s:MSWIN
  let s:plugin_dir  = $VIM.'\vimfiles\plugin\'
else
  let s:plugin_dir  = $HOME.'/.vim/plugin/'
endif
"
"------------------------------------------------------------------------------
"  Control variables (user configurable)
"------------------------------------------------------------------------------
let s:Doxy_ExCommandLeader   = 'Doxy'           " Ex command leader
let s:Doxy_LoadMenus         = 'yes'            " toggle default
let s:Doxy_RootMenu          = 'Do&xy.'         " name of the root menu (not empty)
let s:Doxy_TemplateFile      = s:plugin_dir.'doxygen.templates'
"
"------------------------------------------------------------------------------
"  Control variables (not user configurable)
"------------------------------------------------------------------------------
let s:Attribute                   = { 'below':'', 'above':'', 'append':'', 'insert':'' }
let s:Doxy_Attribute              = {}
let s:Doxy_ExpansionLimit         = 10
let s:Doxy_FileVisited            = []
let s:Doxy_ItemOrder              = []
let s:Doxy_MacroNameRegex         = '\$[a-zA-Z][a-zA-Z0-9_]*\$'
let s:Doxy_Makro                  = { '$sortmenus$':'no' }
let s:Doxy_Menuheader             = ''
let s:Doxy_MenuVisible            = 0           " state : 0 = not visible / 1 = visible
let s:Doxy_Template               = {}
let s:Doxy_TemplateNameDelimiter  = '-+_,\. '
let s:Doxy_TemplateRegex					= '^==\s*\([a-zA-Z][0-9a-zA-Z'.s:Doxy_TemplateNameDelimiter
let s:Doxy_TemplateRegex				 .= ']\+\)\s*==\s*\([a-z]\+\s*==\)\?'
let s:Doxy_TemplateSaveCmd        = {}
let s:Doxy_TemplateSaveMenu       = {}
"
"------------------------------------------------------------------------------
"  Look for global variables (if any), to override the defaults.
"------------------------------------------------------------------------------
function! s:DoxygenCheckGlobal ( name )
  if exists('g:'.a:name)
    exe 'let s:'.a:name.'  = g:'.a:name
  endif
endfunction
"
call s:DoxygenCheckGlobal("Doxy_ExCommandLeader  ")
call s:DoxygenCheckGlobal("Doxy_LoadMenus        ")
call s:DoxygenCheckGlobal("Doxy_RootMenu         ")
call s:DoxygenCheckGlobal("Doxy_TemplateFile     ")
"
if s:Doxy_RootMenu == ""
  let s:Doxy_RootMenu = 'Do&xy.'       " use the default
endif
"
let s:Doxy_TemplateFileDir  = fnamemodify( s:Doxy_TemplateFile, ":p:h" ).'/'
let s:Doxy_TemplateFile     = fnamemodify( s:Doxy_TemplateFile, ":t" ) 

"------------------------------------------------------------------------------
" find the Ex command leader
" remove non-word character, leading digits, underscore
" first character must be uppercase
"------------------------------------------------------------------------------
"
let s:Doxy_ExCommandLeader  = substitute( s:Doxy_ExCommandLeader, '\(^\d\+\|\W\|_\)', '', 'g' )
let s:Doxy_ExCommandLeader  = substitute( s:Doxy_ExCommandLeader, "^\\(.\\)", "\\U\\0", "" )
if s:Doxy_ExCommandLeader == ""
  let s:Doxy_RootMenu = 'Doxy'       " use the default
endif
"
"------------------------------------------------------------------------------
" find the menu header (last part of the complete root menu name)
"------------------------------------------------------------------------------
"
let s:Doxy_Menuheader = matchstr( s:Doxy_RootMenu, '[^\.]\+\.$' )
let s:Doxy_Menuheader = substitute( s:Doxy_Menuheader, '\.\+$', '', '' )
if s:Doxy_Menuheader == ""
  let s:Doxy_RootMenu = 'Doxy'       " use the default
endif

"===================================================================================
" FUNCTIONS
"===================================================================================

"------------------------------------------------------------------------------
"  DoxygenToolMenu
"  set the tool menu item (Load Menu)
"------------------------------------------------------------------------------
function! DoxygenToolMenu ()
  amenu   <silent> 40.1000 &Tools.-SEP100- :
  amenu   <silent> 40.1035 &Tools.Load\ Doxygen\ Support\ Menu <C-C>:call DoxygenCreateGuiMenus()<CR>
endfunction    " ----------  end of function DoxygenToolMenu  ----------

"------------------------------------------------------------------------------
"  DoxygenCreateGuiMenus
"  create  the doxygen menu / change tool menu
"------------------------------------------------------------------------------
function! DoxygenCreateGuiMenus ()
  if s:Doxy_MenuVisible == 0
    aunmenu <silent> &Tools.Load\ Doxygen\ Support\ Menu
    amenu   <silent> 40.1000 &Tools.-SEP100- :
    amenu   <silent> 40.1035 &Tools.Unload\ Doxygen\ Support\ Menu <C-C>:call DoxygenRemoveGuiMenus()<CR>
    call DoxygenInitMenu()
  endif
endfunction    " ----------  end of function DoxygenCreateGuiMenus  ----------

"------------------------------------------------------------------------------
"  DoxygenRemoveGuiMenus
"  remove the doxygen menu / change tool menu
"------------------------------------------------------------------------------
function! DoxygenRemoveGuiMenus ()
  if s:Doxy_MenuVisible == 1
    "
    exe "aunmenu <silent> ".s:Doxy_RootMenu
    aunmenu <silent> &Tools.Unload\ Doxygen\ Support\ Menu
    call DoxygenToolMenu()
    "
    let s:Doxy_MenuVisible = 0
  endif
endfunction    " ----------  end of function DoxygenRemoveGuiMenus  ----------

"------------------------------------------------------------------------------
"  DoxygenInitMenu
"  create the doxygen menu items
"------------------------------------------------------------------------------
function! DoxygenInitMenu ()
  "
  silent exe "amenu .1 ".s:Doxy_RootMenu.s:Doxy_Menuheader.'\ \ (rebuild)    <Esc><Esc>:call DoxygenRebuild()<CR>'
  silent exe "amenu .1 ".s:Doxy_RootMenu.'-Sep00-    :'

  "------------------------------------------------------------------------------
  "  remove existing menus (if any)
  "------------------------------------------------------------------------------
  if s:Doxy_MenuVisible == 1
    for key in keys(s:Doxy_TemplateSaveMenu)
      exe "silent aunmenu ".s:Doxy_RootMenu.key
    endfor
  end

  "------------------------------------------------------------------------------
  "  build new menus from the templates / save the templates
  "------------------------------------------------------------------------------
  if s:Doxy_Makro['$sortmenus$'] == 'yes'
    for key in sort( keys(s:Doxy_Template ))
      exe "amenu  <silent> .100 ".s:Doxy_RootMenu.key."  <Esc><Esc>:call DoxygenInsertTemplate ('".key."')<CR>"
    endfor
  else
    for key in s:Doxy_ItemOrder
      exe "amenu  <silent> .100 ".s:Doxy_RootMenu.key."  <Esc><Esc>:call DoxygenInsertTemplate ('".key."')<CR>"
    endfor

  end
  let s:Doxy_TemplateSaveMenu = s:Doxy_Template

  let s:Doxy_MenuVisible = 1
  return
endfunction    " ----------  end of function DoxygenInitMenu  ----------

"------------------------------------------------------------------------------
"  DoxygenRebuild
"  rebuild commands and the menu from the (changed) template file
"------------------------------------------------------------------------------
function! DoxygenRebuild ()
  "-------------------------------------------------------------------------------
  "   (1.1) template file already loaded:
  "     (1.1.1) window open : go to this window
  "     (1.1.2) window not open : open a window for the template file
  "     update the template file
  "     reread the template file
  "     rebuild commands and menus
  "   (1.2) 
  "     update the current buffer
  "     open the template file in a new window for editing
  "-------------------------------------------------------------------------------
  if bufexists( s:Doxy_TemplateFileDir.s:Doxy_TemplateFile )
    if bufwinnr( s:Doxy_TemplateFileDir.s:Doxy_TemplateFile ) == -1
      exe ":sbuffer ".bufnr( s:Doxy_TemplateFileDir.s:Doxy_TemplateFile )
    else
      exe bufwinnr(s:Doxy_TemplateFileDir.s:Doxy_TemplateFile) . "wincmd w"
    end
    :update 

    let s:Doxy_ItemOrder    = []
    let s:Doxy_Template     = {}
    let s:Doxy_FileVisited  = []
  
    call DoxygenReadTemplates(s:Doxy_TemplateFile)
    call DoxygenBuildCommands()
    if has("gui_running")
      call DoxygenInitMenu()
    endif
    echomsg "doxygen comments rebuilt from '".s:Doxy_TemplateFileDir.s:Doxy_TemplateFile."'"
  else
    :update 
    exe ":new ".s:Doxy_TemplateFileDir.s:Doxy_TemplateFile
  end
endfunction    " ----------  end of function DoxygenRebuild  ----------

"------------------------------------------------------------------------------
"  DoxygenReadTemplates
"  read the template file(s), build the macro and the template dictionary
"
"------------------------------------------------------------------------------
function! DoxygenReadTemplates ( templatefile )

  if !filereadable( s:Doxy_TemplateFileDir.a:templatefile )
    echohl WarningMsg
    echomsg "doxygen template file '".s:Doxy_TemplateFileDir.a:templatefile."' does not exist or is not readable"
    echohl None
    return
  end

  let s:Doxy_FileVisited  += [a:templatefile]

  "------------------------------------------------------------------------------
  "  read template file, start with an empty template dictionary
  "------------------------------------------------------------------------------

  let item  = ''
  for line in readfile( s:Doxy_TemplateFileDir.a:templatefile )
    if line !~ '^#'
      "
      " macros and file includes
      "
      let name  = matchstr( line, '^\s*'.s:Doxy_MacroNameRegex.'\s*=' )
      if name != ''
        let key = matchstr( line, s:Doxy_MacroNameRegex )
        let val = matchstr( line, '=.*' )
        let val = substitute( val, '\s*$', "", "" )
        let val = substitute( val, '=\s*', "", "" )
        let val = substitute( val, "[\"\']$", '', '' )
        let val = substitute( val, "^[\"\']", '', '' )
        "
        if key == '$includefile$' && count( s:Doxy_FileVisited, val ) == 0
          call DoxygenReadTemplates( val )    " recursive call
        else
          let s:Doxy_Makro[key] = val
        end
        continue                                            " next line
      endif
      "
      " template header
      "
      let name  = matchstr( line, s:Doxy_TemplateRegex )
      "
      if name != ''
        let part  = split( name, '\s*==\s*')
        let item  = part[0]
        if has_key( s:Doxy_Template, item )
          echomsg "existing doxygen template '".item."' overwritten"
        end
        let s:Doxy_ItemOrder += [ item ]
        let s:Doxy_Template[item] = ''
        "
        let s:Doxy_Attribute[item] = 'below'
        if has_key( s:Attribute, get( part, 1, 'NONE' ) )
          let s:Doxy_Attribute[item] = part[1]
        end
      else
        if item != ''
          let s:Doxy_Template[item] = s:Doxy_Template[item].line."\n"
        end
      end
    endif
  endfor

  "------------------------------------------------------------------------------
  "  expand the user macros
  "  one additional expansion in DoxygenInsertTemplate()
  "------------------------------------------------------------------------------
  for n in range(s:Doxy_ExpansionLimit-1)
    for key in keys(s:Doxy_Template)
      let s:Doxy_Template[key]  = DoxygenExpandUserMacros (key)
    endfor
  endfor
  "
endfunction    " ----------  end of function DoxygenReadTemplates  ----------

"------------------------------------------------------------------------------
"  DoxygenBuildCommands
"  build the commands from the template dictionary
"------------------------------------------------------------------------------
function! DoxygenBuildCommands ()

  "-------------------------------------------------------------------------------
  "   remove existing commands
  "-------------------------------------------------------------------------------
  if s:Doxy_TemplateSaveCmd != {}
    for key in keys(s:Doxy_TemplateSaveCmd)
      exe "silent delcommand  ".s:Doxy_ExCommandLeader.key
    endfor
    let s:Doxy_TemplateSaveCmd = {}
  end

  "-------------------------------------------------------------------------------
  "   build new commands; report no error if a command already exists
  "-------------------------------------------------------------------------------
  for key in sort( keys(s:Doxy_Template ))
    let camelcase = s:DoxygenCamelCaseName( key )
    let s:Doxy_TemplateSaveCmd[camelcase] = camelcase
    exe "command!   ".s:Doxy_ExCommandLeader.camelcase."  call DoxygenInsertTemplate ('".key."')"
  endfor

endfunction    " ----------  end of function DoxygenBuildCommands  ----------

"------------------------------------------------------------------------------
"  s:DoxygenCamelCaseName
"  Build a camel-case-name from a raw name by removing separators and joining
"  the parts each starting with an uppercase letter.
"------------------------------------------------------------------------------
function! s:DoxygenCamelCaseName ( raw_name )
  let parts = split( a:raw_name, '['.s:Doxy_TemplateNameDelimiter.']' )
  let parts = map( parts, 'substitute( v:val, "^\\(.\\)", "\\U\\0", "" )' )
  return join( parts, '' )
endfunction    " ----------  end of function s:DoxygenCamelCaseName  ----------

"------------------------------------------------------------------------------
"  DoxygenInsertTemplate
"  insert a template from the template dictionary
"  do macro expansion
"------------------------------------------------------------------------------
function! DoxygenInsertTemplate ( key )

  "------------------------------------------------------------------------------
  "  renew the predefined macros and expand them
  "------------------------------------------------------------------------------
  let s:Doxy_Makro['$DATE$']  = strftime("%x")
  let s:Doxy_Makro['$YEAR$']  = strftime("%Y")
  let s:Doxy_Makro['$TIME$']  = strftime("%X %Z")
  let s:Doxy_Makro['$FILE$']  = expand("%:t")
  let s:Doxy_Makro['$PATH$']  = expand("%:p:h")
  let val = DoxygenExpandUserMacros (a:key)

  "------------------------------------------------------------------------------
  "  insert the user macros
  "------------------------------------------------------------------------------
  let mode  = s:Doxy_Attribute[a:key]

  if mode == 'below'
    let pos1  = line(".")+1
    put  =val
    let pos2  = line(".")
  end

  if mode == 'above'
    let pos1  = line(".")+1
    put! =val
    let pos2  = line(".")
  end

  if mode == 'append'
    let pos1  = line(".")
    put =val
    let pos2  = line(".")-1
    exe ":".pos1
    :join!
  end

  if mode == 'insert'
    let val   = substitute( val, '\n$', '', '' )
    let pos1  = line(".")
    let pos2  = pos1 + count( split(val,'\zs'), "\n" ) 
    exe "normal a".val
  end
  "
  "------------------------------------------------------------------------------
  "  position the cursor
  "------------------------------------------------------------------------------
  exe ":".pos1
  let match = search( '\$CURSOR\$', "", pos2 )
  if match != 0
    if  matchend( getline(match) ,'\$CURSOR\$') == match( getline(match) ,"$" )
      normal 8x
      :startinsert!
    else
      normal 8x
      :startinsert
    endif
  end

endfunction    " ----------  end of function DoxygenInsertTemplate  ----------

"------------------------------------------------------------------------------
"  DoxygenExpandUserMacros
"------------------------------------------------------------------------------
function! DoxygenExpandUserMacros ( key )

  let val = s:Doxy_Template[a:key]
  for macroname in keys(s:Doxy_Makro)
    let valsave = val
    let val = substitute( val, escape(macroname, '$' ), s:Doxy_Makro[macroname], "g" )
    if val != valsave
      let restart = 1
    end
  endfor
  "
  return val
endfunction    " ----------  end of function DoxygenExpandUserMacros  ----------

"------------------------------------------------------------------------------
"  INITIALIZE THIS PLUGIN
"  build the commands
"  build the menus (GUI only)
"------------------------------------------------------------------------------
"
call DoxygenReadTemplates(s:Doxy_TemplateFile)
call DoxygenBuildCommands()
"
if has("gui_running")
  "
  call DoxygenToolMenu()
  "
  if s:Doxy_LoadMenus == 'yes'
    call DoxygenCreateGuiMenus()
  endif
  "
endif
"
command! Doxygen   call DoxygenRebuild()
"
"------------------------------------------------------------------------------
"vim: set tabstop=2 shiftwidth=2:
