" Mapleader {{{
    let mapleader=","
" }}}
" Colors {{{
    syntax enable
    colorscheme molokai
    set termguicolors
    set t_Co=256
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
    " remove trailing whitespace on save - now handled by ale plugin
    " autocmd BufWritePre * :%s/\s\+$//e
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

set hidden
set nobackup
set nowritebackup
set cmdheight=2
set signcolumn=yes
set updatetime=500
set shell=/bin/bash

" File Type overrides {{{
augroup filetype_ruby
    autocmd!

    au BufRead,BufNewFile Rakefile,Capfile,Gemfile,.autotest,.irbrc,*.treetop,*.tt set ft=ruby syntax=ruby
augroup END
" }}}
