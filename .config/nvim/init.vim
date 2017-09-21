call plug#begin('~/.local/share/nvim/plugged')
Plug 'cespare/vim-toml'
Plug 'chriskempson/base16-vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'fatih/vim-go'
Plug 'hashivim/vim-terraform'
Plug 'majutsushi/tagbar'
Plug 'mustache/vim-mustache-handlebars'
Plug 'racer-rust/vim-racer'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'timonv/vim-cargo'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-syntastic/syntastic'
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

let g:rustfmt_autosave = 0

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
let g:syntastic_mode_map = {
    \ "mode": "active",
    \ "passive_filetypes": ["rust"] }

au FileType rust nmap <leader>r :CargoRun<CR>
au FileType rust nmap <leader>t :CargoTest<CR>
au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)

nmap <F8> :TagbarToggle<CR>
