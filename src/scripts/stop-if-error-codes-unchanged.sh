#!/usr/bin/env bash
set -euo pipefail

# Halts the job (success) when the generated file is unchanged, skipping the API dump and PR.
# Uses `git status --porcelain` (not `git diff`) so a brand-new untracked file or a
# staged change still counts as "changed" — `git diff --quiet` reports untracked files
# as no-change and would wrongly halt on first adoption of a new platform.
# Inputs (environment): OUTPUT (repo-root-relative path of the generated file).
if [ -z "$(git status --porcelain -- "${OUTPUT}")" ]; then
  echo "Generated error codes are up to date. Nothing to do."
  circleci-agent step halt
fi
