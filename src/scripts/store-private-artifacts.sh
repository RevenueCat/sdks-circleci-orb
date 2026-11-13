#!/usr/bin/env bash
set -euo pipefail

# Pinned AWS CLI version and SHA256 of each platform's release artifact.
# Bump all values together when upgrading. AWS publishes no checksums, so check the Linux
# zips' PGP signatures and the macOS package's signature before taking their SHA256. See:
#   https://raw.githubusercontent.com/aws/aws-cli/v2/CHANGELOG.rst
#   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-version.html
AWSCLI_VERSION="2.40.2"
AWSCLI_MACOS_SHA256="3b03319491c8cee675cf71310a43bfc48ee61c9d706ddbf5b6716d3a8c25d393"
AWSCLI_LINUX_X86_64_SHA256="a9ac0d635e97fab65e234ae1519fa6bd2b02d72120bf965a8ff6eaf7611f1833"
AWSCLI_LINUX_AARCH64_SHA256="ef8b0ab093d7924caa6fd7bbc6581b92c56332eb20b4062305ce6cf63da1f440"

AWSCLI_DIR="${AWSCLI_DIR:-$HOME/.revenuecat/aws-cli/$AWSCLI_VERSION}"

download_dir=""
token_file=""
cleanup() {
    if [ -n "$download_dir" ]; then rm -rf "$download_dir"; fi
    if [ -n "$token_file" ]; then rm -f "$token_file"; fi
}
trap cleanup EXIT

fail() {
    echo "Error: $*" >&2
    exit 1
}

verify_sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        echo "$1  $2" | sha256sum -c -
    else
        echo "$1  $2" | shasum -a 256 -c -
    fi
}

download() {
    curl -fsSL --connect-timeout 10 --max-time 300 --retry 3 --retry-connrefused -o "$1" "$2"
}

# Unpacks into a sibling directory and renames it into place, so an interrupted install
# never leaves a partial CLI behind for the next call to reuse.
install_aws_cli() {
    if [ -x "$AWSCLI_DIR/aws" ]; then
        return
    fi

    echo "Installing AWS CLI ${AWSCLI_VERSION} into ${AWSCLI_DIR}..."
    mkdir -p "$(dirname "$AWSCLI_DIR")"
    download_dir="$(mktemp -d "$(dirname "$AWSCLI_DIR")/.download.XXXXXX")"

    local unpacked
    case "$(uname -s)-$(uname -m)" in
        Darwin-*)
            download "$download_dir/awscli.pkg" "https://awscli.amazonaws.com/AWSCLIV2-${AWSCLI_VERSION}.pkg"
            verify_sha256 "$AWSCLI_MACOS_SHA256" "$download_dir/awscli.pkg"
            pkgutil --expand-full "$download_dir/awscli.pkg" "$download_dir/expanded"
            unpacked="$download_dir/expanded/aws-cli.pkg/Payload/aws-cli"
            ;;
        Linux-x86_64)
            command -v unzip >/dev/null 2>&1 || fail "unzip is required to install the AWS CLI."
            download "$download_dir/awscli.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip"
            verify_sha256 "$AWSCLI_LINUX_X86_64_SHA256" "$download_dir/awscli.zip"
            unzip -q "$download_dir/awscli.zip" -d "$download_dir"
            unpacked="$download_dir/aws/dist"
            ;;
        Linux-aarch64 | Linux-arm64)
            command -v unzip >/dev/null 2>&1 || fail "unzip is required to install the AWS CLI."
            download "$download_dir/awscli.zip" "https://awscli.amazonaws.com/awscli-exe-linux-aarch64-${AWSCLI_VERSION}.zip"
            verify_sha256 "$AWSCLI_LINUX_AARCH64_SHA256" "$download_dir/awscli.zip"
            unzip -q "$download_dir/awscli.zip" -d "$download_dir"
            unpacked="$download_dir/aws/dist"
            ;;
        *)
            fail "store-private-artifacts does not support $(uname -s) on $(uname -m)."
            ;;
    esac

    rm -rf "$AWSCLI_DIR"
    mv "$unpacked" "$AWSCLI_DIR"
}

destination="$(printf '%s' "$PARAMETERS_DESTINATION" | sed -E 's#/+#/#g; s#^/##; s#/$##')"
if [ -z "$destination" ]; then
    fail "destination must not be empty."
