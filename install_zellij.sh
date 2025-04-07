#!/bin/bash
# Script to install Zellij terminal multiplexer from binary package
# Created: April 7, 2025

set -e  # Exit immediately if a command exits with a non-zero status

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print with color
echo_color() {
    color=$1
    message=$2
    echo -e "${color}${message}${NC}"
}

# Get latest version from GitHub API
echo_color $GREEN "=== Zellij Terminal Multiplexer Installer ==="
echo_color $YELLOW "Detecting the latest version..."

# Default version in case we can't get the latest
VERSION="0.42.1"

# Try to get the latest version from GitHub API
LATEST_VERSION=$(curl -s "https://api.github.com/repos/zellij-org/zellij/releases/latest" | 
                 grep '"tag_name":' | 
                 sed -E 's/.*"v([^"]+)".*/\1/')

# If we got a valid version, use it
if [[ -n "$LATEST_VERSION" ]]; then
    VERSION="$LATEST_VERSION"
    echo_color $GREEN "Latest version detected: $VERSION"
else
    echo_color $YELLOW "Could not detect latest version. Using default: $VERSION"
fi

# Detect architecture and OS
echo_color $YELLOW "Detecting system architecture..."
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture to binary name
if [[ $ARCH == "x86_64" ]]; then
    ARCH="x86_64"
elif [[ $ARCH == "aarch64" || $ARCH == "arm64" ]]; then
    ARCH="aarch64"
else
    echo_color $RED "Unsupported architecture: $ARCH"
    exit 1
fi

# Map OS to binary name
if [[ $OS == "darwin" ]]; then
    TARGET="x86_64-apple-darwin"
elif [[ $OS == "linux" ]]; then
    TARGET="x86_64-unknown-linux-musl"
else
    echo_color $RED "Unsupported operating system: $OS"
    exit 1
fi

echo_color $YELLOW "Installing Zellij v${VERSION} for ${TARGET}..."

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download the binary package
DOWNLOAD_URL="https://github.com/zellij-org/zellij/releases/download/v${VERSION}/zellij-${TARGET}.tar.gz"
echo_color $YELLOW "Downloading from: ${DOWNLOAD_URL}"

if ! curl -L -o zellij.tar.gz "$DOWNLOAD_URL"; then
    echo_color $RED "Failed to download Zellij. Please check your internet connection."
    exit 1
fi

# Extract the tarball
if ! tar -xzf zellij.tar.gz; then
    echo_color $RED "Failed to extract Zellij package."
    exit 1
fi

# Determine installation path
INSTALL_PATH=""
if [[ -d "$HOME/.local/bin" && ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    INSTALL_PATH="$HOME/.local/bin"
elif [[ -d "/usr/local/bin" && -w "/usr/local/bin" ]]; then
    INSTALL_PATH="/usr/local/bin"
else
    INSTALL_PATH="$HOME/bin"
    mkdir -p "$INSTALL_PATH"
    # Add to PATH if needed
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc" 2>/dev/null || true
        echo_color $YELLOW "Added $HOME/bin to PATH in .bashrc and .zshrc"
    fi
fi

# Install the binary
echo_color $YELLOW "Installing Zellij to $INSTALL_PATH..."
cp zellij "$INSTALL_PATH/"
chmod +x "$INSTALL_PATH/zellij"

# Clean up
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo_color $GREEN "Zellij v${VERSION} installed successfully to $INSTALL_PATH/zellij"
echo_color $GREEN "You may need to restart your terminal or source your shell config to update your PATH."

# Check if the binary works
if command -v zellij >/dev/null 2>&1; then
    echo_color $GREEN "Verifying installation:"
    zellij --version
else
    echo_color $YELLOW "Zellij is installed but not in your current PATH."
    echo_color $YELLOW "You can run it with $INSTALL_PATH/zellij"
fi

echo_color $GREEN "=== Installation Complete ==="