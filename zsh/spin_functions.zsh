alias g='git'
alias e='nvim'

sys() {

preview_service() {
    awk '{print $1}' | fzf --multi --ansi --preview="SYSTEMD_COLORS=1 systemctl $1 -n 30 status --no-pager {}"
}

list_units() {
    systemctl list-unit --no-legend
}

show() {
    list_units | preview_service
}

status() {
    list_units \
        | awk '{print $1}' \
        | fzf --ansi --preview="SYSTEMD_COLORS=1 systemctl $1 -n 30 status --no-pager {}" \
        | if read -r unit && [ "$unit" ]; then
            systemctl status "$unit" --no-pager
          fi
}

stop() {
    list_units \
        | preview_service \
        | while read -r unit && [ "$unit" ]; do
            if systemctl stop "$unit"; then
                systemctl -n20 status "$unit" --no-pager
            fi
          done
}

restart() {
}



while :; do
    case $1 in
        show)
            show
            break;;
        status)
            status
            break;;
    esac
    shift
done
}
