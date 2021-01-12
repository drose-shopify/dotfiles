#!/bin/bash

if command -v brew @>/dev/null ; then
    #Install fonts using HomeBrew - MacOS
    brew tap homebrew/cask-fonts
    brew install --cask font-firacode-nerd-font-mono
    brew install --cask font-firacode-nerd-font
    brew install --cask font-fira-code
    brew install --cask font-xkcd-script
    brew install --cask font-xkcd
fi
