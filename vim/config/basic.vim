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
    " remove trailing whitespace on save
    autocmd BufWritePre * :%s/\s\+$//e
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
    set relativenumber " Show relative line number
    set showmatch
    set wildmenu
    set lazyredraw
" }}}


