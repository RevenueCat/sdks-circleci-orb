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

# Install xcodes plugin from asdf-xcodes
mise plugins install xcodes https://github.com/younke/asdf-xcodes.git

# Check if mise.toml exists
if [ ! -f "mise.toml" ]; then
    echo "❌ mise.toml not found. Please create a mise.toml file with xcodes version specified."
    exit 1
fi

# Install tools
mise install

# Verify xcodes
xcodes version || { echo "❌ xcodes did not install properly."; exit 1; }

echo "✅ xcodes installation completed"

