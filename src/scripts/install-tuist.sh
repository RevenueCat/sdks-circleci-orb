#!/usr/bin/env bash
set -euo pipefail

# Install mise
echo "Installing mise..."
curl https://mise.run | sh

# Add mise to PATH
export PATH="$HOME/.local/bin:$PATH"

# Activate mise (includes env, shims, etc.)
eval "$(mise activate bash)"

# Add shims to PATH (required in CI)
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Optional: Ensure tuist plugin is installed
mise plugins install tuist

# Check if mise.toml exists
if [ ! -f "mise.toml" ]; then
    echo "❌ mise.toml not found. Please create a mise.toml file with tuist version specified."
    exit 1
fi

# Install tools
mise install

# Verify tuist
tuist version || { echo "❌ Tuist did not install properly."; exit 1; }

echo "✅ Tuist installation completed" 