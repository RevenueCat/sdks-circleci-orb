#!/usr/bin/env bash

set -euo pipefail

if command -v mise &> /dev/null; then
  echo "mise is already installed"
  mise --version
else
  echo "Installing mise..."
  curl -fsSL https://mise.jdx.dev/install.sh | bash
  
  # Add mise to PATH for current session and future sessions
  export PATH="$HOME/.local/bin:$PATH"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$BASH_ENV"
  
  # Verify installation
  if command -v mise &> /dev/null; then
    echo "mise installed successfully"
    mise --version
  else
    echo "Error: mise installation failed"
    exit 1
  fi
fi 