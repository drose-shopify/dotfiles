if exists('g:vscode')
    finish
endif

" Select all results with <C-a>
augroup update_bat_theme
    autocmd!
    autocmd colorscheme * call ToggleBatEnvVar()
augroup end
function ToggleBatEnvVar()
   let $BAT_THEME='Monokai Extended'
endfunction

lua <<EOF
local batcmd = 'bat'
if vim.env.SPIN then
    batcmd = 'batcat'
end

require('nvim-web-devicons').setup {
    default = true;
}

local actions = require("fzf-lua.actions")
require('fzf-lua').setup {
    winopts = {
        preview = {
            default = 'bat'
        }
    },
    files = {
        fd_opts = [[--color never --type f --hidden --follow --exclude .git --exclude node_modules --exclude '*.rbi']],
        git_icons = false,
        file_icons = true
    },
    previewers = {
        bat = {
            cmd = batcmd
        }
    },
    grep = {
        input_prompt = 'Rg> ',
        rg_opts = [[--column --line-number --no-heading --color=always --ignore-case --max-columns=512]],
        no_esc=true,
        file_icons = true,
        git_icons = false,
    }
}
EOF

if empty($SPIN)
lua << EOF
    require('dash').setup({
        dash_app_path = '/Applications/Dash.app',
        debounce = 0,
        file_type_keywords = {
            ruby = { 'ruby', 'rails', 'rubygems' }
        }
    })
EOF
endif

nnoremap <C-F> :lua require('fzf-lua').grep({ winopts = { split = "belowright new" } })<Cr>
"nnoremap <C-F> :lua require('fzf-lua').live_grep_glob({ winopts = { split = "belowright new" } })<Cr>
nnoremap <C-p> :lua require('fzf-lua').files()<Cr>
"nnoremap <leader>f :Rg! <Up><CR>
"nnoremap <leader>// :Rg<space>


"let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'
"
"
"let g:fzf_layout = { 'down': '40%' }
"
"nn <leader>pf :GFiles<cr>
"nn <leader>pg :GFiles?<cr>
"nn <leader>pc :BCommits<cr>
"nn <leader>pl :BLines<cr>
"nn <leader>pm :Marks<cr>
"nn <leader>ps :Snippets<cr>
"nn <leader>hr :History<cr>
"nn <leader>hc :History:<cr>
"nn <leader>hs :History/<cr>
"nn <leader>bb :Buffers<cr>
"nn <leader>ww :Windows<cr>
"
"
"" Insert mode completion
"imap <c-x><c-k> <plug>(fzf-complete-word)
"imap <c-x><c-f> <plug>(fzf-complete-path)
"imap <c-x><c-j> <plug>(fzf-complete-file-ag)
"imap <c-x><c-l> <plug>(fzf-complete-line)
"
"" Send FZF results to the quickfix list
"function! s:build_quickfix_list(lines)
"  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
"  copen
"  cc
"endfunction
"
"let g:fzf_action = {
"  \ 'ctrl-q': function('s:build_quickfix_list'),
"  \ 'ctrl-t': 'tab split',
"  \ 'ctrl-x': 'split',
"  \ 'ctrl-v': 'vsplit' }
"
"command! -bang -nargs=* -complete=dir Rg call Rg(<q-args>)
"
"command! -bang -nargs=* Rg
"  \ call fzf#vim#grep(
"  \   'rg --column --line-number --no-heading --color=always --ignore-case '.shellescape(<q-args>), 1,
"  \   <bang>0 ? fzf#vim#with_preview({'up': '60%'})
"  \           : fzf#vim#with_preview('right50%:hidden', '?'),
"  \   <bang>0
"  \ )
"
""****************************************
"" Floating Windows
""****************************************
"function! FloatingFZF()
"  let buf = nvim_create_buf(v:false, v:true)
"  call setbufvar(buf, '&signcolumn', 'no')
"  let height = float2nr(&lines * 0.5)
"  let width = float2nr(&columns * 0.8)
"  let horizontal = float2nr((&columns - width) / 2)
"  let vertical = 10
"  let opts = {
"        \ 'relative': 'editor',
"        \ 'row': vertical,
"        \ 'col': horizontal,
"        \ 'width': width,
"        \ 'height': height,
"        \ 'style': 'minimal'
"        \ }
"
"  call nvim_open_win(buf, v:true, opts)
"endfunction
"
" let g:fzf_layout = { 'window': 'call FloatingFZF()' }
