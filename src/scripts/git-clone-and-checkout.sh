#!/usr/bin/env bash

set -euo pipefail

cd ~/ && git clone "$CIRCLE_REPOSITORY_URL" && cd "$CIRCLE_PROJECT_REPONAME" && git checkout "$CIRCLE_SHA1"
