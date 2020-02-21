if executable('rg')
    let g:ctrlp_user_command = 'rg %s --files --hidden --color=never --ignore-case'
    let g:ctrlp_use_caching = 0
else
    let g:ctrlp_clear_cache_on_exit = 0
endif

nnoremap <C-F> :Rg!<space>
nnoremap <leader>f :Rg! <Up><CR>
nnoremap <leader>// :Rg<space>
"nnoremap <expr> <leader>/w ':Rg ' . expand('<cword>') . '<cr>'

nnoremap <leader>/ :set operatorfunc=<SID>RgOperator<cr>g@
vnoremap <leader>/ :<c-u>call <SID>RgOperator(visualmode())<cr>

function! s:RgOperator(type)
    let saved_unnamed_register = @@

    if a:type ==# 'v'
        normal! `<v`>y
    elseif a:type ==# 'char'
        normal! `[v`]y
    else
        return
    endif

    silent exec ":Rg " . @@

    let @@ = saved_unnamed_register
endfunction
