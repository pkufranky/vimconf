" Vim database client (Perl::DBI)
"
" File:			database-client.vim
" Maintainer:	Lubomir Host 'rajo' <rajo AT platon.sk>
" Version:		$Platon: vimconfig/vim/modules/database-client.vim,v 1.3 2004-02-23 17:52:54 rajo Exp $
"
" Copyright (c) 2003 Platon SDG, http://platon.sk/
" Licensed under terms of GNU General Public License.
" All rights reserved.
"
" $Platon: vimconfig/vim/modules/database-client.vim,v 1.3 2004-02-23 17:52:54 rajo Exp $
" 

" This plugin needs Perl interpreter to be enabled (+perl feature)
if ! has('perl')
	echo "You don't have perl"
	finish
endif

echo "sourcing DBI client ..."

"---------------------------------------------------------------------------
"------------------------ USER CONFIGURABLE OPTIONS ------------------------
"---------------------------------------------------------------------------
" Set default values:
if !exists('g:SQL_main_window_title')
    let g:SQL_main_window_title = "SQL"
endif
if !exists('g:SQL_data_window_title')
    let g:SQL_data_window_title = "SQL_data"
endif
if !exists('g:SQL_cmd_window_title')
    let g:SQL_cmd_window_title = "SQL_command"
endif

" width of main window
if !exists('g:SQL_main_window_width')
	let g:SQL_main_window_width = 20
endif
" height of command window
if !exists('g:SQL_cmd_window_height')
	let g:SQL_cmd_window_height = 10
endif

" Control whether additional help is displayed as part of the taglist or not.
" Also, controls whether empty lines are used to separate the tag tree.
if !exists('SQL_Compact_Format')
    let SQL_Compact_Format = 0
endif

"---------------------------------------------------------------------------
"-------------------- END OF USER CONFIGURABLE OPTIONS ---------------------
"---------------------------------------------------------------------------


" Initialize the taglist plugin local variables for the supported file types
" and tag types

" Are we displaying brief help text
let s:sql_brief_help = 1


" autosource this file on write
augroup DBIclient
	autocmd!
	autocmd BufWritePost database-client.vim source ~/.vim/modules/database-client.vim
augroup END

" initialize DBI engine
function! SQL_Init() " {{{
perl << EOF

	package DBI::st;

	# fetch and print data from _executed_ DBI statement handler
	sub dump_data ($)
	{ # {{{
		my $sth = shift;

		my $numFields     = $sth->{'NUM_OF_FIELDS'};
		my $column_names  = $sth->{'NAME'};
		my $column_sizes  = $sth->{'mysql_max_length'};
		my $column_is_num = $sth->{'mysql_is_num'};

		# build column name's line
		my $header_names = "";
		foreach (my $i = 0; $i < $numFields; $i++) {
			# numeric columns have smaller length as column name, overwrite ...
			$$column_sizes[$i] = $$column_sizes[$i] > length($$column_names[$i])
				? $$column_sizes[$i]
				: ($$column_is_num[$i] ? -1 : 1) * length($$column_names[$i]); # WARN: negative length! - used for right aligment of numbers
			$header_names .= sprintf("%s%s", $i ? " | " : "| ", $$column_names[$i] . " " x ($$column_sizes[$i] - length($$column_names[$i])));
		}
		$header_names .= " |\n";

		# build header separator
		my $separator = "";
		foreach (my $i = 0; $i < $numFields; $i++) {
			$separator .= "+" . ("-" x (abs($$column_sizes[$i]) + 2));
		}
		$separator .= "+\n"; # the end

		# print header
		VIM::Msg($separator);
		VIM::Msg($header_names);
		VIM::Msg($separator);

		# print data
		while (my @row = $sth->fetchrow_array()) {
			my $line = "";
			foreach (my $i = 0; $i < $numFields; $i++) {
				$line .= sprintf("%s%s", $i ? " | " : "| ",
					$$column_sizes[$i] > 0 # usage of negative length
						? $row[$i] . " " x ($$column_sizes[$i] - length($row[$i]))
						: " " x (- $$column_sizes[$i] - length($row[$i])) . $row[$i]
				);
			}
			VIM::Msg("$line |\n");
		}

		# print footer
		VIM::Msg($separator);

	} # }}}

EOF
endfunction
" }}}

" Initialize NOW!
call SQL_Init()

