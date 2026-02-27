#!/bin/bash

bundle exec fastlane run enable_auto_merge_for_pr \
    repo_name:"${REPO_NAME}" \
    branch:"release/$(tr -d '\n' < "${VERSION_FILE}")"
