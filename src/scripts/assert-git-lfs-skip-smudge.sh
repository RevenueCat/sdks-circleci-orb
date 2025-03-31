#!/bin/bash
if [ "$GIT_LFS_SKIP_SMUDGE" != "1" ]; then
  echo "Error: GIT_LFS_SKIP_SMUDGE is not set to 1, but it's set to '$GIT_LFS_SKIP_SMUDGE'"
  echo "If GIT_LFS_SKIP_SMUDGE is not set to 1, a regular checkout will download all LFS files anyway, and using checkout-with-lfs is pointless."
  echo "A good place to do this is in the CircleCI Environment Variables settings."
  echo "https://app.circleci.com/settings/project/github/RevenueCat/purchases-android/environment-variables"
  exit 1
fi