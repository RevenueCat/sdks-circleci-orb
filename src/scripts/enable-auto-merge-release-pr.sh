#!/bin/bash

bundle exec fastlane run enable_auto_merge_for_pr \
    repo_name:${REPO_NAME} \
    branch:release/$(cat "${VERSION_FILE}" | tr -d '\n')
