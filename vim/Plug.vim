set nocompatible
set hidden

if has('nvim')
  call plug#begin('~/.local/share/nvim/plugged')
else
  call plug#begin('~/.vim/plugged')
endif

    "Install plugins
    Plug 'tpope/vim-sensible'
    Plug 'tpope/vim-fugitive'
    Plug 'vim-ruby/vim-ruby'
    Plug 'tpope/vim-rails'
    Plug 'tpope/vim-rake'
    Plug 'tpope/vim-projectionist'
    Plug 'stephpy/vim-yaml'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'rust-lang/rust.vim'
    Plug 'scrooloose/nerdtree'
    Plug 'christoomey/vim-tmux-navigator'
    " Plug 'ludovicchabant/vim-gutentags'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'tpope/vim-surround'
    Plug 'peitalin/vim-jsx-typescript'
    Plug 'HerringtonDarkholme/yats.vim'
    Plug 'SirVer/ultisnips'
    Plug 'tpope/vim-eunuch'
    Plug 'xolox/vim-misc'
    Plug 'xolox/vim-notes'
    Plug 'tpope/vim-dispatch'
    Plug 'radenling/vim-dispatch-neovim'
    Plug 'tpope/vim-dadbod'
    Plug 'tpope/vim-jdaddy'
    Plug 'tpope/vim-speeddating'
    Plug 'svermeulen/vim-subversive'
    Plug 'svermeulen/vim-yoink'
    Plug 'dense-analysis/ale'
    Plug 'dag/vim-fish'

call plug#end()
