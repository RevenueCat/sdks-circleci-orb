#!/usr/bin/env bash

set -euo pipefail

# Install mise
echo "Installing mise..."
curl https://mise.run | sh

# Activate mise
eval "$(mise activate bash)"

# Create mise.toml file
cat > mise.toml << 'EOF'
[tools]
tuist = "4.49.0"

EOF

# Check mise configuration
mise doctor

# Ensure tuist plugin is installed
mise plugins install tuist || true

# Install tools from mise.toml
mise install

# Check final configuration
mise doctor

echo "Tuist installation completed" 