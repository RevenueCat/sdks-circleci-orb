#!/usr/bin/env bash
set -euo pipefail

if [ -n "${MISE_PROJECT_ROOT:-}" ]; then
    cd "${MISE_PROJECT_ROOT}"
fi

if [ ! -f "mise.toml" ]; then
    echo "❌ mise.toml not found at $(pwd). Please create a mise.toml file with tool versions."
    exit 1
fi

# Project-level [hooks] postinstall still requires experimental mode; it no-ops without it.
if grep -q '^\[hooks\]' mise.toml; then
    mise settings set experimental true
fi

install_args=()
if [ "${MISE_INSTALL_LOCKED:-true}" != "false" ]; then
    install_args+=(--locked)
fi

if [ -n "${MISE_INSTALL_TOOLS:-}" ]; then
    # shellcheck disable=SC2206
    install_args+=(${MISE_INSTALL_TOOLS})
fi

mise install "${install_args[@]}"

if java_home="$(mise where java 2>/dev/null)"; then
    echo "export JAVA_HOME=\"$java_home\"" >> "$BASH_ENV"
    java -version || { echo "❌ Java did not install properly."; exit 1; }
fi

echo "✅ mise tools installation completed"
