filetype plugin on
filetype plugin indent on
syntax on

colorscheme desert

let g:ale_linters = {'rust': ['cargo']}
let g:ale_rust_rls_toolchain = 'stable'
let g:ale_completion_enabled = 0
let g:ale_open_list = 0
let g:ale_set_quickfix = 0

let g:airline_powerline_fonts = 0
""" remapping leader to comma key
let mapleader = ","
let maplocalleader = ","

""" cursor line
set cursorline

set cmdheight=5

""" line numbers
set number

""" reload .vimrc
nmap <leader>v :source $MYVIMRC<CR>
nmap <leader>V :tabnew $MYVIMRC<CR>

""" escape
inoremap jj <Esc>

nnoremap <c-p> :FZF<cr>

nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

nmap <leader>d :NERDTreeToggle<CR>
nmap <F8> :TagbarToggle<CR>

au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)
au FileType rust nmap <leader>f :RustFmt<CR>
au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

set swapfile
set dir^=/dev/shm//

set nofixendofline

packloadall
silent! helptags ALL
