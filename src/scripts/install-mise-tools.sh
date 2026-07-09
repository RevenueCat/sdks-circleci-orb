#!/usr/bin/env bash
set -euo pipefail

if [ -n "${MISE_PROJECT_ROOT:-}" ]; then
    cd "${MISE_PROJECT_ROOT}"
fi

if [ ! -f "mise.toml" ]; then
    echo "❌ mise.toml not found at $(pwd). Please create a mise.toml file with tool versions."
    exit 1
fi

install_args=()
if [ "${MISE_INSTALL_LOCKED:-true}" != "false" ]; then
    install_args+=(--locked)
fi

if [ -n "${MISE_TOOLS:-}" ]; then
    normalized=$(printf '%s' "$MISE_TOOLS" | tr '\n' ' ')
    read -ra selected_tools <<< "$normalized"
    for tool in "${selected_tools[@]}"; do
        [ -n "$tool" ] || continue
        install_args+=("$tool")
    done
fi

mise install "${install_args[@]}"

if java_home="$(mise where java 2>/dev/null)"; then
    echo "export JAVA_HOME=\"$java_home\"" >> "$BASH_ENV"
    java -version || { echo "❌ Java did not install properly."; exit 1; }
fi

echo "✅ mise tools installation completed"
