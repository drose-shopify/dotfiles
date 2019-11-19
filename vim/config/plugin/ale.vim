nmap <leader>af <Plug>(ale_fix)
nmap <leader>al <Plug>(ale_lint)

let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0
let g:ale_lint_on_save = 1
let g:ale_lint_delay = 1000
let g:ale_sign_error = '>>'

let g:ruby_sorbet_executable = '/opt/dev/bin/shim bundle exec srb'
let g:ruby_sorbet_options = '--enable-all-experimental-lsp-features'
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\    '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'typescript': ['prettier', 'eslint'],
\   'typescript.tsx': ['prettier', 'eslint'],
\   'ruby': ['rubocop'],
\   'yaml': ['prettier']
\}
