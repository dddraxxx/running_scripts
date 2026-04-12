source ~/.bashrc

# Continue with normal tunneling process
curl -Lk 'https://api2.cursor.sh/updates/download-latest?os=cli-alpine-x64' --output vscode_cli.tar.gz

tar -xf vscode_cli.tar.gz
./cursor tunnel --no-sleep --accept-server-license-terms --install-extension ms-python.python --install-extension ms-toolsai.jupyter \
    --install-extension kisstkondoros.vscode-gutter-preview --install-extension anyscalecompute.ray-distributed-debugger --install-extension openai.chatgpt \
    | tee cursor_tunnel.log

sleep infinity
