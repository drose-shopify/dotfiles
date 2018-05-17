" Colors {{{
syntax enable
colorscheme molokai
set termguicolors
" }}}
" Spaces & Tabs {{{
set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
set modelines=1
filetype indent on
filetype plugin on
set autoindent
" }}}
"Searching {{{
set ignorecase
set incsearch
set hlsearch
" }}}
" Folding {{{
set foldmethod=indent "fold based on indent level
set foldnestmax=10 "Max depth 10
set foldenable "Don't fold files by default on open
nnoremap <space> za
set foldlevelstart=10 "start with fold level of 1
" }}}
" UI Layout {{{
set number " Show line numbers
set showmatch
set wildmenu
set lazyredraw
" }}}

" Yaml Specific {{{
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
"}}}
