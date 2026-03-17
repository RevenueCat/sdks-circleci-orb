#!/bin/bash

if [ -n "${VERSION}" ]; then
    version="${VERSION}"
else
    version="$(tr -d '\n' < "${VERSION_FILE}")"
fi

bundle exec fastlane run merge_pr \
    repo_name:"${REPO_NAME}" \
    branch:"release/${version}" \
    merge_method:"${MERGE_METHOD}"
