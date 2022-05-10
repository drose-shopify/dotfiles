set nocompatible
set hidden

if has('nvim')
    let $VIMHOME = expand('~/.local/share/nvim/')
else
    let $VIMHOME = expand('~/.vim/')
endif

call plug#begin($VIMHOME . 'plugged')

    Plug 'tpope/vim-sensible'


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
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'AndrewRadev/splitjoin.vim'

    " Text Objects
    Plug 'machakann/vim-textobj-delimited'
    Plug 'tpope/vim-jdaddy'
    Plug 'easymotion/vim-easymotion'


    " Does not work in VSCode

    if !exists('g:vscode')
        " Linters and Language Servers
        Plug 'neoclide/coc.nvim', {'branch': 'release'}
        Plug 'dense-analysis/ale'
        Plug 'ibhagwan/fzf-lua'
        Plug 'vijaymarupudi/nvim-fzf'

        " UI
        Plug 'itchyny/lightline.vim'
        Plug 'maximbaz/lightline-ale'

        " QoL
        Plug 'github/copilot.vim'

        "Directories and Projects
        Plug 'tpope/vim-projectionist'
        Plug 'scrooloose/nerdtree'

        "Version Control
        Plug 'tpope/vim-fugitive'
    endif

    " Work Related
    if empty($SPIN)
        Plug 'Shopify/shadowenv.vim'
        Plug 'Shopify/vim-devilish'
        Plug 'mrjones2014/dash.nvim', { 'do': 'make install' }
    endif
    Plug 'Shopify/vim-sorbet'
call plug#end()
