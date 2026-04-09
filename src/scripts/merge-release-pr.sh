#!/usr/bin/env bash
set -euo pipefail

if [ -n "${VERSION}" ]; then
    version="${VERSION}"
else
    version="$(tr -d '\n' < "${VERSION_FILE}")"
fi

using_merge_queue=false
merge_queue_arg=""
if [ "${USE_MERGE_QUEUE}" = "1" ] || [ "${USE_MERGE_QUEUE}" = "true" ]; then
    using_merge_queue=true
    merge_queue_arg="use_merge_queue:true"
fi

merge_exit_code=0
bundle exec fastlane run merge_pr \
    repo_name:"${REPO_NAME}" \
    branch:"release/${version}" \
    merge_method:"${MERGE_METHOD}" \
    ${merge_queue_arg} || merge_exit_code=$?

if [ "${merge_exit_code}" -eq 0 ]; then
    exit 0
fi

if [ "${using_merge_queue}" = true ]; then
    echo "Merge queue enqueue failed."
    exit "${merge_exit_code}"
fi

echo "Direct merge failed. Enabling auto-merge and updating branch..."

bundle exec fastlane run enable_auto_merge_for_pr \
    repo_name:"${REPO_NAME}" \
    branch:"release/${version}" \
    merge_method:"${MERGE_METHOD}"

bundle exec fastlane run update_pr_branch \
    repo_name:"${REPO_NAME}" \
    branch:"release/${version}"

echo "Auto-merge enabled and branch updated. The PR will merge automatically once CI passes."
