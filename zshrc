# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

source $ZSH/plugins_before.zsh

#source $ZSH/settings.zsh

source ~/.shell/bootstrap.sh
#source ~/.shell/external.sh
#source ~/.shell/aliases.sh

plugins=(
  git
  rails
  ruby
  brew
  bundler
  gem
  node
  golang
  shopify_dev
  zsh-completions
)

autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh
source $ZSH/plugins_after.zsh

[ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh