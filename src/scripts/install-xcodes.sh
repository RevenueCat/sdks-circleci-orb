#!/usr/bin/env bash
set -euo pipefail

# mise is installed by the install-mise command in this orb; assume it is on PATH.
mise plugins install xcodes https://github.com/younke/asdf-xcodes.git

if [ ! -f "mise.toml" ]; then
    echo "❌ mise.toml not found. Please create a mise.toml file with xcodes version specified."
    exit 1
fi

mise install

xcodes version || { echo "❌ xcodes did not install properly."; exit 1; }

echo "✅ xcodes installation completed"
