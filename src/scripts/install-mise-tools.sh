#!/usr/bin/env bash
set -euo pipefail

if [ -n "${MISE_PROJECT_ROOT:-}" ]; then
    cd "${MISE_PROJECT_ROOT}"
fi

if [ ! -f "mise.toml" ]; then
    echo "❌ mise.toml not found at $(pwd). Please create a mise.toml file with tool versions."
    exit 1
fi

# mise runs project [hooks] (e.g. postinstall) on every `mise install`, regardless of
# which tools were requested. Suppress them unless explicitly opted in: most callers
# don't need them, and paying for e.g. a postinstall task meant for one tool on every
# call (including single-tool calls via MISE_TOOLS) is wasteful and can hang CI.
if [ "${MISE_HOOKS:-false}" != "true" ]; then
    export MISE_NO_HOOKS=1
fi

install_args=()
if [ "${MISE_INSTALL_LOCKED:-true}" != "false" ]; then
    install_args+=(--locked)
fi

if [ -n "${MISE_TOOLS:-}" ]; then
    IFS=',' read -ra selected_tools <<< "$MISE_TOOLS"
    for tool in "${selected_tools[@]}"; do
        tool="${tool#"${tool%%[![:space:]]*}"}"
        tool="${tool%"${tool##*[![:space:]]}"}"
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
