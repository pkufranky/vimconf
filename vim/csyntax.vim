" Source this file while editing C source code for better formating.

" $Id: csyntax.vim,v 1.1 2001/10/13 22:28:40 host8 Exp $

:silent! execute "%s/} else/}else/gc"
:silent! execute "%s/\([ 	]\+\)if(/\1if (/gc"
:silent! execute "%s/\([ 	]\+\)for(/\1for (/gc"
:silent! execute "%s/\([ 	]\+\)switch(/\1switch (/gc"
:silent! execute "%s/\([ 	]\+\)while(/\1while (/gc"
:silent! execute "%s/[ 	]\+$//gc"
:silent! execute "%s/[^ 	]==[^ 	]/ == /gc"
