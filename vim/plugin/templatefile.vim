"=============================================================================
" Vim global plugin for autoload template files
" File: templatefile.vim
" Maintainer:	Lubomir Host <host8@kepler.fmph.uniba.sk>
" Last Change: 2002/02/05
" Version: $Id: $
" Thanks:
" 		Scott Urban       : First version of templatefile.vim
" 		                    http://vim.sourceforge.net/scripts/
" 		                           script.php?script_id=198


" Description: 
" 		load template file for new files

augroup TemplateSystem
	autocmd!
	au BufNewFile * silent call LoadTemplateFile()
augroup END


" template file loaded
fun! LoadTemplateFile()
	let extension = expand ("%:e")
	if extension == ""
		let template_file = "templates/" . expand("%:t")
		let template_func = "TemplateFileFunc_noext_" . expand("%:t")
	else
		let template_file = "templates/skel." . extension
		let template_func = "TemplateFileFunc_" . extension
	endif
	if filereadable(expand($VIMTEMPLATE . template_file))
		execute "0r "  $VIMTEMPLATE . template_file 
	elseif filereadable(expand($HOME . "/.vim/" . template_file))
		execute "0r " $HOME . "/.vim/" . template_file
	elseif filereadable(expand($VIM . template_file))
		execute "0r " $VIM . template_file
	elseif filereadable(expand($VIMRUNTIME . template_file))
		execute "0r " $VIMRUNTIME . template_file
	else
		" Template not found
	endif

	let date = strftime("%c")
	let year = strftime("%Y")
	let cwd = getcwd()
	let lastdir = substitute(cwd, ".*/", "", "g")
	let myfile = expand("%:t:r")
	let myfile_ext = expand("%")
	let inc_gaurd = substitute(myfile, "\\.", "_", "g")
	let inc_gaurd = toupper(inc_gaurd)
	silent! execute "%s/@DATE@/" .  date . "/g"
	silent! execute "%s/@YEAR@/" .  year . "/g"
	silent! execute "%s/@LASTDIR@/" .  lastdir . "/g"
	silent! execute "%s/@FILE@/" .  myfile . "/g"
	silent! execute "%s/@FILE_EXT@/" .  myfile_ext . "/g"
	silent! execute "%s/@INCLUDE_GAURD@/" . inc_gaurd . "/g"
	if exists ("*" . template_func)
		" echo "calling " . template_func
		" exec(":call " . template_func . "()")
	endif
endfun

" example for no-extension file specific template processing
fun! TemplateFileFunc_noext_makefile ()
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

