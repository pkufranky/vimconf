" LaTeX filetype plugin
"	  Language: LaTeX (ft=tex)
"	Maintainer: Srinath Avadhanula
"		 Email: srinath@eecs.berkeley.edu
"		   URL: http://vim.sourceforge.net/scripts/script.php?script_id=93
"  Last Change: Thu Mar 21 06:00 AM 2002 PST
"
" Help: 
" NOTE: the macros which were previously placed in this file have been moved
" to the plugin imaps.vim (get it from http://vim.sf.net).
"
" Changes: {{{
" Mar 17 2002: 1. added errorformat and makeprg options for latex.
" 2001 Dec 9: 1. took some stuff from auctex.vim
"				such as smart quotes and dollar, etc.
" 2001 Dec 7: 1. changed things so that most mappings emulate the operator
"				pending mode. this greatly facilitates typing by not
"				requiring the LHS to be typed quickly. one can infact type
"				the LHS (without the <tab>), roam around in the file, come
"				back to the end of the file, press <tab> and still have the
"				LHS expand properly!
"			  2. planning a second release for this.
" }}}

" $ID: $

if exists("b:didLocalTex")
	finish	
end
let b:didLocalTex = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal isk+=:
setlocal sw=4
setlocal ts=4
setlocal textwidth=72
setlocal formatoptions=croqt

" disable IMAP() function in math environments
let g:disabled_imap_syntax_items = "texMathZone\\|texStatement"

" These lines come from $VIMRUNTIME/ftplugin/tex.vim (modified by Lubomir Host) {{{
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

" mappings {{{
let s:ml = exists('g:mapleader') ? g:mapleader : '\'

