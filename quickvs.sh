
touch vscode_tunnel.log

# Continue with normal tunneling process
curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz

tar -xf vscode_cli.tar.gz
./code tunnel --accept-server-license-terms --install-extension ms-python.python  | tee vscode_tunnel.log

sleep infinity
