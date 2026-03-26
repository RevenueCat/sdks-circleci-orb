#!/usr/bin/env bash
set -euo pipefail

if [ -n "${VERSION}" ]; then
    version="${VERSION}"
else
    version="$(tr -d '\n' < "${VERSION_FILE}")"
fi

echo "DEBUG: USE_MERGE_QUEUE raw value: '${USE_MERGE_QUEUE}'"
merge_queue_arg=""
if [ "${USE_MERGE_QUEUE}" = "true" ] || [ "${USE_MERGE_QUEUE}" = "1" ]; then
    merge_queue_arg="use_merge_queue:true"
fi
echo "DEBUG: merge_queue_arg='${merge_queue_arg}'"

bundle exec fastlane run merge_pr \
    repo_name:"${REPO_NAME}" \
    branch:"release/${version}" \
    merge_method:"${MERGE_METHOD}" \
    ${merge_queue_arg}
