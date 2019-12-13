let NERDTreeShowHidden=1
augroup nerdtree_config
    autocmd!
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimLeave * NERDTreeClose
    autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

    let g:NERDTreeShowBookmarks=1
    let g:NERDTreeChDirMode=2
    let g:NERDTreeAutoDeleteBuffer=1
    let g:NERDTreeMinimalUI=1
    let g:NERDTreeHijackNetrw = 0

    map <C-n> :NERDTreeToggle<CR>
    nmap <leader>nf :NERDTreeFind<CR>
    map <leader>nb :NERDTreeFromBookmark<Space>
augroup END