fi
case "/$destination/" in
    */./* | */../*) fail "destination must not contain '.' or '..' segments: $PARAMETERS_DESTINATION" ;;
esac

path="$PARAMETERS_PATH"
case "$path" in
    \~) path="$HOME" ;;
    \~/*) path="$HOME/${path#\~/}" ;;
esac

if [ ! -e "$path" ]; then
    echo "No file or directory at ${PARAMETERS_PATH}; nothing to upload."
    exit 0
fi
if [ -d "$path" ]; then
    if [ -z "$(find -L "$path" -type f -print 2>/dev/null | head -n 1 || true)" ]; then
        echo "${PARAMETERS_PATH} has no files; nothing to upload."
        exit 0
    fi
elif [ ! -f "$path" ]; then
    fail "${PARAMETERS_PATH} is neither a file nor a directory."
fi

# CircleCI gives jobs no OIDC token in builds of pull requests from forks, unless the
# project passes secrets to them. Those builds can't authenticate, so they skip the upload.
if [ -z "${CIRCLE_OIDC_TOKEN_V2:-}" ]; then
    echo "This job has no OIDC token, as in builds of pull requests from forks; skipping the upload of ${PARAMETERS_PATH}."
    exit 0
fi

for name in PRIVATE_ARTIFACTS_BUCKET PRIVATE_ARTIFACTS_REGION PRIVATE_ARTIFACTS_ROLE_ARN; do
    if [ -z "${!name:-}" ]; then
        fail "$name is not set. Add it to the job's environment, for example through a context."
    fi
done

install_aws_cli
"$AWSCLI_DIR/aws" --version

# The job's own token expires an hour after the job starts, so mint a fresh one. It goes
# straight to a file for the AWS CLI and is never held in a variable or printed.
token_file="$(mktemp)"
circleci run oidc get --claims "{\"aud\": \"${CIRCLE_ORGANIZATION_ID}\"}" | tr -d '\n' > "$token_file"
if ! grep -Eqx '[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+' "$token_file"; then
    fail "circleci run oidc get did not return a token."
fi

# Drop the job's own AWS configuration: static keys, profiles and credentials files would
# take precedence over the web identity, and the upload must only ever use the role.
while IFS= read -r name; do
    unset "$name"
done < <(compgen -e | grep '^AWS_' || true)
export AWS_CONFIG_FILE=/dev/null
export AWS_SHARED_CREDENTIALS_FILE=/dev/null
export AWS_EC2_METADATA_DISABLED=true
export AWS_PAGER=""
export AWS_REGION="$PRIVATE_ARTIFACTS_REGION"
export AWS_ROLE_ARN="$PRIVATE_ARTIFACTS_ROLE_ARN"
export AWS_WEB_IDENTITY_TOKEN_FILE="$token_file"
AWS_ROLE_SESSION_NAME="$(printf '%s' "circleci-${CIRCLE_PROJECT_REPONAME}-${CIRCLE_BUILD_NUM}" | tr -c 'A-Za-z0-9+=,.@_-' '-' | cut -c 1-64)"
export AWS_ROLE_SESSION_NAME

# Assume the role once up front: when that fails, the upload would print a traceback per file.
if ! role_session="$("$AWSCLI_DIR/aws" sts get-caller-identity --query Arn --output text)"; then
    fail "could not assume ${PRIVATE_ARTIFACTS_ROLE_ARN} with this job's OIDC token."
fi
echo "Authenticated as ${role_session}"

job_prefix="${CIRCLE_PROJECT_REPONAME}/${CIRCLE_BUILD_NUM}/${CIRCLE_NODE_INDEX:-0}"
target="s3://${PRIVATE_ARTIFACTS_BUCKET}/${job_prefix}/${destination}"

echo "Uploading ${PARAMETERS_PATH} to ${target}..."
if [ -d "$path" ]; then
    "$AWSCLI_DIR/aws" s3 cp "$path" "${target}/" --recursive --no-progress
else
    "$AWSCLI_DIR/aws" s3 cp "$path" "$target" --no-progress
fi

echo "Uploaded. Browse this job's private artifacts (AWS sign-in required):"
echo "https://${PRIVATE_ARTIFACTS_REGION}.console.aws.amazon.com/s3/buckets/${PRIVATE_ARTIFACTS_BUCKET}?region=${PRIVATE_ARTIFACTS_REGION}&prefix=${job_prefix}/"
