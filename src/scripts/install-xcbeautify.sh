#!/usr/bin/env bash
set -euo pipefail

# Get version from environment variable (empty string means not provided)
VERSION=${XCBEAUTIFY_VERSION:-}

# mise is installed by the install-mise command in this orb; assume it is on PATH.
mise plugins install xcbeautify https://github.com/mise-plugins/asdf-xcbeautify.git

# Install xcbeautify - use parameter if provided, otherwise use mise.toml
if [ -n "$VERSION" ]; then
    echo "Installing xcbeautify version $VERSION (from parameter)..."
    mise install "xcbeautify@$VERSION"
    mise use -g "xcbeautify@$VERSION"
else
    if [ ! -f "mise.toml" ]; then
        echo "❌ No version parameter provided and mise.toml not found."
        echo "Please either pass a version parameter or create a mise.toml file with xcbeautify version specified."
        exit 1
    fi
    echo "Installing xcbeautify from mise.toml..."
    mise install
fi

xcbeautify --version || { echo "❌ xcbeautify did not install properly."; exit 1; }

echo "✅ xcbeautify installation completed"
