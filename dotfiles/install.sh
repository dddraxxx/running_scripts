#!/usr/bin/env bash
# Symlink dotfiles into $HOME. Idempotent.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [[ -L "$dst" || -e "$dst" ]]; then
        if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
            echo "ok    $dst -> $src"
            return
        fi
        local backup="${dst}.bak.$(date +%s)"
        mv "$dst" "$backup"
        echo "moved $dst -> $backup"
    fi
    ln -s "$src" "$dst"
    echo "link  $dst -> $src"
}

link "$DOTFILES_DIR/tmux/tmux.conf"       "$HOME/.tmux.conf"
link "$DOTFILES_DIR/tmux/tmux.local.conf" "$HOME/.tmux.local.conf"
link "$DOTFILES_DIR/bin/claude-fork.sh"   "$HOME/.local/bin/claude-fork.sh"

echo
echo "Done. Reload tmux config in a running session with:"
echo "  tmux source-file ~/.tmux.conf"
