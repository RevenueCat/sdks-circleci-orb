#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "mise.toml" ]; then
    echo "❌ mise.toml not found. Please create a mise.toml file with tool versions."
    exit 1
fi

# Consumer postinstall hooks (e.g. link-jdks) require experimental mode.
mise settings set experimental true

if [ "${MISE_INSTALL_LOCKED:-true}" = "true" ]; then
    mise install --locked
else
    mise install
fi

if java_home="$(mise where java 2>/dev/null)"; then
    echo "export JAVA_HOME=\"$java_home\"" >> "$BASH_ENV"
    java -version || { echo "❌ Java did not install properly."; exit 1; }
fi

echo "✅ mise tools installation completed"
