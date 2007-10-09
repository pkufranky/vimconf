if exists("g:vjde_java_utils")
        "finish
endif
if !has('ruby') || v:version<700
	finish
endif
let g:vjde_java_utils=1  "{{{1
if !exists("g:vjde_utils_setup")
	let g:vjde_utils_setup=1
endif
let s:cursor_l=1
let s:cursor_c=0
   
func! GetImportsStr() "{{{2
    let l:line_imp = search ("^\\s*import\\s\\+","nb")
    let l:res = "java.lang.*;"
    "if l:line_imp == 0 
        "return l:res
    "endif
    while l:line_imp > 0 
        let l:str = getline(l:line_imp)
        let l:cend = matchend(l:str,"^\\s*import\\s")
        if  l:cend!= -1
           
            let l:res =l:res.matchstr(l:str,".*$",l:cend)
                "echo matchstr(l:str,".*$",l:cend)
        endif
        let l:line_imp -= 1
    endw

    let l:line_imp = search ('^\s*package\s\+',"nb")
    if  l:line_imp > 0 
        let l:str = getline(l:line_imp)
        let l:cend = matchend(l:str,'^\s*package\s\+')
        if  l:cend!= -1
           
            let l:tmp = matchstr(l:str,".*$",l:cend)
            
            let l:res =l:res.strpart(l:tmp,0,stridx(l:tmp,";"))
            let l:res = l:res.".*;"
                "echo matchstr(l:str,".*$",l:cend)
        endif
    endif
    return l:res
endf
func! VjdeFindParent(findimps) "{{{2
    let x_l = line('.')
    let x_c = col('.')
    let res1 = []
    "let l = search('extends\s\+\(\i\+\.\)*\<\i\+\>','nb')
    let pos = VjdeGotoDefPos('\<extends\>','b')
    let l = pos[0]
    if ( l > 0 )
        let str = matchstr(getline(l),  'extends\s\+\(\i\+\.\)*\<\i\+\>',pos[1]-1)
        call add(res1,substitute(str, 'extends\s\+\(\(\i\+\.\)*\<\i\+\>\)','\1',''))
    else
        call add(res1,'java.lang.Object')
    endif
    if !a:findimps
        call cursor(x_l,x_c)
        return res1
    endif
    "let l = search('implements\s\+','nb')
    if l > 0 
        let pos2 = VjdeGotoDefPos('\(\<implements\>\|{\)','')
    else
        let pos2 = VjdeGotoDefPos('\<implements\>','b')
    endif
    if ( pos2[0] >0 )

ruby<<EOF

