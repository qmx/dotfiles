call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'fatih/vim-go'
Plug 'vim-syntastic/syntastic'
Plug 'rust-lang/rust.vim'
call plug#end()

let g:rustfmt_autosave = 1
