alias g='git'
alias e='nvim'
alias bat='batcat'


restart() {
    ls ~/src/github.com/Shopify | fzf --multi | while read line; do
      systemctl list-units --all | rg proc-shopify--$line | awk '{print $1}' | xargs  systemctl restart
    done
}

status() {
    ls ~/src/github.com/Shopify | fzf --multi | while read line; do
      systemctl list-units --all | rg proc-shopify--$line | awk '{print $1}' | xargs  systemctl restart
    done
}

stop() {
    ls ~/src/github.com/Shopify | fzf --multi | while read line; do
      systemctl list-units --all | rg proc-shopify--$line | awk '{print $1}' | xargs  systemctl restart
    done
}
