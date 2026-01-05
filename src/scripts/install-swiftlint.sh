#!/usr/bin/env bash
set -euo pipefail

# Add mise to PATH
export PATH="$HOME/.local/bin:$PATH"

# Install mise if not already installed
if command -v mise &> /dev/null; then
    echo "mise is already installed, skipping installation..."
else
    echo "Installing mise..."
    curl https://mise.run | sh
fi

# Activate mise (includes env, shims, etc.)
eval "$(mise activate bash)"

# Add shims to PATH (required in CI)
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Optional: Ensure swiftlint plugin is installed
mise plugins install swiftlint

# Check if mise.toml exists
if [ ! -f "mise.toml" ]; then
    echo "❌ mise.toml not found. Please create a mise.toml file with swiftlint version specified."
    exit 1
fi

# Install tools
mise install

# Verify swiftlint
swiftlint version || { echo "❌ SwiftLint did not install properly."; exit 1; }

echo "✅ SwiftLint installation completed"

