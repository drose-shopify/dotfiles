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

nnoremap <C-F> :lua require('fzf-lua').grep({ winopts = { split = "belowright new" } })<Cr>
nnoremap <C-p> :lua require('fzf-lua').files()<Cr>
