" cache-directory (where to store perldoc search results)
let g:Perldoc_CacheDir = 'd:/perl/cache'

" key to start the perldoc-prompt
nmap <buffer><silent> <F3> :call Perldoc_Prompt( 0 )<CR>
au BufRead *.perldoc map <buffer><silent> <F3> :call Perldoc_Prompt( 1 )<CR>

"{{{ some magic code
au BufRead *.perldoc exe 'source ' . expand("%:r") . ".vim"

"{{{
fun! Perldoc_UnquoteFilename( name, isDir )
    let name = substitute( a:name, '^["' . "']*", "", "g" )
    let name = substitute( name, '[/\\]*["' . "']*$", "", "g" )
    if a:isDir
	if -1 != match( name, "\\" )
	    return name . "\\"
	else
	    return name . "/"
	endif
    endif
    return name
endfun
"}}}

let g:Perldoc_CacheDir      = Perldoc_UnquoteFilename( g:Perldoc_CacheDir, 1 )
let g:Perldoc_ConvertScript = expand("<sfile>")

"{{{
fun! Perldoc_Hexchr( num )
    if a:num >= 10 && a:num <= 15
	return nr2char( char2nr("A") + a:num - 10 )
    endif
    return a:num
endfun
fun! Perldoc_2Fname( string )
    let pos       = 0
    let len       = strlen(a:string)
    let inString  = tolower( a:string )
    let outString = ""

    while pos < len
	let chr = strpart(a:string, pos, 1)
	let ord = char2nr(chr)

	if ord >= char2nr("a") && ord <= char2nr("z")
	    let outString = outString . chr
	else
	    let hexhigh = Perldoc_Hexchr(ord / 16)
	    let hexlow  = Perldoc_Hexchr(ord % 16)

	    let outString = outString . hexhigh . hexlow
	endif

	let pos = pos + 1
    endw

    return outString
endfun
"}}}

"{{{
fun! Perldoc_Prompt( mode ) " show perldoc-output in <a) [mode=0] new b) [mode=1] current> window

    if "/" == g:Perldoc_CacheDir || !isdirectory(g:Perldoc_CacheDir)
	redraw
	echohl Question
	echon "g:Perldoc_CacheDir"
	echohl WarningMsg
	echon " must be a valid directory\n"
	echon " - please edit 2nd line of "
	echohl Question
	echon g:Perldoc_ConvertScript
	echohl WarningMsg
	echo "Press [Enter] to go there now..."
	echohl Normal
	let chr = getchar() 
	redraw
	if 13 != chr
	    return
	endif
	exe "split " . g:Perldoc_ConvertScript
	normal ggj
	let pos = match( getline("."), '\(["' . "'" . ']\).*\1' )
	if pos != -1
	    let quote = strpart(getline("."),pos,1)
	    call cursor(0,pos+2)
	    exe "normal vt" . quote
	endif
	return
    endif

    " Suchwort einlesen und für die Suche zurechtschneidern
    let searchfor = input("Perldoc>", expand("<cword>"))
    let searchfor = substitute( searchfor, '^\s\+\|\s\+$', "", "g" )
    if searchfor == ""
	return
    endif
    let searchfor = Perldoc_2Fname( searchfor )

    let pdocfile = g:Perldoc_CacheDir . searchfor . ".perldoc"

    " entsprechende Perldoc-Datei schon vorhanden?
    if !filereadable( pdocfile )
	let badnews = tempname()
	" nein -> von Perl besorgen lassen
	exe "silent! !perl -x " . g:Perldoc_ConvertScript . " " . pdocfile . " " . badnews
	if filereadable(badnews)
	    " Fehlerfall wird von Perl selbst angezeigt
	    call delete(badnews)
	    return
	endif
    endif

    " neues Fenster für Perldoc-Ausgabe öffnen (sofern noch nicht geschehen)
    if a:mode == 0
	silent vnew +normal|
    endif

    " gewünschtes Perldoc-Dokument laden
    exe "silent edit " . pdocfile
endfun
"}}}