" connect to database
function! SQL_Connect() " {{{
	perl << EOF
	use DBI;

	package main;

	# get hostname from user
	$db_host = "localhost" unless (defined $db_host); # remember server name
	my ($success, $value) = VIM::Eval("inputdialog('Hostname of your database server', '$db_host')");
	if ($success) {
		$db_host = $value;
	}
	else {
		return;
	}
	
	# get username from user
	$db_user = "user" unless (defined $db_user); # remember username
	my ($success, $value) = VIM::Eval("inputdialog('Login', '$db_user')");
	if ($success) {
		$db_user = $value;
	}
	else {
		return;
	}

	if (exists $main::connections->{"$db_host; $db_user;"}) {
		VIM::Msg("This connection already exists!");
		return;
	}
	
	# get password from user
	my ($success, $value) = VIM::Eval('inputsecret("Password: ")');
	if ($success) {
		$db_pass = $value;
	}
	else {
		return;
	}
	
	$dbh = DBI->connect("DBI:mysql:host=$db_host", $db_user, $db_pass)
		or die $DBI::errstr;

	if (defined $dbh) {
		$main::connections->{"$db_host; $db_user;"} = {
			'dbh'	=> $dbh,
			'desc'	=> "$db_user\@$db_host",
		};
		$main::current_conn = "$db_host; $db_user;";
	}
	else {
		undef $main::connections->{"$db_host; $db_user;"}->{dbh};
		undef $main::connections->{"$db_host; $db_user;"}->{desc};
		undef $main::connections->{"$db_host; $db_user;"};
	}

	my $count = 0;
	foreach my $key (sort keys %{$main::connections}) {
		$count++;
		# reorder connections
		$main::connections->{$key}->{order} = $count;
	}
		
	VIM::Msg("Connect to database succsesfull");

EOF
endfunction
" }}}

" show used connections
function! SQL_ShowConnections() " {{{
	perl << EOF
	use DBI;

	package main;

	my $count = 0;
	unless (scalar(keys %{$main::connections})) {
		VIM::Msg("No connections");
		return;
	}
	VIM::Msg("Active connections to database:");
	foreach my $key (sort keys %{$main::connections}) {
		$count++;
		# reorder connections
		$main::connections->{$key}->{order} = $count;
		VIM::Msg("$count - $main::connections->{$key}->{desc}");
	}

EOF
endfunction
" }}}

" disconnect from given connection
function! SQL_Disconnect() " {{{

	" use vertical layout of buttons
	let s:save_guioptions = &guioptions
	set guioptions+=v

	perl << EOF
	use DBI;

	package main;

	my $count = 0;
	my $choices = "";
	foreach my $key (sort keys %{$main::connections}) {
		$count++;
		# reorder connections
		$main::connections->{$key}->{order} = $count;
		$choices .=  '&' . "$count - $main::connections->{$key}->{desc}" . '\n';
	}
	#$choices =~ s/\\n$//g;
	$choices .= "&Cancel";
	if ($count == 0) {
		VIM::Msg("No connections...");
		return;
	}
	my ($success, $value) = VIM::Eval('confirm("From which database do you wish to disconnect?", "'
			. $choices . '", 1, "Question")');

	return unless ($value > 0);
	my $count = 0;
	foreach my $key (sort keys %{$main::connections}) {
		$count++;
		if ($count == $value) {
			$main::connections->{$key}->{dbh}->disconnect()
				or warn "Can't disconnect from database #$count: " . $DBI::errstr;
			undef $main::connections->{$key}->{dbh};
			delete $main::connections->{$key};
		}
	}

EOF

	let &guioptions = s:save_guioptions

endfunction
" }}}

" execute SQL command
function! SQL_Do(sql_cmd) " {{{

	perl << EOF
	use DBI;

	package main;

	my $dbh = $main::connections->{$main::current_conn}->{dbh};
	my $sql_cmd = VIM::Eval("a:sql_cmd"); # get function parameter from Vim to Perl

	my $sth = $dbh->prepare($sql_cmd) or warn $DBI::errstr;
	$sth->execute();
	$sth->dump_data();

EOF

endfunction
" }}}


"create menu
function! CreateMenu() " {{{
	" remove whole menu 
	silent! aunmenu SQL
	amenu 200.10 S&QL.&Connect :call SQL_Connect()<Return>
	amenu 200.20 S&QL.&Disconnect :call SQL_Disconnect()<Return>
	amenu 200.30.5  S&QL.&Show.&connections :call SQL_ShowConnections()<Return>
	amenu 200.30.10 S&QL.&Show.&databases :call SQL_Do('SHOW DATABASES')<Return>
	amenu 200.30.20 S&QL.&Show.&tables :call SQL_Do('SHOW TABLES')<Return>
	amenu 200.30.30 S&QL.&Show.&variables :call SQL_Do('SHOW VARIABLES')<Return>
	amenu 200.30.40 S&QL.&Show.&server\ status :call SQL_Do('SHOW STATUS')<Return>
endfunction
" }}}
call CreateMenu()

