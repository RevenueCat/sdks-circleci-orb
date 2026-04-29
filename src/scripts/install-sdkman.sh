#!/usr/bin/env bash
set -euo pipefail

# Pinned SDKMAN CLI version and SHA256 of its release artifact.
# Bump both values together when upgrading. See:
#   https://github.com/sdkman/sdkman-cli/releases
#   https://github.com/sdkman/sdkman-cli/releases/download/${SDKMAN_VERSION}/checksums_sha256.txt
SDKMAN_VERSION="5.22.5"
SDKMAN_CLI_SHA256="301de44c2455c061c8ac40fae194dd9287251115e34f8d86de68914510eb12c9"

SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

if [ -f "$SDKMAN_DIR/var/version" ] && [ "$(cat "$SDKMAN_DIR/var/version")" = "$SDKMAN_VERSION" ]; then
    echo "SDKMAN ${SDKMAN_VERSION} already installed at ${SDKMAN_DIR}, skipping download."
else
    case "$(uname -s)/$(uname -m)" in
        Linux/x86_64)  platform="linuxx64" ;;
        Linux/aarch64) platform="linuxarm64" ;;
        Darwin/arm64)  platform="darwinarm64" ;;
        Darwin/x86_64) platform="darwinx64" ;;
        *)
            echo "Unsupported platform: $(uname -s)/$(uname -m)." >&2
            exit 1
            ;;
    esac

    url="https://github.com/sdkman/sdkman-cli/releases/download/${SDKMAN_VERSION}/sdkman-cli-${SDKMAN_VERSION}.zip"

    echo "Installing SDKMAN ${SDKMAN_VERSION} (${platform}) into ${SDKMAN_DIR}..."
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT
    curl -fsSL --connect-timeout 10 --max-time 60 --retry 3 --retry-connrefused \
        -o "$tmpdir/sdkman-cli.zip" "$url"
    echo "${SDKMAN_CLI_SHA256}  $tmpdir/sdkman-cli.zip" | shasum -a 256 -c -

    rm -rf "$SDKMAN_DIR"
    mkdir -p "$SDKMAN_DIR"
    unzip -q "$tmpdir/sdkman-cli.zip" -d "$tmpdir/extract"
    cp -R "$tmpdir/extract/sdkman-${SDKMAN_VERSION}/." "$SDKMAN_DIR/"
    mkdir -p "$SDKMAN_DIR/libexec" "$SDKMAN_DIR/etc" "$SDKMAN_DIR/var" \
             "$SDKMAN_DIR/candidates" "$SDKMAN_DIR/tmp" "$SDKMAN_DIR/ext"

    # Write a CI-friendly SDKMAN config:
    # - sdkman_auto_update / sdkman_selfupdate_enable = false: SDKMAN must
    #   never silently upgrade itself in CI; the version is pinned above.
    # - sdkman_auto_env = false: don't auto-source .sdkmanrc on cd; consumers
    #   invoke `sdk env install` explicitly.
    # - sdkman_native_enable = false: we install only the script CLI, not the
    #   optional Rust native binary, so sdkman must fall back to shell impls
    #   for commands that have native counterparts.
    # - sdkman_healthcheck_enable = false: skip the api.sdkman.io probe that
    #   runs on every shell init.
    cat > "$SDKMAN_DIR/etc/config" <<'EOF'
sdkman_auto_answer=false
sdkman_auto_complete=true
sdkman_auto_env=false
sdkman_auto_update=false
sdkman_beta_channel=false
sdkman_checksum_enable=true
sdkman_colour_enable=true
sdkman_curl_connect_timeout=7
sdkman_curl_max_time=10
sdkman_debug_mode=false
sdkman_healthcheck_enable=false
sdkman_insecure_ssl=false
sdkman_native_enable=false
sdkman_rosetta2_compatible=false
sdkman_selfupdate_enable=false
EOF

    echo "$platform" > "$SDKMAN_DIR/var/platform"
    echo "$SDKMAN_VERSION" > "$SDKMAN_DIR/var/version"
    # var/candidates is a CSV cache of valid candidate names. SDKMAN refuses
    # to run any command if the file is empty ("Cache is corrupt"), so we
    # populate it from api.sdkman.io the same way the upstream installer
    # does. The contents are non-sensitive (a list of names like
    # "java,kotlin,gradle,…") and any tampering can't widen what `sdk env
    # install` will install — that's controlled by .sdkmanrc.
    curl -fsSL --connect-timeout 10 --max-time 30 --retry 3 --retry-connrefused \
        "https://api.sdkman.io/2/candidates/all" \
        -o "$SDKMAN_DIR/var/candidates"
fi

# Persist sdkman init for subsequent CircleCI run steps (each step is a fresh shell).
echo "export SDKMAN_DIR=\"${SDKMAN_DIR}\"" >> "$BASH_ENV"
echo "source \"${SDKMAN_DIR}/bin/sdkman-init.sh\"" >> "$BASH_ENV"
