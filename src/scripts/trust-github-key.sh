#!/bin/bash
mkdir -p ~/.ssh
ssh-keyscan -t ed25519,ecdsa,rsa github.com >> ~/.ssh/known_hosts 2>/dev/null