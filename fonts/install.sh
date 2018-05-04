#!/bin/bash

# Set source and target directories

firacode_fonts_dir="$( cd "$( dirname "$0" )" && pwd )/FiraCode"

find_command="find \"$firacode_fonts_dir\" \( -name '*.[o,t]tf' -or -name '*.pcf.gz' \) -type f -print0"

if [[ $(uname) == 'Darwin' ]]; then
    #Mac OS
    font_dir="$HOME/Library/Fonts"
else
    #Linux
    font_dir="$HOME/.fonts"
    mkdir -p "$font_dir"
fi

echo "Copying fonts.."
eval "$find_command" | xargs -0 -I % cp "%" "$font_dir/"

#Reset font cache on linux
if command -v fc-cache @>/dev/null ; then
    echo "Resetting font cache, this may take a moment..."
    fc-cache -f "$font_dir"
fi

if command -v brew @>/dev/null ; then
    #Install fonts using HomeBrew - MacOS
    brew tap caskroom/fonts
    brew cask install font-firacode-nerd-font-mono
    brew cask install font-firacode-nerd-font
fi
