" File: FileExplore
" Author: Pradeep Kudethur ( pradeeppp_k@yahoo.com )
" Version: 1.0
" Date: 09 June 2005
" 
" Purpose: Emulates the project file browser similar to some popular code browsers.
" This will list all the files in the project in a new window and allow user
" to open any file by mouse click/<CR>/O/V/H. This will come very handy
" when you are dealing with huge number of files and you really dont want to worry
" about the project directory structure, but just about the filename you are working on.
"
" Limitation: This script relies heavily on the Unix find command(initially takes time 
" for explorer to open) and cscope (once the explorer is open things will be fast).
"
" Distribution: This plugin comes with GPL (General Public License), You have
" are free to use/distribute/modify the plugin.
"
" Installation: Copy this file to .vim/plugin folder.  
" I have tried this on free BSD. Should also work on linux and cygwin.
"
" Tunable parameters
" set file name for storing the list of files
let s:fileListName='filelist'

" Substitue with path below your project root dir or just '.', in case you are
" working on multiple projects. I use '.' and ensure to open vim/gvim from the
" project's root directory, I am interested on.
let s:fileProjectPath='.'

" set path to the find binary
let s:find_path='/usr/bin/find'

" set filter -- see find man page for details
let s:filter='-name *.c -or -name *.h'

" set splitting behavior : none | vert | horiz
let s:splitBehavior='vert'

"Eliminate duplicate filenames in the file explorer. If you wish to keep the
"duplicate filenames (if you keep duplicates, it will give you an idea of how many such files 
"are there in the give project) then you can set this variable to no.
let s:fileExplorerDuplicateRemove='yes'

"Remove file names starting with '.' from the project explorer
let s:fileExplorerDotRemove='yes'

" You need to specify F5 (in my example, refer the map command above to change the same) 
" on your gvim/vim to open the file explorer. The window split format (horizontal/vertical/none) 
" configuration is supported below. The file explorer will come up (initially it will take time, 
" because it uses the unix find command) with all the files (.c and .h file, support is provided 
" below to specify more extensions) in ascending order. User can use '\' or '\^' (search from 
" first letter of the file) vi commands to go the appropriate file in the file explorer and press 
" 'O' to open the file in the specified window (vert/hor/none - you can tune this parameter 'splitBehaviour').
" User can press <CR>/ double click left mouse button to open the file in the previous window.
" 'V' to open the file in vertical split (this will override the split stype configuration).
" 'H' to open the file in horizontal split (this will override the split stype configuration).
" Vi command '?'  or '?^' can also be used for searching the file in the file explorer 
" (regular expression search should also work).
"
" FYI: the file opening strongly depends on the 'cscope find f' command, so please ensure the 
" cscope configuration is proper and you can acutally open the interested file using " ':cs f f <filename>' 
" command from the vim/gvim editor itself. For information on using/setting up cscope please go to 
" 'http://cscope.sourceforge.net/' and 'http://cscope.sourceforge.net/cscope_vim_tutorial.html'
"
 map <F5> :FileExplore<CR> 

 "Open the file explorer with the existing file list in the file, specified by the parameter
 "s:fileListName. The advantage of this is that the 'find' command will not be
 "used everytime you open the project, instead the filelist is picked up from
 "the existing file, specified by s:fileListName parameter. This list can be
 "updated based upon the requirement ('R' is mapped for updating/refrehing filelist)
 map <C-p> :FileExploreList<CR> 



" Code begins
" multiple define check
if !exists(':FileExplore')
	command -nargs=0 -complete=dir FileExplore call s:FileBrowse()
endif

if !exists(':FileExploreList')
	command -nargs=0 -complete=dir FileExploreList call s:FileBrowseList()
endif

" FileBrowse
function! s:FileBrowse()
	if "vert" == s:splitBehavior
		botright vertical new 
	elseif "horiz" == s:splitBehavior
		new
	endif

	setlocal bufhidden=wipe buftype=nofile noswapfile
	exec ':r!' . s:find_path . ' ' . s:fileProjectPath . ' ' . s:filter
	:0
	setlocal ignorecase nohlsearch

    :1,$s/\..*\///g 
    :%!sort 
    "Remove first blank line
	:0
    "Remove the empty parent folder line
    :1d 
	if "yes" == s:fileExplorerDotRemove
        :g/^\..*/d 
    endif
	if "yes" == s:fileExplorerDuplicateRemove
        exec ':g/^/ call s:Duplicate()'
    endif
    exec ':%!cat >' s:fileListName
    exec ':%!cat ' s:fileListName

    call s:FileMapKeys()
endfunction


" FileBrowseList
function! s:FileBrowseList()
	if "vert" == s:splitBehavior
		botright vertical new 
	elseif "horiz" == s:splitBehavior
		new
	endif

	setlocal bufhidden=wipe buftype=nofile noswapfile
    exec ':%!cat ' s:fileListName
	:0
	setlocal ignorecase nohlsearch

    call s:FileMapKeys()
endfunction


" FileMapKeys -- To may the keys
function! s:FileMapKeys()
    nnoremap <silent> <buffer> O :call <SID>EditFile(0)<cr>
	noremap <buffer> <CR> :call <SID>EditFile(1)<CR>
    nnoremap <silent> <buffer> <2-LeftMouse> :call <SID>EditFile(1)<cr>
    nnoremap <silent> <buffer> V :call <SID>EditFile(2)<cr>
    nnoremap <silent> <buffer> H :call <SID>EditFile(3)<cr>
    nnoremap <silent> <buffer> R :call <SID>RefreshList()<cr>
endfunction

" FileMapKeys -- To may the keys
function! s:RefreshList()
    "Remove everything from the file
    :1,$d 
	exec ':r!' . s:find_path . ' ' . s:fileProjectPath . ' ' . s:filter
	:0
	setlocal ignorecase nohlsearch

    :1,$s/\..*\///g 
    :%!sort 
    "Remove first blank line
	:0
    "Remove the empty parent folder line
    :1d 
	if "yes" == s:fileExplorerDotRemove
        :g/^\..*/d 
    endif
	if "yes" == s:fileExplorerDuplicateRemove
        exec ':g/^/ call s:Duplicate()'
    endif
    exec ':%!cat >' s:fileListName
    exec ':%!cat ' s:fileListName
endfunction
" EditFile -- open the file in the current line in a buffer.
fun! s:EditFile(openOption)
  " split type configured, based on 'splitBehaviour' (a:openOption=0)
  " in previous window (a:openOption=1)
  " in new vertical window (a:openOption=2)
  " in new horizontal window (a:openOption=3)
  let l = getline(".")
	if l =~ '^"'  " checks for comments
		return
   endif
  if a:openOption == 0
	if "vert" == s:splitBehavior
        vsplit
	elseif "horiz" == s:splitBehavior
	    split	
	endif
  elseif a:openOption == 1
    wincmd p
  elseif a:openOption == 2
    vsplit
  elseif a:openOption == 3
    split
  endif
  exec ':cs find f '  . l
endfunction

" function to delete duplicate lines
fun! s:Duplicate()
    if getline(".") == getline(line(".") - 1)
        norm dd
    endif
endfunction
