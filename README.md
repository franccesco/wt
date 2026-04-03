# wt

A fish shell plugin for managing git worktrees. Create, list, and remove worktrees with automatic environment setup via a per-repo `.wtrc` config file.

## Install

```fish
fisher install franccesco/wt
```

## Usage

```fish
wt new feature/auth        # create worktree, branching from HEAD
wt new fix/bug main        # create worktree, branching from main
wt ls                      # list worktrees (numbered)
wt rm 1                    # remove worktree by index
wt rm -f 1                 # force remove (discard uncommitted changes)
```

When inside tmux, `wt new` opens a new window in the worktree directory. Otherwise it `cd`s into it.

## Configuration

Drop a `.wtrc` file in your repo root to define what happens after creating a worktree:

```
# Initialize git submodules
submodule all               # all submodules
submodule lib/foo           # or specific ones by path

# Symlink files from the main worktree
link .envrc
link .mcp.json

# Run commands in the new worktree
run uv sync
run dbt deps
run direnv allow
```

**Directives:**

| Directive | Description |
|-----------|-------------|
| `submodule all` | Initialize all git submodules recursively |
| `submodule <path>` | Initialize a specific git submodule by path |
| `link <file>` | Symlink a file from the main worktree |
| `run <command>` | Run a shell command in the new worktree |

Lines starting with `#` are comments. Blank lines are ignored.

## Example

```
$ wt new feature/auth
Creating worktree at /home/user/myproject-feature-auth...
  Linked .envrc
  Linked .mcp.json
  Running: npm install
  Done: npm install
  Running: direnv allow
  Done: direnv allow

Worktree ready. Opened tmux window: feature-auth
```

```
$ wt ls
  1) feature/auth  (/home/user/myproject-feature-auth)
  2) fix/typo      (/home/user/myproject-fix-typo)
```

```
$ wt rm 1
Removed worktree: feature/auth
```

## License

MIT
