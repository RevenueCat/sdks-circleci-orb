#!/usr/bin/env bash
set -euo pipefail

# Get version from environment variable, default to 0.10.1 if not set
VERSION=${PUBLIC_API_DIFF_VERSION:-0.10.1}

echo "Installing public-api-diff version $VERSION..."

# Create tools directory
mkdir -p ~/tools

# Clone the repository
git clone https://github.com/Adyen/adyen-swift-public-api-diff.git ~/tools/adyen-swift-public-api-diff

# Navigate to the cloned directory
cd ~/tools/adyen-swift-public-api-diff

# Checkout the specific version tag
git checkout "$VERSION"

# Build the tool
swift build -c release

# Create bin directory
mkdir -p ~/bin

# Copy the built executable
cp .build/release/public-api-diff ~/bin/

# Add to PATH for current session
export PATH="$PATH:~/bin"

# Verify installation
public-api-diff --help > /dev/null || { echo "❌ public-api-diff did not install properly."; exit 1; }

echo "✅ public-api-diff installation completed"