str = ""
l = VIM.evaluate("pos2[0]").to_i
c = VIM.evaluate("pos2[1]").to_i
if VIM::Buffer.current[l][c-1,1]!='{'
    str << VIM::Buffer.current[l][c+10..-1]
    l = l+1
    while  !str.include?('{')
        str << VIM::Buffer.current[l]
        l = l + 1
    end
    l = str.index('throws')
    str = str[0,l] if l != nil
    arr = str.split(/[, \t{]/).delete_if { |a| a.length==0 }
    arr.each_with_index { |a,i| VIM.command('call add(res1,"'+a+'")') }
end
EOF
    endif
    call cursor(x_l,x_c)
    return res1
endf
func! s:VjdeGetStrBetween(lstart,cstart,lend,cend) "{{{2
    let str = ''
    if a:lstart == a:lend
        str = strpart(getline(a:lstart),a:cstart-1,a:cend-a:cstart+1)
    else
        let lcurr = a:lstart+1
        let str=strpart(getline(a:lstart,a:cstart-1))
        while lcurr < a:lend
            let str = str.getline(lcurr)
        endw
        let str = str.strpart(getline(a:lend),0,a:cend)
    endif
    return str
endf
" search a block backward , such as try { , public class .. { .....
" don't move the cursor
"
func! VjdeFindDefination(pattern) "{{{2
    let l = line('.')
    let c = col('.')
        let res1 = VjdeGotoDefPos(a:pattern,'b')
        let res2 = VjdeGotoDefPos('{','')
        call cursor(l,c)
        return res1+res2
endf
" search a block backward , such as try { , public class .. { .....
func! VjdeGotoDefination(pattern,dir)
        let res1 = VjdeGotoDefPos(a:pattern,a:dir)
        let res2 = VjdeGotoDefPos('{',a:dir)
        return res1+res2
endf
" search a pttern by ,f_dir is 'nb' 'b' ''... , ignore occured in Constant and comment
func! VjdeGotoDefPos(pattern,f_dir) "{{{2
        let l:firsttime = 0
        let l:firstpos = 0
        let res1 = [0,0]
        let l:line_d = search(a:pattern,a:f_dir)
        while line_d > 0 
                "let l:col_i = match(getline(l:line_d),a:pattern)
                let l:col_i = col('.') " match(getline(l:line_d),a:pattern)
                let synname= synIDattr(synIDtrans(synID(l:line_d,l:col_i+1,1)),"name")
                if synname != "Comment" && synname!="Constant" && synname!="Special"
                        break
                else
                        if ( l:firsttime == 0 )
                                let l:firsttime = 1
                                let l:firstpos = l:line_d
                        else
                                if ( l:firstpos == l:line_d)
                                        let l:line_d = 0
                                        break
                                endif
                        endif
                        let l:line_d=search(a:pattern,a:f_dir)
                endif
        endw
        if l:line_d > 0 
                let res1[0] = l:line_d
                let res1[1] = l:col_i
        endif
        return res1
endf "}}}2
" search a pair block ,such as { } , 
func! VjdeGotoBlock(mpre,mnext) "{{{2
	let stack=[line('.')]
	while len(stack)>0
		let l:pos = VjdeGotoDefPos('\('.a:mpre.'\|'.a:mnext.'\)','W')
		if l:pos[0]==0
			echo 'Block search failed!'
			return [0,0]
		endif
		if match(getline(l:pos[0]),'^'.a:mpre,l:pos[1]-1) == l:pos[1]-1
			call add(stack,l:pos[0])
		else
			call remove(stack,-1)
		endif
	endw
	return l:pos
endf
" find a code block , such as try { ... } , if { ... } , backward
func! VjdeFindBlockUp(patt) "{{{2
	let res_pos=[]	
	let pos = VjdeFindDefination(a:patt)
	if pos[0] <= 0 || pos[2]<=0
		return [0,0,0,0,0,0]
	endif
	let res_pos+=pos

	let l:line = line('.')
	let l:col= line('.')
	call cursor(pos[2],pos[3]+1)
	let res_pos += VjdeGotoBlock('{','}')

	return res_pos
endf
" find a code block , such as try { ... } , if { ... } , forward
func! VjdeFindBlockDown(patt) "{{{2
	let res_pos=[]	
	let pos = VjdeGotoDefination(a:patt,'')
	if pos[0] <= 0 || pos[2]<=0
		return [0,0,0,0,0,0]
	endif
	let res_pos+=pos

	let l:line = line('.')
	let l:col= line('.')
	call cursor(pos[2],pos[3]+1)
	let res_pos += VjdeGotoBlock('{','}')

	return res_pos
endf
func! s:Java_get_type(str,v_v) "{{{2
        let str1 = matchstr(a:str,'\<[^ \t]\+\s\+\<'.a:v_v.'\>')
        return substitute(str1,'\<\([^ \t]\+\)\s\+\<'.a:v_v.'\>','\1','')
endf
func! Vjde_get_set() " {{{2
        let l:line = line('.')
        let l:v_v = expand('<cword>')
        let str = getline(l:line)
        let l:v_t = s:Java_get_type(str,l:v_v)
        "let l:v_t = VjdeGetTypeName(l:v_v)
        let l:v_Va = substitute(l:v_v,"^\\(.\\)","\\U\\1","")
        call append(l:line,"\tpublic ".l:v_t." get".l:v_Va."(){")
        call append(l:line+1,"\t\treturn this.".l:v_v.";")
        call append(l:line+2,"\t}")
        call append(l:line+3,"\tpublic void set".l:v_Va."(".l:v_t." ".l:v_v.") {")
        call append(l:line+4,"\t\tthis.".l:v_v."=".l:v_v.";")
        call append(l:line+5,"\t}")
endf

func! Vjde_sort_import() range "{{{2
ruby<<EOF
def packageSorter(a,b)
    aw = a.sub(/\s*import\s+(static\s+)*(\w+).*$/,'\2')
    bw = b.sub(/\s*import\s+(static\s+)*(\w+).*$/,'\2')
    #bw = b[/\w+/]
    return a<=>b if aw==bw
    return -1 if aw=='java'
    return 1 if bw=='java'
    return -1 if aw=='javax'
    return 1 if bw=='javax'
    return -1 if aw=='org'
    return 1 if bw=='org'
    return a<=>b
end
lstart = VIM::evaluate("a:firstline").to_i
lend = VIM::evaluate("a:lastline").to_i
lines=[]
for i in lstart..lend
    lines << VIM::Buffer.current[i]
end
lines.delete_if { |l| l==nil || l.length==0 }
lines.sort! { |a,b| packageSorter(a,b) }
count = lstart
header = lines[0].sub(/\s*import\s+(static\s+)*(\w+).*$/,'\2') if lines.length>0
lines.each { |l|
    h = l.sub(/\s*import\s+(static\s+)*(\w+).*$/,'\2') 
    if h!=header
        header = h
        if ( count <= lend)
            VIM::Buffer.current[count]=''
        else
            VIM::Buffer.current.append(count-1,'')
        end
        count +=1
    end
    if count <= lend
        VIM::Buffer.current[count]=l 
    else
        VIM::Buffer.current.append(count-1,l) 
    end
    count += 1
}
EOF
endf
func! Vjde_ext_import() "{{{2
        let l:line = line('.')
	let l:column = col('.')
        let l:str = getline(l:line)
	let l:head = strpart(l:str,0,match(l:str,'\([ \t,){(<]\|$\)',l:column))
        if l:head==''
            return
        endif
	"let l:target = strpart(matchstr(l:head,"[ \\t,(]\\(\\i\\+\\.\\)\\+\\i\\+$"),1)
	let l:target = strpart(matchstr(l:head,'[^0-9A-Za-z\.]\(\i\+\.\)\+\i\+$'),1)
        if l:target == ''
            return 
        endif
        let l:target_sub = strpart(l:target,match(l:target,"\\.\\i\\+$")+1)

        let l:line_pkg = search('^\s*package\s\+','nb')+1

        let l:line_imp = search('^\s*import\s\+'.l:target,'nb') +1
        if l:line_imp ==1
            exec '%s/'.l:target.'/'.l:target_sub.'/g'
            call append(l:line_pkg,'import '.l:target.';')
            call cursor(l:line+1,l:column-strlen(l:target)+strlen(l:target_sub))
        else
            exec l:line_imp.',$s/'.l:target.'/'.l:target_sub.'/g'
            call cursor(l:line,l:column-strlen(l:target)+strlen(l:target_sub))
        endif
endf
func! s:Vjde_get_pkg(cls) "{{{2
        return substitute(a:cls,'^\(\(\w\+\.\)*\)\(\w\+\)$','\1','')
endf
func! s:Vjde_get_cls(cls)
        return substitute(a:cls,'^\(\(\w\+\.\)*\)\(\w\+\)$','\3','')
endf
func! Vjde_import_check(cls) "{{{2
    if match(a:cls,'\<\(char\|int\|void\|long\|double\|byte\|boolean\|float\)\>')==0
        return 0
    endif
    return s:Vjde_add_import(a:cls)
endf
func! s:Vjde_add_import(cls) "{{{2
        if match(a:cls,'^java\.lang\.[A-Z]')==0
            return 0
        endif
        let l:line_imp = search('^\s*import\s\+'.a:cls.'\s*;','nb')
        if l:line_imp > 0 
                return 0
        endif
        let pkg = s:Vjde_get_pkg(a:cls)
        let l:line_imp = search('^\s*import\s\+'.pkg.'\*\s*;','nb')
        if l:line_imp > 0 
                return 0
        endif
        let l:line_imp = search('^\s*import\s\+','nb')
        if l:line_imp <= 0 
                let l:line_imp = search('^\s*package\s\+','nb')
        endif
        call append(l:line_imp,'import '.a:cls.';')
        return 1
endf
func! Vjde_fix_throws() "{{{2
    let bnum = bufnr('%')
    let lnum = line('.')
    let mfind = 0
    let offset = 1 
    let pos = s:Java_pos_fun()
    for item in getqflist()
        if item.bufnr == bnum && item.lnum == lnum  
            let str = matchstr(item.text,'unreported exception [^ \t;]*;') 
            if str==""
                continue
            endif
            let str = substitute(str,'\(unreported exception \)\([^ \t;]*\);','\2','')
            let add = s:Vjde_add_import(str)
            let str = s:Vjde_get_cls(str)
            if !mfind
                let tpos = VjdeGotoDefination('\<throws\>','nb')
                if tpos[0]>=pos[0] && tpos[0] <=pos[2]
                    let mfind = 1
                    call cursor(tpos[0],1)
                    exec 's/\<throws\>/throws '.str.', '
                else
                    call cursor(pos[2],1)
                    exec 's/{/throws '.str.' {/'
                    let mfind =1 
                    continue
                endif
            else
                call cursor(tpos[0],1)
                exec 's/\<throws\>/throws '.str.', '
            endif
        endif
    endfor
    call cursor(lnum,1)
endf

func! Vjde_fix_try() "{{{2
        let bnum = bufnr('%')
        let lnum = line('.')
        let mfind = 0
        let offset = 1 
        for item in getqflist()
            if item.bufnr == bnum && item.lnum == lnum  
                let str = matchstr(item.text,'unreported exception [^ \t;]*;') 
                if str==""
                    continue
                endif
                let str = substitute(str,'\(unreported exception \)\([^ \t;]*\);','\2','')
                let add = s:Vjde_add_import(str)
                let str = s:Vjde_get_cls(str)

                if !mfind
                    let bpos = VjdeFindBlockUp('^\s*try\>')
                    let lastpos =[0,0]
                    let lastpos[0:1] = bpos[4:5]
                    if lnum > bpos[2] && lnum < bpos[4]
                        let cpos = VjdeFindBlockDown('\<\(catch\|finally\)\>')
                            while cpos[0]!=0 && cpos[2]!= 0 && cpos[4]!=0
                                let checkpos = VjdeGotoDefPos('}','b')
                                if checkpos[0]==lastpos[0] && checkpos[1]==lastpos[1]
                                    "call cursor(cpos[0],cpos[1]+1)  " fix for
                                    "try catch statment
                                    call cursor(cpos[0],cpos[1])
                                    if getline(cpos[0])[cpos[1]-1]=='c'
                                        let lastpos[0:1] = cpos[4:5]
                                    else
                                        break
                                    endif
                                else " not the last
                                    break
                                endif
                                let cpos = VjdeFindBlockDown('\<\(catch\|finally\)\>')
                                endw
                                let offset = lastpos[0]-lnum -1
                                let mfind = 1
                            endif
                        endif

                        if mfind
                            call append(lnum+offset+add,'}')
                            call append(lnum+offset+add+1,'catch('.str.' e'.offset.') {')
                            let offset += (2+add)
                        else
                            let mfind = 1
                            call append(lnum-1+add,'try {')
                            call append(lnum+1+add,'}')
                            call append(lnum+2+add,'catch('.str.' e'.offset.') {')
                            call append(lnum+3+add,'}')
                            let offset = 3+add
                        endif
                    endif
        endfor
        if mfind
                call cursor(lnum-1,0)
                exec 'normal '.(offset+3).'=='
        endif
endf "}}}2
func! s:Java_add_arg(firstl,lastl,str_def) "{{{2
ruby<<EOF
	first = VIM::evaluate("a:firstl").to_i
	last = VIM::evaluate("a:lastl").to_i
	str_def = VIM::evaluate("a:str_def")
	str=""
	for i in first..last
		str << VIM::Buffer.current[i]
		break if str.include?(')')
	end
	cm = ''
	if str.index(/[^ \t(]+\s*\)/)
		cm << ','
	end
	str = VIM::Buffer.current[i]
	VIM::Buffer.current[i]= str.sub(/\)/,cm+str_def+')')
EOF
endf
func! s:Java_pos_fun() "{{{2
    "return VjdeFindDefination('^\s*\(public\|private\|protected\)\?\(\s\+final\|\s\+static\|\s\+synchronized\)*\s*[^ \t]\+\s\+\i\+(')
    return VjdeFindDefination('^\s*\(\(public\|private\|protected\|final\|static\|synchronized\|native\|abstract\|synchronized\)\s\+\)*\s*[^ \t]\+\s\+\(if\|while\|for\|catch\)\@!\(\i\+\)\s*(')
endf
func! s:Java_pos_class() "{{{2
    return VjdeFindDefination('^\s*\(public\|private\|protected\)\?\(\s*abstract\|\s*final\|\s*static\)*\s*\(class\|interface\)\s\+\i\+')
endf
func! Vjde_test(ll)
    echo s:Java_range_class(a:ll)
endf
func! s:Java_range_class(ll) "{{{2
        let l = line('.')
        let c = col('.')
    let pos=[0,0,0,0,0,0]
    while ( a:ll > pos[4])
        let pos = VjdeFindBlockUp('^\s*\(public\|private\|protected\)\?\(\s\+abstract\|\s\+final\|\s*static\)*\s*\(class\|interface\)\+\s\+\i\+')

        if pos[0]==0 || pos[2]==0 || pos[4] == 0
            break
        elseif pos[0]<=a:ll && pos[4]>=a:ll
            break
        else
            call cursor(pos[0],pos[1])
        end
    endw
    call cursor(l,c)
    return pos
endf
func! Vjde_surround_try() range "{{{2
	call append(a:firstline-1,'try {')
	call append(a:lastline+1,'}')
	call append(a:lastline+2,'catch(Exception ex) {')
        call append(a:lastline+3,'//TODO: Add Exception handler here')
	call append(a:lastline+4,'}')
	call cursor(a:firstline-1,0)
	exec 'normal '.(a:lastline-a:firstline+7).'=='
	"exec (a:firstline-1).','.(a:lastline+4).'=='
endf "}}}2
func! Vjde_rft_var(pos_t) "{{{2
    let l:var = expand('<cword>')
    let l:lnum = line('.')
    let l:var_t = s:Java_get_type(getline(l:lnum),l:var)
    let pos = []
    let ident=''
    if a:pos_t == 1 " member
        "let pos = s:Java_pos_class()
        let pos = s:Java_range_class(l:lnum)
    elseif a:pos_t == 2 " local
        let pos = s:Java_pos_fun()
        let ident="\t"
    else
        let pos = s:Java_pos_class()
    endif

    if  pos[0]>0 && pos[2] > 0
	if stridx(getline(l:lnum),'=')>=0
		exec 's/'.l:var_t.'\s\+//'
	else
		exec 'normal dd'
	endif
        if match(l:var_t,'^\(int\|long\|boolean\|char\|double\|byte\)$') >= 0
            call append(pos[2],"\t".ident.l:var_t." ".l:var." ;")
        else
            call append(pos[2],"\t".ident.l:var_t." ".l:var." = null ;")
        endif
    else
        echo 'not found class defination.'
        "exec 'normal ^' 3.3
    endif
endf
func! Vjde_rft_arg() "{{{
    let l:var = expand('<cword>')
    let l:lnum = line('.')
    let l:var_t = s:Java_get_type(getline(l:lnum),l:var)
    let pos = s:Java_pos_fun()
    if  pos[0]>0 && pos[2] > 0
	if stridx(getline(l:lnum),'=')>=0
		exec 's/'.l:var_t.'\s\+//'
	else
		exec 'normal dd'
	endif
	call s:Java_add_arg(pos[0],pos[2],l:var_t.' '.l:var)
    else
        echo ' not found method defination.'
    endif
endf
func! Vjde_rft_const() range "{{{2
    let pos = s:Java_range_class(line('.'))
    if pos[0]==0 || pos[2] == 0
        echo 'Can''t find a class defination . Sorry!'
        return
    endif
    let v_t = inputdialog('Please enter the name of variable :','')
    if v_t == ''
        return
    endif
    let firstcol = col('''<')
    let lastcol = col('''>') -1
    let str = ''
    if a:firstline == a:lastline
        let ll  = getline(a:firstline)
        let str = strpart(ll,firstcol-1,lastcol-firstcol+1)
        call setline(a:firstline,strpart(ll,0,firstcol-1).v_t.strpart(ll,lastcol))
        call s:Vjde_add_var(pos[2],str,v_t)
    else
        let lines = []
        call add(lines, "\tprivate final static String ".v_t." = ".strpart(getline(a:firstline),firstcol-1))
        let lcount = a:firstline+1
        while lcount < a:lastline
            call add(lines,getline(lcount))
            "call setline(lcount , '')
            let lcount+=1
        endw
        call add(lines,strpart(getline(a:lastline),0,lastcol).';')
        call setline(a:firstline,strpart(getline(a:firstline),0,firstcol-1).v_t.strpart(getline(a:lastline),lastcol))
        call cursor(a:firstline+1,1)
        exec 'normal '.(a:lastline-a:firstline).'dd'
        call append(pos[2],lines)
    endif

endf "}}}2
func! s:Vjde_add_var(lnum,str,v_t) "{{{2
        if a:str[0]=='"'
            call append(a:lnum,"\tprivate final static String ".a:v_t." = ".a:str." ; ")
        elseif a:str[0]==''''
            call append(a:lnum,"\tprivate final static char ".a:v_t." = ".a:str." ; ")
        elseif match(a:str,'\.')>=0 || match(a:str,'[dDfF]$')>=0
            call append(a:lnum,"\tprivate final static double ".a:v_t." = ".a:str." ; ")
        elseif  match(a:str,'[lL]$')>=0
            call append(a:lnum,"\tprivate final static long ".a:v_t." = ".a:str." ; ")
        else
            call append(a:lnum,"\tprivate final static int ".a:v_t." = ".a:str." ; ")
        endif
endf
func! Vjde_override(type) " 0 extends 1 implements {{{2
    let imps = GetImportsStr()
    let pars = VjdeFindParent(a:type)
    if len(pars) < 1
        return 
    endif
    "call cursor(line('$'),col('$'))
    "let pos = VjdeGotoDefPos('}','nb')
    let pos = s:Java_range_class(line('.'))
    if pos[0] == 0 || pos[2] == 0 || pos[4] == 0
        return
    endif
    if a:type==0
        let par_l = pars[0]
    elseif len(pars)>1
        let par_l = join(pars[1:-1],';')
    elseif a:type!=0
        echo 'not interface implements found.'
        return
    end
    "{{{3
ruby<<EOF
   if ( $vjde_java_cfu  == nil)
       $vjde_java_cfu = Vjde::JavaCompletion.new(
            VIM::evaluate('g:vjde_install_path')+"/vjde/vjde.jar",
            VIM::evaluate("g:vjde_lib_path"))
   end
   offset = -1 
   pos = VIM::evaluate("pos[4]").to_i 
   sel = ''
   mymethods=[]
   allpars = VIM::evaluate("par_l").split(';')
   allpars.each { |p|
       if $vjde_java_cfu.findClass4imps(p,VIM::evaluate("imps"),5)!=nil
           VIM::command("echo \""+$vjde_java_cfu.found_class.name+"\"")
           sel = ''
           $vjde_java_cfu.found_class.methods.each_with_index { |m,i|
                str =  ''
                str << 'protected ' if ( m.modifier & Vjde::PROTECTED!=0)
                str << 'abstract  ' if ( m.modifier & Vjde::ABSTRACT!=0)
                str << "\t" if str==''
                str =  "\t"+i.to_s + "\t" + str + m.to_s
                VIM::command("echo \"" + str +"\"")
                if ( i % 20 == 19)
                    sel << VIM::evaluate('inputdialog("\tSelect methods ( comma or space sepearted: 1 2,3..)<CR>\t:","")')
                    sel << ','
                    VIM::command('echo "\n"')
                end
           }
           if ( $vjde_java_cfu.found_class.methods.length%20!=0 )
               sel << VIM::evaluate('inputdialog("\tSelect methods ( comma or space sepearted: 1 2,3..)<CR>\t:","")')
               sel << ','
               VIM::command('echo "\n"')
           end
           if (sel != '')
                arr = sel.split(/[, \t;]/).delete_if {|s| s.length==0 }
                arr.each { |mi|
                    case mi
                        when /^[0-9]+$/
                        mymethods << $vjde_java_cfu.found_class.methods[mi.to_i] 
                        when /^[0-9]+\s*-\s*[0-9]+$/
                        mymethods.concat( $vjde_java_cfu.found_class.methods[eval(mi.sub(/-/,'..'))] )
                    end
                }
            end
       end
   }
    mymethods.each { |cm|
        next if cm==nil
        str = "\tpublic "
        offset += VIM::evaluate('Vjde_import_check("'+cm.ret_type+'")').to_i        
        str << VIM::evaluate('s:Vjde_get_cls("'+cm.ret_type+'")')
        str << " " << cm.name << "("
        cm.paras.each_with_index { |me,i|
                offset += VIM::evaluate('Vjde_import_check("'+me+'")').to_i
                str << "," if i!= 0
                str << VIM::evaluate('s:Vjde_get_cls("'+me+'")') << " arg" << i.to_s
                }
        str << ")"
        cm.exces.each_with_index { |mc,i|
                str << "  throws " if i==0
                str << "," if i!= 0
                str << VIM::evaluate('s:Vjde_get_cls("'+mc+'")')
                offset += VIM::evaluate('Vjde_import_check("'+mc+'")').to_i
            }
        str << '{'
        VIM::Buffer.current.append(pos+offset, str)
        VIM::Buffer.current.append(pos+offset+1,"\t}")
        offset += 2
    }

EOF
"}}}3
endf "}}}2

func! VjdeSelectMethods(class,imps) "{{{2
   let res_arr=[]
ruby<<EOF
   mymethods=[]
   if ( $vjde_java_cfu  == nil)
       $vjde_java_cfu = Vjde::JavaCompletion.new(
            VIM::evaluate('g:vjde_install_path')+"/vjde/vjde.jar",
            VIM::evaluate("g:vjde_lib_path"))
   end
   if $vjde_java_cfu.findClass4imps(VIM::evaluate("a:class"),VIM::evaluate("a:imps"))!=nil
       VIM::command("echo \""+$vjde_java_cfu.found_class.name+"\"")
       sel = ''
       $vjde_java_cfu.found_class.methods.each_with_index { |m,i|
            str =  ''
            str << 'protected ' if ( m.modifier & Vjde::PROTECTED!=0)
            str << 'abstract  ' if ( m.modifier & Vjde::ABSTRACT!=0)
            str << "\t" if str==''
            str =  "\t"+i.to_s + "\t" + str + m.to_s
            VIM::command("echo \"" + str +"\"")
            if ( i % 20 == 19)
                sel << VIM::evaluate('inputdialog("\tSelect methods ( comma or space sepearted: 1 2,3..)<CR>\t:","")')
                sel << ','
                VIM::command('echo "\n"')
            end
       }
       if ( $vjde_java_cfu.found_class.methods.length%20!=0 )
           sel << VIM::evaluate('inputdialog("\tSelect methods ( comma or space sepearted: 1 2,3..)<CR>\t:","")') 
           sel << ','
           VIM::command('echo "\n"')
       end
       if (sel != '')
            arr = sel.split(/[, \t;]/).delete_if {|s| s.length==0 }
            arr.each { |mi|
            case mi
                when /^[0-9]+$/
                mymethods << $vjde_java_cfu.found_class.methods[mi.to_i] 
                when /^[0-9]+\s*-\s*[0-9]+$/
                mymethods.concat( $vjde_java_cfu.found_class.methods[eval(mi.sub(/-/,'..'))] )
            end
            }
        end
   end
    mymethods.each { |cm|
        next if cm==nil
        VIM::command("call add(res_arr," + cm.to_arr_str + ")")
    }
EOF
    return res_arr
endf
function! s:Vjde_utils_setup() "{{{2
    nnoremap <buffer> <silent> <Leader>e :call Vjde_ext_import()<CR>
    nnoremap <buffer> <silent> <Leader>g :call Vjde_get_set()<CR>
    nnoremap <buffer> <silent> <Leader>s :call Vjde_surround_try()<CR>
    vnoremap <buffer> <silent> <Leader>s :call Vjde_surround_try()<CR>
    "vnoremap <buffer> <silent> <Leader>N :call Vjde_sort_import()<CR>
    nnoremap <buffer> <silent> <Leader>r :call Vjde_fix_throws()<CR>
    nnoremap <buffer> <silent> <Leader>t :call Vjde_fix_try()<CR>
    " extract variable to local
    nnoremap <buffer> <silent> <Leader>l :call Vjde_rft_var(2)<CR>
    " extract variable to member
    nnoremap <buffer> <silent> <Leader>m :call Vjde_rft_var(1)<CR>
    nnoremap <buffer> <silent> <Leader>a :call Vjde_rft_arg()<CR>
    vnoremap <buffer> <silent> <Leader>n :call Vjde_rft_const()<CR>
    nnoremap <buffer> <silent> <Leader>p :call Vjde_override(0)<CR>
    nnoremap <buffer> <silent> <Leader>i :call Vjde_override(1)<CR>
    "imap <M-g> <ESC> :call <SID> Vjde_get_set()<cr>
    "map <M-g> :call <SID>Vjde_get_set()<cr>
endf "}}}2

if g:vjde_utils_setup==1
	au BufNewFile,BufRead *.java silent call s:Vjde_utils_setup()
endif

" vim:fdm=marker:sts=4:ts=4
