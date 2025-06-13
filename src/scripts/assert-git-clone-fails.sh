#!/usr/bin/env bash

set -euo pipefail

if git clone "git@$PARAMETERS_HOST:$PARAMETERS_OWNER/$PARAMETERS_REPOSITORY.git"; then
    exit 1
fi
