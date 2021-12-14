set nocompatible
set hidden

if has('nvim')
    let $VIMHOME = expand('~/.local/share/nvim/')
else
    let $VIMHOME = expand('~/.vim/')
endif

call plug#begin($VIMHOME . 'plugged')

    Plug 'tpope/vim-sensible'

    "Linters and Language Servers
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'dense-analysis/ale'

    "Syntax Highlighters
    Plug 'vim-ruby/vim-ruby'
    Plug 'tpope/vim-rails'
    Plug 'tpope/vim-rake'
    Plug 'stephpy/vim-yaml'
    Plug 'rust-lang/rust.vim'
    Plug 'peitalin/vim-jsx-typescript'
    Plug 'HerringtonDarkholme/yats.vim' "Yet another typscript syntax
    Plug 'dag/vim-fish'
    Plug 'jparise/vim-graphql'

    "Version Control
    Plug 'tpope/vim-fugitive'

    "Directories and Projects
    Plug 'tpope/vim-projectionist'
    Plug 'scrooloose/nerdtree'

    "Productivity
    Plug 'SirVer/ultisnips'
    Plug 'xolox/vim-misc'

    "Commands / Quality of Life
    Plug 'tpope/vim-eunuch'
    Plug 'tpope/vim-dispatch'
    Plug 'radenling/vim-dispatch-neovim'
    Plug 'tpope/vim-dadbod'
    Plug 'tpope/vim-speeddating'
    Plug 'svermeulen/vim-subversive'
    Plug 'svermeulen/vim-yoink'
    Plug 'junegunn/vim-easy-align'
    Plug 'machakann/vim-sandwich'
    Plug 'tpope/vim-commentary'
    "Plug 'junegunn/fzf'
    "Plug 'junegunn/fzf.vim'
    Plug 'ibhagwan/fzf-lua'
    Plug 'vijaymarupudi/nvim-fzf'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'AndrewRadev/splitjoin.vim'

    " Text Objects
    Plug 'machakann/vim-textobj-delimited'
    Plug 'tpope/vim-jdaddy'

    "UI
    Plug 'itchyny/lightline.vim'
    Plug 'maximbaz/lightline-ale'

    " Work Related
    if empty($SPIN)
        Plug 'Shopify/shadowenv.vim'
        Plug 'Shopify/vim-devilish'
        Plug 'mrjones2014/dash.nvim', { 'do': 'make install' }
    endif
    Plug 'Shopify/vim-sorbet'
call plug#end()
