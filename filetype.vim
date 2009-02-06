" my filetype file
if exists("did_load_myfiletypes")
  finish
endif
let did_load_myfiletypes = 1

augroup filetypedetect
au BufNewFile,BufReadPost *.hdf setf hdf
au BufNewFile,BufReadPost *.cst setf xhtml 
au BufRead,BufNewFile COMMIT_EDITMSG setf git 
augroup END
