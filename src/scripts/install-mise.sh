#!/usr/bin/env bash
set -euo pipefail

# Pinned mise version and SHA256 checksums for the release artifacts.
# Bump all three values together when upgrading. See:
#   https://github.com/jdx/mise/releases
#   https://github.com/jdx/mise/releases/download/${MISE_VERSION}/SHASUMS256.txt
MISE_VERSION="v2026.4.19"
MISE_SHA256_MACOS_ARM64="0785176288afc613cc152956bca905b7a47b91232f1b360fa9136e594af1c593"
MISE_SHA256_MACOS_X64="ce274ebeb8762e059c171fca1d0a7d8170f9870617b8defb7f2ed5ac798f9afb"

export PATH="$HOME/.local/bin:$PATH"

installed_version=""
if command -v mise &> /dev/null; then
    installed_version="$(mise --version 2>/dev/null | awk '{print $1}' || true)"
fi

if [ "$installed_version" = "${MISE_VERSION#v}" ]; then
    echo "mise ${MISE_VERSION} already installed, skipping download."
else
    os="$(uname -s)"
    arch="$(uname -m)"
    case "$os/$arch" in
        Darwin/arm64)
            artifact="macos-arm64"
            expected_sha="$MISE_SHA256_MACOS_ARM64"
            ;;
        Darwin/x86_64)
            artifact="macos-x64"
            expected_sha="$MISE_SHA256_MACOS_X64"
            ;;
        *)
            echo "Unsupported platform: $os/$arch. install-mise.sh supports macOS only." >&2
            exit 1
            ;;
    esac

    tarball="mise-${MISE_VERSION}-${artifact}.tar.gz"
    url="https://github.com/jdx/mise/releases/download/${MISE_VERSION}/${tarball}"

    echo "Installing mise ${MISE_VERSION} (${artifact})..."
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    curl -fsSL -o "$tmpdir/mise.tar.gz" "$url"
    echo "${expected_sha}  $tmpdir/mise.tar.gz" | shasum -a 256 -c -
    mkdir -p "$HOME/.local"
    tar xzf "$tmpdir/mise.tar.gz" -C "$HOME/.local" --strip-components=1
fi

# Activate mise (includes env, shims, etc.)
eval "$(mise activate bash)"

# Add shims to PATH (required in CI)
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Persist PATH changes to BASH_ENV for subsequent CircleCI steps.
echo "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\"" >> "$BASH_ENV"
