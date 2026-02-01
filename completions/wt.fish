complete -c wt -f
complete -c wt -n "__fish_use_subcommand" -a new -d "Create a worktree"
complete -c wt -n "__fish_use_subcommand" -a ls -d "List worktrees"
complete -c wt -n "__fish_use_subcommand" -a rm -d "Remove a worktree"
complete -c wt -n "__fish_seen_subcommand_from rm" -s f -l force -d "Force remove with uncommitted changes"
