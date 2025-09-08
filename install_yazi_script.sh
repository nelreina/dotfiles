#!/bin/bash

# Yazi Installation Script for Ubuntu (ROOT VERSION)
# This script installs yazi terminal file manager on Ubuntu systems
# Requires: sudo/root access

set -e  # Exit on any error

echo "🚀 Starting yazi installation on Ubuntu (Root Version)..."
echo "⚠️  This script requires sudo/root access"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect Ubuntu version
get_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$VERSION_ID"
    else
        echo "unknown"
    fi
}

# Check if running on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    echo "❌ This script is designed for Ubuntu. Detected: $(lsb_release -d 2>/dev/null || echo 'Unknown distribution')"
    exit 1
fi

UBUNTU_VERSION=$(get_ubuntu_version)
echo "📋 Detected Ubuntu version: $UBUNTU_VERSION"

# Update package list
echo "📦 Updating package list..."
sudo apt update

# Method 1: Try installing from official repositories (Ubuntu 23.04+)
if command_exists apt && apt-cache show yazi >/dev/null 2>&1; then
    echo "✅ Installing yazi from official Ubuntu repositories..."
    sudo apt install -y yazi
    echo "🎉 yazi installed successfully from repositories!"
else
    echo "ℹ️  yazi not available in repositories, installing from GitHub releases..."
    
    # Install dependencies
    echo "📦 Installing dependencies..."
    sudo apt install -y curl wget unzip
    
    # Get latest release version
    echo "🔍 Fetching latest yazi release information..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    
    if [ -z "$LATEST_VERSION" ]; then
        echo "❌ Failed to fetch latest version. Installing via cargo instead..."
        
        # Install Rust and Cargo if not present
        if ! command_exists cargo; then
            echo "📦 Installing Rust and Cargo..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source ~/.cargo/env
        fi
        
        echo "🔧 Installing yazi via cargo..."
        cargo install --locked yazi-fm yazi-cli
        
        # Add cargo bin to PATH if not already there
        if ! echo "$PATH" | grep -q "$HOME/.cargo/bin"; then
            echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
            echo "📝 Added cargo bin to PATH in ~/.bashrc"
        fi
        
    else
        echo "📥 Latest version: $LATEST_VERSION"
        
        # Determine architecture
        ARCH=$(uname -m)
        case $ARCH in
            x86_64) YAZI_ARCH="x86_64-unknown-linux-gnu" ;;
            aarch64) YAZI_ARCH="aarch64-unknown-linux-gnu" ;;
            *) echo "❌ Unsupported architecture: $ARCH"; exit 1 ;;
        esac
        
        # Download and install binary
        DOWNLOAD_URL="https://github.com/sxyazi/yazi/releases/download/$LATEST_VERSION/yazi-$LATEST_VERSION-$YAZI_ARCH.zip"
        TEMP_DIR=$(mktemp -d)
        
        echo "📥 Downloading yazi binary..."
        cd "$TEMP_DIR"
        wget -q "$DOWNLOAD_URL" -O yazi.zip
        
        echo "📦 Extracting and installing..."
        unzip -q yazi.zip
        
        # Find the extracted directory
        EXTRACTED_DIR=$(find . -name "yazi-*" -type d | head -1)
        if [ -z "$EXTRACTED_DIR" ]; then
            echo "❌ Failed to find extracted directory"
            exit 1
        fi
        
        # Install binaries
        sudo cp "$EXTRACTED_DIR/yazi" /usr/local/bin/
        sudo cp "$EXTRACTED_DIR/ya" /usr/local/bin/
        sudo chmod +x /usr/local/bin/yazi /usr/local/bin/ya
        
        # Cleanup
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        
        echo "🎉 yazi installed successfully from GitHub releases!"
    fi
fi

# Install optional dependencies for enhanced functionality
echo "📦 Installing optional dependencies for enhanced functionality..."
sudo apt install -y \
    file \
    ffmpegthumbnailer \
    unar \
    jq \
    poppler-utils \
    fd-find \
    ripgrep \
    fzf \
    zoxide \
    imagemagick \
    || echo "⚠️  Some optional dependencies failed to install (this is usually fine)"

# Verify installation
echo "🔍 Verifying installation..."
if command_exists yazi; then
    YAZI_VERSION=$(yazi --version 2>/dev/null || echo "Version check failed")
    echo "✅ yazi installed successfully!"
    echo "📋 Version: $YAZI_VERSION"
    echo ""
    echo "🚀 Quick start:"
    echo "  - Run 'yazi' to start the file manager"
    echo "  - Press 'q' to quit"
    echo "  - Press '?' for help"
    echo ""
    echo "📚 For more information, visit: https://yazi-rs.github.io/"
    
    # Suggest shell integration
    echo ""
    echo "💡 Optional: For shell integration (y to change directory on exit):"
    echo "   Add this to your ~/.bashrc or ~/.zshrc:"
    echo '   function y() {'
    echo '       local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd'
    echo '       yazi "$@" --cwd-file="$tmp"'
    echo '       if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then'
    echo '           builtin cd -- "$cwd"'
    echo '       fi'
    echo '       rm -f -- "$tmp"'
    echo '   }'
else
    echo "❌ Installation verification failed. yazi command not found."
    echo "💡 Try running 'source ~/.bashrc' or restart your terminal if installed via cargo."
    exit 1
fi

echo ""
echo "🎉 Installation complete! Enjoy using yazi!"