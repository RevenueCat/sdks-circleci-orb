#!/usr/bin/env bash

set -euo pipefail

if command -v mise &> /dev/null; then
  echo "mise is already installed"
  mise --version
  
  # Ensure mise environment is properly activated
  eval "$(mise activate bash)"
  export PATH="$HOME/.local/share/mise/shims:$PATH"
  echo "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\"" >> "$BASH_ENV"
  echo "eval \"\$(mise activate bash)\"" >> "$BASH_ENV"
else
  echo "Installing mise..."
  curl -fsSL https://mise.jdx.dev/install.sh | bash
  
  # Add mise to PATH for current session and future sessions
  export PATH="$HOME/.local/bin:$PATH"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$BASH_ENV"
  
  # Add mise shims to PATH for tools installed via mise
  export PATH="$HOME/.local/share/mise/shims:$PATH"
  echo "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\"" >> "$BASH_ENV"
  
  # Activate mise for current session
  eval "$(mise activate bash)"
  echo "eval \"\$(mise activate bash)\"" >> "$BASH_ENV"
  
  # Verify installation
  if command -v mise &> /dev/null; then
    echo "mise installed successfully"
    mise --version
  else
    echo "Error: mise installation failed"
    exit 1
  fi
fi 