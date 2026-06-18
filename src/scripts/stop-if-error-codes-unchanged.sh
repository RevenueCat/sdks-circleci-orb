#!/usr/bin/env bash
set -euo pipefail

# Halts the job (success) when every generated file is unchanged, skipping the API dump and PR.
# Uses `git status --porcelain` (not `git diff`) so a brand-new untracked file or a
# staged change still counts as "changed" — `git diff --quiet` reports untracked files
# as no-change and would wrongly halt on first adoption of a new platform.
#
# Inputs (environment):
#   OUTPUTS  newline-delimited `source:destination` pairs
destinations=()
while IFS= read -r line; do
  [[ -z "${line}" ]] && continue
  destinations+=("${line#*:}")
done <<< "${OUTPUTS}"

if [[ ${#destinations[@]} -eq 0 ]]; then
  echo "No destination paths resolved from 'outputs'." >&2
  exit 1
fi

if [ -z "$(git status --porcelain -- "${destinations[@]}")" ]; then
  echo "Generated error codes are up to date. Nothing to do."
  circleci-agent step halt
fi
