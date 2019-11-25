nnoremap <C-p> :Files<Cr>
nmap <F3> i<C-R>=strftime("%Y-%m-%d %T")<CR><Esc>
imap <F3> <C-R>=strtime("%Y-%m-%d %T")<CR>
nmap <F4> i<C-R>=strftime("%Y-%m-%d")<CR><Esc>
imap <F4> <C-R>=strtime("%Y-%m-%d")<CR>



" Vim-Workspace
" nnoremap <leader>w :ToggleWorkspace<CR>

" CtrlSPace
let g:CtrlSpaceDefaultMappingKey = "<C-space> "


augroup general_config
    autocmd!
" Better split switching (Ctrl-j, Ctrl-k, Ctrl-h, Ctrl-l) {{{
    tnoremap <C-h> <C-\><C-n><C-w>h
    tnoremap <C-j> <C-\><C-n><C-w>j
    tnoremap <C-k> <C-\><C-n><C-w>k
    tnoremap <C-l> <C-\><C-n><C-w>l
    nnoremap <C-j> <C-W>j
    nnoremap <C-k> <C-W>k
    nnoremap <C-h> <C-W>h
    nnoremap <C-l> <C-W>l
" }}}

" Yank from cursor to end of line {{{
  nnoremap Y y$
" }}}

" Directory / Editing {{{
    "create file from directory of current buffer
    nnoremap <leader>ef :e %:h/
" }}}

augroup END
