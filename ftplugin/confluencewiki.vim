if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

setlocal foldexpr=getline(v:lnum)=~'^h[1-3]\.'?'>'.getline(v:lnum)[1]:'='
setlocal fdm=expr
setlocal fdl=1
