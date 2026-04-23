#!/usr/bin/env bash
set -euo pipefail

# mise is installed by the install-mise command in this orb; assume it is on PATH.
mise plugins install tuist

if [ ! -f "mise.toml" ]; then
    echo "❌ mise.toml not found. Please create a mise.toml file with tuist version specified."
    exit 1
fi

mise install

tuist version || { echo "❌ Tuist did not install properly."; exit 1; }

echo "✅ Tuist installation completed"
