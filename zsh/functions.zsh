alias e=nvim

if [ -v SHOPIFY_LOCAL ]
then
    . ~/.zsh/shopify_local_functions.zsh
fi
if [ "$SPIN" ]; then
    . ~/.zsh/spin_functions.zsh
fi
