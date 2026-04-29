#!/usr/bin/env bash
set -euo pipefail

# Pinned Maestro CLI version and SHA256 of its release artifact.
# Bump both values together when upgrading. See:
#   https://github.com/mobile-dev-inc/maestro/releases
#   https://github.com/mobile-dev-inc/maestro/releases/download/cli-${MAESTRO_VERSION}/checksums_sha256.txt
MAESTRO_VERSION="2.5.0"
MAESTRO_SHA256="9c9a7617b47e21d4a9add205e0a2ec45f71f9fb0cb651051281afbc3f87158ea"

MAESTRO_DIR="${MAESTRO_DIR:-$HOME/.maestro}"

# Sentinel file used for the early-exit check below. Avoids depending on
# `maestro --version` output (would also require Java on PATH, and the
# format isn't a stable contract).
version_marker="$MAESTRO_DIR/.installed-version"

if [ -f "$version_marker" ] && [ "$(cat "$version_marker")" = "$MAESTRO_VERSION" ]; then
    echo "Maestro ${MAESTRO_VERSION} already installed at ${MAESTRO_DIR}, skipping download."
else
    url="https://github.com/mobile-dev-inc/maestro/releases/download/cli-${MAESTRO_VERSION}/maestro.zip"

    echo "Installing Maestro ${MAESTRO_VERSION} into ${MAESTRO_DIR}..."
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    curl -fsSL -o "$tmpdir/maestro.zip" "$url"
    echo "${MAESTRO_SHA256}  $tmpdir/maestro.zip" | shasum -a 256 -c -

    rm -rf "$MAESTRO_DIR"
    mkdir -p "$MAESTRO_DIR"
    unzip -q "$tmpdir/maestro.zip" -d "$tmpdir/extract"
    cp -R "$tmpdir/extract/maestro/." "$MAESTRO_DIR/"
    echo "$MAESTRO_VERSION" > "$version_marker"
fi

# Persist PATH for subsequent CircleCI run steps (each step starts a fresh shell).
echo "export PATH=\"${MAESTRO_DIR}/bin:\$PATH\"" >> "$BASH_ENV"
