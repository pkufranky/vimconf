" Source this file for removing some unimportang lines from strace output.

" $Id: strace.vim,v 1.2 2001/10/13 22:28:40 host8 Exp $

:silent! execute 'g/^\(\d\+ \{1,2}\)\{0,1}brk/d'
:silent! execute 'g/^\(\d\+ \{1,2}\)\{0,1}rt_sig/d'
:silent! execute 'g/ELF/d'
:silent! execute 'g/^\(\d\+ \{1,2}\)\{0,1}time/d'
:silent! execute 'g/^\(\d\+ \{1,2}\)\{0,1}gettimeofday/d'
:silent! execute 'g/^\(\d\+ \{1,2}\)\{0,1}select/d'
