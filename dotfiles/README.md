# dotfiles

Personal config for tmux + the `prefix+F` Claude Code session-fork shortcut.

## Layout

```
dotfiles/
├── tmux/
│   ├── tmux.conf         # main config (mouse, scrollback, sources tmux.local.conf)
│   └── tmux.local.conf   # prefix+F binding + status-right tweak
├── bin/
│   └── claude-fork.sh    # invoked by prefix+F; forks the current pane's Claude session
└── install.sh            # symlinks the above into $HOME
```

## Install

```bash
git clone git@github.com:dddraxxx/running_scripts.git
cd running_scripts/dotfiles
./install.sh
```

`install.sh` symlinks:

- `tmux/tmux.conf`       -> `~/.tmux.conf`
- `tmux/tmux.local.conf` -> `~/.tmux.local.conf`
- `bin/claude-fork.sh`   -> `~/.local/bin/claude-fork.sh`

Existing files are backed up to `<file>.bak.<timestamp>` before being replaced.

Make sure `~/.local/bin` is on your `PATH`.

## Usage

Inside any tmux pane running `claude`, press **`prefix` + `F`**. A new tmux
window opens with `claude --resume <id> --fork-session`, leaving the original
session untouched.
