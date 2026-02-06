function wt
    set -l cmd $argv[1]

    switch "$cmd"
        case new
            set -l branch_name $argv[2]
            set -l base_branch $argv[3]

            if test -z "$branch_name"
                echo "Usage: wt new <branch-name> [base-branch]"
                return 1
            end

            set -l main (__wt_main_dir)
            set -l repo_name (basename $main)
            set -l parent_dir (dirname $main)
            set -l safe_name (string replace -a '/' '-' $branch_name)
            set -l worktree_dir "$parent_dir/$repo_name-$safe_name"

            echo "Creating worktree at $worktree_dir..."

            if test -n "$base_branch"
                git worktree add -b $branch_name $worktree_dir $base_branch
            else
                git worktree add -b $branch_name $worktree_dir
            end

            if test $status -ne 0
                echo "Failed to create worktree."
                return 1
            end

            __wt_run_rc $main $worktree_dir

            echo ""
            if set -q TMUX
                tmux new-window -c $worktree_dir -n $safe_name
                echo "Worktree ready. Opened tmux window: $safe_name"
            else
                cd $worktree_dir
                echo "Worktree ready. Now in $worktree_dir"
            end

        case ls ""
            __wt_list

            if test (count $__wt_dirs) -eq 0
                echo "No worktrees (besides main)."
                return 0
            end

            for i in (seq (count $__wt_dirs))
                echo "  $i) $__wt_branches[$i]  ($__wt_dirs[$i])"
            end

        case rm
            set -l force 0
            set -l all 0
            set -l idx ""

            for arg in $argv[2..]
                switch $arg
                    case --force -f
                        set force 1
                    case --all -a
                        set all 1
                    case '*'
                        set idx $arg
                end
            end

            if test $all -eq 1
                __wt_list

                if test (count $__wt_dirs) -eq 0
                    echo "No worktrees to remove."
                    return 0
                end

                if test $force -eq 0
                    echo "This will remove the following worktrees:"
                    for i in (seq (count $__wt_dirs))
                        echo "  $i) $__wt_branches[$i]  ($__wt_dirs[$i])"
                    end
                    read -P "Continue? [y/N] " confirm
                    if not string match -qi "y" "$confirm"
                        echo "Aborted."
                        return 1
                    end
                end

                set -l orig_dir (pwd)
                set -l was_inside 0
                for dir in $__wt_dirs
                    if string match -q "$dir*" (pwd)
                        set was_inside 1
                        cd $__wt_main
                        break
                    end
                end

                set -l failed 0
                for i in (seq (count $__wt_dirs) -1 1)
                    set -l dir $__wt_dirs[$i]
                    set -l branch $__wt_branches[$i]

                    if test $force -eq 1
                        git -C $__wt_main worktree remove --force $dir
                    else
                        git -C $__wt_main worktree remove $dir
                    end

                    if test $status -ne 0
                        echo "Failed to remove worktree: $branch ($dir)"
                        set failed (math $failed + 1)
                        continue
                    end

                    if test $force -eq 1
                        git -C $__wt_main branch -D $branch 2>/dev/null
                    else
                        git -C $__wt_main branch -d $branch 2>/dev/null
                    end

                    echo "Removed worktree: $branch"
                end

                if test $failed -gt 0
                    echo "$failed worktree(s) failed to remove."
                    if test $was_inside -eq 1
                        cd $orig_dir
                    end
                    return 1
                end

                return 0
            end

            if test -z "$idx"
                echo "Usage: wt rm [--force] <number>"
                echo ""
                wt ls
                return 1
            end

            __wt_list

            if test $idx -lt 1 -o $idx -gt (count $__wt_dirs)
                echo "Invalid index. Run 'wt ls' to see worktrees."
                return 1
            end

            set -l dir $__wt_dirs[$idx]
            set -l branch $__wt_branches[$idx]

            set -l was_inside 0
            set -l orig_dir (pwd)
            if string match -q "$dir*" (pwd)
                set was_inside 1
                cd $__wt_main
            end

            if test $force -eq 1
                git -C $__wt_main worktree remove --force $dir
            else
                git -C $__wt_main worktree remove $dir
            end

            if test $status -ne 0
                if test $was_inside -eq 1
                    cd $orig_dir
                end
                return 1
            end

            if test $force -eq 1
                git -C $__wt_main branch -D $branch 2>/dev/null
            else
                git -C $__wt_main branch -d $branch 2>/dev/null
            end

            echo "Removed worktree: $branch"

        case '*'
            echo "Usage: wt <command>"
            echo ""
            echo "Commands:"
            echo "  new <branch> [base]       Create a worktree"
            echo "  ls                        List worktrees"
            echo "  rm [--force] <number>     Remove a worktree by index"
            echo "  rm --all [--force]        Remove all worktrees"
    end
end
