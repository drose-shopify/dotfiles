#!/bin/bash

if ! command -v pip3 &> /dev/null; then
    sudo apt-get install -y python3
fi

if ! command -v rg &> /dev/null; then
  sudo apt-get install -y ripgrep
fi

if ! command -v fd &> /dev/null; then
  sudo apt-get install -y fd
fi

if ! command -v fzf &> /dev/null; then
    sudo apt-get install -y fzf
fi
if ! command -v nvim &> /dev/null; then
    sudo apt-get install -y python3-neovim
    pip3 install --user neovim
fi

sudo apt-get install -y powerline fonts-powerline
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

# Link dotfiles
set -e
CONFIG=".install.conf.yaml"
DOTBOT_DIR="dotbot"

DOTBOT_BIN="bin/dotbot"
#BASEDIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)/.."

#cd "${BASEDIR}"
git submodule update --init --recursive "${DOTBOT_DIR}"
"${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" "${@}"

# Setup nvim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

nvim +PlugInstall +qall
nvim +PlugUpdate +qall
nvim -c 'CocInstall -sync coc-solargraph coc-json coc-rls coc-tsserver coc-yaml coc-highlight coc-lists coc-eslint|q'
nvim -c 'CocUpdateSync|q'
