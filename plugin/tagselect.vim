" tagselect.vim: Provides a better :tselect command.
" Author: Hari Krishna (hari_vim at yahoo dot com)
" Last Change: 12-May-2005 @ 16:12
" Created:     18-May-2004
" Requires:    Vim-6.3, genutils.vim(1.12)
" Version:     1.0.7
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Acknowledgements:
" Download From:
"     http://www.vim.org//script.php?script_id=1282
" Description:
"     Use :Tselect command instead of :tselect to bring up the :tselect output
"     in a vim window. You can then search and press enter on the line(s) of
"     the tag which you would like to select. If you don't want to select any
"     tag you can quit by pressing "q". You can also start typing the number
"     of the tag instead of moving the cursor to the line and pressing enter.
"
"     To select another tag index for the same tag, you can use :Tselect
"     without arguments or just use :tselect itself.
"
"     The normal mode command, "g^]" (:help g_CTRL-]) and the corresponding
"     visual mode command (:help v_g_CTRL-]) will be remapped to use the
"     plugin. To disable these maps, set g:no_tagselect_maps in your vimrc.
"
"     Use g:tagselectWinSize to set the preferred size of the window. The
"     default is -1, which is to take just as much as required (up to the
"     maximum), but you can set it to empty string to make the window as high
"     as possible, or any +ve number to limit its size.
"
"     Use g:tagselectExpandCurWord to configure if <cword> and <cWORD> tokens
"     will be expanded or not.
"   Tips:
"     - You can intermix the usage of :Tselect without of :tselect.
"     - You can use :Ts instead of the full :Tselect, as long as there are no
"       other commands which could confuse the usage.
"   Limitations:
"     - Executes :tselect twice, once to show the list, and once to jump to
"       the selected tag. This means, if the tag search takes considerable
"       time, then the time could potentially be doubled (depends on Vim
"       caching the results).
" TODO:
"   - The :tags command seems to be pretty close to :ts, it should be possible
"     to support that also. But the tag depth is only 20, so you should never
"     see the more prompt, not useful enough (still allows searches etc.).
"   - A setting to dictate the positioning of the window.
"   - When quitting the window the cursor always goes to the below window,
"     there should be a way to go back to the originating window.
"   - Better way to select the tag. Use vim7 features if available.
"   - Sometimes I get terse output (is it constrained by the width?), how
"     do I avoid this?
"   - Why isn't noreadonly working, I still see the warning first time.

if exists('loaded_tagselect')
  finish
endif
if v:version < 603
  echomsg 'tagselect: You need Vim 6.3 or higher'
  finish
endif


if !exists('loaded_genutils')
  runtime plugin/genutils.vim
endif
if !exists('loaded_genutils') || loaded_genutils < 112
  echomsg 'tagselect: You need a newer version of genutils.vim plugin'
  finish
endif
let loaded_tagselect=100

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

if !exists('g:tagselectWinSize')
  let g:tagselectWinSize = -1
endif

if !exists('g:tagselectExpandCurWord')
  let g:tagselectExpandCurWord = 1
endif


if !exists('s:myBufNum')
let s:myBufNum = -1
let s:title = '[Tag Select]'
let s:curTagName = ''
endif
let s:nextTagPat = '^\s\{0,2}\d\+'

command! -nargs=? -complete=tag Tselect :call <SID>TagSelectMain(<f-args>)

if (! exists("no_plugin_maps") || ! no_plugin_maps) &&
      \ (! exists("no_tagselect_maps") || ! no_tagselect_maps)
  nnoremap <silent> g<C-]> :Tselect <cword><CR>
  vnoremap <silent> g<C-]> :<C-U>call <SID>TagSelectVisual()<CR>
endif

function! s:TagSelectMain(...) " {{{
  let tagName = a:0 ? a:1 : ''
  if g:tagselectExpandCurWord
    " Expand <cword> and <cWORD> in arguments.
    let tagName = substitute(tagName, '<cword>\|<cWORD>',
          \ '\=expand(submatch(0))', 'g')
  endif
  let results = GetVimCmdOutput('tselect '.tagName)
  if v:errmsg != '' && results =~ '^\_s*$'
    redraw | echohl ErrorMsg | echomsg v:errmsg | echohl NONE
    return 1
  endif

  let _isf = &isfname
  let _splitbelow = &splitbelow
  set splitbelow
  try
    call SaveWindowSettings2('TagSelect', 1)
    if s:myBufNum == -1
      " Temporarily modify isfname to avoid treating the name as a pattern.
      set isfname-=\
      set isfname-=[
      if exists('+shellslash')
        call OpenWinNoEa("sp \\\\". escape(s:title, ' '))
      else
        call OpenWinNoEa("sp \\". escape(s:title, ' '))
      endif
      exec "normal i\<C-G>u\<Esc>"
      let s:myBufNum = bufnr('%')
    else
      let buffer_win = bufwinnr(s:myBufNum)
      if buffer_win == -1
        exec 'sb '. s:myBufNum
      else
        exec buffer_win . 'wincmd w'
      endif
    endif
  finally
    let &isfname = _isf
    let &splitbelow = _splitbelow
  endtry
  call s:SetupBuf()

  let s:curTagName = tagName
  let lastLine = line('$')
  silent! $put =results
  " Remove the prompt.
  silent! $delete _
  silent! exec '1,' . (lastLine + 1) . 'delete _'
  call append(0, 'Current Pattern: ' . s:curTagName)
  " Position the cursor at the current-line if there is any.
  call search('^> ', 'w')
  normal! zz

  " Resize only if this is not the only window vertically.
  if !IsOnlyVerticalWindow()
    let targetSize = g:tagselectWinSize
    if targetSize == -1
      let targetSize = line('$')
    endif
    exec 'resize ' targetSize
  endif

  return 0
endfunction " }}}

" Function to use the current visual selection as the tag. Should be called
" only from the visual mode.
function! s:TagSelectVisual() " {{{
  let invalid = 0
  if line("'<") != line("'>")
    let invalid = 1
  endif

  let selected = ''
  if !invalid
    if line('.') >= line("'<") && line('.') <= line("'>")
        let selected = strpart(getline('.'), col("'<") - 1,
              \ (col("'>") - col("'<") + 1))
    endif
    let invalid = s:TagSelectMain(selected)
  endif
  if invalid
    " Beep and reselect the selection, just like the built-in command.
    exec "normal \<Esc>gv"
  endif
endfunction " }}}

function! s:GetTagIndxUnderCursor() " {{{
  let tagIndex = 0
  if line('.') > 2
    if strpart(getline('.'), 0, 3) !~ s:nextTagPat
      " We prefer to find the previous tag, but if there is none, then select
      " the current one again.
      if !search(s:nextTagPat, 'bW')
        call search('^>', 'bW')
      endif
    endif
    let tagIndex = substitute(strpart(getline('.'), 0, 3), '^>\?\s\+', '', '')
          \ + 0
  endif
  return tagIndex
endfunction

function! s:SelectTagUnderCursor(bang)
  let tagIndex = s:GetTagIndxUnderCursor()
  call s:SelectTag(tagIndex, a:bang)
endfunction

function! s:SelectTag(index, bang)
  let tagIndex = a:index
  if tagIndex != 0
    let tagSelWin = winnr()
    wincmd p
    " FIXME: Avoid doing a :tag first.
    let _cscopetag = &cscopetag
    set nocscopetag
    let _more = &more
    set nomore
    try
      exec 'nnoremap <Plug>TagSelectTS :tselect'.a:bang.' '.s:curTagName.
            \ '<CR>'.tagIndex.'<CR>'
      exec "normal \<Plug>TagSelectTS"
      " WORKAROUND: Avoid Hit ENTER prompt.
      redraw
      nunmap <Plug>TagSelectTS
      "let v:errmsg = ''
      "silent exec 'tag ' . curTagPat
      "if v:errmsg == ''
      "  exec tagIndex.'tnext'
      "endif
    catch
      "call confirm(v:exception, '&OK', 1, 'Error')
      echohl ErrorMsg | echo substitute(v:exception, '^[^:]\+:', '', '') |
            \ echohl NONE
    finally
      call CloseWindow(tagSelWin, 1)
      call RestoreWindowSettings2('TagSelect')
      let &more = _more
      let &cscopetag = _cscopetag
    endtry
  endif
endfunction " }}}

function! s:SetupBuf() " {{{
  call SetupScratchBuffer()
  setlocal nowrap
  setlocal bufhidden=delete

  setlocal winfixheight

  nnoremap <silent> <buffer> q :TSQuit<CR>
  nnoremap <silent> <buffer> <CR> :TSSelect<CR>
  nnoremap <silent> <buffer> <2-LeftMouse> :TSSelect<CR>

  " When user types numbers in the browser window, input the tag index
  " directly.
  let chars = "123456789"
  let i = 0
  let max = strlen(chars)
  while i < max
    exec 'noremap <buffer>' chars[i] ':call <SID>InputTagIndex()<CR>'.
          \ chars[i]
    let i = i + 1
  endwhile

  command! -buffer TSQuit :call <SID>Quit()
  command! -buffer -bang TSSelect :call <SID>SelectTagUnderCursor('<bang>')

  syn clear
  set ft=tagselect
  syn match TagSelectTagHeader "^\s*# pri kind.*"
  syn match TagSelectCurTagLine "^>.*"
  syn match TagSelectTagLine "^\s*\d\+\s.*" contains=TagSelectTagName,TagSelectTagFile
  syn match TagSelectTagName "^\s*\d\+\s[a-zA-Z ]\{3} [a-zA-Z ]\s\+\zs\S\+\ze" contained
  syn match TagSelectTagFile "\S\+$" contained
  syn match TagSelectTagDetails "^\s\{9,}.*" contains=TagSelectTagType
  syn match TagSelectTagType "\w\+\ze:" contained

  hi! def link TagSelectTagHeader Title
  hi! def link TagSelectCurTagLine WildMenu
  hi! def link TagSelectTagFile Directory
  hi! def link TagSelectTagName Title
  hi! def link TagSelectTagType ModeMsg
endfunction " }}}

" From selectbuf.vim {{{
function! s:InputTagIndex()
  " Generate a line with spaces to clear the previous message.
  let i = 1
  let clearLine = "\r"
  while i < &columns
    let clearLine = clearLine . ' '
    let i = i + 1
  endwhile

  let tagIndex = ''
  let abort = 0
  call s:Prompt(tagIndex)
  let breakLoop = 0
  while !breakLoop
    try
      let char = getchar()
    catch /^Vim:Interrupt$/
      let char = "\<Esc>"
    endtry
    "exec BPBreakIf(cnt == 1, 2)
    if char == '^\d\+$' || type(char) == 0
      let char = nr2char(char)
    endif " It is the ascii code.
    if char == "\<BS>"
      let tagIndex = strpart(tagIndex, 0, strlen(tagIndex) - 1)
    elseif char == "\<Esc>"
      let breakLoop = 1
      let abort = 1
    elseif char == "\<CR>"
      let breakLoop = 1
    else
      let tagIndex = tagIndex . char
    endif
    echon clearLine
    call s:Prompt(tagIndex)
  endwhile
  if !abort && tagIndex != ''
    call s:SelectTag(tagIndex)
  endif
endfunction

function! s:Prompt(bufNr)
  echon "\rTag Index: " . a:bufNr
endfunction
" }}}

function! s:Quit()
  if NumberOfWindows() == 1
    redraw | echohl WarningMsg | echo "Can't quit the last window" |
          \ echohl NONE
  else
    quit
    call RestoreWindowSettings2('TagSelect')
  endif
endfunction

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6:fdm=marker et sw=2
