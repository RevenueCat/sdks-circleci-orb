#!/usr/bin/env bash
set -euo pipefail

# Install Maestro
echo "Installing maestro..."
curl -Ls "https://get.maestro.mobile.dev" | bash

# Add Maestro to PATH
echo 'export PATH="$HOME/.maestro/bin:$PATH"' >> $BASH_ENV
source $BASH_ENV

echo "✅ Maestro installation completed" 