finish
#!perl
#{{{ in addition, some perls
    # dieses Zeichen wird zur Erleichterung des Syntaxhighlighting für VIM benutzt
    my $colorChar = chr( 127 );

    # Zuordnung Escape-Sequenz <=> VIM-Highlightgruppe
    my %vimColorLinks = (
	4 => "Title",
	1 => "Keyword"
    );

    # arg1 = gewünschtes Perldoc-Dokument
    # arg2 = Name einer Datei, die (nur) im Fehlerfall angelegt wird
    my $pdocfile   = shift ;
    local $errfile = shift ;

    # Perldoc-Dateinamen trennen in Verzeichnis + Suchbegriff (=Dateiname ohne Endung)
    $pdocfile =~ /(^.*[\/\\])(.*?)\.perldoc$/i
	or dumpAndDie( "sorry, some error occured...\n" );

    my( $dir, $fname ) = ( $1, $2 );

    my $name = $fname ;
    $name =~ s/([0-9A-F]{2})/chr(hex($1))/ge ;

    # Perldoc mit dem Suchbegriff aufrufen...
    print "asking Perldoc for \"$name\"...\n" ;
    my @perldoc = `perldoc -M Pod::Text::Termcap $name` ;
    if( @perldoc == 0 or @perldoc < 10 and grep /no documentation/i, @perldoc ){
	# ...ggf. nachhaken...
	print "asking Perldoc for -f \"$name\"...\n" ;
	@perldoc = `perldoc -M Pod::Text::Termcap -f $name` ;
    }

    # ...Fehlerfall abfangen...
    if( @perldoc == 0 or @perldoc < 10 and grep /no documentation/i, @perldoc ){
	dumpAndDie( "...unable to find \"$name\".\n" );
    }

    # Ausgabedateien anlegen
    open PDOCFILE, ">$pdocfile" and
    open VIMFILE, ">$dir" . $fname . ".vim"
	or dumpAndDie( "File error: $!" );

