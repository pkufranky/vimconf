
let g:no_end = '¡°£¨' . '([{'
let g:no_beg = '¡££¿£¡¡¹¡±£©¡¢£¬' . '!,.?)]}-_~:;'


function! <SID>IsTaboo(ch, taboo_list) " <<<
    if a:ch =~ '^$'
        return 0
    endif
    let r =  a:ch =~ '^[' . escape(a:taboo_list,'[]-') . ']$'
    echom a:taboo_list
    echom 'ch: ' . a:ch
    echom 'res: ' . r
    return r
endfunction ">>>
function! <SID>GetCharUnderCursor() " <<<
    return matchstr(getline('.'), '.', col('.')-1)
endfunction ">>>
function! <SID>GetCharNextCursor() " <<<
    return matchstr(getline('.'), '.\zs.', col('.')-1)
endfunction ">>>

function! <SID>Format() " <<<

    setlocal nowrap tw=70 
    setlocal formatoptions+=mM
    " linewidth[linewidth] denotes the count of lines with width linewidth
    let linewidth = {}
    " blank line count
    let blanknum = 0
    " the maximum line count we will deal with
    let lineup = line('$') < 1000 ? line('$') : 1000

    " count the blank line and linewidth
    let i = 0
    while i <= lineup
        let line = getline(i)
        let i += 1
        let lw = strlen(line)
        if line =~ '^$' 
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

    setlocal modifiable
    " add blank line between paragraph
    if blanknum > lineup / 20
        " partion paragrpha by  blank line, do nothing
    elseif maxnum > lineup / 5
        " partition paragraph by punctuation
        let lines = []
        let i = 1
        while i <= line('$')
            let line = getline(i)
            call add(lines, line)
            let w = strlen(line)

            " && line =~ '[¡££¿£¡¡­¡­,!?¡°¡±]\s*$' 
            if w <= normwidth-2
                        \ && i<line('$') && getline(i+1) !~ '^$'
                call add(lines,"")  
            endif
            let i += 1  
        endwhile
        normal ggdG
        call append(0, lines)
    else
        " partition paragraph by <Return>
        let lines = []
        let i = 1
        while i <= line('$')
            let line = getline(i)
            call add(lines, line)
            if line =~ '^$'
                let i += 1
                continue
            endif
            let w = strlen(line)
            if i<line('$') && getline(i+1) !~ '^$'
                call add(lines,"")  
            endif   
            let i += 1
        endwhile
        normal ggdG
        call append(0, lines)
    endif

    " remove beginning blank line
    let lnum = nextnonblank(1)
    if lnum>1
        exe 'silent normal 1,' . lnum-1 . 'd'
    endif

    " one line for each paragraph
    let blnum = 1
    normal gg
    while line('.') != line('$')
        if getline('.') =~ '^$'
            let elnum = line('.')
            let cnt = elnum-blnum
            if(cnt>=2)
                exe 'normal ' . cnt . 'k'
                exe 'normal ' . cnt . 'J'
                " replace <tab> with four <space>
"                silent! s/\t/    /g
                normal j
            endif
            normal j
            let blnum = line('.')
        else
            normal j
        endif
    endwhile


    let tw = &textwidth
    " format each paragraph line
    normal gg
    let finish_par = 0
    while !( line('.') == line('$') && finish_par )
        " skip blank line
        if getline('.') =~ '^$'
            normal j
            let finish_par = 1
            continue
        endif


        " remove leading space
        normal 0
        while <SID>GetCharUnderCursor() =~ '\s'
            normal x
        endwhile

        if len(getline('.')) <= tw
            " finish format
            normal j
            continue
        endif

        exe 'normal ' . tw . '|'

        " english word
        while <SID>GetCharUnderCursor() =~ '\w\|-'
            normal l
        endwhile

        " no_end and n_beg char
        echom <SID>GetCharUnderCursor()
        while <SID>IsTaboo(<SID>GetCharUnderCursor(), g:no_end)
            normal h
        endwhile
            echom 'next ' . <SID>GetCharNextCursor()
        while <SID>IsTaboo(<SID>GetCharNextCursor(), g:no_beg)
            echom 'next ' . <SID>GetCharNextCursor()
            normal l
        endwhile

        " remove trailing space
        while <SID>GetCharUnderCursor() =~ '\s'
            normal h
        endwhile
        if <SID>GetCharNextCursor() != ""
            exe "normal a\<CR>\<ESC>"
            let finish_par = 0
        else
            normal j
            let finish_par = 1
        endif
        echom 'finish? ' . finish_par

    endwhile


   " silent normal gggqG
   " normal gg
   " while(getline(line('.')) =~ '^[\t \ua1a1\ua140]*$')
   "     silent normal dd
   " endwhile

   " call cursor(1,1)
   " while(1) 
   "     if getline('.') =~ '^$'
   "         normal! j
   "         continue
   "     endif

   "     normal 0
   "     while(IsTaboo(<SID>GetCharUnderCursor(), g:no_beg)
   "         normal l
   "     endwhile
   "     normal i\<CR>\<ESC>
   "     normal kkJj

   "     normal $
   "     while(IsTaboo(<SID>GetCharUnderCursor(), g:no_end)) 
   "         normal! h
   "     endwhile
   "     normal a\<CR>\<ESC>
   " endwhile
    "setlocal nomodifiable
    " replace all È«½Ç¿Õ¸ñwith two spaces
    " %s/\%ua1a1\|\%ua140/  /g
    "silent! write!
endfunction " >>>

    command! -nargs=?  Fx call <SID>Format()

finish


" vim600: set foldmethod=marker foldmarker=<<<,>>> foldlevel=1:

