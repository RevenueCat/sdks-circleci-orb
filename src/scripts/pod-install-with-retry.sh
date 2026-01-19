#!/usr/bin/env bash
set -uo pipefail

# Pod install with retry mechanism for when CocoaPods CDN hasn't propagated new versions yet
# Parameters are passed via environment variables:
#   PARAM_POD_INSTALL_COMMAND - The pod install command to run
#   PARAM_MAX_RETRIES - Maximum number of retry attempts (default: 5)
#   PARAM_RETRY_WAIT_SECONDS - Seconds to wait between retries (default: 300)

PodInstallWithRetry() {
    local pod_install_command="${PARAM_POD_INSTALL_COMMAND:-bundle exec pod install --repo-update}"
    local max_retries="${PARAM_MAX_RETRIES:-5}"
    local retry_wait="${PARAM_RETRY_WAIT_SECONDS:-300}"
    local retry_count=0

    echo "Running: $pod_install_command"
    echo "Max retries: $max_retries, Wait between retries: ${retry_wait}s"

    until eval "$pod_install_command"; do
        retry_count=$((retry_count + 1))
        if [ "$retry_count" -ge "$max_retries" ]; then
            echo "❌ Pod install failed after $max_retries attempts"
            return 1
        fi
        echo "⚠️  Pod install failed (attempt $retry_count/$max_retries)"
        echo "⏳ Waiting $retry_wait seconds before retrying (CocoaPods CDN may not have propagated yet)..."
        sleep "$retry_wait"
        echo "🔄 Retrying pod install..."
    done

    echo "✅ Pod install succeeded"
}

# Will not run if sourced for bats-core testing
TEST_ENV="bats-core"
if [ "${0#*"$TEST_ENV"}" == "$0" ]; then
    PodInstallWithRetry
fi
