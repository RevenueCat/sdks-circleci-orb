#!/usr/bin/env bats

# Test for install-swiftlint.sh script

setup() {
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/.local/share/mise/shims:$PATH"
}

@test "swiftlint is installed and accessible" {
    run swiftlint version
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "mise has swiftlint plugin installed" {
    run mise plugins list
    [ "$status" -eq 0 ]
    [[ "$output" =~ swiftlint ]]
}

@test "swiftlint version matches mise.toml specification" {
    # Get the version from mise.toml
    expected_version=$(grep 'swiftlint' mise.toml | sed 's/.*= *"\([^"]*\)".*/\1/')
    
    # Get installed version
    actual_version=$(swiftlint version)
    
    [ "$expected_version" = "$actual_version" ]
}

