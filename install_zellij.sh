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

# Function to detect system architecture
detect_architecture() {
    arch=$(uname -m)
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    if [[ $arch == "x86_64" ]]; then
        arch="x86_64"
    elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
        arch="aarch64"
    else
        echo_color $RED "Unsupported architecture: $arch"
        exit 1
    fi
    
    if [[ $os == "darwin" ]]; then
        echo "x86_64-apple-darwin"
    elif [[ $os == "linux" ]]; then
        echo "x86_64-unknown-linux-musl"
    else
        echo_color $RED "Unsupported operating system: $os"
        exit 1
    fi
}

# Function to download and extract zellij
install_zellij() {
    # Latest stable release version as of April 2025
    version="0.41.2"
    arch=$(detect_architecture)
    
    echo_color $YELLOW "Installing Zellij v${version} for ${arch}..."
    
    # Create temp directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download the binary package
    download_url="https://github.com/zellij-org/zellij/releases/download/v${version}/zellij-${arch}.tar.gz"
    echo_color $YELLOW "Downloading from: ${download_url}"
    
    if ! curl -L -o zellij.tar.gz "$download_url"; then
        echo_color $RED "Failed to download Zellij. Please check your internet connection."
        exit 1
    fi
    
    # Extract the tarball
    if ! tar -xzf zellij.tar.gz; then
        echo_color $RED "Failed to extract Zellij package."
        exit 1
    fi
    
    # Determine installation path
    install_path=""
    if [[ -d "$HOME/.local/bin" && ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
        install_path="$HOME/.local/bin"
    elif [[ -d "/usr/local/bin" && -w "/usr/local/bin" ]]; then
        install_path="/usr/local/bin"
    else
        install_path="$HOME/bin"
        mkdir -p "$install_path"
        # Add to PATH if needed
        if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
            echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
            echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc" 2>/dev/null || true
            echo_color $YELLOW "Added $HOME/bin to PATH in .bashrc and .zshrc"
        fi
    fi
    
    # Install the binary
    echo_color $YELLOW "Installing Zellij to $install_path..."
    cp zellij "$install_path/"
    chmod +x "$install_path/zellij"
    
    # Clean up
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    echo_color $GREEN "Zellij v${version} installed successfully to $install_path/zellij"
    echo_color $GREEN "You may need to restart your terminal or source your shell config to update your PATH."
    
    # Check if the binary works
    if command -v zellij >/dev/null 2>&1; then
        echo_color $GREEN "Verifying installation:"
        zellij --version
    else
        echo_color $YELLOW "Zellij is installed but not in your current PATH."
        echo_color $YELLOW "You can run it with $install_path/zellij"
    fi
}

# Main program
echo_color $GREEN "=== Zellij Terminal Multiplexer Installer ==="
install_zellij
echo_color $GREEN "=== Installation Complete ==="