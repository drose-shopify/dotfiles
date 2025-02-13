autoload -U compinit
compinit

if [ -f /opt/dev/dev.sh ]
then
    export SHOPIFY_LOCAL=1
    source /opt/dev/dev.sh
fi

if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]
then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

. ~/.zsh/functions.zsh

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
fpath=(/usr/local/share/zsh-completions $fpath)

unsetopt LIST_BEEP

export CLICOLOR=1
alias ls='ls -G'
setopt auto_cd

zstyle ':prompt:pure:prompt:success' color green

### begin zinit
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && ommand chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light-mode for \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node
### end zinit

# plugins
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure

zinit wait lucid for \
    OMZ::lib/git.zsh \
    OMZ::plugins/git/git.plugin.zsh \
    zdharma-continuum/fast-syntax-highlighting

[[ -f /opt/dev/sh/chruby/chruby.sh ]] && type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; }
if [ -e /Users/davidrose/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/justincarvalho/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
[[ -x /usr/local/bin/brew ]] && eval $(/usr/local/bin/brew shellenv)

[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
source "$HOME/.cargo/env"
export KUBECONFIG=${KUBECONFIG:+$KUBECONFIG:}/Users/daverose/.kube/config:/Users/daverose/.kube/config.shopify.cloudplatform
export EDITOR='nvim'
for file in /Users/daverose/src/github.com/Shopify/cloudplatform/workflow-utils/*.bash; do source ${file}; done

export PATH="$HOME/.rbenv/shims:$HOME/.pyenv/shims:/opt/homebrew/opt/qt@5/bin:$PATH"

kubectl-short-aliases
