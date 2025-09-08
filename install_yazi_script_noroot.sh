#!/bin/bash

# Yazi Installation Script for Ubuntu (NO ROOT VERSION)
# This script installs yazi terminal file manager on Ubuntu systems
# Does NOT require sudo/root access - installs locally

set -e  # Exit on any error

echo "🚀 Starting yazi installation on Ubuntu (No Root Version)..."
echo "✅ This script does NOT require sudo/root access"

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

# Create local bin directory if it doesn't exist
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

# Add local bin to PATH if not already there
if ! echo "$PATH" | grep -q "$LOCAL_BIN"; then
    echo "📝 Adding $LOCAL_BIN to PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$LOCAL_BIN:$PATH"
    echo "✅ Added to ~/.bashrc (restart terminal or run 'source ~/.bashrc' to apply)"
fi

# Check if we can install via pre-compiled binary
echo "🔍 Attempting to install yazi from GitHub releases..."

# Check for required tools (try to install via user methods if missing)
MISSING_TOOLS=()
for tool in curl wget unzip; do
    if ! command_exists "$tool"; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "❌ Missing required tools: ${MISSING_TOOLS[*]}"
    echo "💡 Please install these tools first:"
    echo "   sudo apt install ${MISSING_TOOLS[*]}"
    echo "   Or ask your system administrator to install them"
    echo ""
    echo "🔄 Falling back to Rust/Cargo installation..."
    USE_CARGO=true
else
    USE_CARGO=false
fi

if [ "$USE_CARGO" = false ]; then
    # Try binary installation
    echo "📥 Fetching latest yazi release information..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name"' | cut -d'"' -f4 2>/dev/null || echo "")
    
    if [ -z "$LATEST_VERSION" ]; then
        echo "❌ Failed to fetch latest version. Falling back to cargo installation..."
        USE_CARGO=true
    else
        echo "📥 Latest version: $LATEST_VERSION"
        
        # Determine architecture
        ARCH=$(uname -m)
        case $ARCH in
            x86_64) YAZI_ARCH="x86_64-unknown-linux-gnu" ;;
            aarch64) YAZI_ARCH="aarch64-unknown-linux-gnu" ;;
            *) 
                echo "❌ Unsupported architecture: $ARCH for binary installation"
                echo "🔄 Falling back to cargo installation..."
                USE_CARGO=true
                ;;
        esac
        
        if [ "$USE_CARGO" = false ]; then
            # Download and install binary
            DOWNLOAD_URL="https://github.com/sxyazi/yazi/releases/download/$LATEST_VERSION/yazi-$LATEST_VERSION-$YAZI_ARCH.zip"
            TEMP_DIR=$(mktemp -d)
            
            echo "📥 Downloading yazi binary..."
            cd "$TEMP_DIR"
            
            if wget -q "$DOWNLOAD_URL" -O yazi.zip; then
                echo "📦 Extracting and installing..."
                unzip -q yazi.zip
                
                # Find the extracted directory
                EXTRACTED_DIR=$(find . -name "yazi-*" -type d | head -1)
                if [ -z "$EXTRACTED_DIR" ]; then
                    echo "❌ Failed to find extracted directory"
                    USE_CARGO=true
                else
                    # Install binaries to local bin
                    cp "$EXTRACTED_DIR/yazi" "$LOCAL_BIN/"
                    cp "$EXTRACTED_DIR/ya" "$LOCAL_BIN/"
                    chmod +x "$LOCAL_BIN/yazi" "$LOCAL_BIN/ya"
                    
                    echo "🎉 yazi installed successfully from GitHub releases!"
                fi
            else
                echo "❌ Failed to download binary. Falling back to cargo installation..."
                USE_CARGO=true
            fi
            
            # Cleanup
            cd - > /dev/null
            rm -rf "$TEMP_DIR"
        fi
    fi
fi

# Cargo installation fallback
if [ "$USE_CARGO" = true ]; then
    echo "🔧 Installing yazi via Rust/Cargo..."
    
    # Install Rust and Cargo if not present
    if ! command_exists cargo; then
        echo "📦 Installing Rust and Cargo..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
        
        # Add cargo bin to PATH if not already there
        if ! echo "$PATH" | grep -q "$HOME/.cargo/bin"; then
            echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
            echo "📝 Added cargo bin to PATH in ~/.bashrc"
        fi
    fi
    
    echo "🔧 Compiling and installing yazi..."
    cargo install --locked yazi-fm yazi-cli
    echo "🎉 yazi installed successfully via cargo!"
fi

# Verify installation
echo "🔍 Verifying installation..."

# Source bashrc to get updated PATH
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

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
    
    # Installation location info
    YAZI_PATH=$(which yazi 2>/dev/null || echo "Not found in PATH")
    echo "📍 Installed at: $YAZI_PATH"
    
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
    
    echo ""
    echo "📝 Note: You may need to restart your terminal or run 'source ~/.bashrc' for PATH changes to take effect"
    
else
    echo "❌ Installation verification failed. yazi command not found."
    echo "💡 Try running 'source ~/.bashrc' or restart your terminal."
    echo "💡 Also ensure the following directories are in your PATH:"
    echo "   - $HOME/.local/bin"
    echo "   - $HOME/.cargo/bin"
    exit 1
fi

# Optional dependencies suggestions (without installing them)
echo ""
echo "💡 Optional dependencies for enhanced functionality:"
echo "   You can ask your system administrator to install these, or install them yourself if you have sudo:"
echo "   sudo apt install file ffmpegthumbnailer unar jq poppler-utils fd-find ripgrep fzf zoxide imagemagick"
echo ""
echo "   These provide:"
echo "   • file - File type detection"
echo "   • ffmpegthumbnailer - Video thumbnails"
echo "   • unar - Archive extraction"
echo "   • jq - JSON processing"
echo "   • poppler-utils - PDF handling"
echo "   • fd-find - Fast file finder"
echo "   • ripgrep - Fast text search"
echo "   • fzf - Fuzzy finder"
echo "   • zoxide - Smart directory jumper"
echo "   • imagemagick - Image processing"

echo ""
echo "🎉 Installation complete! Enjoy using yazi!"