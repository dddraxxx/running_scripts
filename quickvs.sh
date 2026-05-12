
# Clear old VS Code server/cache from previous tunnel runs.
rm -rf ~/.vscode-server
rm -rf ~/.vscode
rm -rf ~/.cache/Code
rm -rf ~/.config/Code

# Clear old CLI binaries/logs from previous script runs.
rm -f ~/code ~/vscode_cli.tar.gz ~/vscode_tunnel.log

# Continue with normal tunneling process
curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz

tar -xf vscode_cli.tar.gz
./code tunnel --no-sleep --accept-server-license-terms --install-extension ms-python.python --install-extension ms-toolsai.jupyter \
    --install-extension kisstkondoros.vscode-gutter-preview --install-extension anyscalecompute.ray-distributed-debugger --install-extension openai.chatgpt \
    | tee vscode_tunnel.log

sleep infinity
