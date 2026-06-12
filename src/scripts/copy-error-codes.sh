#!/usr/bin/env bash
set -euo pipefail

# Clones the error-codes SSOT repo and copies this platform's committed generated file.
# The file under generated/<platform> is byte-identical to `pnpm generate` output
# (enforced by the SSOT's golden test), so no JS toolchain is needed here.
# Inputs (environment): PLATFORM (android|ios|js), OUTPUT (repo-root-relative destination).
git clone --depth 1 git@github.com:RevenueCat/purchases-error-codes.git ../purchases-error-codes

echo "export ERROR_CODES_SHA=$(git -C ../purchases-error-codes rev-parse HEAD)" >> "${BASH_ENV}"

cp ../purchases-error-codes/generated/"${PLATFORM}".* "${OUTPUT}"
