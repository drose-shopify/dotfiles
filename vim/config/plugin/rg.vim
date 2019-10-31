if executable('rg')
    let g:ctrlp_user_command = 'rg %s --files --hidden --color=never --ignore-case'
    let g:ctrlp_use_caching = 0
else
    let g:ctrlp_clear_cache_on_exit = 0
endif
