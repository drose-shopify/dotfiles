function ss -d "Spin shell [workspace]"
    set -l workspace (spin list -o name | fzf +m -1)
    spin shell $workspace
end
