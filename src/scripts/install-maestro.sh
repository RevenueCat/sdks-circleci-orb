#!/usr/bin/env bash
set -euo pipefail

# Install Maestro
echo "Installing maestro..."
curl -Ls "https://get.maestro.mobile.dev" | bash

# Add Maestro to PATH
export PATH="$HOME/.maestro/bin:$PATH"

# Verify Maestro installation
maestro --version || { echo "❌ Maestro did not install properly."; exit 1; }

echo "✅ Maestro installation completed" 