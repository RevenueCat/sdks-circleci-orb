#!/usr/bin/env bash

set -euo pipefail

# Ensure mise is available
if ! command -v mise &> /dev/null; then
  echo "Error: mise is not installed. Please run the install-mise command first."
  exit 1
fi

# Install Tuist
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

# Verify installation
if command -v tuist &> /dev/null; then
  echo "Tuist installed successfully"
  tuist --version
else
  echo "Error: Tuist installation failed"
  exit 1
fi 