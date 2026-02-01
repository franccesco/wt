function __wt_list
    set -l main (__wt_main_dir)
    set -l worktrees (git worktree list --porcelain)
    set -g __wt_main $main
    set -g __wt_dirs
    set -g __wt_branches

    set -l current_dir ""
    for line in $worktrees
        if string match -q "worktree *" $line
            set current_dir (string replace "worktree " "" $line)
        else if string match -q "branch *" $line
            if test "$current_dir" = "$main"
                set current_dir ""
                continue
            end
            set -l branch (string replace "refs/heads/" "" (string replace "branch " "" $line))
            set -a __wt_dirs $current_dir
            set -a __wt_branches $branch
            set current_dir ""
        end
    end
end
