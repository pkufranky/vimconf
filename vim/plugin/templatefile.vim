"=============================================================================
" Vim global plugin for autoload template files
" File: templatefile.vim
" Maintainer:	Lubomir Host <8host AT pauli.fmph.uniba.sk>
" Last Change: 2003/01/10
" Version: $Platon: vimconfig/vim/plugin/templatefile.vim,v 1.7 2003-01-10 11:52:11 rajo Exp $
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

" template file loaded
fun! LoadTemplateFile()
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

	let date = strftime("%c")
	let year = strftime("%Y")
	let cwd  = getcwd()
	let lastdir = substitute(cwd, ".*/", "", "g")
	let myfile  = expand("%:t:r")
	let myfile_ext = expand("%")
	let myfile_ext = substitute(myfile_ext, "/", "@PATH_SEP@", "")
	let inc_gaurd = substitute(myfile, "\\.", "_", "g")
	let inc_gaurd = toupper(inc_gaurd)
	if exists("g:author")
		let Author = g:author
	endif
	if exists("g:email")
		let Email  = g:email
	endif
	silent! execute "%s/@DATE@/" .  date . "/g"
	silent! execute "%s/@YEAR@/" .  year . "/g"
	silent! execute "%s/@LASTDIR@/"  .  lastdir    . "/g"
	silent! execute "%s/@FILE@/"     .  myfile     . "/g"
	silent! execute "%s/@FILE_EXT@/" .  myfile_ext . "/g"
	silent! execute "%s/@PATH_SEP@/\\//g"
	silent! execute "%s/@INCLUDE_GAURD@/" . inc_gaurd . "/g"
	silent! execute "%s/@AUTHOR@/" . Author . "/g"
	silent! execute "%s/@EMAIL@/"  . Email  . "/g"
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
endfun

fun! LoadTemplateFileConfirm(filename)
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
endfun

fun! LoadFile(filename)
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
endfun

" example for no-extension file specific template processing
fun! TemplateFileFunc_noext_makefile()
	let save_r = @r
	let @r = "all:\n\techo your template files need work"
	normal G
	put r
	let @r = save_r
endfun

" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
" }}}

