#!/usr/bin/env bash

set -euo pipefail

key_found=false
for key in ~/.ssh/*; do
    if [ -f "$key" ]; then
        if sha256=$(ssh-keygen -lf "$key" -E sha256 2>/dev/null | awk '{print $2}' 2>/dev/null); then
            if [ "$sha256" = "$PARAMETERS_FINGERPRINT" ]; then
                echo "export GIT_SSH_COMMAND=\"ssh -i $key\"" >> "$BASH_ENV"
                key_found=true
                break
            fi
        fi
    fi
done
if [ "$key_found" = false ]; then
    echo "Error: SSH key with fingerprint $PARAMETERS_FINGERPRINT not found"
    exit 1
fi
