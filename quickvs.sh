stop_existing_tunnels() {
    echo "Stopping existing VS Code tunnel processes..."
    pkill -f '(^|/)code tunnel' 2>/dev/null || true
}

stop_existing_tunnels

CODE_CLI="$HOME/code"
VSCODE_CLI_TAR="$HOME/vscode_cli.tar.gz"
VSCODE_TUNNEL_LOG="$HOME/vscode_tunnel.log"

# Clear old VS Code server/cache from previous tunnel runs.
rm -rf ~/.vscode-server
rm -rf ~/.vscode
rm -rf ~/.cache/Code
rm -rf ~/.config/Code

# Clear old CLI binaries/logs from previous script runs.
rm -f "$CODE_CLI" "$VSCODE_CLI_TAR" "$VSCODE_TUNNEL_LOG"

# Continue with normal tunneling process
curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output "$VSCODE_CLI_TAR"

tar -xf "$VSCODE_CLI_TAR" -C "$HOME"

# Remove the old registered tunnel before creating a fresh one. This prevents
# stale forwarded ports from making the tunnel hit the PortsPerTunnel limit.
"$CODE_CLI" tunnel unregister 2>/dev/null || true

"$CODE_CLI" tunnel --no-sleep --accept-server-license-terms --install-extension ms-python.python --install-extension ms-toolsai.jupyter \
    --install-extension kisstkondoros.vscode-gutter-preview --install-extension anyscalecompute.ray-distributed-debugger --install-extension openai.chatgpt \
    | tee "$VSCODE_TUNNEL_LOG"

sleep infinity
