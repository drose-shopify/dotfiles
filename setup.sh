#!/bin/bash
#if ! command -v pip3 &> /dev/null; then
#    sudo apt-get install -y python3-pip
#fi
#
#if ! command -v rg &> /dev/null; then
#  sudo apt-get install -y ripgrep
#fi
#
#if ! command -v fd &> /dev/null; then
#  sudo apt-get install -y fd
#fi
#
#if ! command -v fzf &> /dev/null; then
#    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
#    "$HOME"/.fzf/install --all
#fi
#if ! command -v nvim &> /dev/null; then
#    sudo apt-get install -y python3-neovim
#    pip3 install --user neovim
#fi
#
## Setup nvim
#git clone https://github.com/junegunn/vim-plug.git "$HOME/vim-plug"
#mkdir -p $HOME/.local/share/nvim/site/autoload
#cp ~/vim-plug/plug.vim $HOME/.local/share/nvim/site/autoload
#
#sudo apt-get install -y powerline fonts-powerline
#git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
#
## Link dotfiles
#set -e
#CONFIG=".spin_install.conf.yaml"
#DOTBOT_DIR="dotbot"
#
#DOTBOT_BIN="bin/dotbot"
#git submodule update --init --recursive "${DOTBOT_DIR}"
#"${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" "${@}"
