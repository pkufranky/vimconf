" Source this file while editing C source code for better formating.

" $Id: $

%s/} else/}else/gc
%s/\([ 	]\+\)if(/\1if (/gc
%s/\([ 	]\+\)for(/\1for (/gc
%s/\([ 	]\+\)switch(/\1switch (/gc
%s/\([ 	]\+\)while(/\1while (/gc
%s/[ 	]\+$//gc
%s/[^ 	]==[^ 	]/ == /gc
