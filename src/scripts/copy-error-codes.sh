#!/usr/bin/env bash
set -euo pipefail

# Clones the error-codes SSOT repo and copies this platform's committed generated files.
# Files under generated/<platform>/ are byte-identical to `pnpm generate` output (enforced by
# the SSOT's golden test), so no JS toolchain is needed here.
#
# Inputs (environment):
#   PLATFORM  android|ios|js|kmp|flutter|hybridCommon
#   OUTPUTS   newline-delimited `source:destination` pairs, one per generated file
git clone --depth 1 git@github.com:RevenueCat/purchases-error-codes.git ../purchases-error-codes

echo "export ERROR_CODES_SHA=$(git -C ../purchases-error-codes rev-parse HEAD)" >> "${BASH_ENV}"

platform_dir="../purchases-error-codes/generated/${PLATFORM}"

# One `source:destination` pair per line. `source` names a file under generated/<platform>/;
# split on the first colon so destination paths are unaffected.
while IFS= read -r line; do
  [[ -z "${line}" ]] && continue
  if [[ "${line}" != *:* ]]; then
    echo "Malformed outputs line (expected 'source:destination'): ${line}" >&2
    exit 1
  fi
  destination="${line#*:}"
  mkdir -p "$(dirname "${destination}")"
  cp "${platform_dir}/${line%%:*}" "${destination}"
  echo "Copied ${line%%:*} -> ${destination}"
done <<< "${OUTPUTS}"
