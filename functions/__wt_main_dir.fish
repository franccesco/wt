function __wt_main_dir
    git worktree list --porcelain | head -1 | string replace "worktree " ""
end
