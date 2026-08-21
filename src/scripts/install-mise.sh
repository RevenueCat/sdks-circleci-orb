#!/usr/bin/env bash
set -euo pipefail

# Pinned mise version and SHA256 checksums for the release artifacts.
# Bump the version and every checksum together when upgrading. See:
#   https://github.com/jdx/mise/releases
#   https://github.com/jdx/mise/releases/download/${MISE_VERSION}/SHASUMS256.txt
MISE_VERSION="v2026.7.0"
MISE_SHA256_MACOS_ARM64="23efe18046d12b95895d17b2bf0101a0efb9bf174767c57b6e2c8d019b964252"
MISE_SHA256_MACOS_X64="c33f2974806db45d5a2b0ab480d0750c54328c6fe87be5cf915106d46e55b9f0"
MISE_SHA256_LINUX_ARM64="fcbba22dfd6bfaf94912fdba3e1f034c89841cda7a895fd2b7402cef3d7ae214"
MISE_SHA256_LINUX_X64="a3ff8f55b61504e7d7556d7b0cac4413e0c85ef7279545d2c2c3f49bd2cf8472"

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
        Linux/aarch64 | Linux/arm64)
            artifact="linux-arm64"
            expected_sha="$MISE_SHA256_LINUX_ARM64"
            ;;
        Linux/x86_64)
            artifact="linux-x64"
            expected_sha="$MISE_SHA256_LINUX_X64"
            ;;
        *)
            echo "Unsupported platform: $os/$arch. install-mise.sh supports macOS and Linux (x86_64/arm64)." >&2
            exit 1
            ;;
    esac

    tarball="mise-${MISE_VERSION}-${artifact}.tar.gz"
    url="https://github.com/jdx/mise/releases/download/${MISE_VERSION}/${tarball}"

    echo "Installing mise ${MISE_VERSION} (${artifact})..."
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    curl -fsSL -o "$tmpdir/mise.tar.gz" "$url"
    # sha256sum on Linux (coreutils), shasum on macOS.
    if command -v sha256sum > /dev/null 2>&1; then
        echo "${expected_sha}  $tmpdir/mise.tar.gz" | sha256sum -c -
    else
        echo "${expected_sha}  $tmpdir/mise.tar.gz" | shasum -a 256 -c -
    fi
    mkdir -p "$HOME/.local"
    tar xzf "$tmpdir/mise.tar.gz" -C "$HOME/.local" --strip-components=1
fi

# Activate mise (includes env, shims, etc.)
eval "$(mise activate bash)"

# Add shims to PATH (required in CI)
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Persist PATH changes to BASH_ENV so mise and its shims are available in
# subsequent CircleCI run steps (each step starts a fresh shell).
echo "export PATH=\"\$HOME/.local/bin:\$HOME/.local/share/mise/shims:\$PATH\"" >> "$BASH_ENV"

# CircleCI cache keys can checksum a file but not a command's output.
mise --version > "$HOME/.mise_version"

# CircleCI's `arch` template gives the OS and CPU but not the OS version, and one
# fleet can span several: purchases-ios runs macOS 13.2, 15.3 and 26.3 side by side.
# The cached toolchain holds native binaries linked against the OS they were built
# on, so a Ruby built under 15.3 and restored onto 13.2 leaves its gems failing to
# dlopen. Only the major version is recorded, since a minor bump does not move that
# boundary and keying on it would miss the cache for no gain.
if [ -r /etc/os-release ]; then
    # Linux reads the distro release because a container's kernel belongs to the
    # host, so `uname -r` would describe a machine the cache has nothing to do with.
    # shellcheck disable=SC1091
    os_release="$(. /etc/os-release && echo "${ID:-linux}-${VERSION_ID:-unknown}")"
else
    # macOS has no /etc/os-release. Its kernel major is the token native builds bake
    # in (darwin24, darwin25) and it moves once per macOS release.
    os_release="$(uname -s)-$(uname -r | cut -d. -f1)"
fi
echo "$os_release" > "$HOME/.mise_platform"
