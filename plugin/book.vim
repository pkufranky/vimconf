
if exists('loaded_book')
  finish
endif
if v:version < 700 
  echomsg 'tagselect: You need Vim 7.0aa or higher'
  finish
endif
let loaded_book=1
let s:verbose_help = 0
let s:sep = '<=>'
let s:bookinfo = {}
let s:index_bookinfo = {}

" s:preview_mode = 0 no preview
" s:preview_mode = 1 preview basic infomation
" s:preview_mode = 2 preview file
" s:preview_mode = 3 preview index
" s:preview_mode = 4 preview mark
let s:preview_mode = 0
let s:initdir = 'd:/book'
let g:begin = ['' ,'第','(','（','[', '［', '【' ,'PART[.-]']
let g:middle = ['', '[一二三四五六七八九十零壹贰叁肆伍陆柒捌玖拾百千廿卅]\+', '[0-9]\+', '[a-zA-Z]\+']
let g:end = ['', '章', '节', '回', ')', '）', ']', '］', '】', '\.', '、', ',']
let s:sfile = expand('<sfile>:p')

let g:no_end = '“（' . '([{'
let g:no_beg = '。？！」”）、，' . '!,.?)]}-_~:;'
let s:lnum_cache = [1,1]
let g:list = ['楔子','序章', '前言', '引子', '简介']

function! <SID>AddSpace(s) " <<<
	let s=a:s
	let str = '\%('
	for item in s
		let tmp = '\%(' . item[0:1]
		let i=2
		while i<len(item)
			let tmp .= '[\t \ua1a1\ua140]*' . item[i : i+1]
			let i += 2
		endwhile
		let tmp .= '\)'
		let str .= tmp . '\|'
	endfor
	let str = str[0:-3] . '\)'
	return str
endfunction " >>>
let g:or = <SID>AddSpace(g:list)
let g:or = '\%(.*' . g:or . '.*\)'

let s:debug = 1
function! Debug(msg) " <<<
    if s:debug
        echom a:msg
    endif
endfunction " >>>


function! <SID>IsTaboo(ch, taboo_list) " <<<
    if a:ch =~ '^$'
        return 0
    endif
     return a:ch =~ '^[' . escape(a:taboo_list,'[]-') . ']$'
endfunction ">>>
function! <SID>GetCharUnderCursor() " <<<
    return matchstr(getline('.'), '.', col('.')-1)
endfunction ">>>
function! <SID>GetCharNextCursor() " <<<
    return matchstr(getline('.'), '.\zs.', col('.')-1)
endfunction ">>>


function! s:Layout(ctrl, wnr) " <<<
" s:Layout()    Control window layout and cursor position
" ctrl=1 bookcase_window | book_window or preview_window
" ctrl=2 bookcase_window | preview_window
" wnr=0     Don't move the cusor window
" wnr!=0    put the cursor in this window
" return    the origin window number if this number <=2
    let [ctrl, wnr] = [a:ctrl, a:wnr]
    if !bufexists(g:bookcase_window_title)
        echoe 'The bookcase has been closed'
		silent throw ''
        return
    endif
    " Make sure we have and only have2 windows
    if  2 < winnr('$')
        wincmd o
    endif
    if 1 == winnr('$')
        vert botright new
    endif

    " todo: assure the 2 windows are vertical
    
    " window 1 should be bookcase window
    if 1 != bufwinnr(g:bookcase_window_title)
        1wincmd w
        exe 'b '.bufnr(g:bookcase_window_title)
    endif

    "now window 2
    2wincmd w
    if 1==ctrl  " book window
        if !empty(s:bookinfo)
            exe 'edit ' . s:bookinfo.path
        endif
    else    " preview window
        exe 'enew'
        silent normal ggdG
        setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
        setlocal nowrap report=10000
        syntax clear
        mapclear <buffer>
        nnoremap <buffer> q :call <SID>JumpBacktoFile()<CR>
        nnoremap <buffer> ? :call <SID>DisplayHelp()<CR>
    endif
    
    " now resize the bookcase window
    " 1wincmd w
    " exe 'vert resize ' . s:bookcase_window_width

    " move to window wnr
    exe wnr . 'wincmd w'
endfunction " >>>

function! s:PreviewFile() " <<<
    if 0==s:preview_mode
        return
    endif
    let line = getline(line('.'))
    if 3!=<SID>BookLineType(line) 
        "echo 'Can''t preview directory'
        return
    endif
    let bookinfo = <SID>GetBookInfo(line)
    echo bookinfo.title . ' Author: ' . bookinfo.author
    if 1==s:preview_mode
        call <SID>Layout(2,2)
        exe 'file! ' . g:preview_window_title
        let text = line . "\n"
                    \ . "Title:          " . bookinfo.title . "\n"
                    \ . "Author:         " . bookinfo.author . "\n"
                    \ . "--------------------------------------------------\n"
                    \ . "Path:           " . bookinfo.path . "\n"
                    \ . "Size:           " . getfsize(bookinfo.path) . ' bytes' . "\n"
                    \ . "--------------------------------------------------\n"
                    \ . "Last page:      " .bookinfo.last . "\n"
                    \ . "Last access:    " . bookinfo.date . "\n"
        0put=text
        syntax clear
        syntax match Title /Title:/he=e-1
        syntax match Title /Author:/he=e-1
        syntax match Title /Path:/he=e-1
        syntax match Title /Size:/he=e-1
        syntax match Title /Last page:/he=e-1
        syntax match Title /Last access:/he=e-1
        1wincmd w
    elseif 2==s:preview_mode
        if filereadable(bookinfo.path)
            call <SID>Layout(2,2)
            exe 'file! ' . g:preview_window_title
            let text = join(readfile(bookinfo.path,"",g:preview_line_count),"\n")
            0put=text
            1wincmd w
            "exe 'match TreeCurSel ''^\%' . line('.') . 'l\s*\zs.\{-}\ze|'''
        else
            echo 'file does''t exist: '. bookinfo.path
        endif
    elseif 3==s:preview_mode
        call <SID>Layout(2,2)
        exe 'file! ' . g:index_window_title
        1wincmd w
        call <SID>DisplayIndex(1)
        1wincmd w
    elseif 4==s:preview_mode
        call <SID>Layout(2,2)
        exe 'file! ' . g:index_window_title
        1wincmd w
        call <SID>DisplayIndex(2)
        1wincmd w
    endif