function! s:CloseWindow(winnum) " {{{
	" if window exists
	if a:winnum >= 0
		execute "normal \<c-w>" . a:winnum . "w"
		close
	endif
endfunction
" }}}

" create windows
function! CreateWindows() " {{{
	let s:main_winnum = bufwinnr(g:SQL_main_window_title)
	let s:data_winnum = bufwinnr(g:SQL_data_window_title)
	let s:cmd_winnum  = bufwinnr(g:SQL_cmd_window_title)

	call s:CloseWindow(s:main_winnum)
	call s:CloseWindow(s:data_winnum)
	call s:CloseWindow(s:cmd_winnum)

	execute 'topleft split ' . g:SQL_cmd_window_title
	setlocal noswapfile
	setlocal buftype=nowrite
	setlocal bufhidden=delete
	setlocal nonumber
	setlocal nowrap
	setlocal norightleft
	setlocal foldcolumn=0
	setlocal modifiable
	set filetype=sql


	execute g:SQL_main_window_width " vsplit " . g:SQL_main_window_title
	setlocal noswapfile
	setlocal buftype=nowrite
	setlocal bufhidden=delete
	setlocal nonumber
	setlocal nowrap
	setlocal norightleft
	setlocal foldcolumn=0
	setlocal modifiable
	call s:SQL_Display_Help()

	let s:winnr_SQL_cmd = bufwinnr(g:SQL_cmd_window_title)
	" switch to SQL_cmd window
	if s:winnr_SQL_cmd
		execute "normal \<c-w>" . s:winnr_SQL_cmd . "w"
	endif
	let s:vheight = winheight(s:winnr_SQL_cmd) - g:SQL_cmd_window_height
	if s:vheight > 0
		execute s:vheight . ' split ' . g:SQL_data_window_title
	else
		execute ' split ' . g:SQL_data_window_title
	endif
	
	setlocal noswapfile
	setlocal buftype=nowrite
	setlocal bufhidden=delete
	setlocal nonumber
	setlocal nowrap
	setlocal norightleft
	setlocal foldcolumn=0
	setlocal modifiable

	call s:Map_SQL_mappings()


endfunction
" }}}
"call CreateWindows()

" SQL_Display_Help() " {{{
" Function from taglist.vim plugin
" (Author: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
function! s:SQL_Display_Help()

	if s:sql_brief_help
		" Add the brief help
		call append(0, '" Press ? to display help text')
	else
		" Add the extensive help
		call append(0, '" u : Update table list')
		call append(1, '" U : Update database list')
		call append(2, '" ? : Remove help text')
	endif
endfunction
" }}}

" SQL_Toggle_Help_Text() {{{
" Toggle SQL plugin help text between the full version and the brief
" version
" Function from taglist.vim plugin
" (Author: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
function! s:SQL_Toggle_Help_Text()
	if g:SQL_Compact_Format
		" In compact display mode, do not display help
		return
	endif

	" Include the empty line displayed after the help text
	let brief_help_size = 1
	let full_help_size = 3

	setlocal modifiable

	" Set report option to a huge value to prevent informational messages
	" while deleting the lines
	let old_report = &report
	set report=99999

	" Remove the currently highlighted tag. Otherwise, the help text
	" might be highlighted by mistake
	match none

	" Toggle between brief and full help text
	if s:sql_brief_help
		let s:sql_brief_help = 0

		" Remove the previous help
		exe '1,' . brief_help_size . ' delete _'

		" Adjust the start/end line numbers for the files
		"call s:SQL_Update_Line_Offsets(0, 1, full_help_size - brief_help_size)
	else
		let s:sql_brief_help = 1

		" Remove the previous help
		exe '1,' . full_help_size . ' delete _'

		" Adjust the start/end line numbers for the files
		"call s:SQL_Update_Line_Offsets(0, 0, full_help_size - brief_help_size)
	endif

	call s:SQL_Display_Help()

	" Restore the report option
	let &report = old_report

	setlocal nomodifiable
endfunction
" }}}

" Map_SQL_cmd_mappings() {{{
function! s:Map_SQL_mappings()
	" get number of current window
	let curwinnum = bufwinnr('%')
	
	let winnum = bufwinnr("SQL")
	if winnum >= 0 " if window exists
		" toggle to SQL window and then back
		execute "normal \<c-w>" . winnum . "w"

		inoremap <buffer> <silent> ?    <C-o>:call <SID>SQL_Toggle_Help_Text()<CR>
		nnoremap <buffer> <silent> ? :call <SID>SQL_Toggle_Help_Text()<CR>

		execute "normal \<c-w>" . curwinnum . "w"
	endif

endfunction
" }}}


" Modeline {{{
" vim: ts=4
" vim600: fdm=marker fdl=0 fdc=3
" }}}

