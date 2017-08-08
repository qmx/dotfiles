call plug#begin('~/.local/share/nvim/plugged')
Plug 'ctrlpvim/ctrlp.vim'
Plug 'fatih/vim-go'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdtree'
Plug 'timonv/vim-cargo'
Plug 'mustache/vim-mustache-handlebars'
Plug 'cespare/vim-toml'
Plug 'vim-syntastic/syntastic'
Plug 'racer-rust/vim-racer'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'chriskempson/base16-vim'
call plug#end()

let g:airline_powerline_fonts = 0
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

let g:deoplete#enable_at_startup = 1

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_rust_checkers = ['rustc']

nmap <leader>r :CargoRun<CR>
nmap <leader>t :CargoTest<CR>

