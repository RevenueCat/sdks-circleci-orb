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

# On success we must NOT call `exit` explicitly. This script runs in a login
# shell (bash --login) and the `exit` builtin makes bash source ~/.bash_logout,
# whose default `clear_console` command exits non-zero when there is no
# controlling TTY (as in CI). With `set -e` still active that failure would
# override our status and turn a successful merge into a job failure. Falling
# off the end of the script does not source ~/.bash_logout, so the success path
# does nothing here and simply lets the script end.
if [ "${merge_exit_code}" -ne 0 ]; then
    # The job fails on any non-zero exit, so the ~/.bash_logout caveat above is
    # harmless here; the original code is logged so it isn't lost.
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
fi
