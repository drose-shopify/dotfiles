augroup ale_config
    autocmd!
    nnoremap <leader>af <Plug>(ale_fix)
    nnoremap <leader>al <Plug>(ale_lint)

    let g:ale_lint_on_text_changed = 'never'
    let g:ale_lint_on_enter = 0
    let g:ale_lint_on_insert_leave = 0
    let g:ale_lint_on_filetype_changed = 0
    let g:ale_lint_on_save = 1
    let g:ale_fix_on_save = 1
    let g:ale_lint_delay = 1000
    let g:ale_sign_error = '>>'

    let g:ale_use_global_executables = 1

    let g:ale_linters = {}
    let g:ale_fixers = {}

    " Other
    let g:ale_fixers['*'] = ['remove_trailing_lines', 'trim_whitespace']
    let g:ale_fixers.yaml = ['prettier', 'remove_trailing_lines', 'trim_whitespace']

    " Ruby
        let g:ale_ruby_sorbet_executable = 'bundle'
        let g:ale_ruby_sorbet_options = '--enable-all-experimental-lsp-features'
        let g:ale_ruby_rubocop_executable = 'bundle'

        let g:ale_fixers.ruby = ['rubocop', 'remove_trailing_lines', 'trim_whitespace']
        let g:ale_linters.ruby = ['rubocop', 'sorbet']

    " Javascript / Typescript
        let g:ale_linters.javascript = [
          \ 'tsserver'
          \ ]

        let g:ale_linters.typescript = [
          \ 'tslint',
          \ 'tsserver',
          \ 'typecheck'
          \ ]

        let g:ale_fixers.javascript = [
          \ 'prettier',
          \ 'eslint',
          \ ]

        let g:ale_fixers.typescript = [
          \ 'prettier',
          \ 'tslint',
          \ ]

        let g:ale_fixers['typescript.tsx'] = [
            \ 'prettier',
            \ 'tslint',
            \ ]
        let g:ale_linters['typescript.tsx'] = [
                    \ 'tslint',
                    \ 'tsserver',
                    \ 'typecheck'
                    \ ]

        let g:ale_json_jq_options = '-S'

        let g:ale_fixers.json = [
          \ 'jq',
          \ 'remove_trailing_lines',
          \ 'trim_whitespace'
          \ ]

    " Golang
    let g:ale_fixers.go = [
          \ 'gofmt',
          \ 'goimports',
          \ ]

    " HTML
    let g:ale_fixers.html = [
          \ 'prettier',
          \ 'tidy',
          \ ]
augroup END
