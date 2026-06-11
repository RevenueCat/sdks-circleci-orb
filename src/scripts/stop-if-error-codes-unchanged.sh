#!/usr/bin/env bash
set -euo pipefail

# Halts the job (success) when the generated file is unchanged, skipping the API dump and PR.
# Inputs (environment): OUTPUT (repo-root-relative path of the generated file).
if git diff --quiet -- "${OUTPUT}"; then
  echo "Generated error codes are up to date. Nothing to do."
  circleci-agent step halt
fi
