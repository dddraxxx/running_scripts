#!/usr/bin/env bash
# Open Codex's session picker in a new tmux window. Letting `codex fork --all`
# choose the source session is more stable than trying to infer it from tmux
# pane state or process argv.

set -euo pipefail

die() {
    local msg="$*"
    if [[ -n "${TMUX:-}" ]]; then
        tmux display-message "codex-fork: $msg"
    fi
    echo "codex-fork: $msg" >&2
    exit 1
}

pane_id="${1:-${TMUX_PANE:-}}"
[[ -n "$pane_id" ]] || die "no tmux pane (run inside tmux)"

pane_cwd=$(tmux display-message -t "$pane_id" -p '#{pane_current_path}')

codex_bin="/home/colligo/.nvm/versions/node/v24.14.1/bin/codex"
[[ -x "$codex_bin" ]] || codex_bin=$(command -v codex || true)
[[ -n "$codex_bin" ]] || die "codex binary not found"

window_name="cx:fork"
cmd="env PATH=/home/colligo/.nvm/versions/node/v24.14.1/bin:\$PATH '$codex_bin' fork --sandbox danger-full-access --ask-for-approval on-request --all"
msg="opened Codex fork picker"

tmux new-window -c "$pane_cwd" -n "$window_name" "$cmd"
tmux display-message "codex-fork: $msg"
