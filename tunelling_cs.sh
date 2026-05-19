stop_existing_tunnels() {
    echo "Stopping existing Cursor tunnel processes..."
    pkill -f '(^|/)cursor tunnel' 2>/dev/null || true
}

stop_existing_tunnels

REMOTE_DIR="$HOME/remote"
CURSOR_CLI="$REMOTE_DIR/cursor"
CURSOR_CLI_TAR="$REMOTE_DIR/cursor_cli.tar.gz"
CURSOR_TUNNEL_LOG="$REMOTE_DIR/cursor_tunnel.log"
CURSOR_CLI_DATA_DIR="$REMOTE_DIR/cursor-cli-data"

mkdir -p "$REMOTE_DIR" "$CURSOR_CLI_DATA_DIR"

# Clear old Cursor server/cache from previous tunnel runs.
rm -rf ~/.cursor-server
rm -rf ~/.cursor
rm -rf ~/.cache/cursor
rm -rf ~/.config/Cursor

# Clear old CLI binaries/logs from previous script runs.
rm -f "$CURSOR_CLI" "$CURSOR_CLI_TAR" "$CURSOR_TUNNEL_LOG"

# Continue with normal tunneling process
curl -L 'https://api2.cursor.sh/updates/download-latest?os=cli-alpine-x64' --output "$CURSOR_CLI_TAR"

tar -xf "$CURSOR_CLI_TAR" -C "$REMOTE_DIR"

"$CURSOR_CLI" --cli-data-dir "$CURSOR_CLI_DATA_DIR" tunnel unregister 2>/dev/null || true

"$CURSOR_CLI" --cli-data-dir "$CURSOR_CLI_DATA_DIR" tunnel --no-sleep --accept-server-license-terms --install-extension ms-python.python --install-extension ms-toolsai.jupyter \
    --install-extension kisstkondoros.vscode-gutter-preview --install-extension anyscalecompute.ray-distributed-debugger --install-extension openai.chatgpt \
    | tee "$CURSOR_TUNNEL_LOG"

sleep infinity
