" Plugin Management setup
set nocompatible
filetype off
if has('nvim')
  set rtp+=~/.config/nvim/bundle/Vundle.vim
  call vundle#begin('~/.config/nvim/bundle')
else
  set rtp+=~/.vim/bundle/Vundle.vim
  call vundle#begin()
endif

Plugin 'VundleVim/Vundle.vim'

"Install plugins
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-rake'
Plugin 'tpope/vim-projectionist'
Plugin 'stephpy/vim-yaml'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'rust-lang/rust.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'ludovicchabant/vim-gutentags'

if has('nvim')
  Plugin 'autozimu/LanguageClient-neovim'
  Plugin 'Shougo/deoplete.nvim'
endif

call vundle#end()
"Plugin Management end

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

"Keymaps
nnoremap <C-p> :Files<Cr>

"Plugin Overrides
if executable('rg')
    let g:ctrlp_user_command = 'rg %s --files --no-ignore-vcs --hidden --color=never'
    let g:ctrlp_use_caching = 0
else
    let g:ctrlp_clear_cache_on_exit = 0
endif

set statusline+=%{gutentags#statusline()}

"NERD Tree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
map <C-n> :NERDTreeToggle<CR>


"Language Server
if has('nvim')
  let g:deoplete#enable_at_startup = 1
  let g:LanguageClient_serverCommands = {
      \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
      \ 'javascript': ['tsserver'],
      \ 'typescript': ['tsserver'],
      \ 'ruby': ['solargraph', 'stdio'],
      \ 'eruby': ['solargraph', 'stdio'],
      \ 'go': [
      \   'bingo',
      \   '--mode',
      \   'stdio',
      \   '--logfile',
      \   '/tmp/lspserver.log',
      \   '--trace',
      \   '--pprof', ':6060'
      \   ],
      \ }

  let g:LanguageClient_autoStop = 0
  autocmd FileType ruby setlocal omnifunc=LanguageClient#complete

  nnoremap <F5> :call LanguageClient_contextMenu()<CR>
endif
