" Vim database client (Perl::DBI)
"
" File:			database-client.vim
" Maintainer:	Lubomir Host 'rajo' <rajo AT platon.sk>
" Version:		$Platon: vimconfig/vim/modules/database-client.vim,v 1.5 2004-02-29 20:01:11 rajo Exp $
"
" Copyright (c) 2003 Platon SDG, http://platon.sk/
" Licensed under terms of GNU General Public License.
" All rights reserved.
"
" $Platon: vimconfig/vim/modules/database-client.vim,v 1.5 2004-02-29 20:01:11 rajo Exp $
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
	"let g:SQL_main_window_width = 20
	let g:SQL_main_window_width = 39
endif
" height of command window
if !exists('g:SQL_cmd_window_height')
	let g:SQL_cmd_window_height = 10
endif

" Control whether additional help is displayed as part of the taglist or not.
" Also, controls whether empty lines are used to separate the tag tree.
if !exists('g:SQL_Compact_Format')
    let g:SQL_Compact_Format = 0
endif


" Default SQL command on startup
if !exists('g:SQL_last_command')
    let g:SQL_last_command = "SELECT * FROM table"
endif

"---------------------------------------------------------------------------
"-------------------- END OF USER CONFIGURABLE OPTIONS ---------------------
"---------------------------------------------------------------------------

" Initialize the SQL plugin local variables for the supported file types
" and tag types

" Are we displaying brief help text
let s:sql_brief_help = 1

" Include the empty line displayed after the help text
let s:brief_help_size = 2
let s:full_help_size = 4


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

	package main;

	# number of executed SQL commands
	my $sql_cmd_num = 0;

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
			'list_tables'	=> 1,
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
	call s:SQL_UpdateDatabaseList()

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

	call s:SQL_UpdateDatabaseList()

endfunction
" }}}

" get SQL command from user and execute
function! SQL_Execute() " {{{
	
	let sql_cmd = inputdialog('SQL command:', g:SQL_last_command)
	if sql_cmd != ''
		call SQL_Do(sql_cmd)
	endif
	unlet sql_cmd
	
endfunction
" }}}


" execute SQL command
function! SQL_Do(sql_cmd) " {{{

	" get number of SQL cmd window
	let cmd_winnum  = bufwinnr(g:SQL_cmd_window_title)

	perl << EOF
	use DBI;

	package main;

	my $dbh = $main::connections->{$main::current_conn}->{dbh};
	my $sql_cmd = VIM::Eval("a:sql_cmd"); # get function parameter from Vim to Perl

	# remove empty chars from beginning and end of string
	# add semilon at the end
	$sql_cmd =~ s/^\s+//g;
	$sql_cmd =~ s/;?\s*$/;/g;

	# remember last SQL command
	VIM::DoCommand('let g:SQL_last_command="' . $sql_cmd . '"');

	$main::sql_cmd_num++;
	my $winnr = VIM::Eval("cmd_winnum");
	my ($window) = VIM::Windows($winnr);
	my $cmd_buf = $window->Buffer();
	my $last_line = $cmd_buf->Count(); # number of lines

	# add SQL cmd separator
	$cmd_buf->Append($last_line, "-- Commnad #$main::sql_cmd_num: " . scalar localtime, $sql_cmd, "");

	my $sth = $dbh->prepare($sql_cmd) or warn $DBI::errstr;
	$sth->execute();
	$sth->dump_data();

	undef $window;
	undef $cmd_buf;
	undef $last_line;
	undef $winnr;

EOF

	unlet cmd_winnum

endfunction
" }}}


"create menu
function! SQL_CreateMenu() " {{{
	" remove whole menu 
	silent! aunmenu SQL
	amenu 200.10 S&QL.&Connect :call SQL_Connect()<Return>
	amenu 200.20 S&QL.&Disconnect :call SQL_Disconnect()<Return>
	amenu 200.30 S&QL.&Execute :call SQL_Execute()<Return>
	amenu 200.40.10 S&QL.&Show.&connections :call SQL_ShowConnections()<Return>
	amenu 200.40.20 S&QL.&Show.&databases :call SQL_Do('SHOW DATABASES')<Return>
	amenu 200.40.30 S&QL.&Show.&tables :call SQL_Do('SHOW TABLES')<Return>
	amenu 200.40.40 S&QL.&Show.&variables :call SQL_Do('SHOW VARIABLES')<Return>
	amenu 200.40.50 S&QL.&Show.&server\ status :call SQL_Do('SHOW STATUS')<Return>
	amenu 200.50.10 S&QL.&Windows.&create :call <SID>SQL_CreateWindows()<Return>
endfunction
" }}}
call SQL_CreateMenu()

