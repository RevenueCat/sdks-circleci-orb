#!/usr/bin/env bash
set -euo pipefail

# Clones the error-codes SSOT repo and regenerates this repo's platform file from it.
# Uses the SSOT repo's own mise-pinned node/pnpm so the consumer doesn't need a JS toolchain.
# Inputs (environment): PLATFORM (android|ios|js), OUTPUT (repo-root-relative path to write).
git clone --depth 1 git@github.com:RevenueCat/purchases-error-codes.git ../purchases-error-codes

repo_root="${PWD}"
cd ../purchases-error-codes
mise install
echo "export ERROR_CODES_SHA=$(git rev-parse HEAD)" >> "${BASH_ENV}"
mise exec -- pnpm install --frozen-lockfile
mise exec -- pnpm --silent generate --platform "${PLATFORM}" > "${repo_root}/${OUTPUT}"
