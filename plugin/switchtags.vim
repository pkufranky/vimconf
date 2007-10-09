"============================================================================
"    Copyright: Copyright (C) 2005 Yubao Liu<dieken at 126 dot com>
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               switchtags.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damages
"               resulting from the use of this software.
"Name Of File: switchtags.vim
" Description: Vim global plugin for switch tags automatically between different projects
"  Maintainer: Yubao Liu<dieken at 126 dot com>
" Last Change: 2005 Sep 5
"     Version: 1.0
"
"
" Usage:
" 	copy switchtags.vim to $VIM/vimfiles/plugin or ~/.vim/plugin, and change
"   %__tags (in the code below) to fit your requirement.
"
" Notes: 
"   	%__tags consists of (top_dir, tags_path) pairs, each pair means
"	all files in "top_dir" directory and its sub directories use the "tag_path"
"	as the value of VIM's tags option. The order of directory names doesn't matter.
"   
"   1. This plugin need a VIM compiled with Perl support, and Perl should has been
"      installed in your operating system. (For windows user, you can download Perl
"      from www.activestate.com. Ensure perl.exe is in your PATH.)
"
"   2. top_dir is an absolute path name, it must be separated by "/" and not ended with "/".
"      Under Windows, the disk number and directory name must be separated by "/" too.
"   
"   3. Under Windows, the top_dir must be lower case, you can use lc() function to do it.
"
"   4. tags_path is a path name list separated with comma, see ":help 'tags'" for details.
"
"   5. top_dir and tags_path must be enclosed with single quotes to avoid Perl interpreting
"      them as special characters.
"
"   6. You can set %__verbose to 1 to view debug information if something wrong.
"
"   7. You can set default tags_path by adding a ('/', 'pathto_your_tags') pair
"      (for UNIX/Linux) or a ('x:', 'pathto_your_tags') pair (for Windows) to %__tags.
"
"=============================================================================


"-------------------------------------------------------
if has('perl')
function <SID>InitSwitchTags()
perl <<EOF
	if (! defined(%__tags)) {
		%__tags = (
		lc('D:/work/dev/project1') => 'd:\tags\project1.tags',
		lc('D:/work/dev/project2') => 'd:\tags\project2.tags',
		lc('D:/work') => 'd:\tags\common.tags',
		lc('D:') => 'd:\tags\default.tags'			# not end with comma!!
		);
		
		# for UNIX/Linux, %__tags is like this:
		# %__tags = (
		# '/home/dieken/work/dev/project1' => '/home/dieken/tags/project1.tags',
		# '/home/dieken/work/dev/project2' => '/home/dieken/tags/project2.tags',
		# '/home/dieken/work' => '/home/dieken/tags/common.tags',
		# '/' => '/home/dieken/tags/default.tags'
		# );
	}
	
	if (! defined(%__cache)) {
		%__cache = ();
	}
	
	$__verbose = 0;
EOF
endfunction
call <SID>InitSwitchTags()
endif

"-----------------------------------------------------
if has('perl')
function <SID>SwitchTags(fullpath)
	if &tags==""
		set tags=./tags,tags
	endif
	
	perl <<EOF
	my ($success, $fullpath, $path, $p, $s);
	($success, $fullpath) = VIM::Eval('a:fullpath');
	if ($success) {
		if (exists($__cache{$fullpath})) {
			VIM::SetOption("tags=$__cache{$fullpath}");
			if($__verbose) {VIM::Msg("Cache: $fullpath=>$__cache{$fullpath}");}
			return;
		}
		if ($^O =~ /MSWin32/) {
			$path = lc($fullpath);
		} else {
			$path = $fullpath;
		}
		$path =~ s/\\/\//g;
		$p = rindex($path, '/');
		while ($p >= 0) {
			$s = substr($path, 0, $p);
			if (exists($__tags{$s})) {
				$__cache{$fullpath} = $__tags{$s};
				VIM::SetOption("tags=$__tags{$s}");
				if($__verbose) {VIM::Msg("FOUND: $s=>$__tags{$s}");}
				last;
			}
			$p = rindex($path, '/', $p - 1);
		} #end while
		if ($__verbose && $p < 0) {VIM::Msg("Miss tags for \"$fullpath\"");}
	} else {
		if ($__verbose) {VIM::Msg("VIM::Eval failed.......");}
	}
EOF
endfunction
endif

" ---------------------------------------------------
if has('perl')
augroup	switchtags
au!
au BufEnter * call <SID>SwitchTags(expand("%:p"))
augroup END
endif
