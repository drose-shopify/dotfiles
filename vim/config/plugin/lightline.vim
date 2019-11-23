augroup lightline_config
    autocmd!
    let g:lightline#ale#indicator_checking = "\uf110 "
    let g:lightline#ale#indicator_warnings = "\uf071 "
    let g:lightline#ale#indicator_errors = "\uf05e "
    let g:lightline#ale#indicator_ok = "\uf00c "

    function! GitBranch()
        if !exists('b:git_dir')
            return ''
        endif
        " return "\ue0a0 %{fugitive#head()}"
        return "git:(%{fugitive#head()})"
    endfunction

    let g:lightline = {}
    let g:lightline.colorscheme = 'one'
    let g:lightline.component_expand = {
        \   'linter_checking': 'lightline#ale#checking',
        \   'linter_warnings': 'lightline#ale#warnings',
        \   'linter_errors': 'lightline#ale#errors',
        \   'linter_ok': 'lightline#ale#ok',
        \   'gitbranch': 'GitBranch'
        \ }
    let g:lightline.component_function = {
        \   'cocstatus': 'coc#status',
        \   'currentfunction': 'CocCurrentFunction',
        \ }
    let g:lightline.component_type = {
        \   'linter_checking': 'left',
        \   'linter_warnings': 'warning',
        \   'linter_errors': 'error',
        \   'linter_ok': 'left',
        \ }

    let g:lightline.active = {
        \   'left': [[ 'mode', 'paste' ],
        \           ['readonly', 'filename', 'modified','gitbranch'],
        \           ['cocstatus', 'currentfunction']],
        \   'right': [[ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ]]
        \ }

augroup END
