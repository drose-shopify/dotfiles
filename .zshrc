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
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node
### end zinit

# plugins
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure

zinit wait lucid for \
    OMZ::lib/git.zsh \
    OMZ::plugins/git/git.plugin.zsh \
    zdharma/fast-syntax-highlightingc
