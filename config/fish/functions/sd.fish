function sd -d "Spin deleta [workspace,...]"
    set -l workspaces (spin list -o name | fzf -m -1)
    for workspace in $workspaces
        spin destroy $workspace
    end
end
