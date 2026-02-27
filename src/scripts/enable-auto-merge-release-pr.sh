#!/bin/bash

if [ -n "${VERSION}" ]; then
    version="${VERSION}"
else
    version="$(tr -d '\n' < "${VERSION_FILE}")"
fi

bundle exec fastlane run enable_auto_merge_for_pr \
    repo_name:"${REPO_NAME}" \
    branch:"release/${version}"
