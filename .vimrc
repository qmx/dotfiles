filetype plugin on
filetype plugin indent on
syntax on

let g:ale_linters = {'rust': ['rls']}
let g:ale_completion_enabled = 1

let g:airline_powerline_fonts = 0
""" remapping leader to comma key
let mapleader = ","
let maplocalleader = ","

""" cursor line
set cursorline

""" line numbers
set number

""" reload .vimrc
nmap <leader>v :source $MYVIMRC<CR>
nmap <leader>V :tabnew $MYVIMRC<CR>

nnoremap <c-p> :FZF<cr>

nmap <leader>d :NERDTreeToggle<CR>
nmap <F8> :TagbarToggle<CR>

au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)
