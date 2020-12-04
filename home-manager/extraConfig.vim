let g:airline_powerline_fonts = 0
let g:airline#extensions#branch#displayed_head_limit = 10

" [Tags] Command to generate tags file
let g:fzf_tags_command = 'ctags -R'

""" remapping leader to comma key
let mapleader = ","
let maplocalleader = ","

""" reload .vimrc
nmap <leader>v :source $MYVIMRC<CR>
nmap <leader>V :tabnew $MYVIMRC<CR>
"
""" escape
inoremap jj <Esc>

""" FZF bindings
nnoremap <c-p> :FZF<cr>
nnoremap <F12> :Tags<cr>

""" nerdtree bindings
nmap <leader>d :NERDTreeToggle<CR>

""" some sanite mappings
cab WQ wq | cab Wq wq | cab W w | cab Q q

""" cursor line
set cursorline

""" line numbers
set number

nmap <F8> :TagbarToggle<CR>
nnoremap <C-]> g<C-]>

set autowrite

colorscheme nord

syntax on
