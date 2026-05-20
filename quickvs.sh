stop_existing_tunnels() {
    echo "Stopping existing VS Code tunnel processes..."
    pkill -f '(^|/)code tunnel' 2>/dev/null || true
}

stop_existing_tunnels

REMOTE_DIR="$HOME/remote"
CODE_CLI="$REMOTE_DIR/code"
VSCODE_CLI_TAR="$REMOTE_DIR/vscode_cli.tar.gz"
VSCODE_TUNNEL_LOG="$REMOTE_DIR/vscode_tunnel.log"
VSCODE_CLI_DATA_DIR="$REMOTE_DIR/vscode-cli-data"

mkdir -p "$REMOTE_DIR" "$VSCODE_CLI_DATA_DIR"

# Clear old VS Code server/cache from previous tunnel runs.
rm -rf ~/.vscode-server
rm -rf ~/.vscode
rm -rf ~/.cache/Code
rm -rf ~/.config/Code

# Clear old CLI binaries/logs from previous script runs.
rm -f "$CODE_CLI" "$VSCODE_CLI_TAR" "$VSCODE_TUNNEL_LOG"

# Continue with normal tunneling process
curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output "$VSCODE_CLI_TAR"

tar -xf "$VSCODE_CLI_TAR" -C "$REMOTE_DIR"

# Remove the old registered tunnel before creating a fresh one. This prevents
# stale forwarded ports from making the tunnel hit the PortsPerTunnel limit.
"$CODE_CLI" tunnel --cli-data-dir "$VSCODE_CLI_DATA_DIR" unregister 2>/dev/null || true
rm -rf "$VSCODE_CLI_DATA_DIR"
mkdir -p "$VSCODE_CLI_DATA_DIR"

"$CODE_CLI" tunnel --cli-data-dir "$VSCODE_CLI_DATA_DIR" --no-sleep --accept-server-license-terms --install-extension ms-python.python --install-extension ms-toolsai.jupyter \
    --install-extension kisstkondoros.vscode-gutter-preview --install-extension anyscalecompute.ray-distributed-debugger --install-extension openai.chatgpt \
    | tee "$VSCODE_TUNNEL_LOG"

sleep infinity
