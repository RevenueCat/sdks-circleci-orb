#!/usr/bin/env bash

set -euo pipefail

# Function to get latest tuist version
get_latest_tuist_version() {
  # Get the latest CLI release (not app@ releases)
  curl -s https://api.github.com/repos/tuist/tuist/releases | grep '"tag_name"' | grep -v 'app@' | head -1 | cut -d'"' -f4
}

# Function to install tuist directly
install_tuist_direct() {
  local version=$1
  local install_dir="$HOME/.local/bin"
  
  # Get version to install
  if [ "$version" = "latest" ]; then
    version=$(get_latest_tuist_version)
    echo "Latest Tuist version: $version"
  fi
  
  echo "Installing Tuist version $version directly..."
  
  # Create install directory
  mkdir -p "$install_dir"
  
  # Download and install tuist
  local download_url="https://github.com/tuist/tuist/releases/download/$version/tuist.zip"
  local temp_file="/tmp/tuist.zip"
  
  echo "Downloading from: $download_url"
  if curl -fsSL -o "$temp_file" "$download_url"; then
    echo "Download successful, extracting..."
    if command -v unzip &> /dev/null; then
      if unzip -q "$temp_file" -d "/tmp/tuist_extract"; then
        # Move tuist binary to install directory
        if [ -f "/tmp/tuist_extract/tuist" ]; then
          mv "/tmp/tuist_extract/tuist" "$install_dir/tuist"
          chmod +x "$install_dir/tuist"
          echo "Tuist installed successfully to $install_dir/tuist"
        else
          echo "Error: tuist binary not found in extracted files"
          return 1
        fi
      else
        echo "Error: Failed to extract tuist.zip"
        return 1
      fi
    else
      echo "Error: unzip command not available"
      return 1
    fi
  else
    echo "Error: Failed to download tuist from $download_url"
    return 1
  fi
  
  # Clean up
  rm -f "$temp_file"
  rm -rf "/tmp/tuist_extract"
}

# Check if mise is available for fallback
MISE_AVAILABLE=false
if command -v mise &> /dev/null; then
  MISE_AVAILABLE=true
fi

# Try direct installation first
if install_tuist_direct "$PARAMETERS_VERSION"; then
  # Add install directory to PATH
  export PATH="$HOME/.local/bin:$PATH"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$BASH_ENV"
  
  # Verify installation
  if command -v tuist &> /dev/null; then
    echo "Tuist installed successfully"
    tuist --version
  else
    echo "Error: Tuist installation failed - command not found"
    exit 1
  fi
else
  echo "Direct installation failed, trying mise fallback..."
  
  # Fallback to mise if available
  if [ "$MISE_AVAILABLE" = "true" ]; then
    echo "Using mise as fallback installation method..."
    
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
    
    # Activate mise environment to make tuist available
    eval "$(mise activate bash)"
    
    # Also add mise shims to PATH as a fallback
    export PATH="$HOME/.local/share/mise/shims:$PATH"
    
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
  else
    echo "Error: Both direct installation and mise fallback failed"
    exit 1
  fi
fi 