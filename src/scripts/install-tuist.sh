#!/usr/bin/env bash

set -euo pipefail

# Ensure mise is available
if ! command -v mise &> /dev/null; then
  echo "Error: mise is not available. Please install mise first."
  exit 1
fi

echo "Installing Tuist using mise..."

# Ensure mise environment is activated
eval "$(mise activate bash)"

# Install Tuist using mise
if [ "$PARAMETERS_VERSION" = "latest" ]; then
  echo "Installing latest Tuist using mise..."
  mise install tuist@latest
else
  echo "Installing Tuist version $PARAMETERS_VERSION using mise..."
  mise install "tuist@$PARAMETERS_VERSION"
fi

# Set the version to use
if [ "$PARAMETERS_GLOBAL" = "true" ]; then
  if [ "$PARAMETERS_VERSION" = "latest" ]; then
    echo "Setting latest Tuist as global default..."
    mise use -g tuist@latest
  else
    echo "Setting Tuist $PARAMETERS_VERSION as global default..."
    mise use -g "tuist@$PARAMETERS_VERSION"
  fi
else
  if [ "$PARAMETERS_VERSION" = "latest" ]; then
    echo "Setting latest Tuist for current directory..."
    mise use tuist@latest
  else
    echo "Setting Tuist $PARAMETERS_VERSION for current directory..."
    mise use "tuist@$PARAMETERS_VERSION"
  fi
fi

# Activate mise environment and update PATH
eval "$(mise activate bash)"
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Ensure PATH persists for subsequent steps
echo "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\"" >> "$BASH_ENV"
echo "eval \"\$(mise activate bash)\"" >> "$BASH_ENV"

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