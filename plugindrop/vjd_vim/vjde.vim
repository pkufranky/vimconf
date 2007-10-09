if exists('g:vjde_loaded') || &cp 
    finish
endif

if !has('ruby')
    echo 'VJDE need +ruby future is enabled!'
    finish
endif
let g:vjde_loaded = 1

if !exists('g:vjde_show_paras') 
    let g:vjde_show_paras = 0
endif

if !exists('g:vjde_lib_path') 
    let g:vjde_lib_path = ""
endif

if !exists('g:vjde_out_path')
    let g:vjde_out_path = ""
endif

if !exists('g:vjde_src_path')
    let g:vjde_src_path=""
endif
if !exists('g:vjde_test_path')
    let g:vjde_test_path=""
endif
if !exists('g:vjde_web_app')
    let g:vjde_web_app=""
endif
if !exists('g:vjde_cfu_downcase')
    let g:vjde_cfu_downcase="0"
endif
if !exists('g:vjde_autoload_stl')
    let g:vjde_autoload_stl=1
endif
if !exists('g:vjde_auto_mark')
    let g:vjde_auto_mark=1
endif
if !exists('g:vjde_xml_advance')
    let g:vjde_xml_advance=1
endif
if !exists('g:vjde_show_preview')
    let g:vjde_show_preview=1
endif
if !exists('g:vjde_cfu_java_dot')
	let g:vjde_cfu_java_dot = 1
endif
if !exists('g:vjde_cfu_java_para')
	let g:vjde_cfu_java_para = 0
endif
if !exists('g:vjde_javadoc_path')
	let g:vjde_javadoc_path ='.'
endif

let g:vjde_install_path=expand('<sfile>:p:h')

exec 'rubyf '.g:vjde_install_path.'/vjde/vjde_completion.rb'
exec 'rubyf '.g:vjde_install_path.'/vjde/vjde_taglib_cfu.rb'
exec 'rubyf '.g:vjde_install_path.'/vjde/vjde_html_cfu.rb'
exec 'rubyf '.g:vjde_install_path.'/vjde/vjde_xml_cfu.rb'
exec 'rubyf '.g:vjde_install_path.'/vjde/vjde_javadoc.rb'
"rubyf $VIM/vimfiles/plugin/vjde/vjde_html_cfu.rb
"rubyf $VIM/vimfiles/plugin/vjde/vjde_xml_cfu.rb
"rubyf $VIM/vimfiles/plugin/vjde/vjde_javadoc.rb

runtime plugin/vjde/vjde_java_utils.vim
runtime plugin/vjde/vjde_completion.vim
runtime plugin/vjde/vjde_menu_def.vim
runtime plugin/vjde/vjde_template.vim

if g:vjde_autoload_stl
    ruby Vjde::init_jstl(VIM::evaluate("g:vjde_install_path")+"/vjde/tlds/")
endif
if has('win32')
    call VjdeSetJava('javaw')
endif
command! -nargs=0 VjdeJstl ruby Vjde::init_jstl(VIM::evaluate('g:vjde_install_path')+"/vjde/tlds/")
"ruby $vjde_html_loader=parse(File.new(VIM::evaluate("$VIM")+"/vimfiles/plugin/vjde/tlds/html.def"))
"ruby $vjde_xsl_loader.parse(File.new(VIM::evaluate("$VIM")+"/vimfiles/plugin/vjde/tlds/xsl.def"))
"ruby Vjde::VjdeDefLoader.new("xsd",VIM::evaluate("$VIM")+"/vimfiles/plugin/vjde/tlds/xsd.def")
if v:version>=700
    au BufNewFile,BufRead,BufEnter *.html set cfu=VjdeHTMLFun | ruby $vjde_def_loader=Vjde::VjdeDefLoader.[]("html",VIM::evaluate("g:vjde_install_path")+"/vjde/tlds/html.def")
    au BufNewFile,BufRead,BufEnter *.htm set cfu=VjdeHTMLFun | ruby $vjde_def_loader=Vjde::VjdeDefLoader.[]("html",VIM::evaluate("g:vjde_install_path")+"/vjde/tlds/html.def")
    au BufNewFile,BufRead,BufEnter *.xsl set cfu=VjdeHTMLFun | ruby $vjde_def_loader=Vjde::VjdeDefLoader.[]("xsl",VIM::evaluate("g:vjde_install_path")+"/vjde/tlds/xsl.def")
    au BufNewFile,BufRead,BufEnter *.xsd set cfu=VjdeHTMLFun | ruby $vjde_def_loader=Vjde::VjdeDefLoader.[]("xsd",VIM::evaluate("g:vjde_install_path")+"/vjde/tlds/xsd.def")
    au BufNewFile,BufRead,BufEnter *.java set cfu=VjdeCompletionFun | ruby $vjde_def_loader=Vjde::VjdeDefLoader.[]("html",VIM::evaluate("g:vjde_install_path")+"/vjde/tlds/html.def")
    au BufNewFile,BufRead,BufEnter *.jsp set cfu=VjdeCompletionFun | ruby $vjde_def_loader=Vjde::VjdeDefLoader.[]("html",VIM::evaluate("g:vjde_install_path")+"/vjde/tlds/html.def")

    au BufNewFile,BufRead,BufEnter *.xml set cfu=VjdeXMLFun 
    au BufNewFile,BufRead,BufEnter *.java runtime plugin/vjde/vjde_java_iab.vim
    "au BufNewFile,BufRead,BufEnter *.java source $VIM/vimfiles/plugin/vjde/vjde_menu_def.vim
    "au! CursorHold *.java nested call VjdeJavaPreview()
