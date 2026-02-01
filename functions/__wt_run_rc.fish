function __wt_run_rc --argument-names main_dir worktree_dir
    set -l rc "$main_dir/.wtrc"
    if not test -f "$rc"
        return 0
    end

    pushd $worktree_dir
    while read -l line
        set line (string trim $line)
        # Skip empty lines and comments
        if test -z "$line"; or string match -q '#*' $line
            continue
        end

        set -l directive (string split -m 1 ' ' $line)
        set -l action $directive[1]
        set -l value $directive[2]

        switch $action
            case link
                if test -e "$main_dir/$value"
                    ln -sf "$main_dir/$value" "$worktree_dir/$value"
                    echo "  Linked $value"
                else
                    echo "  Warning: $value not found in main worktree"
                end
            case run
                echo "  Running: $value"
                eval $value 2>/dev/null
                if test $status -eq 0
                    echo "  Done: $value"
                else
                    echo "  Failed: $value"
                end
        end
    end <$rc
    popd
end
