" Source this file for removing some unimportang lines from strace output.

" $Id: $

:exec 'g/^\(\d\+ \{1,2}\)\{0,1}brk/d'
:exec 'g/^\(\d\+ \{1,2}\)\{0,1}rt_sig/d'
:exec 'g/ELF/d'
:exec 'g/^\(\d\+ \{1,2}\)\{0,1}time/d'
:exec 'g/^\(\d\+ \{1,2}\)\{0,1}gettimeofday/d'
:exec 'g/^\(\d\+ \{1,2}\)\{0,1}select/d'
