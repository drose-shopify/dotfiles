# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
export DISABLE_UNTRACKED_FILES_DIRTY="true"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

alias e='nvim'
alias g='git'
source ~/.shell/bootstrap.sh
#source ~/.shell/external.sh
source ~/.shell/aliases.sh

plugins=(
  git
  ruby
  brew
  bundler
  gem
  node
  golang
  zsh-completions
  zsh-syntax-highlighting
  zsh_reload
  misc
  vi-mode
)

autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh

if [ !$SPIN ]; then
    [ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh
    export GOPATH=$HOME/go
fi

export EJSON_KEYDIR=$HOME/.ejson/keys
export PATH="/usr/local/share:$PATH"
export FZF_DEFAULT_COMMAND='rg --files --ignore-vcs --hidden'
export KEYTIMEOUT=1

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[[ -f /opt/dev/sh/chruby/chruby.sh ]] && type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; }
