# dotfiles

Personal config for tmux, including the `prefix+F` Claude Code session-fork
shortcut and the `prefix+G` Codex fork picker.

## Layout

```
dotfiles/
├── tmux/
│   ├── tmux.conf         # main config (mouse, scrollback, sources tmux.local.conf)
│   └── tmux.local.conf   # prefix+F/prefix+G bindings + status-right tweak
├── bin/
│   ├── claude-fork.sh    # invoked by prefix+F; forks the current pane's Claude session
│   └── codex-fork.sh     # invoked by prefix+G; opens Codex's all-session fork picker
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
- `bin/codex-fork.sh`    -> `~/.local/bin/codex-fork.sh`

Existing files are backed up to `<file>.bak.<timestamp>` before being replaced.

Make sure `~/.local/bin` is on your `PATH`.

## Usage

Inside any tmux pane running `claude`, press **`prefix` + `F`**. A new tmux
window opens with `claude --resume <id> --fork-session`, leaving the original
session untouched.

Inside tmux, press **`prefix` + `G`** to open a new window running
`codex fork --all` with full-access sandboxing and on-request approvals. Codex
shows the all-session picker so you can choose the source session manually.
