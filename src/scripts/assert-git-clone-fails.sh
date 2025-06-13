#!/usr/bin/env bash

set -euo pipefail

if git clone "git@<< parameters.host >>:<< parameters.owner >>/<< parameters.repository >>.git"; then
    exit 1
fi