endif
    if g:vjde_cfu_java_dot
        au BufNewFile,BufRead,BufEnter *.java nested inoremap <buffer> . .<Esc>:call VjdeJavaPreview('.')<CR>a
        au BufNewFile,BufRead,BufEnter *.java nested inoremap <buffer> @ @<Esc>:call VjdeJavaPreview('@')<CR>a
        au BufNewFile,BufRead,BufEnter *.java imap <buffer> <C-space> <Esc>:call VjdeJavaPreview('<C-space>')<CR>a

        au BufNewFile,BufRead,BufEnter *.jsp nested inoremap <buffer> < <<Esc>:call VjdeJavaPreview('<')<CR>a
        au BufNewFile,BufRead,BufEnter *.jsp nested inoremap <buffer> : :<Esc>:call VjdeJavaPreview(':')<CR>a
        au BufNewFile,BufRead,BufEnter *.jsp imap <buffer> <C-space> <Esc>:call VjdeJavaPreview('<C-space>')<CR>a
        "au BufNewFile,BufRead,BufEnter *.jsp nested inoremap <buffer> <space> <space><Esc>:call VjdeJavaPreview(' ')<CR>a

        au BufNewFile,BufRead,BufEnter *.html nested inoremap <buffer> < <<Esc>:call VjdeJavaPreview('<')<CR>a
        au BufNewFile,BufRead,BufEnter *.html imap <buffer> <C-space> <Esc>:call VjdeJavaPreview('<C-space>')<CR>a
        "au BufNewFile,BufRead,BufEnter *.html nested inoremap <buffer> <space> <space><Esc>:call VjdeJavaPreview(' ')<CR>a
        au BufNewFile,BufRead,BufEnter *.htm nested inoremap <buffer> < <<Esc>:call VjdeJavaPreview('<')<CR>a
        au BufNewFile,BufRead,BufEnter *.htm imap <buffer> <C-space> <Esc>:call VjdeJavaPreview('<C-space>')<CR>a
        "au BufNewFile,BufRead,BufEnter *.htm nested inoremap <buffer> <space> <space><Esc>:call VjdeJavaPreview(' ')<CR>a

        au BufNewFile,BufRead,BufEnter *.xml nested inoremap <buffer> < <<Esc>:call VjdeJavaPreview('<')<CR>a
        "au BufNewFile,BufRead,BufEnter *.xml nested inoremap <buffer> <space> <space><Esc>:call VjdeJavaPreview(' ')<CR>a
        au BufNewFile,BufRead,BufEnter *.xml imap <buffer> <C-space> <Esc>:call VjdeJavaPreview('<C-space>')<CR>a

    endif
    if g:vjde_cfu_java_para
	    au BufNewFile,BufRead,BufEnter *.java nested inoremap <buffer> ( <Esc>:call VjdeJavaParameterPreview()<CR>a(
    endif

autocmd BufReadPost,FileReadPost	*.vjde  exec 'Vjdeload '.expand('<afile>')
"au BufNewFile,BufRead *.xsl set cfu=VjdeXslCompletionFun

"------------------------------------------------------
"vim:fdm=marker:
