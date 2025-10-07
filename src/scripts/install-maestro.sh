#!/usr/bin/env bash
set -euo pipefail

# Install Maestro
echo "Installing maestro..."
curl -Ls "https://get.maestro.mobile.dev" | bash

# Add Maestro to PATH
export PATH="$HOME/.maestro/bin:$PATH"

echo "✅ Maestro installation completed" 