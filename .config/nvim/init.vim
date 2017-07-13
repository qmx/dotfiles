call plug#begin('~/.local/share/nvim/plugged')
Plug 'ctrlpvim/ctrlp.vim'
Plug 'fatih/vim-go'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdtree'
Plug 'timonv/vim-cargo'
Plug 'vim-syntastic/syntastic'
Plug 'Valloric/YouCompleteMe', { 'do':'./install.py --racer-completer' }
call plug#end()

""" remapping leader to comma key
let mapleader = ","
let maplocalleader = ","

""" reload .vimrc
nmap <leader>v :source $MYVIMRC<CR>
nmap <leader>V :tabnew $MYVIMRC<CR>

""" nerdtree bindings
nmap <leader>d :NERDTreeToggle<CR>

""" some sanite mappings
cab WQ wq | cab Wq wq | cab W w | cab Q q

""" cursor line
set cursorline

""" line numbers
set number

let g:rustfmt_autosave = 1

set autowrite

colorscheme desert

""" vim-go settings
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 1
let g:go_auto_sameids = 1
