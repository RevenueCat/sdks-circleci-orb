#!/usr/bin/env bash
set -euo pipefail

# Commits the regenerated files and opens/updates the error-codes PR.
# Inputs (environment): ERROR_CODES_SHA (source commit), COMMIT_PATHS (comma-separated, may be empty).
repo_name="$(basename -s .git "$(git config --get remote.origin.url)")"

bundle exec fastlane run commit_and_create_pr_if_necessary \
    repo_name:"${repo_name}" \
    branch_name:"update-error-codes" \
    commit_message:"[Automated] Update generated error codes (purchases-error-codes@${ERROR_CODES_SHA})" \
    title:"[AUTOMATIC] Update generated error codes" \
    body:"Automatic update of generated error codes from https://github.com/RevenueCat/purchases-error-codes/commit/${ERROR_CODES_SHA}" \
    labels:"pr:other,auto:codegen" \
    commit_paths:"${COMMIT_PATHS}"
