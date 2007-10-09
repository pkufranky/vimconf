" Has this already been loaded?
if exists("loaded_tree_explorer") && !exists("g:treeExplDebug")
	finish
endif

" TODO - set foldopen option

let loaded_tree_explorer=1

" Line continuation used here
let s:cpo_save = &cpo
set cpo&vim

" show hidden files
let s:treeExplHidden = (exists("g:treeExplHidden")) ? 1 : 0

" explorer window is created with vertical split if needed
let s:treeExplVertical = (exists("g:treeExplVertical")) ? g:treeExplVertical : 0

" explorer windows initial size
let s:treeExplWinSize = (exists("g:treeExplWinSize")) ? g:treeExplWinSize : 20

" levels to get from tree at a time - perl doesn't work except for 2
let s:treeExplLevels = (exists("g:treeExplLevels")) ? g:treeExplLevels : 2
let s:treeExplLevels = 2

" Create commands
command! -n=? -complete=dir TreeExplore :call s:StartTreeExplorer(0, '<a>')
command! -n=? -complete=dir STreeExplore :call s:StartTreeExplorer(1, '<a>')

" Start the explorer using the preferences from the global variables
function! s:StartTreeExplorer(split, start_dir) " <<<
	if a:start_dir != ""
		let fname=a:start_dir
	else
		let fname = expand("%:p:h")
	endif
	if fname == ""
		let fname = getcwd()
	endif

	" Create a variable to use if splitting vertically
	let splitMode = ""
	if s:treeExplVertical == 1
		let splitMode = "vertical"
	endif

	if a:split || &modified
		let cmd = splitMode . " " . s:treeExplWinSize . "new TreeExplorer"
	else
		let cmd = "e TreeExplorer"
	endif
	silent execute cmd

	setlocal noswapfile
	setlocal buftype=nowrite
	setlocal bufhidden=delete
	setlocal nowrap

	iabc <buffer>

	let w:longhelp = 1

	setlocal foldmethod=marker
	setlocal foldtext=substitute(getline(v:foldstart),'.{{{.*','','')
	setlocal foldlevel=1

  " Set up syntax highlighting
  if has("syntax") && exists("g:syntax_on") && !has("syntax_items")
    syn match treeSynopsis    #^"[ -].*#
    syn match treeDirectory   #\(^[^"][-| `]*\)\@<=[^-| `].*/#
    syn match treeDirectory   "^\.\. (up a directory)$"
		syn match treeParts       #!-- #
		syn match treeParts       #`-- #
		syn match treeParts       #!   #
    syn match treeCurDir      #^/.*$# contains=treeFolds
		syn match treeFolds       "{{{"
		syn match treeFolds       "}}}"
		syn match treeClass "[*=|]$" contained
		" TODO - fix these
		syn match treeExec  #\(^[^"][-| `]*\)\@<=[^-| `].*\*$# contains=treeClass
		syn match treePipe  #\(^[^"][-| `]*\)\@<=[^-| `].*|$# contains=treeClass
		syn match treeSock  #\(^[^"][-| `]*\)\@<=[^-| `].*=$# contains=treeClass
		syn match treeLink  #[^-| `].* -> .*$# contains=treeFolds,treeParts
		"syn match treeLink  #.* -> .*$# contains=treeFolds

		hi def link treeParts       Normal

		hi def link treeFolds       Ignore
		hi def link treeClass       Ignore

    hi def link treeSynopsis    Special
    hi def link treeDirectory   Directory
    hi def link treeCurDir      Statement

		hi def link treeExec        Type
		hi def link treeLink        Title
		hi def link treePipe        String
		hi def link treesock        Identifier

  endif

	" set up mapping for this buffer
  let cpo_save = &cpo
  set cpo&vim
  nnoremap <buffer> <cr> :call <SID>Activate()<cr>
  nnoremap <buffer> o    :call <SID>Activate()<cr>
  nnoremap <buffer> C    :call <SID>ChangeTop()<cr>
  nnoremap <buffer> H    :call <SID>InitWithDir($HOME)<cr>
	nnoremap <buffer> u    :call <SID>ChdirUp()<cr>
	nnoremap <buffer> p    :call <SID>MoveParent()<cr>
  nnoremap <buffer> r    :call <SID>InitWithDir("")<cr>
	nnoremap <buffer> a    :call <SID>ToggleHiddenFiles()<cr>
	nnoremap <buffer> S    :call <SID>StartShell()<cr>
  nnoremap <buffer> ?    :call <SID>ToggleHelp()<cr>
  let &cpo = cpo_save

	call s:InitWithDir(fname)