# Zeilen (von perldoc) nach Escape-Sequenzen parsen und umwandeln für VIM-Syntaxhighlighting
    my @newlines ;
    my $openColorpart ;
    my @fullColoredLines ;

    my %colorWords ;
    my @colorWordParts ;
    my @colorKoords ;

    LINE: for my $line( @perldoc ){
	chomp $line ;

	# Escapesequenzen isolieren
	my @lineparts = split /(\e\[\d?m)/, $line  ;
	my $newline   = "" ;
	my $pos       = 0 ;
	my @colorParts ;

	# Grenzen der farbigen Bereiche bestimmen
	while( @lineparts ){
	    my $linepart = shift @lineparts ;

	    $pos += length $linepart ;
	    $newline .= $linepart ;

	    @lineparts or last ;

	    if( $openColorpart ){
		$openColorpart->{ to } = $pos ;
		push @colorParts, $openColorpart ;
		$openColorpart = undef ;
	    }

	    my $escSeq = shift @lineparts ;
	    $escSeq =~ /(\d)/ or next ;
	    $openColorpart = {
		color => $1,
		from  => $pos
	    };
	}

	push @newlines, $newline ;

	# Sonderfall: farbiger Bereich läuft in nächster Zeile weiter
	if( $openColorpart ){
	    $openColorpart->{ to } = $pos ;
	    push @colorParts, $openColorpart ;
	    $openColorpart = { 
		color => $openColorpart->{color},
		from  => 0
	    };
	}

	# Dummy-Bereiche entfernen, farblose Zeilen überspringen
	@colorParts = grep { substr($newline, $$_{from}, $$_{to}-$$_{from}) =~ /\S/ } @colorParts
	    or next ;

	# Ist Zeile voll- und einfarbig?
	my $color      = $colorParts[0]{color} ;
	my $allTheSame = 1 ;
	for( @colorParts[1 .. $#colorParts] ){
	    next if $$_{color} eq $color ;
	    $allTheSame = 0, last ;
	}

	if( $allTheSame ){
	    my $uncolored = $newline ;

	    # zum Test alle farbigen Bereiche entfernen und prüfen, ob etwas übrig bleibt
	    for( reverse @colorParts ){
		substr( $uncolored, $$_{from}, $$_{to}-$$_{from} ) = "" ;
	    }

	    # wenn nicht, ist die Zeile vollfarbig
	    push( @fullColoredLines, { line => $#newlines, color => $color } ), next LINE
		unless $uncolored =~ /\S/ ;
	}

	# wenn Zeile nicht vollfarbig:
	# farbige Teile mit Koordinaten abspeichern
	# (wenn möglich, als Syntaxhighlight-Schlüsselworte)
	for my $part( @colorParts ){
	    my( $from, $to ) = @$part{qw( from to )} ;
	    $part->{line} = $#newlines ;

	    my $colorstring = substr $newline, $from, $to - $from ;
	    my @words ;

	    if( istWortgrenze( $newline, $from ) and
		istWortgrenze( $newline, $to ) and
		$colorstring !~ /[^\s\w]/ ){

		@words = grep length, split /\W+/, $colorstring ;

		for my $word( @words ){
		    if( exists $colorWords{$word} ){
			my $partNo = $colorWords{$word} ;
			my $part   = $colorWordParts[ $partNo ] ;
			if( defined $part ){
			    push @colorKoords, $part ;
			    $colorWordParts[ $partNo ] = undef ;
			}
			@words = () ;
		    }
		}
	    }

	    if( @words ){
		push @colorWordParts, $part ;
		@colorWords{ @words } = ($#colorWordParts) x @words ;
	    } else {
		push @colorKoords, $part ;
	    }
	}
    }

# prüfen, ob Syntaxhighlight-Schlüsselworte einmalig sind;
# wenn nötig, doch speichern als "Text-Koordinaten"
    my %hiAgain ;
    for my $line( @newlines ){
	my @words = grep length, split /\W+/, $line ;

	for my $word( @words ){
	    exists $colorWords{ $word } or next ;
	    exists $hiAgain{ $word } or $hiAgain{$word}=undef, next ;

	    local *part = \$colorWordParts[ $colorWords{$word} ] ;
	    defined $part and push(@colorKoords, $part), $part = undef ;
	    delete $colorWords{$word} ;
	    delete $hiAgain{$word} ;
	}
    }
    for( keys %colorWords ){
	delete $colorWords{$_} unless defined $colorWordParts[ $colorWords{$_} ];
    }

# Perldoc-Datei für VIM's Syntaxhighlighting präparieren,
# Syntaxfile für VIM generieren

# 1. Vollfarbige Zeilen präparieren
    my %vimLineColors ;
    for my $line( @fullColoredLines ){
	$newlines[ $line->{line} ] .= $colorChar . $line->{color} ;
	$vimLineColors{ $line->{color} } = undef ;
    }

# 	entsprechende Syntaxanweisungen generieren
    my @vimStrings ;

    for my $color( keys %vimLineColors ){
	push @vimStrings, "syn match perldocColor$color \".*$colorChar$color\" contains=perldocColorMarker" ;
    }

    if( keys %vimLineColors ){
	push @vimStrings, "syn match perldocColorMarker \"$colorChar.*\" contained" ;
	push @vimStrings, "hi link perldocColorMarker Ignore" ;
    }


# 2. Syntaxanweisungen für Syntax-Schlüsselworte generieren
    my $maxVimString = 80 ;
    my %vimWordColors ;
    for my $word( keys %colorWords ){
	my $color     = $colorWordParts[ $colorWords{$word} ]->{color} ;
	local *vimstr = \$vimWordColors{ $color } ;

	if( $vimstr ne "" and length($vimstr) + length($word) + 1 > $maxVimString ){
	    push @vimStrings, $vimstr ;
	    $vimstr = "" ;
	}

	if( $vimstr eq "" ){
	    $vimstr = "syn keyword perldocColor$color $word" ;
	} else {
	    $vimstr .= " $word" ;
	}
    }

    for my $color ( keys %vimWordColors ){
	local *vimstr = \$vimWordColors{ $color };
	if( $vimstr ne "" ){
	    push @vimStrings, $vimstr ;
	}
    }

# 3. Syntaxanweisungen für Highlighting nach Text-Koordinaten generieren
    my %vimKoordColors ;
    for my $koord( @colorKoords ){
	my( $line, $from, $to, $color ) = @$koord{qw( line from to color )};
	$line++, $to+=2 ;

	push @vimStrings, "syn match perldocColor$color \"\\%${line}l\\%>${from}c.*\\%<${to}c\"" ;
	$vimKoordColors{$color} = undef ;
    }

# zum Schluss noch die hi-link-Anweisungen für VIM generieren
    my %vimColors ;
    @vimColors{ keys %vimLineColors, keys %vimWordColors, keys %vimKoordColors } = () ;
    for my $color( keys %vimColors ){
	my $vimColor = $vimColorLinks{$color} || "Error" ;
	push @vimStrings, "hi link perldocColor$color $vimColor" ;
    }

# VIM-Syntaxanweisungen schreiben
    print VIMFILE map "$_\n", @vimStrings ;
    close VIMFILE ;

# Perldoc-Datei schreiben
    print PDOCFILE map "$_\n", @newlines ;
    close PDOCFILE ;

sub istWortgrenze {
    my( $str, $pos ) = @_ ;

    return 1 if $pos == 0 or $pos == length($str) ;

    my $isLeft  = (substr($str, $pos-1, 1) =~ /\w/ );
    my $isRight = (substr($str, $pos, 1) =~ /\w/ );

    return ($isLeft xor $isRight) ;
}

sub dumpAndDie {
    my $errmsg = shift ;
    open ERRFILE, ">$errfile"
	and print ERRFILE $errmsg ;
    print "$errmsg\n" ;
    print "(press ENTER to close)\n" ;
    <STDIN> ;
    exit ;
}
#}}}
#}}}

# Perldoc for VIM, version 1.0
# Please mail to Johannes.Petzold@gmx.de for any feedback like critics or suggestions.

# vim: foldmethod=marker
