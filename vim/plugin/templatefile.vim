"=============================================================================
" Vim global plugin for autoload template files
" File: templatefile.vim
" Maintainer:	Lubomir Host 'rajo' <8host AT pauli.fmph.uniba.sk>
" Last Change:	2003/01/10
" Version: $Platon: vimconfig/vim/plugin/templatefile.vim,v 1.10 2003-01-16 12:19:32 rajo Exp $
" Thanks:
" 	Scott Urban:	First version of templatefile.vim
" 		        	http://vim.sourceforge.net/scripts/script.php?script_id=198
"	Roland Lezuo:	<roland.lezuo AT chello.at> 
"	             	some suggestions	
" 
" Description: 
" 		Plugin load template file for new files
" 		Templates for new files aren't loaded, if g:load_templates == "no"
" 		if g:load_templates == "ask" you are asked before loading template
" 		If exists enviroment variable $VIMTEMPLATE, templates are loaded from
" 		this directory.

augroup TemplateSystem
	autocmd!
	au BufNewFile * call LoadTemplateFile()
augroup END

command! -nargs=0 LoadTemplateFile call LoadTemplateFile()
command! -nargs=1 LoadFile call LoadFile(<args>)

" escape special characters
function! Escape(str)
	return escape(a:str, '/\\')
endfunction

" template file loaded
function! LoadTemplateFile()
	if exists("g:load_templates")
		if g:load_templates == "no"
			return
		endif
	endif
	let extension = expand ("%:e")
	if extension == ""
		let template_file = "/templates/" . expand("%:t")
		let template_func = "TemplateFileFunc_noext_" . expand("%:t")
	else
		let template_file = "/templates/skel." . extension
		let template_func = "TemplateFileFunc_" . extension
	endif
	if filereadable(expand($VIMTEMPLATE . template_file))
		call LoadTemplateFileConfirm($VIMTEMPLATE . template_file)
	elseif filereadable(expand($HOME . "/.vim" . template_file))
		call LoadTemplateFileConfirm($HOME . "/.vim" . template_file)
	elseif filereadable(expand($VIM . template_file))
		call LoadTemplateFileConfirm($VIM . template_file)
	elseif filereadable(expand($VIMRUNTIME . template_file))
		call LoadTemplateFileConfirm($VIMRUNTIME . template_file)
	else
		" Template not found
	endif

	let date       = Escape(strftime("%d/%m/%Y"))
	let year       = Escape(strftime("%Y"))
	let cwd        = Escape(getcwd())
	let lastdir    = Escape(substitute(cwd, ".*/", "", "g"))
	let myfile     = Escape(expand("%:t:r"))
	let myfile_ext = Escape(expand("%"))
	let inc_gaurd  = Escape(substitute(myfile, "\\.", "_", "g"))
	let inc_gaurd  = Escape(toupper(inc_gaurd))
	if exists("g:author")
		let Author = Escape(g:author)
	endif
	if exists("g:email")
		let Email  = Escape(g:email)
	endif
	if exists("g:company")
		let Company  = Escape(g:company)
	endif
	silent! execute "%s/@DATE@/"          . date       . "/g"
	silent! execute "%s/@YEAR@/"          . year       . "/g"
	silent! execute "%s/@LASTDIR@/"       . lastdir    . "/g"
	silent! execute "%s/@FILE@/"          . myfile     . "/g"
	silent! execute "%s/@FILE_EXT@/"      . myfile_ext . "/g"
	silent! execute "%s/@PATH_SEP@/"      . path_sep   . "/g"
	silent! execute "%s/@INCLUDE_GAURD@/" . inc_gaurd  . "/g"
	silent! execute "%s/@AUTHOR@/"        . Author     . "/g"
	silent! execute "%s/@EMAIL@/"         . Email      . "/g"
	silent! execute "%s/@COMPANY@/"       . Company    . "/g"
	if exists ("*" . template_func)
		if exists("g:load_templates")
			if g:load_templates == "ask"
				let choice = confirm("Call function " . template_func . "() ?:", 
							\ "&yes\n" .
							\ "&no\n")
				if choice == 1
					silent! execute ":call " . template_func . "()"
				endif
			elseif g:load_templates == "yes"
				silent! execute ":call " . template_func . "()"
			endif
		else
			silent! execute ":call " . template_func . "()"
		endif
	endif
endfunction

function! LoadTemplateFileConfirm(filename)
	if filereadable(expand(a:filename))
		if exists("g:load_templates")
			if g:load_templates == "ask"
				let choice = confirm("NEW FILE! Load template file " .
							\ expand(a:filename) . " ?:", 
							\ "&yes\n" .
							\ "&no\n")
				if choice == 1
					execute "0r "  . a:filename
				endif
			elseif g:load_templates == "yes"
				execute "0r "  . a:filename
			endif
		else
			execute "0r "  . a:filename
		endif
	endif
endfunction

function! LoadFile(filename)
	if filereadable(expand(a:filename))
		if exists("g:load_templates")
			if g:load_templates == "ask"
				let choice = confirm("Load file " .
							\ expand(a:filename) . " ?:", 
							\ "&yes\n" .
							\ "&no\n")
				if choice == 1
					execute "0r "  . a:filename
				endif
			elseif g:load_templates == "yes"
				execute "0r "  . a:filename
			endif
		else
			execute "0r "  . a:filename
		endif
	else
		echo "File not found!"
	endif
endfunction

" example for no-extension file specific template processing
function! TemplateFileFunc_noext_makefile()
	let save_r = @r
	let @r = "all:\n\techo your template files need work"
	normal G
	put r
	let @r = save_r
endfunction

" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
" }}}

