nn <leader>pf :GFiles<cr>
nn <leader>pg :GFiles?<cr>
nn <leader>pc :BCommits<cr>
nn <leader>pl :BLines<cr>
nn <leader>pm :Marks<cr>
nn <leader>ps :Snippets<cr>
nn <leader>hr :History<cr>
nn <leader>hc :History:<cr>
nn <leader>hs :History/<cr>
nn <leader>bb :Buffers<cr>
nn <leader>ww :Windows<cr>


" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)
