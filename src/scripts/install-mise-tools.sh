#!/usr/bin/env bash
set -euo pipefail

if [ -n "${MISE_PROJECT_ROOT:-}" ]; then
    cd "${MISE_PROJECT_ROOT}"
fi

if [ ! -f "mise.toml" ]; then
    echo "❌ mise.toml not found at $(pwd). Please create a mise.toml file with tool versions."
    exit 1
fi

selected_tools_file="/tmp/mise-selected-tools.list"

install_args=()
if [ "${MISE_INSTALL_LOCKED:-true}" != "false" ]; then
    install_args+=(--locked)
fi

if [ -f "$selected_tools_file" ] && [ -s "$selected_tools_file" ]; then
    while IFS= read -r tool || [ -n "$tool" ]; do
        [ -n "$tool" ] || continue
        install_args+=("$tool")
    done < "$selected_tools_file"
fi

mise install "${install_args[@]}"

if java_home="$(mise where java 2>/dev/null)"; then
    echo "export JAVA_HOME=\"$java_home\"" >> "$BASH_ENV"
    java -version || { echo "❌ Java did not install properly."; exit 1; }
fi

echo "✅ mise tools installation completed"