if !exists('s:doneMappings')
	let s:doneMappings = 1
	" short forms for latex formatting and math elements. {{{
	" only a few of these are mine originally. otherwise taken from auctex.vim or
	" miktexmacros.vim
	" call IMAP ('__', '_{ää}«»', "tex")
	" call IMAP ('()', '(ää)«»', "tex")
	" call IMAP ('[]', '[ää]«»', "tex")
	" call IMAP ('{}', '{ää}«»', "tex")
	" call IMAP ('^^', '^{ää}«»', "tex")
	" call IMAP ('$$', '$ää$«»', "tex")
	" call IMAP ('==', '&=& ', "tex")
	call IMAP ('...', '\dots', "tex")
	call IMAP ('::', '\cdots', "tex")
	" call IMAP ('((', '\left( ää \right)«»', "tex")
	" call IMAP ('[[', '\left[ ää \right]«»', "tex")
	" call IMAP ('{{', '\left\{ ää \right\}«»', "tex")
	" call IMAP ('`^', '\hat{ää}«»', "tex")
	" call IMAP ('`_', '\bar{ää}«»', "tex")
	call IMAP ('`6', '\partial', "tex")
	call IMAP ('`8', '\infty', "tex")
	" call IMAP ('`/', '\frac{ää}{«»}«»', "tex")
	call IMAP ('`/', '\frac{ää}{}', "tex")
	" call IMAP ('`%', '\frac{ää}{«»}«»', "tex")
	call IMAP ('`%', '\frac{ää}{}', "tex")
	call IMAP ('`@', '\circ', "tex")
	call IMAP ('`0', '^\circ', "tex")
	call IMAP ('`=', '\equiv', "tex")
	call IMAP ('`\', '\setminus', "tex")
	call IMAP ('`.', '\cdot', "tex")
	call IMAP ('`*', '\times', "tex")
	call IMAP ('`&', '\wedge', "tex")
	call IMAP ('`-', '\bigcap', "tex")
	call IMAP ('`+', '\bigcup', "tex")
	call IMAP ('`(', '\subset', "tex")
	call IMAP ('`)', '\supset', "tex")
	call IMAP ('`<', '\le', "tex")
	call IMAP ('`>', '\ge', "tex")
	call IMAP ('`,', '\nonumber', "tex")
	" call IMAP ('`~', '\tilde{ää}«»', "tex")
	call IMAP ('`~', '\tilde{ää}', "tex")
	" call IMAP ('`;', '\dot{ää}«»', "tex")
	call IMAP ('`;', '\dot{ää}', "tex")
	" call IMAP ('`:', '\ddot{ää}«»', "tex")
	call IMAP ('`:', '\ddot{ää}', "tex")
	" call IMAP ('`2', '\sqrt{ää}«»', "tex")
	call IMAP ('`2', '\sqrt{ää}', "tex")
    call IMAP ('`|', '\Big|', "tex")
	" call IMAP ('`I', "\\int_{ää}^{«»}«»", 'tex')
	call IMAP ('`I', "\\int_{ää}^{}", 'tex')
	" }}}
	" latex environments (my style) originally in imaps.vim {{{
	call IMAP ("bar".s:ml, "\\leftää\<cr>\\begin{array}{«dimension»}\<cr>«elements»\<cr>\\end{array}\<cr>\\right«»", "tex")
	call IMAP ("ben".s:ml, "\\begin{enumerate}\<cr>\\item ää\<cr>\\end{enumerate}«»", "tex")
	call IMAP ("bit".s:ml, "\\begin{itemize}\<cr>\\item ää\<cr>\\end{itemize}«»", "tex")
	call IMAP ("beq".s:ml, "\\begin{equation}\<cr>\\label{ää}\<cr>\\end{equation}«»", "tex")
	call IMAP ("bqn".s:ml, "\\begin{eqnarray}\<cr>ää\<cr>\\end{eqnarray}«»", "tex")
	call IMAP ("bfg".s:ml, "\\begin{figure}[h]\<cr>\\centerline{\\psfig{figure=«eps file»}}\<cr>\\caption{«caption text»}\<cr>\\label{fig:«label»}\<cr>\\end{figure}«»", "tex")
	call IMAP ("bfe".s:ml, "\\begin{figure}\<cr>\\vspace{ää}\<cr>\\caption{«caption text»}\<cr>\\end{figure}«»", "tex")
	call IMAP ("btb".s:ml, "\\begin{tabular}{ää}\<cr>\<cr>\\end{tabular}«»", "tex")
	call IMAP ("bta".s:ml, "\\begin{table}\<cr>\\centering\<cr>\\caption{tab:ää}\<cr>\\begin{tabular}{«dimensions»}\<cr>\<cr>\\end{tabular}\<cr>\\label{tab:«label»}\<cr>\\end{table}«»", "tex")
	call IMAP ("pic".s:ml, "\\begin{picture}(4,4)\<cr>\\put(0.5,0){\\framebox(4,4){ää}}\<cr>\\end{picture}«»", "tex")
	call IMAP ("mat".s:ml, "\\left[\<cr>\\begin{array}{ää}\<cr>«»\<cr>\\end{array}\<cr>\\right]«»", "tex")
	call IMAP ("verb".s:ml, "\\begin{verbatim}\<cr>\<cr>ää\\end{verbatim}«»", "tex")
	call IMAP ("minip".s:ml, "\\begin{minipage}[t]{ääcm}\<cr>\\end{minipage}«»", "tex")
	" end my style latex environments }}}
	" latex environments from Mikolaj Machowski {{{
	function! <SID>TeX_imap_env(shortcut,env)
		" exe 'call IMAP ("'.a:shortcut.'",  "\\begin{'.a:env.'}\<cr>ää\<cr>\\end{'.a:env.'}«»", "tex")'
		exe 'call IMAP ("'.a:shortcut.'",  "\\begin{'.a:env.'}\<cr>ää\<cr>\\end{'.a:env.'}", "tex")'
	endfunction
	call <SID>TeX_imap_env("EAB","abstract")
	call <SID>TeX_imap_env("EAP","appendix")
	call <SID>TeX_imap_env("EAR","array")
	call <SID>TeX_imap_env("ECE","center")
	call <SID>TeX_imap_env("EDE","description")
	call <SID>TeX_imap_env("EDI","displaymath")
	call <SID>TeX_imap_env("EDO","document")
	call <SID>TeX_imap_env("EEN","enumerate")
	call <SID>TeX_imap_env("EEA","eqnarray")
	call <SID>TeX_imap_env("EEQ","equation")
	call <SID>TeX_imap_env("EFI","figure")
	call <SID>TeX_imap_env("EFC","filecontents")
	call <SID>TeX_imap_env("EFL","flushleft")
	call <SID>TeX_imap_env("EFR","flushright")
	call <SID>TeX_imap_env("EIT","itemize")
	call <SID>TeX_imap_env("ELE","letter")
	call <SID>TeX_imap_env("ELI","list")
	call <SID>TeX_imap_env("ELR","lrbox")
	call <SID>TeX_imap_env("EMA","math")
	call <SID>TeX_imap_env("EMI","minipage")
	call <SID>TeX_imap_env("ENO","note")
	call <SID>TeX_imap_env("EOV","overlay")
	call <SID>TeX_imap_env("EPI","picture")
	call <SID>TeX_imap_env("EQN","quotation")
	call <SID>TeX_imap_env("EQE","quote")
	call <SID>TeX_imap_env("ESL","slide")
	call <SID>TeX_imap_env("ESB","sloppybar")
	call <SID>TeX_imap_env("ETA","tabbing")
	call <SID>TeX_imap_env("ETE","table")
	call <SID>TeX_imap_env("ETR","tabular")
	call <SID>TeX_imap_env("ETB","thebibliography")
	call <SID>TeX_imap_env("ETI","theindex")
	call <SID>TeX_imap_env("ETH","theorem")
	call <SID>TeX_imap_env("ETP","titlepage")
	call <SID>TeX_imap_env("ETL","trivlist")
	call <SID>TeX_imap_env("EVB","verbatim")
	call <SID>TeX_imap_env("EVS","verse")
	" }}}
	" other miscellaneous stuff taken from imaps.vim. {{{
	call IMAP ("vb".s:ml, "\\verb|ää|«»", "tex")
	call IMAP ("bf".s:ml, "{\\bf ää}«»", "tex")
	call IMAP ("em".s:ml, "{\\em ää}«»", "tex")
	call IMAP ("it".s:ml, "{\\it ää}«»", "tex")
	call IMAP ("mb".s:ml, "\\mbox{ää}«»", "tex")
	call IMAP ("frac".s:ml, "\\frac{ää}{«»}«»", "tex")
	call IMAP ("sq".s:ml, "\\sqrt{ää}«»", "tex")
	call IMAP ("eps".s:ml, "\\psfig{figure=ää.eps}«»", "tex")
	call IMAP ("sec".s:ml, "\\section{ää}«»", "tex")
	call IMAP ("ssec".s:ml, "\\subsection{ää}«»", "tex")
	call IMAP ("sssec".s:ml, "\\subsubsection{ää}«»", "tex")
	call IMAP ("sec2".s:ml, "\\subsection{ää}«»", "tex")
	call IMAP ("sec3".s:ml, "\\subsubsection{ää}«»", "tex")
	call IMAP ("sum".s:ml, "\\sum{ää}{«»}«»", "tex")
	call IMAP ("suml".s:ml, "\\sum\\limits_{ää}^{«»}«»", "tex")
	call IMAP ("int".s:ml, "\\int_{ää}^{«»}«»", "tex")
	call IMAP ("intl".s:ml, "\\int\\limits_{ää}^{«»}«»", "tex")
	call IMAP ("bbr".s:ml, "\\left( ää \\right)«»", "tex")
	call IMAP ("bbc".s:ml, "\\left\\{ ää \\right\\}«»", "tex")
	call IMAP ("bbs".s:ml, "\\left[ ää \\right]«»", "tex")
	call IMAP ("rr".s:ml, "\\right", "tex")
	call IMAP ("ll".s:ml, "\\left", "tex")
	call IMAP ("part".s:ml, "\\partial", "tex")
	call IMAP ("dot".s:ml, "\\dot{ää}«»", "tex")
	call IMAP ("ddot".s:ml, "\\ddot{ää}«»", "tex")
	" }}}
	" Greek letters imaps.vim style {{{
	call IMAP('`a', "\\alpha", "tex")
	call IMAP('`b', "\\beta", "tex")
	call IMAP('`c', "\\chi", "tex")
	call IMAP('`d', "\\delta", "tex")
	call IMAP('`e', "\\varepsilon", 'tex')
	call IMAP('`f', "\\varphi", 'tex')
	call IMAP('`g', "\\gamma", "tex")
	call IMAP('`h', "\\eta", "tex")
	call IMAP('`k', "\\kappa", "tex")
	call IMAP('`l', "\\lambda", "tex")
	call IMAP('`m', "\\mu", "tex")
	call IMAP('`n', "\\nu", "tex")
	call IMAP('`p', "\\pi", "tex")
	call IMAP('`q', "\\theta", "tex")
	call IMAP('`r', "\\rho", "tex")
	call IMAP('`s', "\\sigma", "tex")
	call IMAP('`t', "\\tau", "tex")
	call IMAP('`u', "\\upsilon", "tex")
	call IMAP('`v', "\\varsigma", "tex")
	call IMAP('`w', "\\omega", "tex")
	" call IMAP('`w', "\\wedge", 'tex')  " AUCTEX style
	call IMAP('`x', "\\xi", "tex")
	call IMAP('`y', "\\psi", "tex")
	call IMAP('`z', "\\zeta", "tex")
	call IMAP('`A', "\\Alpha", "tex")
	call IMAP('`B', "\\Beta", "tex")
	call IMAP('`C', "\\Chi", "tex")
	call IMAP('`D', "\\Delta", "tex")
	call IMAP('`E', "\\Epsilon", "tex")
	call IMAP('`F', "\\Phi", "tex")
	call IMAP('`G', "\\Gamma", "tex")
	call IMAP('`H', "\\Eta", "tex")
	call IMAP('`K', "\\Kappa", "tex")
	call IMAP('`L', "\\Lambda", "tex")
	call IMAP('`M', "\\Mu", "tex")
	call IMAP('`N', "\\Nu", "tex")
	call IMAP('`P', "\\Pi", "tex")
	call IMAP('`Q', "\\Theta", "tex")
	call IMAP('`R', "\\Rho", "tex")
	call IMAP('`S', "\\Sigma", "tex")
	call IMAP('`T', "\\Tau", "tex")
	call IMAP('`U', "\\Upsilon", "tex")
	call IMAP('`V', "\\Varsigma", "tex")
	call IMAP('`W', "\\Omega", "tex")
	call IMAP('`X', "\\Xi", "tex")
	call IMAP('`Y', "\\Psi", "tex")
	call IMAP('`Z', "\\Zeta", "tex")
	" }}}
	" Diacritics from Lubomir Host {{{
	if exists("g:tex_input_method")
		if g:tex_input_method == "tex-universal"
			" universal TeX mappings {{{
			call IMAP ('=a', "\\\'{a}", 'tex')
			call IMAP ('+a', "\\v{a}", 'tex')
			call IMAP ('+}', "\\\"{a}", 'tex')
			call IMAP ('=b', "\\'{b}", 'tex')
			call IMAP ('+b', "\\v{b}", 'tex')
			call IMAP ('=c', "\\'{c}", 'tex')
			call IMAP ('+c', "\\v{c}", 'tex')
			call IMAP ('=d', "\\'{d}", 'tex')
			call IMAP ('+d', "\\v{d}", 'tex')
			call IMAP ('=e', "\\'{e}", 'tex')
			call IMAP ('+e', "\\v{e}", 'tex')
			call IMAP ('=f', "\\'{f}", 'tex')
			call IMAP ('+f', "\\v{f}", 'tex')
			call IMAP ('=g', "\\'{g}", 'tex')
			call IMAP ('+g', "\\v{g}", 'tex')
			call IMAP ('=h', "\\'{h}", 'tex')
			call IMAP ('+h', "\\v{h}", 'tex')
			call IMAP ('=i', "\\'{\\i}", 'tex')
			call IMAP ('+i', "\\v{\\i}", 'tex')
			"call IMAP ('=j', "\\'{\\j}", 'tex')
			"call IMAP ('+j', "\\v{\\j}", 'tex')
			"call IMAP ('=k', "\\'{k}", 'tex')
			"call IMAP ('+k', "\\v{k}", 'tex')
			call IMAP ('=l', "\\'{l}", 'tex')
			call IMAP ('+l', "\\q l", 'tex')
			call IMAP ('=m', "\\'{m}", 'tex')
			call IMAP ('+m', "\\v{m}", 'tex')
			call IMAP ('=n', "\\'{n}", 'tex')
			call IMAP ('+n', "\\v{n}", 'tex')
			call IMAP ('=o', "\\'{o}", 'tex')
			call IMAP ('+o', "\\v{o}", 'tex')
			call IMAP ('+:', "\\^{o}", 'tex')
			call IMAP ('=p', "\\'{p}", 'tex')
			call IMAP ('+p', "\\v{p}", 'tex')
			call IMAP ('=q', "\\'{q}", 'tex')
			call IMAP ('+q', "\\v{q}", 'tex')
			call IMAP ('=r', "\\'{r}", 'tex')
			call IMAP ('+r', "\\v{r}", 'tex')
			call IMAP ('=s', "\\'{s}", 'tex')
			call IMAP ('+s', "\\v{s}", 'tex')
			call IMAP ('=t', "\\'{t}", 'tex')
			call IMAP ('+t', "\\q t", 'tex')
			call IMAP ('=u', "\\'{u}", 'tex')
			call IMAP ('+u', "\\v{u}", 'tex')
			call IMAP ('=v', "\\'{v}", 'tex')
			call IMAP ('+v', "\\v{v}", 'tex')
			call IMAP ('=w', "\\'{w}", 'tex')
			call IMAP ('+w', "\\v{w}", 'tex')
			call IMAP ('=x', "\\'{x}", 'tex')
			call IMAP ('+x', "\\v{x}", 'tex')
			call IMAP ('=y', "\\'{y}", 'tex')
			call IMAP ('+y', "\\v{y}", 'tex')
			call IMAP ('=z', "\\'{z}", 'tex')
			call IMAP ('+z', "\\v{z}", 'tex')
			call IMAP ('=A', "\\'{A}", 'tex')
			call IMAP ('+A', "\\v{A}", 'tex')
			call IMAP ('=B', "\\'{B}", 'tex')
			call IMAP ('+B', "\\v{B}", 'tex')
			call IMAP ('=C', "\\'{C}", 'tex')
			call IMAP ('+C', "\\v{C}", 'tex')
			call IMAP ('=D', "\\'{D}", 'tex')
			call IMAP ('+D', "\\v{D}", 'tex')
			call IMAP ('=E', "\\'{E}", 'tex')
			call IMAP ('+E', "\\v{E}", 'tex')
			call IMAP ('=F', "\\'{F}", 'tex')
			call IMAP ('+F', "\\v{F}", 'tex')
			call IMAP ('=G', "\\'{G}", 'tex')
			call IMAP ('+G', "\\v{G}", 'tex')
			call IMAP ('=H', "\\'{H}", 'tex')
			call IMAP ('+H', "\\v{H}", 'tex')
			call IMAP ('=I', "\\'{I}", 'tex')
			call IMAP ('+I', "\\v{I}", 'tex')
			"call IMAP ('=J', "\\'{J}", 'tex')
			"call IMAP ('+J', "\\v{J}", 'tex')
			call IMAP ('=K', "\\'{K}", 'tex')
			call IMAP ('+K', "\\v{K}", 'tex')
			call IMAP ('=L', "\\'{L}", 'tex')
			call IMAP ('+L', "\\v{L}", 'tex')
			call IMAP ('=M', "\\'{M}", 'tex')
			call IMAP ('+M', "\\v{M}", 'tex')
			call IMAP ('=N', "\\'{N}", 'tex')
			call IMAP ('+N', "\\v{N}", 'tex')
			call IMAP ('=O', "\\'{O}", 'tex')
			call IMAP ('+O', "\\v{O}", 'tex')
			call IMAP ('=P', "\\'{P}", 'tex')
			call IMAP ('+P', "\\v{P}", 'tex')
			call IMAP ('=Q', "\\'{Q}", 'tex')
			call IMAP ('+Q', "\\v{Q}", 'tex')
			call IMAP ('=R', "\\'{R}", 'tex')
			call IMAP ('+R', "\\v{R}", 'tex')
			call IMAP ('=S', "\\'{S}", 'tex')
			call IMAP ('+S', "\\v{S}", 'tex')
			call IMAP ('=T', "\\'{T}", 'tex')
			call IMAP ('+T', "\\v{T}", 'tex')
			call IMAP ('=U', "\\'{U}", 'tex')
			call IMAP ('+U', "\\v{U}", 'tex')
			call IMAP ('=V', "\\'{V}", 'tex')
			call IMAP ('+V', "\\v{V}", 'tex')
			call IMAP ('=W', "\\'{W}", 'tex')
			call IMAP ('+W', "\\v{W}", 'tex')
			call IMAP ('=X', "\\'{X}", 'tex')
			call IMAP ('+X', "\\v{X}", 'tex')
			call IMAP ('=Y', "\\'{Y}", 'tex')
			call IMAP ('+Y', "\\v{Y}", 'tex')
			call IMAP ('=Z', "\\'{Z}", 'tex')
			call IMAP ('+Z', "\\v{Z}", 'tex')
			" end universal TeX mappings }}}
		elseif g:tex_input_method == "tex-iso8859-2" ||
					\ g:tex_input_method == "iso8859-2" ||
					\ g:tex_input_method == "tex-latin2" ||
					\ g:tex_input_method == "latin2"
			" iso8859-2(latin2) TeX mappings {{{
			call IMAP ('=a', "á", 'tex')
			call IMAP ('+a', "\\v{a}", 'tex')
			call IMAP ('+}', "ä", 'tex')
			call IMAP ('=b', "\\'{b}", 'tex')
			call IMAP ('+b', "\\v{b}", 'tex')
			call IMAP ('=c', "æ", 'tex')
			call IMAP ('+c', "è", 'tex')
			call IMAP ('=d', "\\'{d}", 'tex')
			call IMAP ('+d', "ï", 'tex')
			call IMAP ('=e', "é", 'tex')
			call IMAP ('+e', "ì", 'tex')
			call IMAP ('=f', "\\'{f}", 'tex')
			call IMAP ('+f', "\\v{f}", 'tex')
			call IMAP ('=g', "\\'{g}", 'tex')
			call IMAP ('+g', "\\v{g}", 'tex')
			call IMAP ('=h', "\\'{h}", 'tex')
			call IMAP ('+h', "\\v{h}", 'tex')
			call IMAP ('=i', "í", 'tex')
			call IMAP ('+i', "\\v{\\i}", 'tex')
			"call IMAP ('=j', "\\'{\\j}", 'tex')
			"call IMAP ('+j', "\\v{\\j}", 'tex')
			"call IMAP ('=k', "\\'{k}", 'tex')
			"call IMAP ('+k', "\\v{k}", 'tex')
			call IMAP ('=l', "å", 'tex')
			call IMAP ('+l', "µ", 'tex')
			call IMAP ('=m', "\\'{m}", 'tex')
			call IMAP ('+m', "\\v{m}", 'tex')
			call IMAP ('=n', "ñ", 'tex')
			call IMAP ('+n', "ò", 'tex')
			call IMAP ('=o', "ó", 'tex')
			call IMAP ('+o', "ö", 'tex')
			call IMAP ('+:', "ô", 'tex')
			call IMAP ('=p', "\\'{p}", 'tex')
			call IMAP ('+p', "\\v{p}", 'tex')
			call IMAP ('=q', "\\'{q}", 'tex')
			call IMAP ('+q', "\\v{q}", 'tex')
			call IMAP ('=r', "à", 'tex')
			call IMAP ('+r', "ø", 'tex')
			call IMAP ('=s', "¶", 'tex')
			call IMAP ('+s', "¹", 'tex')
			call IMAP ('=t', "\\'{t}", 'tex')
			call IMAP ('+t', "»", 'tex')
			call IMAP ('=u', "ú", 'tex')
			call IMAP ('+u', "ü", 'tex')
			call IMAP ('=v', "\\'{v}", 'tex')
			call IMAP ('+v', "\\v{v}", 'tex')
			call IMAP ('=w', "\\'{w}", 'tex')
			call IMAP ('+w', "\\v{w}", 'tex')
			call IMAP ('=x', "\\'{x}", 'tex')
			call IMAP ('+x', "\\v{x}", 'tex')
			call IMAP ('=y', "ý", 'tex')
			call IMAP ('+y', "\\v{y}", 'tex')
			call IMAP ('=z', "¼", 'tex')
			call IMAP ('+z', "¾", 'tex')
			call IMAP ('=A', "Á", 'tex')
			call IMAP ('+A', "Ä", 'tex')
			call IMAP ('=B', "\\'{B}", 'tex')
			call IMAP ('+B', "\\v{B}", 'tex')
			call IMAP ('=C', "Æ", 'tex')
			call IMAP ('+C', "È", 'tex')
			call IMAP ('=D', "\\'{D}", 'tex')
			call IMAP ('+D', "Ï", 'tex')
			call IMAP ('=E', "É", 'tex')
			call IMAP ('+E', "Ì", 'tex')
			call IMAP ('=F', "\\'{F}", 'tex')
			call IMAP ('+F', "\\v{F}", 'tex')
			call IMAP ('=G', "\\'{G}", 'tex')
			call IMAP ('+G', "\\v{G}", 'tex')
			call IMAP ('=H', "\\'{H}", 'tex')
			call IMAP ('+H', "\\v{H}", 'tex')
			call IMAP ('=I', "Í", 'tex')
			call IMAP ('+I', "\\v{I}", 'tex')
			"call IMAP ('=J', "\\'{J}", 'tex')
			"call IMAP ('+J', "\\v{J}", 'tex')
			call IMAP ('=K', "\\'{K}", 'tex')
			call IMAP ('+K', "\\v{K}", 'tex')
			call IMAP ('=L', "Å", 'tex')
			call IMAP ('+L', "¥", 'tex')
			call IMAP ('=M', "\\'{M}", 'tex')
			call IMAP ('+M', "\\v{M}", 'tex')
			call IMAP ('=N', "Ñ", 'tex')
			call IMAP ('+N', "Ò", 'tex')
			call IMAP ('=O', "Ó", 'tex')
			call IMAP ('+O', "Ô", 'tex')
			call IMAP ('=P', "\\'{P}", 'tex')
			call IMAP ('+P', "\\v{P}", 'tex')
			call IMAP ('=Q', "\\'{Q}", 'tex')
			call IMAP ('+Q', "\\v{Q}", 'tex')
			call IMAP ('=R', "À", 'tex')
			call IMAP ('+R', "Ø", 'tex')
			call IMAP ('=S', "¦", 'tex')
			call IMAP ('+S', "©", 'tex')
			call IMAP ('=T', "\\'{T}", 'tex')
			call IMAP ('+T', "«", 'tex')
			call IMAP ('=U', "Ú", 'tex')
			call IMAP ('+U', "Ü", 'tex')
			call IMAP ('=V', "\\'{V}", 'tex')
			call IMAP ('+V', "\\v{V}", 'tex')
			call IMAP ('=W', "\\'{W}", 'tex')
			call IMAP ('+W', "\\v{W}", 'tex')
			call IMAP ('=X', "\\'{X}", 'tex')
			call IMAP ('+X', "\\v{X}", 'tex')
			call IMAP ('=Y', "Ý", 'tex')
			call IMAP ('+Y', "\\v{Y}", 'tex')
			call IMAP ('=Z', "¬", 'tex')
			call IMAP ('+Z', "®", 'tex')
			" end iso8859-2(latin2) TeX mappings }}}
		endif
	endif
	" }}}
	" vmaps: enclose selected region in brackts, environments {{{
	vnoremap <Leader>( "rxi\left(<cr>\right)<cr><esc>k"rP
	vnoremap <Leader>[ "rxi\left[<cr>\right]<cr><esc>k"rP
	vnoremap <Leader>{ "rxi\left\{<cr>\right\}<cr><esc>k"rP
	vnoremap <Leader>v "rxi\begin{verbatim}<cr>\end{verbatim}<esc>k"rP
	vnoremap <Leader>c "rxi\begin{center}<cr>\end{center}<esc>k"rP
	" }}}
end
" }}}

" RunLaTeX: compilation function {{{
" this function runs the latex command on the currently open file. often times
" the file being currently edited is only a fragment being \input'ed into some
" master tex file. in this case, make a file called mainfile.latexmain in the
" directory containig the file. in other words, if the current file is
" ~/thesis/chapter.tex
" so that doing "latex chapter.tex" doesnt make sense, then make a file called 
" main.tex.latexmain 
" in the ~/thesis directory. this will then run "latex main.tex" when
" RunLaTeX() is called.
function! RunLaTeX()
	if &ft != 'tex'
		echo "calling RunLaTeX from a non-tex file"
		return
	end
	let dir = expand("%:p:h").'/'
	let curd = getcwd()
	exec 'cd '.expand("%:p:h")
	if glob(dir.'*.latexmain') != ''
		let lheadfile = glob(dir.'*.latexmain')
		let mainfname = fnamemodify(lheadfile, ":t:r")
		exec 'make '.mainfname
	else
		make % 
	endif
	cwindow
	exec 'cd '.curd
endfunction

if !hasmapto('RunLaTeX')
	if has("gui")
		nnoremap <buffer> <Leader>ll :silent! call RunLaTeX()<cr>
	else
		nnoremap <buffer> <Leader>ll :call RunLaTeX()<cr>
	end
end

" }}}
" set up the latex compiler {{{
if filereadable(expand('<sfile>:p:h:h').'/compiler/tex.vim')
	exe "source ".expand('<sfile>:p:h:h')."/compiler/tex.vim"
else
	runtime! compiler/tex.vim
end
" }}}

" -----------------------------------------------------------------------------
" Smart functions 
" -----------------------------------------------------------------------------

" TexQuotes: inserts `` or '' instead of " {{{
" the functions in this section taken from auctex.vim
" Smart quotes.  Thanks to Ron Aaron <ron@mossbayeng.com>.
" typing " after whitespace results in `` otherwise ''
function! s:TexQuotes()
	let s:insert = "''"
	let s:left = getline(line("."))[col(".")-2]
	if s:left == ' ' || s:left == '' || s:left == '	'   " Tab
		let s:insert = '``'
	elseif s:left == '\'
		let s:insert = '"'
	endif
	return s:insert
endfunction
" disabled: 
"imap <buffer> " <C-R>=<SID>TexQuotes()<CR>
" }}}
" SmartBS: smart backspacing {{{
let g:smartBS_tex = '\(' .
			\ "\\\\[\"^'=v]{\\S}"      . '\|' .
			\ "\\\\[\"^'=]\\S"         . '\|' .
			\ '\\v \S'                 . '\|' .
			\ "\\\\[\"^'=v]{\\\\[iI]}" . '\|' .
			\ '\\v \\[iI]'             . '\|' .
			\ '\\q \S'                 . '\|' .
			\ '\\-'                    .
			\ '\)' . "$"

" This function comes from Benji Fisher <benji AT e-mathDOTAMSDOTorg>
" http://vim.sourceforge.net/scripts/download.php?src_id=409
" (modified/patched by: Lubomir Host 'rajo' <host8 AT keplerDOTfmphDOTuniba.sk>
"                       Srinath Avadhanula  <srinath AT fastmailDOTfm> )
function! s:SmartBS()
	let init = strpart(getline("."), 0, col(".")-1)
	let matchtxt = matchstr(init, g:smartBS_tex)
	echo "SmartBS(" . matchtxt . ")"
	if matchtxt != ''
		let bstxt = substitute(matchtxt, '.', "\<bs>", 'g')
		return bstxt
	else
		return "\<bs>"
	endif
endfun
inoremap <buffer> <BS> <C-R>=<SID>SmartBS()<CR>
" }}} 

" MakeTexFolds: see ../plugin/syntaxFolds.vim for documentation {{{
function! MakeTexFolds(force)

	" the order in which these calls are made decides the nestedness. in
	" latex, a table environment will always be embedded in either an item or
	" a section etc. not the other way around. so we first fold up all the
	" tables. and then proceed with the other regions.
	let b:startPat_1 = '^\s*\\begin{table}'
	let b:endPat_1 = '^\s*\\end{table}'
	let b:startOff_1 = 0
	let b:endOff_1 = 0

	let b:startPat_2 = '^\s*\\begin{figure}'
	let b:endPat_2 = '^\s*\\end{figure}'
	let b:startOff_2 = 0
	let b:endOff_2 = 0

	let b:startPat_3 = '^\s*\\begin{eq'
	let b:endPat_3 = '^\s*\\end{eq'
	let b:startOff_3 = 0
	let b:endOff_3 = 0

	" both versions for taking care of nestedness of the itemize environments
	" work, but the lower one is more general and results in greater
	" recursion.
	let b:startPat_4 = '^\s*\\item'
	let b:endPat_4 = '^\s*\\item\|^\s*\\end{\(enumerate\|itemize\|description\)}'
	let b:startOff_4 = 0
	let b:endOff_4 = -1
	let b:skipStartPat_4 = '^\s*\\begin{\(enumerate\|itemize\)}'
	" let b:skipStartPat_4 = '^\s*\\begin'
	let b:skipEndPat_4 = '^\s*\\end'

	let b:startPat_5 = '^\s*\\subsubsection'
	let b:endPat_5 = '^\s*\\section\|^\s*\\subsection\|^\s*\\subsubsection'
	let b:startOff_5 = 0
	let b:endOff_5 = -1

	let b:startPat_6 = '^\s*\\subsection'
	let b:endPat_6 = '^\s*\\section\|^\s*\\subsection'
	let b:startOff_6 = 0
	let b:endOff_6 = -1

	let b:startPat_7 = '^\s*\\section'
	let b:endPat_7 = '^\s*\\section'
	let b:startOff_7 = 0
	let b:endOff_7 = -1

	let b:startPat_8 = '^\s*\\chapter'
	let b:endPat_8 = '^\s*\\section'
	let b:startOff_8 = 0
	let b:endOff_8 = -1

	call MakeSyntaxFolds(a:force)
endfunction
" }}}

" TexFoldTextFunction: see ../plugin/syntaxFolds.vim for documentation {{{
function! TexFoldTextFunction()
	if getline(v:foldstart) =~ '^\s*\\begin{'
		let header = matchstr(getline(v:foldstart), '^\s*\\begin{\zs[^}]*\ze}')

		let caption = ''
		let label = ''
		let i = v:foldstart
		while i <= v:foldend
			if getline(i) =~ '^\s*\\caption'
				let caption = matchstr(getline(i), '\\caption{\zs.*\ze}')
			elseif getline(i) =~ '\\label'
				let label = matchstr(getline(i), '\\label{\zs.*\ze}')
			end

			let i = i + 1
		endwhile

		let ftxto = foldtext()

		let retText = matchstr(ftxto, '^[^:]*').': '.header.' ('.label.') : '.caption
		return retText
	else
		return foldtext()
	end
endfunction
" }}}

" source other related files.
exe "so ".expand('<sfile>:p:h').'/miktexmenus.vim'

" TEX_ShowVariableValue: debugging help {{{
" provides a way to examine script local variables from outside the script.
" very handy for debugging.
function! TEX_ShowVariableValue(...)
	let i = 1
	while i <= a:0
		exe 'let arg = a:'.i
		if exists('s:'.arg) ||
		\  exists('*s:'.arg)
			exe 'let val = s:'.arg
			echomsg 's:'.arg.' = '.val
		end
		let i = i + 1
	endwhile
endfunction

" }}}

augroup TeXFolds
	au!
	au FileType tex :set foldtext=TexFoldTextFunction()
	au FileType tex :call MakeTexFolds(0)
    au FileType tex :if mapcheck('<F6>') == ""
				\ | exe ':nnoremap <buffer> <F6> :call MakeTexFolds(1)<cr>'
				\ | endif
	au FileType tex :nnoremap <buffer> <leader>rf :call MakeTexFolds(1)<cr>
augroup END

augroup VIMFolds
	au!
    au FileType vim :if mapcheck('<F6>') == ""
				\ | exe ':nnoremap <buffer> <F6> :call MakeVimFolds(1)<cr>'
				\ | endif
augroup END
 
" vim:set ts=4:
" vim600:fdm=marker fdl=0 fdc=3 nowrap:
