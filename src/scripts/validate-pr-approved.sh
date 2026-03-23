#!/usr/bin/env bash
set -euo pipefail
echo "Verifying that the release PR has been approved by an org member with write permissions."
echo "This check prevents tagging a release before the PR is properly reviewed."
bundle exec fastlane run validate_pr_approved
