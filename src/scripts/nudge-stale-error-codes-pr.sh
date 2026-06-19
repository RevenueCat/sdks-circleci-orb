#!/usr/bin/env bash
set -euo pipefail

# Nudges the open update-error-codes PR when it has been ignored for over a day. Runs after the PR
# was opened/updated, so reaching here means the codes drifted from the SSOT; a PR just opened by
# this run is younger than the threshold and is left alone. Daily scheduling keeps this to one ping
# per day. Uses the GITHUB_TOKEN the PR step already requires.

repo="RevenueCat/$(basename -s .git "$(git config --get remote.origin.url)")"

gh_api() {
  curl --silent --show-error --fail --location \
    --header "Authorization: Bearer ${GITHUB_TOKEN}" \
    --header "Accept: application/vnd.github+json" \
    "$@"
}

pr="$(gh_api "https://api.github.com/repos/${repo}/pulls?head=RevenueCat:update-error-codes&state=open")" || {
  echo "Could not query open PRs; skipping nudge." >&2
  exit 0
}

number="$(jq -r '.[0].number // empty' <<<"$pr")"
if [[ -z "$number" ]]; then
  echo "No open update-error-codes PR; nothing to nudge."
  exit 0
fi

created_at="$(jq -r '.[0].created_at' <<<"$pr")"
created_epoch="$(date -u -d "$created_at" +%s)"
age_hours=$(( ($(date -u +%s) - created_epoch) / 3600 ))
if (( age_hours < 24 )); then
  echo "PR #${number} is ${age_hours}h old (< 24h); not nudging yet."
  exit 0
fi

# shellcheck disable=SC2016  # backticks are literal markdown; no shell expansion intended
body='@RevenueCat/coresdk this `update-error-codes` PR has been open for over a day. The generated error codes have drifted from the [SSOT](https://github.com/RevenueCat/purchases-error-codes); please review and merge.'
if gh_api --data "$(jq -n --arg body "$body" '{body: $body}')" \
    "https://api.github.com/repos/${repo}/issues/${number}/comments" > /dev/null; then
  echo "Nudged PR #${number}."
else
  echo "Failed to comment on PR #${number}; continuing." >&2
fi
