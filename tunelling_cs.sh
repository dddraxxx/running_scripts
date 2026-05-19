stop_existing_tunnels() {
    echo "Stopping existing Cursor tunnel processes..."
    pkill -f '(^|/)cursor tunnel' 2>/dev/null || true
}

stop_existing_tunnels

# Clear old Cursor server/cache from previous tunnel runs.
rm -rf ~/.cursor-server
rm -rf ~/.cursor
rm -rf ~/.cache/cursor
rm -rf ~/.config/Cursor

# Clear old CLI binaries/logs from previous script runs.
rm -f ~/cursor ~/cursor_cli.tar.gz ~/cursor_tunnel.log

# Continue with normal tunneling process
curl -L 'https://api2.cursor.sh/updates/download-latest?os=cli-alpine-x64' --output cursor_cli.tar.gz

tar -xf cursor_cli.tar.gz
./cursor tunnel --no-sleep --accept-server-license-terms --install-extension ms-python.python --install-extension ms-toolsai.jupyter \
    --install-extension kisstkondoros.vscode-gutter-preview --install-extension anyscalecompute.ray-distributed-debugger --install-extension openai.chatgpt \
    | tee cursor_tunnel.log

sleep infinity
