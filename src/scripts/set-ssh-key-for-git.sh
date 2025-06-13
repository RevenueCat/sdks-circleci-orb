#!/usr/bin/env bash

set -euo pipefail

key_found=false
for key in ~/.ssh/*; do
    if [ -f "$key" ]; then
        sha256=$(ssh-keygen -lf "$key" -E sha256 | awk '{print $2}')
        if [ "$sha256" = "<< parameters.fingerprint >>" ]; then
            echo "export GIT_SSH_COMMAND=\"ssh -i $key\"" >> "$BASH_ENV"
            key_found=true
            break
        fi
    fi
done
if [ "$key_found" = false ]; then
    echo "Error: SSH key with fingerprint << parameters.fingerprint >> not found"
    exit 1
fi
