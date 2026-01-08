#!/usr/bin/env bash
set -euo pipefail

# Get version from environment variable (empty string means not provided)
VERSION=${XCBEAUTIFY_VERSION:-}

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

# Install xcbeautify plugin from asdf-xcbeautify
mise plugins install xcbeautify https://github.com/mise-plugins/asdf-xcbeautify.git

# Install xcbeautify - use parameter if provided, otherwise use mise.toml
if [ -n "$VERSION" ]; then
    echo "Installing xcbeautify version $VERSION (from parameter)..."
    mise install "xcbeautify@$VERSION"
    mise use -g "xcbeautify@$VERSION"
else
    # Check if mise.toml exists
    if [ ! -f "mise.toml" ]; then
        echo "❌ No version parameter provided and mise.toml not found."
        echo "Please either pass a version parameter or create a mise.toml file with xcbeautify version specified."
        exit 1
    fi
    echo "Installing xcbeautify from mise.toml..."
    mise install
fi

# Verify xcbeautify
xcbeautify --version || { echo "❌ xcbeautify did not install properly."; exit 1; }

echo "✅ xcbeautify installation completed"
