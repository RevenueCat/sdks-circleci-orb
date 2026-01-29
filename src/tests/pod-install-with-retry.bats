#!/usr/bin/env bats

# Tests for pod-install-with-retry.sh

setup() {
    # Load the script functions without executing
    source ./src/scripts/pod-install-with-retry.sh
}

@test "succeeds on first attempt when command succeeds" {
    export PARAM_POD_INSTALL_COMMAND="true"  # 'true' always succeeds
    export PARAM_MAX_RETRIES=3
    export PARAM_RETRY_WAIT_SECONDS=1

    run PodInstallWithRetry

    [ "$status" -eq 0 ]
    [[ "$output" == *"Pod install succeeded"* ]]
}

@test "fails after max retries when command always fails" {
    export PARAM_POD_INSTALL_COMMAND="false"  # 'false' always fails
    export PARAM_MAX_RETRIES=2
    export PARAM_RETRY_WAIT_SECONDS=1

    run PodInstallWithRetry

    [ "$status" -eq 1 ]
    [[ "$output" == *"Pod install failed after 2 attempts"* ]]
}

@test "retries and succeeds when command fails then succeeds" {
    # Create a temporary file to track attempts
    export ATTEMPT_FILE=$(mktemp)
    echo "0" > "$ATTEMPT_FILE"

    # Command that fails twice then succeeds
    export PARAM_POD_INSTALL_COMMAND='
        count=$(cat "$ATTEMPT_FILE");
        count=$((count + 1));
        echo "$count" > "$ATTEMPT_FILE";
        [ "$count" -ge 3 ]
    '
    export PARAM_MAX_RETRIES=5
    export PARAM_RETRY_WAIT_SECONDS=1

    run PodInstallWithRetry

    [ "$status" -eq 0 ]
    [[ "$output" == *"Pod install succeeded"* ]]
    [[ "$output" == *"Retrying pod install"* ]]

    rm -f "$ATTEMPT_FILE"
}

@test "uses default values when parameters not set" {
    unset PARAM_POD_INSTALL_COMMAND
    unset PARAM_MAX_RETRIES
    unset PARAM_RETRY_WAIT_SECONDS

    # Override the command to just echo and succeed
    export PARAM_POD_INSTALL_COMMAND="echo 'testing defaults'"

    run PodInstallWithRetry

    [ "$status" -eq 0 ]
    [[ "$output" == *"Max retries: 5"* ]]
    [[ "$output" == *"Wait between retries: 300s"* ]]
}

@test "shows retry count in output" {
    export PARAM_POD_INSTALL_COMMAND="false"
    export PARAM_MAX_RETRIES=3
    export PARAM_RETRY_WAIT_SECONDS=1

    run PodInstallWithRetry

    [[ "$output" == *"attempt 1/3"* ]]
    [[ "$output" == *"attempt 2/3"* ]]
}
