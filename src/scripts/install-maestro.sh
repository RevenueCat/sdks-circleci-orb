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
    curl -fsSL --connect-timeout 10 --max-time 300 --retry 3 --retry-connrefused \
        -o "$tmpdir/maestro.zip" "$url"
    echo "${MAESTRO_SHA256}  $tmpdir/maestro.zip" | shasum -a 256 -c -

    unzip -q "$tmpdir/maestro.zip" -d "$tmpdir"
    rm -rf "$MAESTRO_DIR"
    mkdir -p "$(dirname "$MAESTRO_DIR")"
    mv "$tmpdir/maestro" "$MAESTRO_DIR"
    echo "$MAESTRO_VERSION" > "$version_marker"
fi

# Persist PATH for subsequent CircleCI run steps (each step starts a fresh shell).
echo "export PATH=\"${MAESTRO_DIR}/bin:\$PATH\"" >> "$BASH_ENV"

# Suppress maestro's per-invocation update check against mobile.dev. The
# install above is version-pinned and SHA-verified; we don't want CI runs
# phoning out for a check that can't change what gets executed anyway.
echo 'export MAESTRO_DISABLE_UPDATE_CHECK=true' >> "$BASH_ENV"
