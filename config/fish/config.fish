set fish_greeting

set -x EDITOR nvim
set -x FZF_LEGACY_KEYBINDINGS 0
set -x FZF_DEFAULT_COMMAND 'rg --files --ignore-vcs --hidden'
set -x FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -x GPG_TTY (tty)
set -x GREP_COLOR "1;37;45"
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8
set -x LSCOLORS "Hx"

fish_vi_key_bindings
set -g __fish_vi_mode 1

# Paths
test -d /usr/local/share ; and set PATH /usr/local/share $PATH
test -d $HOME/go ; and set GOPATH $HOME/go
test -d /usr/local/sbin ; and set PATH /usr/local/sbin $PATH

if test -f /opt/dev/dev.fish
  source /opt/dev/dev.fish
end

# Aliases

function g; git $argv; end
function d; dev $argv; end
function e; nvim $argv; end
function b; bundle exec $argv; end

# Shopify Aliases
function dcd; dev cd $argv; end
function ddu; dev down && dev up; end
function dr; dev reset-railgun; end
function pr; dev open pr; end
function dfmt; dev style --include-branch-commits; end
function gen_rate_job
    set -l date (date +'%Y%m%d')
    bin/rails generate maintenance_task:migration UsaTaxRateImportJobDelta$date
end
function mypr
    set -l selected_pr (gh pr list --assignee 'drose-shopify' | fzf)
    set -l pr_number (echo $selected_pr | rg -o '^\d+')
    set -l pr_branch (echo $selected_pr | rg -o '[^\s]+$')
    echo "Switching to $pr_branch"
    gh pr checkout $pr_number
end

# Completions
function make_completion --argument-names alias command
    echo "
    function __alias_completion_$alias
        set -l cmd (commandline -o)
        set -e cmd[1]
        complete -C\"$command \$cmd\"
    end
    " | source
    complete -c $alias -a "(__alias_completion_$alias)"
end

make_completion g 'git'
make_completion d 'dev'
make_completion e 'nvim'
make_completion b 'bundle exec'
make_completion dcd 'dev cd'

# iterm2
test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish
