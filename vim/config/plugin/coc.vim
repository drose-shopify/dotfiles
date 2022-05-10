if exists('g:vscode')
    finish
endif

augroup coc_config
    if empty($SPIN)
        let g:coc_node_path = '/opt/homebrew/bin/node'
    else
        let g:coc_node_path = '/usr/local/bin/node'
    endif

    function! CocCurrentFunction()
        return get(b:, 'coc_current_function', '')
    endfunction

    " Remap keys for gotos
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)
    " Remap for rename current word
    nmap <leader>rn <Plug>(coc-rename)
    " Find symbol in current file
    " nmap <silent> <leader>s :<C-u>CocList outline<cr>
    " Find symbol in current workspace
    nmap <silent> <leader>S :<C-u>CocList -I symbols<cr>
    nmap <silent> <leader>cw :call coc#float#close_all() <cr>

    " Use tab for trigger completion with characters ahead and navigate.
    " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
    inoremap <silent><expr> <TAB>
          \ pumvisible() ? "\<C-n>" :
          \ <SID>check_back_space() ? "\<TAB>" :
          \ coc#refresh()
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
    inoremap <silent><expr> <c-space> coc#refresh()
    inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() :
                                           \"\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

    " Use K to show documentation in preview window
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    function! s:check_back_space() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    function! s:show_documentation()
      if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
      else
        call CocActionAsync('doHover')
      endif
    endfunction


    "inoremap <silent><expr> <TAB>
    "  \ pumvisible() ? coc#_select_confirm() :
    "  \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
    "  \ <SID>check_back_space() ? "\<TAB>" :
    "  \ coc#refresh()

    function! s:check_back_space() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    "let g:coc_snippet_next = '<tab>'
augroup END