function! s:CloseWindow(winnum) " {{{
	" if window exists
	if a:winnum >= 0
		execute "normal \<c-w>" . a:winnum . "w"
		silent! close
	endif
endfunction
" }}}

" create windows
function! s:SQL_CreateWindows() " {{{
	let s:main_winnum = bufwinnr(g:SQL_main_window_title)
	call s:CloseWindow(s:main_winnum)
	
	let s:data_winnum = bufwinnr(g:SQL_data_window_title)
	call s:CloseWindow(s:data_winnum)
	
	let s:cmd_winnum  = bufwinnr(g:SQL_cmd_window_title)
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
	setlocal filetype=sql


	execute g:SQL_main_window_width " vsplit " . g:SQL_main_window_title
	setlocal noswapfile
	setlocal buftype=nowrite
	setlocal bufhidden=delete
	setlocal nonumber
	setlocal nowrap
	setlocal norightleft
	setlocal foldcolumn=0
	setlocal modifiable
	setlocal filetype=sql_menu
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
	setlocal filetype=sql_data

	call s:Map_SQL_mappings()
	call s:SQL_UpdateDatabaseList()

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
		call append(1, '')
	else
		" Add the extensive help
		call append(0, '" u : Update table list')
		call append(1, '" U : Update database list')
		call append(2, '" ? : Remove help text')
		call append(3, '')
	endif
endfunction
" }}}

" s:SQL_Toggle_Help_Text() {{{
" Toggle SQL plugin help text between the full version and the brief
" version
" Function from taglist.vim plugin
" (Author: Yegappan Lakshmanan (yegappan AT yahoo DOT com)
function! s:SQL_Toggle_Help_Text()
	if g:SQL_Compact_Format
		" In compact display mode, do not display help
		return
	endif

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
		exe '1,' . s:brief_help_size . ' delete _'

		" Adjust the start/end line numbers for the files
		"call s:SQL_Update_Line_Offsets(0, 1, s:full_help_size - s:brief_help_size)
	else
		let s:sql_brief_help = 1

		" Remove the previous help
		exe '1,' . s:full_help_size . ' delete _'

		" Adjust the start/end line numbers for the files
		"call s:SQL_Update_Line_Offsets(0, 0, s:full_help_size - s:brief_help_size)
	endif

	call s:SQL_Display_Help()

	" Restore the report option
	let &report = old_report

	setlocal nomodifiable
endfunction
" }}}

" s:Map_SQL_cmd_mappings() {{{
function! s:Map_SQL_mappings()
	" get number of current window
	let curwinnum = bufwinnr('%')
	
	let winnum = bufwinnr(g:SQL_main_window_title)
	if winnum >= 0 " if window exists
		" toggle to SQL window and then back
		execute "normal \<c-w>" . winnum . "w"

		inoremap <buffer> <silent> ? <C-o>:call <SID>SQL_Toggle_Help_Text()<CR>
		nnoremap <buffer> <silent> ? :call <SID>SQL_Toggle_Help_Text()<CR>

		inoremap <buffer> <silent> U <C-o>:call <SID>SQL_UpdateDatabaseList()<CR>
		nnoremap <buffer> <silent> U :call <SID>SQL_UpdateDatabaseList()<CR>

		execute "normal \<c-w>" . curwinnum . "w"
	endif

endfunction
" }}}

" s:SQL_UpdateDatabaseList() {{{
function! s:SQL_UpdateDatabaseList()

	" get number of current window
	let curwinnum = bufwinnr('%')
	
	let winnum = bufwinnr(g:SQL_main_window_title)
	if winnum >= 0 " if window exists
		" toggle to SQL window and then back
		execute "normal \<c-w>" . winnum . "w"

		setlocal modifiable

		" remove all lines after help lines
		if s:sql_brief_help
			exe (s:brief_help_size + 1) . ',$ delete _'
		else
			exe (s:full_help_size + 1) . ',$ delete _'
		endif

		perl << EOF
		use DBI;

		package main;

		my $count = 0;
		foreach my $key (sort keys %{$main::connections}) {
			$count++;
			# reorder connections
			my $conn = $main::connections->{$key};
			$conn->{order} = $count;
			$main::curbuf->Append($main::curbuf->Count(),
				($conn->{list_tables} ?
					($main::current_conn eq $key ? '* ' : '+ ' ) :
					'- ')
				. "$main::connections->{$key}->{desc}"
			);
		}

		if ($count == 0) { # No connections
			$main::curbuf->Append($main::curbuf->Count(), '" -- No connections');
		}

EOF

		setlocal nomodifiable
		execute "normal \<c-w>" . curwinnum . "w"
	endif

endfunction
" }}}

" Modeline {{{
" vim: ts=4
" vim600: fdm=marker fdl=0 fdc=3
" }}}