endfunction " >>>

" reload tree with dir
function! s:InitWithDir(dir) " <<<
	if a:dir != ""
		execute "lcd " . escape (a:dir, ' ')
	endif
	let cwd = getcwd ()

	setlocal modifiable

	silent normal ggdG

	"insert header
	call s:AddHeader()
	normal G

	let save_f=@f

	"insert parent dir
	if cwd != "/"
		let @f="\n.. (up a directory)"
	else
		let @f="\n\n"
	endif
	put! f

	normal Gdd

	let d = escape (cwd, ' ')
	let cmd = "r!vimtreeexpl.pl "
	let cmd = cmd . d . " "
	let cmd = cmd . s:treeExplLevels . " "
	let cmd = cmd . s:treeExplHidden
	silent execute cmd

	let @f = "\n"
	put f
	let @f=save_f

	if w:longhelp == 1
		14
	else
		4
	endif

	setlocal nomodifiable
endfunction " >>>

" cd up (if possible)
function! s:ChdirUp() " <<<
	if getcwd() == "/"
		echo "already at top dir"
	else
		call s:InitWithDir("..")
	endif
endfunction " >>>

" move cursor to parent dir
function! s:MoveParent() " <<<
	let ln = line(".")
	call s:GetAbsPath2 (ln, 1)
	if s:firstdirline != 0
		exec (":" . s:firstdirline)
	else
		if w:longhelp == 1
			14
		else
			4
		endif
	endif
endfunction " >>>

" change top dir
function! s:ChangeTop() " <<<
	let ln = line(".")
  let l = getline(ln)

	" on current top or non-tree line?
	if l =~ '^/' || l =~ '^$' || l =~ '^"'
		return
	endif

	" parent dir
	if l =~ '^\.\. '
		call s:ChdirUp()
		return
	endif

	let curfile = s:GetAbsPath2(ln, 0)
	if curfile !~ '/$'
		let curfile = substitute (curfile, '[^/]*$', "", "")
	endif
	call s:InitWithDir (curfile)

endfunction " >>>

" open dir, file, or parent dir
function! s:Activate() " <<<
	let ln = line(".")
  let l = getline(ln)

	" parent dir, change to it
  if l =~ '^\.\. (up a directory)$'
		call s:ChdirUp()
    return
  endif

	" directory, loaded, toggle folded state
	if l =~ ' {{{$'
		if foldclosed(ln) == -1
			foldclose
		else
			foldopen
		endif
		return
	endif

	" on top, no folds
	if l =~ '^/'
		return
	endif

	" get path of line
	let curfile = s:GetAbsPath2 (ln, 0)

	if curfile =~ '/$' " dir
		setlocal modifiable
		normal ddk
		let d = escape (curfile, ' ')
		let cmd = "r!vimtreeexpl.pl "
		let cmd = cmd . d . " "
		let cmd = cmd . s:treeExplLevels . " "
		let cmd = cmd . s:treeExplHidden
		let cmd = cmd . " '" . l . "'"
		silent execute cmd
		setlocal nomodifiable
		exec (":" . ln)
	else " file
		let f = escape (curfile, ' ')
		let oldwin = winnr()
		wincmd p
		if oldwin == winnr() || &modified
			wincmd p
			exec ("new " . f)
		else
			exec ("edit " . f)
		endif
	endif
endfunction " >>>

" toggle hidden files
function! s:ToggleHiddenFiles() " <<<
	let s:treeExplHidden = s:treeExplHidden ? 0 : 1
	let hiddenStr = s:treeExplHidden ? "on" : "off"
	let hiddenStr = "hidden files now " . hiddenStr
	echo hiddenStr
