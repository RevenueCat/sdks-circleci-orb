#!/usr/bin/env bash

set -euo pipefail

# Install mise if not available
if ! command -v mise &> /dev/null; then
  echo "Installing mise..."
  curl -fsSL https://mise.run | sh
  
  # Add mise to PATH for current session and future sessions
  export PATH="$HOME/.local/bin:$PATH"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$BASH_ENV"
  
  # Verify mise installation
  if command -v mise &> /dev/null; then
    echo "mise installed successfully"
    mise --version
  else
    echo "Error: mise installation failed"
    exit 1
  fi
else
  echo "mise is already installed"
  mise --version
fi

# Setup mise environment once
eval "$(mise activate bash)"
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Ensure PATH and mise activation persist for subsequent steps
echo "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\"" >> "$BASH_ENV"
echo "eval \"\$(mise activate bash)\"" >> "$BASH_ENV"

# Install Tuist using mise
echo "Installing Tuist using mise..."
mise install tuist

# Verify installation
if command -v tuist &> /dev/null; then
  echo "Tuist installed successfully via mise"
  tuist --version
else
  echo "Error: Tuist installation failed via mise"
  echo "Available tools in mise:"
  mise list
  echo "PATH: $PATH"
  exit 1
fi 