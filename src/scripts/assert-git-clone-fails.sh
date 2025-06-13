#!/usr/bin/env bash

set -euo pipefail

git clone git@<< parameters.host >>:<< parameters.owner >>/<< parameters.repository >>.git && exit 1 || true
