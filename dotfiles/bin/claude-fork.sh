#!/usr/bin/env bash
# Fork the Claude Code session running in the current tmux pane into a new
# tmux window. Uses Claude's native `--resume <id> --fork-session` so the
# original session continues untouched.
#
# Detection: walks the process tree under the pane to find a `claude`
# process, then reads ~/.claude/sessions/<pid>.json to get the session id.

set -euo pipefail

die() {
    local msg="$*"
    if [[ -n "${TMUX:-}" ]]; then
        tmux display-message "claude-fork: $msg"
    fi
    echo "claude-fork: $msg" >&2
    exit 1
}

pane_id="${1:-${TMUX_PANE:-}}"
[[ -n "$pane_id" ]] || die "no tmux pane (run inside tmux)"

pane_pid=$(tmux display-message -t "$pane_id" -p '#{pane_pid}')
pane_cwd=$(tmux display-message -t "$pane_id" -p '#{pane_current_path}')

# BFS the process tree starting at pane_pid (inclusive), return the first
# pid whose /proc/<pid>/comm == "claude". Checking the start pid itself
# matters for fork windows: tmux new-window runs `claude` directly as the
# pane command, so pane_pid IS claude (not a shell parent of claude).
find_claude_pid() {
    local queue=("$1") next pid child comm
    comm=$(cat "/proc/$1/comm" 2>/dev/null || true)
    if [[ "$comm" == "claude" ]]; then
        echo "$1"
        return 0
    fi
    while ((${#queue[@]})); do
        next=()
        for pid in "${queue[@]}"; do
            while read -r child; do
                [[ -z "$child" ]] && continue
                comm=$(cat "/proc/$child/comm" 2>/dev/null || true)
                if [[ "$comm" == "claude" ]]; then
                    echo "$child"
                    return 0
                fi
                next+=("$child")
            done < <(pgrep -P "$pid" 2>/dev/null || true)
        done
        queue=("${next[@]}")
    done
    return 1
}

claude_pid=$(find_claude_pid "$pane_pid") || die "no claude process in this pane"

session_file="$HOME/.claude/sessions/${claude_pid}.json"
[[ -r "$session_file" ]] || die "session file not found: $session_file"

if command -v jq >/dev/null 2>&1; then
    session_id=$(jq -r '.sessionId' "$session_file")
    cwd=$(jq -r '.cwd' "$session_file")
else
    session_id=$(grep -oE '"sessionId":"[^"]+"' "$session_file" | head -1 | cut -d'"' -f4)
    cwd=$(grep -oE '"cwd":"[^"]+"' "$session_file" | head -1 | cut -d'"' -f4)
fi

[[ -n "$session_id" && "$session_id" != "null" ]] || die "could not read sessionId"
[[ -n "$cwd" && "$cwd" != "null" ]] && pane_cwd="$cwd"

# `claude` may not be on PATH for the new shell tmux spawns; resolve absolute path.
claude_bin=$(command -v claude || echo claude)

tmux new-window -c "$pane_cwd" -n "f:${session_id:0:4}" \
    "$claude_bin --resume '$session_id' --fork-session"
tmux display-message "forked from ${session_id:0:8} (pid $claude_pid)"
