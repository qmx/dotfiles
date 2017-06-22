call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdtree'
Plug 'timonv/vim-cargo'
Plug 'vim-syntastic/syntastic'
call plug#end()

let g:rustfmt_autosave = 1
