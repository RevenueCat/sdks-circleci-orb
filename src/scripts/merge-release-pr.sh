#!/usr/bin/env bash
set -euo pipefail

if [ -n "${VERSION}" ]; then
    version="${VERSION}"
else
    version="$(tr -d '\n' < "${VERSION_FILE}")"
fi

release_branch="release/${version}"

using_merge_queue=false
merge_queue_arg=""
if [ "${USE_MERGE_QUEUE}" = "1" ] || [ "${USE_MERGE_QUEUE}" = "true" ]; then
    using_merge_queue=true
    merge_queue_arg="use_merge_queue:true"
fi

merge_exit_code=0
bundle exec fastlane run merge_pr \
    repo_name:"${REPO_NAME}" \
    branch:"${release_branch}" \
    merge_method:"${MERGE_METHOD}" \
    ${merge_queue_arg} || merge_exit_code=$?

# This script runs in a login shell (bash --login) with `set -e`. Using the
# `exit` builtin makes bash source ~/.bash_logout, whose default `clear_console`
# command exits non-zero when there is no controlling TTY (as in CI). With
# `set -e` still active that failure overrides our intended status, which would
# turn a successful merge into a job failure. Disabling `set -e` here preserves
# the `exit 0`. Paths that fall off the end of the script do not source
# ~/.bash_logout, so they are unaffected.
if [ "${merge_exit_code}" -eq 0 ]; then
    set +e
    exit 0
fi

# The job fails on any non-zero exit, so there's no need to disable `set -e`
# here even though ~/.bash_logout may rewrite the exact code (see above). The
# original code is logged below so it isn't lost.
if [ "${using_merge_queue}" = true ]; then
    echo "Merge queue enqueue failed (exit code ${merge_exit_code})."
    exit "${merge_exit_code}"
fi

echo "Direct merge failed. Enabling auto-merge and updating branch..."

bundle exec fastlane run enable_auto_merge_for_pr \
    repo_name:"${REPO_NAME}" \
    branch:"${release_branch}" \
    merge_method:"${MERGE_METHOD}"

bundle exec fastlane run update_pr_branch \
    repo_name:"${REPO_NAME}" \
    branch:"${release_branch}"

echo "Auto-merge enabled and branch updated. The PR will merge automatically once CI passes."
