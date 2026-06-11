#!/usr/bin/env bash
set -euo pipefail

# Resets the local update-error-codes branch to the latest main so re-runs are idempotent.
git fetch origin
git checkout -B update-error-codes origin/main
