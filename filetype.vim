" my filetype file
if exists("did_load_myfiletypes")
  finish
endif
let did_load_myfiletypes = 1

augroup filetypedetect

" ClearSilver
au BufNewFile,BufReadPost *.hdf setf hdf
au BufNewFile,BufReadPost *.cst setf xhtml 

" Git
autocmd BufNewFile,BufRead *.git/COMMIT_EDITMSG    setf gitcommit
autocmd BufNewFile,BufRead *.git/config,.gitconfig setf gitconfig
autocmd BufNewFile,BufRead git-rebase-todo         setf gitrebase
autocmd BufNewFile,BufRead .msg.[0-9]*
      \ if getline(1) =~ '^From.*# This line is ignored.$' |
      \   setf gitsendemail |
      \ endif
autocmd BufNewFile,BufRead *.git/**
      \ if getline(1) =~ '^\x\{40\}\>\|^ref: ' |
      \   setf git |
      \ endif
augroup END