endfunction ">>>
function! s:JumpToFile(bookinfo) " <<<
    let bookinfo = deepcopy(a:bookinfo)
    if empty(bookinfo) | return | endif
    if !filereadable(bookinfo.path)
        echo 'file does''nt exist: ' . bookinfo.path
        return
    endif
    call <SID>Layout(1,2)
    " in where it should be
    if !empty(s:bookinfo)
        if s:bookinfo.path==bookinfo.path
            exe 'edit ' . s:bookinfo.path
            let s:bookinfo.last = bookinfo.last
        else
        " replace former book with new one
            " the new book
            exe 'edit ' . bookinfo.path 
            " Wipe out former book
            exe 'silent! bwipe '. bufnr(s:bookinfo.path)    
            let s:bookinfo = bookinfo
        endif
    else
        exe 'edit ' . bookinfo.path 
        let s:bookinfo = bookinfo
    endif
    exe s:bookinfo.last

    let i=0
    syntax clear
    while i<len(s:bookinfo.index)
        exe 'syn match Comment /^\%' . s:bookinfo.index[i] . 'l.*/'
        let i+=2
    endwhile
    setlocal ro report=100000

    " format
    setlocal formatoptions+=mM tw=70 comments= wrap
"    setlocal lazyredraw
    "When leave the buffer, save the book infomation
    augroup BookAutoCmds
        au! * <buffer>
        autocmd BufLeave <buffer>  exe 'call <SID>SaveBookInfo(s:bookinfo)'  
    augroup END

    " color
   syn keyword   TxtKeyword      author Vim vim Emacs emacs Windows FROM smth org

   " syn match     TxtBrac        "[ {} () \[\] ]"
   " syn match     TxtSpecial     "[ ^ ~ ' \- \+ % * \/ ]"
   " "syn match     TxtChinese     "[ ，；。、？！（）《》￥※＊『』‘’“”]"
   	syn match     TxtChinese     '^[\t \ua1a1\ua140*￥~～□☆★※＝=—＊-]\+$'
	let s = ['作者', '原著', '原着', '扫描', '翻译', '校对', '扫校', '排版', '出版社', '发言人']
	let str = <SID>AddSpace(s)
   	exe 'syn match TxtAuthor /\(^\|[\t \ua1a1\ua140]\)\(' . str .'\|\cauthor\).*/'

	" Scan the last 10 lines, for the end keywords
	let s=['全书完','全文完','剧终','待续']
	let str = <SID>AddSpace(s)
    let lnum = line('$')-100>0 ? line('$')-100 : 1
    exe 'syn match TxtOther /^\%>' . lnum . 'l.*\(\([【（～「-].*[完终].*\([】）～」-]\|$\)\)\|' . str . '\).*$/'
	syn match TxtKeyword /《.\{-}》/

   	syn match     TxtNumber      "-\=\<\d*\.\=[0-9_]\>"
   " syn region    TxtString      start=+L\="+ skip=+\\\\\|\\"+ end=+"+

    syn match     TxtUrl         "http[s]\=://\S*"
    syn match     Txtmms         "mms\=://\S*"
    syn match     TxtFtp         "ftp\=://\S*"
    syn match     TxtFile        "file\=://\S*"
    syn match     TxtMail        "\S*@\S*"

   " syn match     TxtComment     "^#.*$" contains=TxtUrl,TxtMail,TxtFile,TxtFtp,Txtmms,TxtString
   " syn match     TxtVIPLine     "^__.*$" contains=TxtUrl,TxtMail,TxtFile,TxtFtp,Txtmms,TxtString
   " syn region    TxtVIPWord     start="\`"  end="\`"

    hi link       TxtKeyword     Special    "cyan
    hi link       TxtBrac        Identifier "palegreen
    hi link       TxtSpecial     Constant   "gold
    hi link       TxtChinese     Repeat     "
	hi link			TxtAuthor		Repeat	"
	hi link			TxtOther		Repeat	"

    hi link       TxtNumber      Constant   "gold
    hi link       TxtString      String     "lightred

    hi link       TxtUrl         Comment    "gold
    hi link       Txtmms         Comment    "gold
    hi link       TxtFtp         Type       "green
    hi link       TxtFile        Type       "green
    hi link       TxtMail        Special    "cyan

    hi link       TxtComment     Comment    "gold
    hi link       TxtVIPLine     cComment   "skyblue
    hi link       TxtVIPWord     cComment   "skyblue


    nnoremap <buffer> <C-I> :call <SID>DisplayIndex(1)<CR>
    nnoremap <buffer> <C-J> :call <SID>DisplayIndex(2)<CR>
    nnoremap <buffer> <C-K> :call <SID>ConstructIndex()<CR>
    nnoremap <buffer> <C-L> :call <SID>AddBookmark()<CR>
    nnoremap <buffer> <F6> :call <SID>Format()<CR>
    nnoremap <buffer> <PageDown> <C-F>
    nnoremap <buffer> <space> <C-F>
    nnoremap <buffer> <PageUp> <C-B>
    nnoremap <buffer> b <C-B>
    nnoremap <buffer> <C-S> :w!<CR>
    inoremap <buffer> <C-S> <ESC>:w!<CR>
    nnoremap <buffer> ? :call <SID>DisplayHelp()<CR>

    call <SID>HighlightBook(s:bookinfo)
endfunction ">>>
function! s:DisplayIndex(ctrl) " Display Index or mark <<<
" ctrl = 1 index
" ctrl = 2 mark
    let ctrl = a:ctrl
    if winnr()==bufwinnr(g:bookcase_window_title)
        let line=getline(line('.'))
        if 3==<SID>BookLineType(line)
            let s:index_bookinfo = <SID>GetBookInfo(line)
        else
            "echo 'No index for directory'
            return
        endif
    else
        let s:index_bookinfo = s:bookinfo
    endif
    if empty(s:index_bookinfo) | return | endif

    " index or mark
    let tag = ctrl==1 ? 'Index' : 'Bookmark'
    let index = ctrl==1 ? s:index_bookinfo.index : s:index_bookinfo.mark

    " Move to index window
    call <SID>Layout(2,2)
    exe 'file! ' . g:index_window_title
    syntax match IndexEntry /\S.*-\{3,}\s*\d\+\(\s*---[0-9: -]*\)\?$/ contains=ALL
    syntax match IndexTitle /^\s*\zsIndex\ze\s*$/
    syntax match IndexTitle /^\s*\zsBookmark\ze\s*$/
    syntax match Special /-\{3,}\s*\d\+\s*\zs---\s*[0-9: -]*$/ contained
    exe 'syntax match BookTitle /^\s*\zs' . s:index_bookinfo.title . '\ze\s*$/'
    nnoremap <buffer> <CR> :call <SID>JumpToFileByIndex(getline(line('.')))<CR>
    augroup BookAutoCmds
        au! * <buffer>
        autocmd CursorHold <buffer> exe 'match FocusedIndexEntry /\%' . line('.') .'l\S.*-\{3,}\s*\d\+\ze\($\|\s*---\)'
        exe 'autocmd BufWipeout <buffer> call <SID>UpdateIndex(' . ctrl . ')'
    augroup END

    call append(0,  repeat(' ', (70-strlen(s:index_bookinfo.title))/2) . s:index_bookinfo.title)
    call append('$',  repeat(' ', (70-strlen(tag))/2) . tag)
    call append(line('$'), '')
    let i = 0
    while i < len(index)
        let lnum = index[i]
        let text = index[i+1]
        let midlen = 70-strlen(text)-strlen(''.lnum)-10
        let midlen = midlen < 3 ? 3 : midlen
        let entry = '     ' . text . ' ' . repeat('-',midlen) . ' ' . lnum
        if ctrl==2
            let time = index[i+2]
            let i+=3
            let entry .= ' --- ' . time
        else
            let i+=2
        endif
        call append(line('$'), entry)
        "call append(line('$'), "")
    endwhile
    4
    call <SID>HighlightBook(s:index_bookinfo)
endfunction " >>>
function! <SID>ConstructIndex() " <<<
    if !has_key(s:bookinfo,'path')
        echoe 's:bookinfo emtpty'
        return
    endif
    call <SID>Layout(2,2)
    silent exe 'file ' . g:construct_index_window_title
    nnoremap <buffer> i :call <SID>DoConstructIndex()<CR>

    syntax clear
    syntax match Title /-\+\(begin\|middle\|end\|example\|help\)-\+/

    let save_r = @r
    let @r = ''
    let @r .= "-----------begin-----------\n"
    let i = 0
    for item in g:begin
        let @r .= i . ' ' . g:begin[i] . "\n"
        let i += 1  
    endfor

    let @r .= "-----------middle-----------\n"
    let i = 0
    for item in g:middle
        let @r .= i . ' ' . g:middle[i] . "\n"
        let i += 1  
    endfor

    let @r .= "-----------end-----------\n"
    let i = 0
    for item in g:end
        let @r .= i . ' ' . g:end[i] . "\n"
        let i += 1  
    endfor

    let @r .= "-----------example-----------\n"
    let @r .= '111 -- ' . g:begin[1] . g:middle[1] . g:end[1] . "\n"
    let @r .= '011 -- ' . g:begin[0] . g:middle[1] . g:end[1] . "\n"

    let @r .= "-----------help-----------\n"
    let @r .= "press i to input the format code\n"
    let @r .= "press q to quit\n"
    0put r
    let @r = save_r
endfunction " >>>
function! <SID>DisplayHelp() " <<<
    if winnr()==bufwinnr(g:bookcase_window_title)
        let str = 'bookcase window'
    elseif !empty(s:bookinfo) && winnr()==bufwinnr(s:bookinfo.path)
        let str = 'book window'
    elseif winnr()==bufwinnr(g:index_window_title)
        let str = 'index/bookmark window'
    elseif winnr()==bufwinnr(g:help_window_title)
        let str = 'help window'
    elseif winnr()==bufwinnr(g:preview_window_title)
        let str = 'preview window'
    else
        return
    endif
    let str = '/^\s*' . str . '\s*$'

    exe 'botright '.g:help_window_height .'new ' . g:help_window_title
    setlocal report=10000
    set buftype=nofile
    set bufhidden=wipe
    set nobuflisted
    put =s:helptxt
    exe str
    normal zt
    syn match Comment '^\s*\(bookcase window\|book window\|index/bookmark window\|help window\|preview window\)\s*$' 
    exe 'match Title ' . str
    nnoremap <buffer> q :bw!<CR>
    nnoremap <buffer> ? :call <SID>DisplayHelp()<CR>
endfunction " >>>

function! <SID>JumpBacktoFile() " <<<
    if(!empty(s:bookinfo))
        call <SID>JumpToFile(s:bookinfo)
    endif
endfunction " >>>
function! <SID>UpdateIndex(ctrl) " <<<
    " ctrl =1 index
    " ctrl=2 bookmark
    let ctrl=a:ctrl
    if winnr() != bufwinnr(g:index_window_title)
        echom "Must in index window"
        return
    endif
    let i=1
    if ctrl==1
        let s:index_bookinfo.index = []
    else
        let s:index_bookinfo.mark = []
    endif

    while i<=line('$')
        let line = getline(i)
        let i += 1
        if line =~ '.*[^-]-\+\s*\d\+\s*\(---\s*[0-9: -]*\)\?$'
           let page = matchstr(line, '---\s*\zs\d\+\ze\s*\($\|---\)')
           let text = matchstr(line, '^\s*\zs.\{-}\ze\s*---')
           if ctrl==1
               call add(s:index_bookinfo.index, page) 
               call add(s:index_bookinfo.index, text) 
           else
               let time = matchstr(line, '^\d\+\s*----*\s*\zs.*$')
               let time= time=='' ? strftime('%Y-%m-%d %X') : time
               call add(s:index_bookinfo.mark, page) 
               call add(s:index_bookinfo.mark, text) 
               call add(s:index_bookinfo.mark, time)
           endif
        endif
    endwhile
    if !empty(s:bookinfo) && s:index_bookinfo.path==s:bookinfo.path && s:index_bookinfo.title==s:bookinfo.title
        if ctrl==1
            let s:bookinfo.index = s:index_bookinfo.index
        else
            let s:bookinfo.mark = s:index_bookinfo.mark
        endif
    endif
    call <SID>SaveBookInfo(s:index_bookinfo)
endfunction " >>>

function! <SID>CommentLine(lnum) " <<<
    let line = getline(a:lnum)
    if len(line) < 40
        return 0
    endif
    let line = substitute(line, '[\t \ua1a1\ua140]\+', '', 'g')
    if line =~ '^$'
        return 0
    endif
    let i=0
    let words = {}
    while i<len(line)
        if len(words) > 4
            return 0
        endif
        let words[line[i]] = 1
        let i+=1
    endwhile
    return 1
endfunction " >>>
function! <SID>Format() " <<<
    call Debug(expand("<sfile>"))
    setlocal nowrap tw=70 
    setlocal formatoptions+=mM
    setlocal report=100000
    " linewidth[linewidth] denotes the count of lines with width linewidth
    let linewidth = {}
    " blank line count
    let blanknum = 0
    " the maximum line count we will deal with
    let lineup = line('$') < 1000 ? line('$') : 1000

    " count the blank line and linewidth
    let i = 0
    let line='xx'
    while i <= lineup
        let lastline = line
        let line = getline(i)
        let i += 1
        let lw = strlen(line)
        if line =~ '^$' && lastline !~ '^$'
            let blanknum += 1
        else
            if has_key(linewidth, lw)
                let linewidth[lw] += 1
            else
                let linewidth[lw] = 1
            endif   
        endif
    endwhile

    " normalwidth: the line width with maximum count
    let maxnum = max(values(linewidth))
    for width in keys(linewidth)
        if linewidth[width] == maxnum
            let normwidth = width
            break
        endif
    endfor

   " echo 'lineup ' . lineup
   " echo 'blanknum ' . blanknum
   " echo 'maxnum ' . maxnum
   " echo 'normwidth ' . normwidth

    " add blank line between paragraph <<<
    if blanknum > lineup / 12
        " partion paragrpha by  blank line, do nothing
        echom "partition passage by blank line"
        let i = 1
        let lines = []
        while i<= line('$')
            let line = getline(i)
            if line =~ '^$'
                if !empty(lines) && lines[-1] !~ '^$'
                    call add(lines, "")
                endif
            else
                call add(lines, line)
            endif
            let i += 1
        endwhile
       silent normal ggdG
       call append(0, lines)
    elseif maxnum > lineup / 5
        echom "partition paragraph by punctuation and linewidth"
        let lines = []
        let i = 1
        while i <= line('$')
            if <SID>CommentLine(i)
                while i<=line('$') && <SID>CommentLine(i)
                    call add(lines, line)
                    let i+=1
                endwhile
                if i>line('$')
                    break
                endif
                call add(lines, "")
            endif
            let line = getline(i)
            if line =~ '^$'
                if !empty(lines) && lines[-1] !~ '^$'
                    call add(lines, "")
                endif
                let i += 1
                continue
            endif

            call add(lines, line)
            let w = strlen(line)

            " && line =~ '[。？！……,!?“”]\s*$' 
            if w <= normwidth-2
                        \ && i<line('$') && getline(i+1) !~ '^$'
                call add(lines,"")  
            endif
            let i += 1  
        endwhile
        normal ggdG
        call append(0, lines)
    else
        echom "partition paragraph by <Return>"
        let lines = []
        let i = 1
        while i <= line('$')
            if <SID>CommentLine(i)
                while i<=line('$') && <SID>CommentLine(i)
                    call add(lines, line)
                    let i+=1
                endwhile
                if i>line('$')
                    break
                endif
                call add(lines, "")
            endif
            let line = getline(i)
            if line !~ '^$'
                call add(lines, line)
                call add(lines,"")  
            endif
            let i += 1
        endwhile
        silent normal ggdG
        call append(0, lines)
    endif " >>>

    " remove beginning blank line
    let lnum = nextnonblank(1)
    if lnum>1
        exe 'silent 1,' . (lnum-1) . 'd'
    endif
    " remove ending blank line
    let lnum = prevnonblank(line('$'))
    if lnum < line('$')
        exe 'silent  ' . (lnum+1) .',$d'
    endif

    let tw = &textwidth
    " format each paragraph line
    normal gg
    let begin_par = 1
    while 1 " <<<
        " skip blank line
        if getline('.') =~ '^$' || <SID>CommentLine(line('.'))
            if line('.') == line('$')
                break
            endif
            if len(getline('.')) > tw && <SID>CommentLine(line('.'))
                exe 'normal ' . (tw+1) . '|'
                silent normal D
            endif
            normal j
            let begin_par = 1
            continue
        endif

        let keeporigin = 0


        if begin_par
            " add 2 <space> in the first line of a paragraph
            let begin_par = 0
            if getline('.') !~ '^　　[^　]'
                silent! s/^[\t \ua1a1\ua140]*/　　/g
            endif
        else
            " remove other line's leading spaces
            silent! s/^[\t \ua1a1\ua140]\+//g
        endif

        " join lines when neccessary
        while 1
            if getline(line('.')+1) =~ '^$'
                break
            endif

            normal $
            let ch1 = <SID>GetCharUnderCursor()
            normal j0
            let ch2 = <SID>GetCharUnderCursor()
            normal k

            if len(getline('.')) < tw || <SID>IsTaboo(ch1, g:no_end) || <SID>IsTaboo(ch2, g:no_beg)
                silent! normal J
            else
                break
            endif
        endwhile

        if len(getline('.')) <= tw
            " finish formating this line
            if line('.') == line('$')
                break
            else
                normal j
                continue
            endif
        endif

        exe 'normal ' . tw . '|'

        " english word
        while <SID>GetCharUnderCursor() =~ '\w'
            normal l
        endwhile

        " taboo rules: no_end and no_beg char
        while <SID>IsTaboo(<SID>GetCharUnderCursor(), g:no_end)
            normal h
        endwhile
        while <SID>IsTaboo(<SID>GetCharNextCursor(), g:no_beg)
            normal l
        endwhile

        " remove trailing space
        while <SID>GetCharUnderCursor() =~ '\s'
            normal h
        endwhile
        if <SID>GetCharNextCursor() != ""
            exe "normal a\<CR>\<ESC>"
        elseif  line('.') == line('$')
            break
        else
            normal j
        endif
    endwhile " >>>

    " center the first line
    if len(getline(1)) < 30
        let w = (tw-len(getline(1)))/2
        let line = repeat(' ', w) . getline(1)
        call setline(1, line)
    endif 

    " replace all 全角空格with two spaces
    " %s/\%ua1a1\|\%ua140/  /g
    silent! write!
endfunction " >>>
function! <SID>AddBookmark() " <<<
    let text = input('The mark string: ', matchstr(getline(line('.')),'^[\t \ua1a1\ua140]*\zs.\{-}\ze[\t \ua1a1\ua140]*$'))
    if empty(text) | return | endif
    let i = 0
    while i<len(s:bookinfo.mark)
        if s:bookinfo.mark[i] == line('.')
            s:bookinfo.mark[i+1] = text
            break
        elseif s:bookinfo.mark[i] > line('.')
            call insert(s:bookinfo.mark, line('.'), i)
            call insert(s:bookinfo.mark, text, i+1)
            call insert(s:bookinfo.mark, strftime('%Y-%m-%d %X'), i+2)
            break
        endif
        let i += 3
    endwhile
    if i >= len(s:bookinfo.mark)
        call add(s:bookinfo.mark, line('.'))
        call add(s:bookinfo.mark, text)
        call add(s:bookinfo.mark, strftime('%Y-%m-%d %X'))
    endif
    call <SID>SaveBookInfo(s:bookinfo)
    echo 'bookmark added'
endfunction " >>>
function! <SID>PreviewMode(mode) " <<<
    let s:preview_mode = a:mode
" set bookcase window statusline
    if 0==s:preview_mode
        let modestr = "no\ preview"
    elseif 1==s:preview_mode
        let modestr = 'preview\ info'
    elseif 2==s:preview_mode
        let modestr = 'preview\ file'
    elseif 3==s:preview_mode
        let modestr = 'preview\ index'
    elseif 4==s:preview_mode
        let modestr = 'preview\ mark'
    endif
    let statusline = '[' . g:bookcase_window_title .  '][' . modestr .']'
    silent! exec 'setlocal statusline=' . statusline 

    call <SID>PreviewFile()
endfunction ">>>

function! <SID>DoConstructIndex() " <<<
    if !has_key(s:bookinfo,'path')
        echoe 's:bookinfo emtpty'
        return
    endif
    let option = 'xxx'
    let [a, b, c] = [100, 100, 100]
    while option !~ '^\d\d\d\{1,2}$'
                \ || a>=len(g:begin) || b>=len(g:middle) || c>=len(g:end)
        if empty(option)
            return
        endif
        let option = input("Please enter the format code such as 111 or 123:")
        let a = option[0] + 0
        let b = option[1] + 0
        let c = option[2:] + 0
    endwhile

	let part = '\%(.*' . g:begin[a] . '\%([\t \ua1a1\ua140]\)*' . g:middle[b] .'\%([\t \ua1a1\ua140]\)*' . g:end[c] . '\)'
    let index_regex = '^\%([\t \ua1a1\ua140]\)*\zs\c\(' . g:or .'\|' . part .'\).\{-}\ze\%([\t \ua1a1\ua140]\)*$'
    "Now we have the right input a, b and c
    " Go to the book window
    exe 'b ' . bufnr(s:bookinfo.path)

    " Construct the index
    let s:bookinfo.index = []
	call cursor(1,1)
    while search(index_regex, 'W') > 0  
        call add(s:bookinfo.index, line('.'))
        call add(s:bookinfo.index, matchstr(getline(line('.')), index_regex))
    endwhile
    call <SID>SaveBookInfo(s:bookinfo)
    call <SID>DisplayIndex(1)
endfunction " >>>
function! <SID>InsertBook() " Insert a book in the current dir of the bookcase <<<
    if winnr()!=bufwinnr(g:bookcase_window_title)
        return
    endif
    let path = browse(0,"Please select the book",s:initdir,'')
    if empty(path) | return | endif
    let book_line = fnamemodify(path, ":p:t:r")
                \ . '|path=' . fnamemodify(path, ":p") 
                \ . '|author=|last=1|date=|index=|mark=|'
    
    " we are in bookcase window now and on the operation line
    "comment line
    if 1==<SID>BookLineType(getline(line('.')))
        return
    endif
    " Insert below the book
    let save_lnum = line('.')
    if 2==<SID>BookLineType(getline(line('.')))
        normal f{%k
    else
    endif
    let indent = foldlevel(line('.'))
    let book_line = repeat(' ', indent) . book_line
    call append(line('.'), book_line)       
    exe 'silent! write! ' . g:bookcase_path
endfunction " >>>
function! <SID>DoInsertBookDir(dir,indent) " <<<
    let [dir, indent] = [a:dir, a:indent]
    " echo 'dir '.dir .' indent '.indent
    let pathstr = globpath(dir,'*')
    let pathlist = split(pathstr,"\n")
    let dirlist = []
    let filelist = []
    for item in pathlist
        if isdirectory(item)
            call add(dirlist,item)
        else
            call add(filelist,item)
        endif
    endfor  
    
    let prespace = repeat(' ', indent)
    " firstly the dir name
    call append(line('.'), prespace . fnamemodify(dir, ":p:h:t") . '{')
    normal j

    " then the dir list
    for item in dirlist
        call <SID>DoInsertBookDir(item, indent+1)
    endfor

    " then the file list
    for path in filelist
    let book_line = prespace . ' '
                \ . fnamemodify(path, ":p:t:r")
                \ . '|path=' . fnamemodify(path, ":p") 
                \ . '|author=|last=1|date=|index=|mark=|'
    call append(line('.'), book_line)
    normal j
    endfor
    
    " finally the tail '}'
    call append(line('.'), prespace . fnamemodify(dir, ":p:t") . '}')
    normal j
endfunction ">>>
function! <SID>InsertBookDir() " <<<
    " Must be in bookcase window
    if winnr()!=bufwinnr(g:bookcase_window_title)
        return
    endif
    let path = browsedir("Please select the book",s:initdir)
    if empty(path) | return | endif
    let save_lnum = line('.')
    
    " we are in bookcase window now and on the operation line
    "comment line
    if 1==<SID>BookLineType(getline(line('.')))
        return
    endif
    " Insert below the book
    let indent = foldlevel(line('.'))
    if 2==<SID>BookLineType(getline(line('.')))
    else
        while 3==<SID>BookLineType(getline(line('.')))
            normal k
        endwhile
    endif

    "Now at the right line, all line will be inserted below
    call <SID>DoInsertBookDir(fnamemodify(path,":p"), indent)
    exe save_lnum
endfunction " >>>

function! s:JumpToFileByIndex(index_line) " <<<
    let s:index_bookinfo.last = 0 + matchstr(a:index_line, '---\s*\zs\d\+\ze\s*\($\|--\)')
    if s:index_bookinfo.last == 0 | return | endif
    call <SID>JumpToFile(s:index_bookinfo)
endfunction " >>>
function! s:JumpToFile_OpenDir() " <<<
    let line = getline(line('.'))
    if 3!=<SID>BookLineType(line)
        silent normal zo
    else
        call add(s:lnum_cache, line('.'))
        call remove(s:lnum_cache, 0)
        let bookinfo = <SID>GetBookInfo(line)
        call <SID>JumpToFile(bookinfo)
    if empty(s:bookinfo)
        echoe 's:bookinfo emtpty'
        return
    endif
    endif
endfunction " >>>
function! s:ZoomBookcaseWindow() " <<<
    let s:bookcase_window_width = s:bookcase_window_width==g:bookcase_window_width_min ? g:bookcase_window_width_max : g:bookcase_window_width_min
    exe 'vertical resize ' . s:bookcase_window_width    
endfunction " >>>

function! s:HighlightBook(bookinfo) " <<<
    let sv_lazyredraw= &lazyredraw
    set lazyredraw
    let lnum = <SID>LocateMatchBook(a:bookinfo)
    if lnum==0 | echom 'no match book ' .string(a:bookinfo) | let &lazyredraw = sv_lazyredraw | return | endif
    let save_wnr = <SID>JumpBookcase()
    if save_wnr == 0 | let &lazyredraw = sv_lazyredraw | return | endif
    exe 'match TreeCurSel /^\%' .lnum . 'l\s*\zs.\{-}\ze|/' | normal zv
    "echom 'match TreeCurSel ''^\%' .lnum . 'l\s*\zs.\{-}\ze|'''
    exe save_wnr . 'wincmd w'
    let &lazyredraw = sv_lazyredraw
endfunction " >>>

function! s:JumpBookcase() " <<<
    if bufwinnr(g:bookcase_window_title) != 1
        echoe "Window 1 should be  bookcase window!"
		throw ''
        return 0
    endif
    let save_wnr = winnr()
    1wincmd w
    return save_wnr
endfunction " >>>
function! s:LocateMatchBook(bookinfo) " <<<
    if empty(a:bookinfo) | echom 'empty bookinfo' | return 0 | endif
    let save_wnr = <SID>JumpBookcase()
    if save_wnr == 0 | echom 'no bookcase window' | return 0 | endif

    " first look up the cache
    for lnum in s:lnum_cache
        let line = getline(lnum)
        if 3==<SID>BookLineType(line)
            let bookinfo = <SID>GetBookInfo(line)
            if a:bookinfo.path == bookinfo.path && a:bookinfo.title == bookinfo.title
                exe lnum
                exe save_wnr . 'wincmd w'
                " echom 'find in cache'
                return lnum
            endif
        endif
    endfor

    let lnum = 1
    while lnum<=line('$')
        let line = getline(lnum)
        if 3==<SID>BookLineType(line)
            let bookinfo = <SID>GetBookInfo(line)
            if a:bookinfo.path == bookinfo.path && a:bookinfo.title == bookinfo.title
                exe lnum
                break
            endif
        endif
        let lnum = lnum + 1
    endwhile
    
    let lnum = lnum>line('$') ? 0 : lnum
    exe save_wnr . 'wincmd w'
    return lnum
endfunction " >>>
function! s:LocateLatestBook() " <<<
    let save_wnr = <SID>JumpBookcase()
    if save_wnr == 0 | return | endif
    let latest_lnum = 0
    let latest_bookinfo = {}
    let lnum = 1
    while lnum<=line('$')
        let line = getline(lnum)
        if 3==<SID>BookLineType(line)
            let bookinfo = <SID>GetBookInfo(line)
            if(empty(latest_bookinfo))
                let latest_bookinfo = bookinfo
                let latest_lnum = lnum
            endif
            if bookinfo.date > latest_bookinfo.date
                let latest_bookinfo = bookinfo
                let latest_lnum = lnum
            endif
        endif
        let lnum = lnum+1
    endwhile
    exe latest_lnum
    return latest_lnum
    exe save_wnr . 'wincmd w'
endfunction " >>>
function! s:SaveBookInfo(bookinfo) " <<<
    let bookinfo = a:bookinfo
    " echom 'save book: ' . bookinfo.path
    if -1 != bufnr(bookinfo.path)
        let save_bnr = bufnr('%')
        exe 'b ' . bufnr(bookinfo.path)
        "which line we are at and the date
        let bookinfo.last = line('.') 
        let bookinfo.date = strftime('%Y-%m-%d %X')
        silent! exe 'b ' .save_bnr
    endif

    "To the bookcase window
    let save_wnr = <SID>JumpBookcase()
    if save_wnr == 0 | return | endif
    let lnum = <SID>LocateMatchBook(bookinfo)
    let book_line = repeat(' ', foldlevel(lnum))
                \ . bookinfo.title
                \ . '|path=' . bookinfo.path
                \ . '|author=' . bookinfo.author
                \ . '|last=' . bookinfo.last
                \ . '|date=' . bookinfo.date
                \ . '|index=' . join(bookinfo.index,s:sep)
                \ . '|mark=' . join(bookinfo.mark,s:sep)
                \ . '|'
    
    " Write bookcase information
    "echom 'new book line: ' . book_line
    "echom 'save book'
    call setline(lnum, book_line)
    silent! exe 'write! ' . g:bookcase_path

    "Come back
    exe save_wnr . 'wincmd w'
endfunction " >>>
function! s:GetBookInfo(bookinfoline) " <<<
    let bookinfoline = a:bookinfoline
    let bookinfo = {}
    let bookinfo.title = substitute(bookinfoline,'\s*\(.\{-}\)\s*|.*$','\1','')
    let bookinfo.path = substitute(bookinfoline,'^.*|path=\(.\{-}\)\s*|.*$','\1','')
    let bookinfo.author = substitute(bookinfoline,'^.*|author=\(.\{-}\)\s*|.*$','\1','')
    let bookinfo.last = substitute(bookinfoline,'^.*|last=\(.\{-}\)\s*|.*$','\1','')
    let bookinfo.date = substitute(bookinfoline,'^.*|date=\(.\{-}\)\s*|.*$','\1','')
    let l:index_str = substitute(bookinfoline,'^.*index=\(.\{-}\)\s*|.*$','\1','')
    let l:mark_str = substitute(bookinfoline,'^.*|mark=\(.\{-}\)\s*|.*$','\1','')
    let bookinfo.index = split(l:index_str,s:sep) 
    let bookinfo.mark = split(l:mark_str,s:sep) 
    return bookinfo
endfunction " >>>
" function! s:BookLineType(line) " <<<
" return 1 comment
" return 2 directory
" return 3 book
function! s:BookLineType(line) 
    if a:line =~ '^\s*"' || a:line =~ '^\s*$'
        return 1
    elseif a:line =~ '{$' || a:line =~ '^\s*}$' 
        return 2
    elseif a:line =~ '.*|.*|.*|.*|'
        return 3
    else
        return 1
endfunction " >>>

function! s:Book(filename) " <<<
    enew
    setlocal report=10000
    silent exe 'read ' . s:sfile
    1,/=\{3,}\s*START_DOC/ d
    /=\{3,}\s*END_DOC/,$d
    let i = 1
    let s:helptxt = ''
    while i<=line('$')
        let s:helptxt .= getline(i) . "\n"
        let i += 1
    endwhile
    silent bw!

    if(has("gui_win32"))
        set guifont=NSimSun:h22:cGB2312
    endif

    let g:bookcase_window_width_min = exists("g:bookcase_window_width_min") ? g:bookcase_window_width_min : 30
    let g:bookcase_window_width_max = exists("g:bookcase_window_width_max") ? g:bookcase_window_width_max : 100
    let g:bookcase_window_title = exists("g:bookcase_window_title") ? g:bookcase_window_title : '__Bookcase__'
    let g:preview_window_title = exists("g:preview_window_title") ? g:preview_window_title : '__Preview__'
    let g:index_window_title = exists("g:index_window_title") ? g:index_window_title : '__Index__'
    let g:bookmark_window_title = exists("g:bookmark_window_title") ? g:bookmark_window_title : '__Bookmark__'
    let g:construct_index_window_title = exists("g:construct_index_window_title") ? g:construct_index_window_title : '__Construct index__'
    let g:help_window_title = exists("g:help_window_title") ? g:help_window_title : '__Help__'
    let g:help_window_height = exists("g:help_window_height") ? g:help_window_height : 20
    let g:bookcase_path = exists("g:bookcase_path") ? g:bookcase_path : '~/.bookcase'
    let g:preview_line_count = exists("g:preview_line_count") ? g:preview_line_count : 50
    let s:bookcase_window_width = g:bookcase_window_width_min

    " Define the highlighting only if colors are supported
    hi link TreeFold Ignore
    hi link TreeInfo Ignore
    hi link TreeFile Normal
    hi link TreeDir Directory
    hi link TreeCurSel Search
    hi link IndexEntry Identifier
    hi link FocusedIndexEntry Underlined
    hi link IndexTitle Title
    hi link BookTitle Title
    
    if !bufexists(g:bookcase_window_title)
        let g:bookcase_path = strlen(a:filename) ? a:filename : g:bookcase_path
        exe 'vertical topleft new ' . g:bookcase_window_title 
        exe '0read ' . g:bookcase_path
        1
    endif
    call <SID>Layout(1,1)   

    " Init bookcase buffer
    mapclear <buffer>
    syntax clear
    "syntax match TreeFold "{.*$"
    syntax match TreeDir "}.*$"
    syntax match TreeDir #^\s*\zs.\{-}{#
    syntax match TreeFile #^\s*\zs.\{-}\ze|#
    syntax match TreeInfo #|.*$#
    syntax match Comment #\s*\zs".*\ze\s*$#
    
    " Folding related settings
    setlocal foldenable foldmethod=marker foldmarker={,} commentstring=%s foldcolumn=0 nonumber  shiftwidth=1
    setlocal nowrap
    setlocal foldtext=substitute(getline(v:foldstart),'{','','')

    "scract buffer
    setlocal buftype=nofile bufhidden=hide nobuflisted noswapfile

    " for preview
    setlocal updatetime=10

    " Create buffer local mappings
    nnoremap <buffer> ? :call <SID>DisplayHelp()<CR>
    nnoremap <buffer> <silent> <CR> :call <SID>JumpToFile_OpenDir()<CR>
    nnoremap <buffer> <silent> x :call <SID>ZoomBookcaseWindow()<CR>
    nnoremap <buffer> <silent> q :bw<CR>
    let k=0
    while k<=4
        exe 'nnoremap <buffer> ' . k . ' :call <SID>PreviewMode(' . k . ')<CR>'
        let k += 1
    endwhile
    nnoremap <buffer> <F2>   :call <SID>InsertBook()<CR> 
    nnoremap <buffer> <F3>   :call <SID>InsertBookDir()<CR> 
	nnoremap <buffer> [[ m':call searchpair('{','','}', 'bW')<CR> | normal ^
	nnoremap <buffer> ]] m':call searchpair('{','','}', 'W')<CR> | normal ^

    " Define the book autocommands
    augroup BookAutoCmds
        au! * <buffer>
        autocmd CursorHold <buffer> call <SID>PreviewFile()
        autocmd WinLeave <buffer> let s:bookcase_window_width = g:bookcase_window_width_min | vert resize 0
        autocmd WinEnter <buffer> call <SID>PreviewMode(0) | let s:bookcase_window_width = g:bookcase_window_width_min | exe 'vert resize ' . s:bookcase_window_width | normal ^
    augroup END

    call <SID>LocateLatestBook()
    call <SID>JumpToFile_OpenDir()
endfunction " >>>

if !exists(":Book")
    command -nargs=? -complete=file Book call <SID>Book('<args>')
endif

finish

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Section: Documentation Contents <<<
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
=== START_DOC
            bookcase window
    - x             = Zoom bookcase window
    - q             = Quit bookcase window
    - 0             = No preview mode
    - 1             = Preview information mode
    - 2             = Preview file mode
    - 3             = Preview index mode
    - 4             = Preview mark mode
    - <F2>          = Insert a book
    - <F3>          = Insert a directory
    - <CR>          = Open the book
	- [[			= Move to begin of up-level dir
	- ]]			= Move to end of up-level dir
    - ?             = Show help
    - 
            book window
    - <C-I>         = Show the index
    - <C-J>         = Show the bookmark
    - <C-K>         = Construct the index
    - <C-L>         = Insert a bookmark
    - <F6>          = Format the book
    - <PageDown>    = Page down
    - <space>       = Page down
    - <PageUp>      = Page up
    - b             = Page up
    - <C-S>         = Save the book
    - ?             = Show help

            index/bookmark window
    - q             = Quit index/bookmark window
    - ?             = Show help
    - Note
            You can edit this window directly, and the change will be saved automatically.
            If you don't want to the changes you have made, make sure to undo all the changes.

            preview window
    - q             = Quit preview window
    - ?             = Show help

            build index window
    - i             = Enter the format code
    - q             = Quit build index window
    - ?             = Show help
=== END_DOC
" >>>

" vim600: set foldmethod=marker foldmarker=<<<,>>> foldlevel=1:

