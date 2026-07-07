#!/usr/bin/env bash
set -euo pipefail

# mise is installed by the install-mise command in this orb; assume it is on PATH.

if [ ! -f "mise.toml" ]; then
    echo "❌ mise.toml not found. Please create a mise.toml file with tool versions."
    exit 1
fi

mise install

export PATH="$HOME/.local/share/mise/shims:$PATH"

if mise which java >/dev/null 2>&1; then
    java_home="$(mise where java)"
    echo "export JAVA_HOME=\"$java_home\"" >> "$BASH_ENV"
    echo "Set JAVA_HOME to $java_home"
    java -version
fi

echo "✅ mise tools installation completed"
