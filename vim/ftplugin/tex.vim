" Vim filetype plugin file
" Language:		TeX, LaTeX
" Maintainer:	Lubomir Host <host8@kepler.fmph.uniba.sk>
" License:		GNU GPL
" Version:		$Id: tex.vim,v 1.6 2002/02/02 04:35:41 host8 Exp $
" Language Of Comments:	English


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

setlocal textwidth=72
setlocal formatoptions=croqt
" iskeyword probably dosn't work correctly, dissabling
"setlocal iskeyword=a-z,A-Z,_,-,>,^\\,{,}

" These lines come from $VIMRUNTIME/ftplugin/tex.vim (modified) {{{
" Thanks to Benji Fisher, Ph.D. <benji@member.AMS.org>
let s:save_cpo = &cpo
set cpo&vim

" Set 'comments' to format dashed lists in comments
setlocal comments=sO:%\ -,mO:%\ \ ,eO:%%,:%

" Allow "[d" to be used to find a macro definition:
" Recognize plain TeX \def as well as LaTeX \newcommand and \renewcommand .
setlocal define=\\\\def\\\\|\\\\\\(re\\)\\=newcommand{

" Tell Vim how to recognize LaTeX \include{foo} and plain \input bar :
setlocal include=\\\\input\\\\|\\\\include{
setlocal includeexpr=s:TexIncludeExpr()
if !exists("*s:TexIncludeExpr")
	fun! s:TexIncludeExpr()
		" On some file systems, "}" is inluded in 'isfname'.  In case the
		" TeX file has \include{fname} (LaTeX only), strip the "}" and
		" any other trailing characters.
		let fname = substitute(v:fname, '}.*', '', '')
		" Now, add ".tex" if there is no other file extension.
		if fname !~ '\.'
			let fname = fname . '.tex'
		endif
		return fname
	endfun
endif

" The following lines enable the macros/matchit.vim plugin for
" extended matching with the % key.
if exists("loaded_matchit")
	let b:match_ignorecase = 0
		\ | let b:match_skip = 'r:\\\@<!\%(\\\\\)*%'
		\ | let b:match_words = '(:),\[:],{:},\\(:\\),\\\[:\\],' .
		\ '\\begin\s*\({\a\+\*\=}\):\\end\s*\1'
endif " exists("loaded_matchit")

let &cpo = s:save_cpo
" }}} end cut&paste form $VIMRUNTIME/ftplugin/tex.vim

" These lines comes from file $VIMRUNTIME/compiler/tex.vim  {{{
" Thanks to Artem Chuprina <ran@ran.pp.ru>
let s:cpo_save = &cpo
set cpo-=C
setlocal errorformat=%E!\ LaTeX\ %trror:\ %m,
	\%E!\ %m,
	\%+WLaTeX\ %.%#Warning:\ %.%#line\ %l%.%#,
	\%+W%.%#\ at\ lines\ %l--%*\\d,
	\%WLaTeX\ %.%#Warning:\ %m,
	\%Cl.%l\ %m,
	\%+C\ \ %m.,
	\%+C%.%#-%.%#,
	\%+C%.%#[]%.%#,
	\%+C[]%.%#,
	\%+C%.%#%[{}\\]%.%#,
	\%+C<%.%#>%.%#,
	\%C\ \ %m,
	\%-GSee\ the\ LaTeX%m,
	\%-GType\ \ H\ <return>%m,
	\%-G\ ...%.%#,
	\%-G%.%#\ (C)\ %.%#,
	\%-G(see\ the\ transcript%.%#),
	\%-G\\s%#,
	\%+O(%f)%r,
	\%+P(%f%r,
	\%+P\ %\\=(%f%r,
	\%+P%*[^()](%f%r,
	\%+P[%\\d%[^()]%#(%f%r,
	\%+Q)%r,
	\%+Q%*[^()])%r,
	\%+Q[%\\d%*[^()])%r
let &cpo = s:cpo_save
unlet s:cpo_save
" }}} end cut&paste from $VIMRUNTIME/compiler/tex/vim

" Mappings {{{
" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_tex_maps")
	" Ctrl-F reformat paragraph
	if !hasmapto('<Plug>TexFormat')
		imap <buffer> <C-F> <Plug>TexFormat
		map  <buffer> <C-F> <Plug>TexFormat
	endif
	inoremap <buffer> <Plug>TexFormat <Esc>gqapi
	noremap  <buffer> <Plug>TexFormat gqap
	vnoremap <buffer> <Plug>TexFormat gq
	
	imap <buffer> =a \'{a}
	imap <buffer> +a \v{a}
	imap <buffer> +} \"{a}
	imap <buffer> =b \'{b}
	imap <buffer> +b \v{b}
	imap <buffer> =c \'{c}
	imap <buffer> +c \v{c}
	imap <buffer> =d \'{d}
	imap <buffer> +d \v{d}
	imap <buffer> =e \'{e}
	imap <buffer> +e \v{e}
	imap <buffer> =f \'{f}
	imap <buffer> +f \v{f}
	imap <buffer> =g \'{g}
	imap <buffer> +g \v{g}
	imap <buffer> =h \'{h}
	imap <buffer> +h \v{h}
	imap <buffer> =i \'{\i}
	imap <buffer> +i \v{\i}
	imap <buffer> =j \'{j}
	imap <buffer> +j \v{j}
	imap <buffer> =k \'{k}
	imap <buffer> +k \v{k}
	imap <buffer> =l \'{l}
	imap <buffer> +l \q l
	imap <buffer> =m \'{m}
	imap <buffer> +m \v{m}
	imap <buffer> =n \'{n}
	imap <buffer> +n \v{n}
	imap <buffer> =o \'{o}
	imap <buffer> +o \v{o}
	imap <buffer> +: \^{o}
	imap <buffer> =p \'{p}
	imap <buffer> +p \v{p}
	imap <buffer> =q \'{q}
	imap <buffer> +q \v{q}
	imap <buffer> =r \'{r}
	imap <buffer> +r \v{r}
	imap <buffer> =s \'{s}
	imap <buffer> +s \v{s}
	imap <buffer> =t \'{t}
	imap <buffer> +t \q t
	imap <buffer> =u \'{u}
	imap <buffer> +u \v{u}
	imap <buffer> =v \'{v}
	imap <buffer> +v \v{v}
	imap <buffer> =w \'{w}
	imap <buffer> +w \v{w}
	imap <buffer> =x \'{x}
	imap <buffer> +x \v{x}
	imap <buffer> =y \'{y}
	imap <buffer> +y \v{y}
	imap <buffer> =z \'{z}
	imap <buffer> +z \v{z}
	imap <buffer> =A \'{A}
	imap <buffer> +A \v{A}
	imap <buffer> =B \'{B}
	imap <buffer> +B \v{B}
	imap <buffer> =C \'{C}
	imap <buffer> +C \v{C}
	imap <buffer> =D \'{D}
	imap <buffer> +D \v{D}
	imap <buffer> =E \'{E}
	imap <buffer> +E \v{E}
	imap <buffer> =F \'{F}
	imap <buffer> +F \v{F}
	imap <buffer> =G \'{G}
	imap <buffer> +G \v{G}
	imap <buffer> =H \'{H}
	imap <buffer> +H \v{H}
	imap <buffer> =I \'{\I}
	imap <buffer> +I \v{\I}
	imap <buffer> =J \'{J}
	imap <buffer> +J \v{J}
	imap <buffer> =K \'{K}
	imap <buffer> +K \v{K}
	imap <buffer> =L \'{L}
	imap <buffer> +L \v{L}
	imap <buffer> =M \'{M}
	imap <buffer> +M \v{M}
	imap <buffer> =N \'{N}
	imap <buffer> +N \v{N}
	imap <buffer> =O \'{O}
	imap <buffer> +O \v{O}
	imap <buffer> =P \'{P}
	imap <buffer> +P \v{P}
	imap <buffer> =Q \'{Q}
	imap <buffer> +Q \v{Q}
	imap <buffer> =R \'{R}
	imap <buffer> +R \v{R}
	imap <buffer> =S \'{S}
	imap <buffer> +S \v{S}
	imap <buffer> =T \'{T}
	imap <buffer> +T \v{T}
	imap <buffer> =U \'{U}
	imap <buffer> +U \v{U}
	imap <buffer> =V \'{V}
	imap <buffer> +V \v{V}
	imap <buffer> =W \'{W}
	imap <buffer> +W \v{W}
	imap <buffer> =X \'{X}
	imap <buffer> +X \v{X}
	imap <buffer> =Y \'{Y}
	imap <buffer> +Y \v{Y}
	imap <buffer> =Z \'{Z}
	imap <buffer> +Z \v{Z}

	" Map <BS> to delete "\'{a}" as one character.
	" To avoid complications (start of line, end of line, etc.) the
	" mapping inserts a character, the function deletes all but two
	" characters, and the mapping deletes the last two.
	inoremap <buffer> <BS> x<Esc>:call <SID>SmartBS('\(\\.{\S}\)')<CR>a<BS><BS>

endif
" }}} end mappings	

" This function comes from Benji Fisher <benji@e-math.AMS.org>
" http://vim.sourceforge.net/scripts/download.php?src_id=409 
fun! s:SmartBS(pat, ...)
  let init = strpart(getline("."), 0, col(".")-1)
  let len = strlen(matchstr(init, a:pat . "$")) - 1
  if len > 0
    execute "normal!" . len . "X"
  endif
endfun


" Modeline {{{
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
" }}}
