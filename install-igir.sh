#!/usr/bin/env bash

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${1:-$SCRIPT_DIR}"
REPO="emmercm/igir"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map to igir release naming
case $OS in
    linux)
        case $ARCH in
            x86_64) PATTERN="Linux-amd64" ;;
            aarch64|arm64) PATTERN="Linux-arm64v8" ;;
            *) echo "Unsupported Linux architecture: $ARCH"; exit 1 ;;
        esac
        ;;
    darwin)
        PATTERN="macOS-arm64"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

echo "Detecting system: $PATTERN"

# Get latest release info
echo "Fetching latest release..."
RELEASE_JSON=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest")
TAG=$(echo "$RELEASE_JSON" | grep '"tag_name"' | cut -d'"' -f4)

if [ -z "$TAG" ]; then
    echo "Failed to fetch latest release"
    exit 1
fi

echo "Latest version: $TAG"

# Find matching asset (pattern like: igir-4.2.0-Linux-amd64.tar.gz)
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep "browser_download_url.*$PATTERN\.tar\.gz" | cut -d'"' -f4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "No release found matching: $PATTERN"
    exit 1
fi

echo "Downloading from: $DOWNLOAD_URL"

# Create temp directory
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Download and extract
cd "$TMP_DIR"
curl -sL "$DOWNLOAD_URL" -o igir.tar.gz
tar -xzf igir.tar.gz

# Create install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Move executable
mv igir "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/igir"

# Symlink igir if ~/Git/dotfiles/bin exists
if [ -d "$HOME/Git/dotfiles/bin" ]; then
  ln -sf "$INSTALL_DIR/igir" "$HOME/Git/dotfiles/bin/igir"
  echo "Symlinked igir to $HOME/Git/dotfiles/bin/igir"
  fi

echo "✓ igir installed"
