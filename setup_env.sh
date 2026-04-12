#!/usr/bin/env bash
set -euo pipefail

ZIP_URL="${ENV_BUNDLE_URL:-https://raw.githubusercontent.com/dddraxxx/running_scripts/main/env_files_protected.zip}"
INSTALL_DIR="${ENV_BUNDLE_DIR:-$HOME/.pluto_env_bundle}"
ZIP_PATH="$INSTALL_DIR/env_files_protected.zip"

if [[ -n "${ENV_BUNDLE_PASSWORD:-}" ]]; then
  ZIP_PASSWORD="$ENV_BUNDLE_PASSWORD"
else
  read -rsp "Bundle password: " ZIP_PASSWORD
  echo
fi

mkdir -p "$INSTALL_DIR"

echo "Downloading env bundle..."
curl -fL "$ZIP_URL" -o "$ZIP_PATH"

echo "Extracting env bundle into $INSTALL_DIR"
rm -rf "$INSTALL_DIR/.ssh" "$INSTALL_DIR/pluto"
unzip -o -P "$ZIP_PASSWORD" "$ZIP_PATH" -d "$INSTALL_DIR" >/dev/null

if [[ ! -f "$INSTALL_DIR/pluto/.bashrc" ]]; then
  echo "Missing $INSTALL_DIR/pluto/.bashrc after extraction"
  exit 1
fi

if [[ -e "$HOME/.bashrc" || -L "$HOME/.bashrc" ]]; then
  mv "$HOME/.bashrc" "$HOME/.bashrc.bck"
fi
ln -sfn "$INSTALL_DIR/pluto/.bashrc" "$HOME/.bashrc"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
cp "$INSTALL_DIR/.ssh"/{id_ed25519.pub,id_ed25519,id_rsa,id_rsa.pub,config} "$HOME/.ssh/"
chmod 600 "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_rsa"
chmod 644 "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_rsa.pub" "$HOME/.ssh/config"

if [[ ! -e "$HOME/.tmux.conf" && ! -L "$HOME/.tmux.conf" ]]; then
  ln -s "$INSTALL_DIR/pluto/.tmux.conf" "$HOME/.tmux.conf"
fi

echo "Environment setup complete."
