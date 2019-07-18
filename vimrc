" Plugin Management setup
set nocompatible
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
    Plug 'ludovicchabant/vim-gutentags'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()
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
    " Remap keys for gotos
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)
    " Remap for rename current word
    nmap <leader>rn <Plug>(coc-rename)

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


"CoC Language Client Settings
    set nobackup
    set nowritebackup
    set cmdheight=2

    " Use tab for trigger completion with characters ahead and navigate.
    " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
    inoremap <silent><expr> <TAB>
          \ pumvisible() ? "\<C-n>" :
          \ <SID>check_back_space() ? "\<TAB>" :
          \ coc#refresh()
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

    function! s:check_back_space() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    " Use K to show documentation in preview window
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    function! s:show_documentation()
      if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
      else
        call CocAction('doHover')
      endif
    endfunction
