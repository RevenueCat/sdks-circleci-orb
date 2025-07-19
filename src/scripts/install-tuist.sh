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
mise plugins install tuist || true

# Write mise.toml with compatible Tuist version
# Using 4.40.0 as it's compatible with older macOS versions (pre-macOS 14.0)
echo "[tools]" > mise.toml
echo "tuist = \"4.40.0\"" >> mise.toml

# Install tools
mise install

# Verify tuist
tuist version || { echo "❌ Tuist did not install properly."; exit 1; }

echo "✅ Tuist installation completed" 