#!/usr/bin/env bash
set -euo pipefail

# Commits the regenerated files and opens/updates the error-codes PR.
# Inputs (environment): ERROR_CODES_SHA (source commit), COMMIT_PATHS (comma-separated, may be empty).
repo_name="$(basename -s .git "$(git config --get remote.origin.url)")"

# The PR step runs fastlane; this orb job is platform-agnostic and does not install gems
# itself, so the consumer's update_api_steps must (e.g. install-gem-unix-dependencies /
# install-dependencies). Fail fast with a clear message instead of a cryptic fastlane error.
if ! bundle check > /dev/null 2>&1; then
  echo "Gems are not installed (bundle check failed). The job's update_api_steps must install gems before the PR step." >&2
  exit 1
fi

bundle exec fastlane run commit_and_create_pr_if_necessary \
    repo_name:"${repo_name}" \
    branch_name:"update-error-codes" \
    commit_message:"[Automated] Update generated error codes (purchases-error-codes@${ERROR_CODES_SHA})" \
    title:"[AUTOMATIC] Update generated error codes" \
    body:"Automatic update of generated error codes from https://github.com/RevenueCat/purchases-error-codes/commit/${ERROR_CODES_SHA}. This branch is auto-regenerated and force-pushed on each update; manual changes pushed here will be overwritten." \
    labels:"pr:other,pr:auto_codegen" \
    commit_paths:"${COMMIT_PATHS}"