endfunction " >>>

" start shell in dir
function! s:StartShell() " <<<
	let ln = line(".")

	let curfile = s:GetAbsPath2 (ln, 1)
	let prevdir = getcwd()

	if s:firstdirline == 0
		let dir = prevdir
	else
		let dir = substitute (curfile, '[^/]*$', "", "")
	endif

	execute "lcd " . escape (dir, ' ')
	shell
	execute "lcd " . escape (prevdir, ' ')
endfunction " >>>

" get absolute parent path of file or dir in line ln, set s:firstdirline
function! s:GetAbsPath2(ln,ignore_current) " <<<
	let lnum = a:ln
	let l = getline(lnum)

	let s:firstdirline = 0

	" in case called from outside the tree
	if l =~ '^[/".]' || l =~ '^$'
		return ""
	endif

	let wasdir = 0

	" strip file
	let curfile = substitute (l,'^[-| `]*',"","") " remove tree parts
	let curfile = substitute (curfile,'[ {}]*$',"",'') " remove fold marks
	let curfile = substitute (curfile,'[*=@|]$',"","") " remove file class

	if curfile =~ '/$' && a:ignore_current == 0
		let wasdir = 1
		let s:firstdirline = lnum
	endif

	let curfile = substitute (curfile,' -> .*',"","") " remove link to
	if wasdir == 1
		let curfile = substitute (curfile, '/\?$', '/', "")
	endif

	let indent = match(l,'[^-| `]') / 4
	let dir = ""
	while lnum > 0
		let lnum = lnum - 1
		let lp = getline(lnum)
		if lp =~ '^/'
			let sd = substitute (lp, '[ {]*$', "", "")
			let dir = sd . '/' . dir
			break
		endif
		if lp =~ ' {{{$'
			let lpindent = match(lp,'[^-| `]') / 4
			if lpindent < indent
				if s:firstdirline == 0
					let s:firstdirline = lnum
				endif
				let indent = indent - 1
				let sd = substitute (lp, '^[-| `]*',"","") " rm tree parts
				let sd = substitute (sd, '/[ {}]*$', "", "") " rm slash & foldmarks
				let sd = substitute (sd, ' -> .*',"","") " rm link to
				let dir = sd . '/' . dir
				continue
			endif
		endif
	endwhile
	let curfile = dir . '/' . curfile
	return curfile
endfunction " >>>

" toggle between long and short help
function! s:ToggleHelp() " <<<
	if exists ("w:longhelp") && w:longhelp == 0
		let w:longhelp = 1
		let s:longhelp = 1
	else
		let w:longhelp = 0
		let s:longhelp = 0
	endif
	setlocal modifiable
	call s:UpdateHeader ()
	setlocal nomodifiable
endfunction " >>>

" Update the header
function! s:UpdateHeader() " <<<
	let oldRep=&report
	set report=10000
	" Save position
	normal! mt
  " Remove old header
  0
  1,/^" ?/ d _
  " Add new header
  call s:AddHeader()
  " Go back where we came from if possible
  0
  if line("'t") != 0
    normal! `t
  endif

  let &report=oldRep
  setlocal nomodified
endfunction " >>>

" Add the header with help information
function! s:AddHeader() " <<<
    let save_f=@f
    1
    if w:longhelp == 1
      let @f="\" <enter> : same as 'o' below\n"
           \."\" o : (file) open in previous or new window\n"
           \."\" o : (dir) toggle dir fold or load dir\n"
			     \."\" C : chdir - make current dir top of the tree\n"
			     \."\" H : chdir to home dir\n"
			     \."\" u : chdir to parent dir\n"
			     \."\" p : move to parent dir\n"
			     \."\" r : refresh top dir\n"
			     \."\" a : toggle hidden file display\n"
			     \."\" S : start a shell in dir\n"
			     \."\" ? : toggle long help\n"
    else
      let @f="\" ? : toggle long help\n"
    endif
    put! f
    let @f=save_f
endfunction " >>>

" vim: set ts=2 sw=2 foldmethod=marker foldmarker=<<<,>>> :
