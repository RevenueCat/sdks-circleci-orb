#!/usr/bin/env bash

# OUTPUT and OUTPUTS are both injected via the job's `environment`; silence the
# "OUTPUT may not be assigned, did you mean OUTPUTS" heuristic.
# shellcheck disable=SC2153
set -euo pipefail

# Clones the error-codes SSOT repo and copies this platform's committed generated files.
# Files under generated/<platform>/ are byte-identical to `pnpm generate` output (enforced by
# the SSOT's golden test), so no JS toolchain is needed here.
#
# Inputs (environment):
#   PLATFORM  android|ios|js|kmp|flutter|hybridCommon
#   OUTPUTS   newline-delimited `source:destination` pairs (preferred, supports >1 file)
#   OUTPUT    legacy single destination path (used when OUTPUTS is empty)
git clone --depth 1 git@github.com:RevenueCat/purchases-error-codes.git ../purchases-error-codes

echo "export ERROR_CODES_SHA=$(git -C ../purchases-error-codes rev-parse HEAD)" >> "${BASH_ENV}"

ssot="../purchases-error-codes"
platform_dir="${ssot}/generated/${PLATFORM}"

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

copy() {
  local source="$1" destination="$2"
  mkdir -p "$(dirname "${destination}")"
  cp "${source}" "${destination}"
  echo "Copied ${source} -> ${destination}"
}

if [[ -n "${OUTPUTS:-}" ]]; then
  # New layout: one `source:destination` pair per line. `source` names a file under
  # generated/<platform>/; split on the first colon so destination paths are unaffected.
  while IFS= read -r line; do
    line="$(trim "${line}")"
    [[ -z "${line}" ]] && continue
    if [[ "${line}" != *:* ]]; then
      echo "Malformed outputs line (expected 'source:destination'): ${line}" >&2
      exit 1
    fi
    source="$(trim "${line%%:*}")"
    destination="$(trim "${line#*:}")"
    copy "${platform_dir}/${source}" "${destination}"
  done <<< "${OUTPUTS}"
elif [[ -n "${OUTPUT:-}" ]]; then
  # Legacy single-file form. Prefer the per-platform directory (new SSOT layout); fall back
  # to the old flat generated/<platform>.* while the SSOT migration is in flight.
  mkdir -p "$(dirname "${OUTPUT}")"
  if [[ -d "${platform_dir}" ]]; then
    platform_files=("${platform_dir}"/*)
    if [[ ${#platform_files[@]} -ne 1 ]]; then
      echo "Platform ${PLATFORM} produces ${#platform_files[@]} files; use the 'outputs' parameter instead of 'output'." >&2
      exit 1
    fi
    cp "${platform_files[0]}" "${OUTPUT}"
  else
    cp "${ssot}"/generated/"${PLATFORM}".* "${OUTPUT}"
  fi
else
  echo "Neither 'outputs' nor 'output' is set; nothing to copy." >&2
  exit 1
fi
