#!/usr/bin/env bash

# OUTPUT and OUTPUTS are both injected via the job's `environment`; silence the
# "OUTPUT may not be assigned, did you mean OUTPUTS" heuristic.
# shellcheck disable=SC2153
set -euo pipefail

# Halts the job (success) when every generated file is unchanged, skipping the API dump and PR.
# Uses `git status --porcelain` (not `git diff`) so a brand-new untracked file or a
# staged change still counts as "changed" — `git diff --quiet` reports untracked files
# as no-change and would wrongly halt on first adoption of a new platform.
#
# Inputs (environment):
#   OUTPUTS  newline-delimited `source:destination` pairs (preferred)
#   OUTPUT   legacy single destination path (used when OUTPUTS is empty)
trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

destinations=()
if [[ -n "${OUTPUTS:-}" ]]; then
  while IFS= read -r line; do
    line="$(trim "${line}")"
    [[ -z "${line}" ]] && continue
    destinations+=("$(trim "${line#*:}")")
  done <<< "${OUTPUTS}"
else
  destinations+=("${OUTPUT}")
fi

if [ -z "$(git status --porcelain -- "${destinations[@]}")" ]; then
  echo "Generated error codes are up to date. Nothing to do."
  circleci-agent step halt
fi
