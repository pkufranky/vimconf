" File: strace.vim
" Maintainer:	Lubomir Host 'rajo' <8host AT pauli.fmph.uniba.sk>
" Last Change: 2003/01/10
" Version: $Platon: vimconfig/vim/strace.vim,v 1.4 2003-01-16 12:16:50 rajo Exp $
"
" Description: Source this file for removing some unimportang
"              lines from strace output.


:silent! execute 'g/^\(\d\+ \{1,2}\)\{0,1}brk/d'
:silent! execute 'g/^\(\d\+ \{1,2}\)\{0,1}rt_sig/d'
:silent! execute 'g/ELF/d'
:silent! execute 'g/^\(\d\+ \{1,2}\)\{0,1}time/d'
:silent! execute 'g/^\(\d\+ \{1,2}\)\{0,1}gettimeofday/d'
:silent! execute 'g/^\(\d\+ \{1,2}\)\{0,1}select/d'
