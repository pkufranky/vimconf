" Vim configuration file
" Language:		Vim 5.6 script    (with Vim 6.0 features)
" Maintainer:	Lubomir Host <host8@kepler.fmph.uniba.sk>
" Bugs Reports:	Lubomir Host <host8@kepler.fmph.uniba.sk>
" License:		GNU GPL
" Version:		01.09.08
" Language Of Comments:	English

" $Id: latex.vim,v 1.1 2001/12/15 04:01:02 host8 Exp $

:setlocal textwidth=72
:setlocal formatoptions=croqt
:setlocal iskeyword="a-z,A-Z,48-57,_,-,>,\\,{.}"

" Ctrl-F reformat paragraph
:map  <buffer>  gqap
:imap <buffer>  gqapi

:imap <buffer> =a \'{a}
:imap <buffer> +a \v{a}
:imap <buffer> =b \'{b}
:imap <buffer> +b \v{b}
:imap <buffer> =c \'{c}
:imap <buffer> +c \v{c}
:imap <buffer> =d \'{d}
:imap <buffer> +d \v{d}
:imap <buffer> =e \'{e}
:imap <buffer> +e \v{e}
:imap <buffer> =f \'{f}
:imap <buffer> +f \v{f}
:imap <buffer> =g \'{g}
:imap <buffer> +g \v{g}
:imap <buffer> =h \'{h}
:imap <buffer> +h \v{h}
:imap <buffer> =i \'{\i}
:imap <buffer> +i \v{\i}
:imap <buffer> =j \'{j}
:imap <buffer> +j \v{j}
:imap <buffer> =k \'{k}
:imap <buffer> +k \v{k}
:imap <buffer> =l \'{l}
:imap <buffer> +l \q l
:imap <buffer> =m \'{m}
:imap <buffer> +m \v{m}
:imap <buffer> =n \'{n}
:imap <buffer> +n \v{n}
:imap <buffer> =o \'{o}
:imap <buffer> +o \v{o}
:imap <buffer> =p \'{p}
:imap <buffer> +p \v{p}
:imap <buffer> =q \'{q}
:imap <buffer> +q \v{q}
:imap <buffer> =r \'{r}
:imap <buffer> +r \v{r}
:imap <buffer> =s \'{s}
:imap <buffer> +s \v{s}
:imap <buffer> =t \'{t}
:imap <buffer> +t \q t
:imap <buffer> =u \'{u}
:imap <buffer> +u \v{u}
:imap <buffer> =v \'{v}
:imap <buffer> +v \v{v}
:imap <buffer> =w \'{w}
:imap <buffer> +w \v{w}
:imap <buffer> =x \'{x}
:imap <buffer> +x \v{x}
:imap <buffer> =y \'{y}
:imap <buffer> +y \v{y}
:imap <buffer> =z \'{z}
:imap <buffer> +z \v{z}
:imap <buffer> =A \'{A}
:imap <buffer> +A \v{A}
:imap <buffer> =B \'{B}
:imap <buffer> +B \v{B}
:imap <buffer> =C \'{C}
:imap <buffer> +C \v{C}
:imap <buffer> =D \'{D}
:imap <buffer> +D \v{D}
:imap <buffer> =E \'{E}
:imap <buffer> +E \v{E}
:imap <buffer> =F \'{F}
:imap <buffer> +F \v{F}
:imap <buffer> =G \'{G}
:imap <buffer> +G \v{G}
:imap <buffer> =H \'{H}
:imap <buffer> +H \v{H}
:imap <buffer> =I \'{\I}
:imap <buffer> +I \v{\I}
:imap <buffer> =J \'{J}
:imap <buffer> +J \v{J}
:imap <buffer> =K \'{K}
:imap <buffer> +K \v{K}
:imap <buffer> =L \'{L}
:imap <buffer> +L \v{L}
:imap <buffer> =M \'{M}
:imap <buffer> +M \v{M}
:imap <buffer> =N \'{N}
:imap <buffer> +N \v{N}
:imap <buffer> =O \'{O}
:imap <buffer> +O \v{O}
:imap <buffer> =P \'{P}
:imap <buffer> +P \v{P}
:imap <buffer> =Q \'{Q}
:imap <buffer> +Q \v{Q}
:imap <buffer> =R \'{R}
:imap <buffer> +R \v{R}
:imap <buffer> =S \'{S}
:imap <buffer> +S \v{S}
:imap <buffer> =T \'{T}
:imap <buffer> +T \v{T}
:imap <buffer> =U \'{U}
:imap <buffer> +U \v{U}
:imap <buffer> =V \'{V}
:imap <buffer> +V \v{V}
:imap <buffer> =W \'{W}
:imap <buffer> +W \v{W}
:imap <buffer> =X \'{X}
:imap <buffer> +X \v{X}
:imap <buffer> =Y \'{Y}
:imap <buffer> +Y \v{Y}
:imap <buffer> =Z \'{Z}
:imap <buffer> +Z \v{Z}
