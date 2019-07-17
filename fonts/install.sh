#!/bin/bash

if command -v brew @>/dev/null ; then
    #Install fonts using HomeBrew - MacOS
    brew tap homebrew/cask-fonts
    brew cask install font-firacode-nerd-font-mono
    brew cask install font-firacode-nerd-font
    brew cask install font-fira-code
    brew cask install font-xkcd-script
    brew cask install font-xkcd
fi
