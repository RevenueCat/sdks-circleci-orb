#!/bin/bash
set -euo pipefail

POLL_INTERVAL="${POLL_INTERVAL:-30}"
TIMEOUT="${TIMEOUT:-1800}"

if [[ -z "${COORDINATES:-}" ]]; then
  echo "Error: COORDINATES is not set or empty."
  exit 1
fi

declare -a pending_coords=()

while IFS= read -r line || [[ -n "$line" ]]; do
  coord="$(echo "$line" | xargs)"
  [[ -z "$coord" ]] && continue

  IFS=':' read -r group_id artifact_id version <<< "$coord"
  if [[ -z "$group_id" || -z "$artifact_id" || -z "$version" ]]; then
    echo "Error: Invalid coordinate '$coord'. Expected format groupId:artifactId:version"
    exit 1
  fi

  pending_coords+=("$coord")
done <<< "$COORDINATES"

if [[ ${#pending_coords[@]} -eq 0 ]]; then
  echo "Error: No valid coordinates provided."
  exit 1
fi

echo "Waiting for ${#pending_coords[@]} artifact(s) to appear on Maven Central:"
for coord in "${pending_coords[@]}"; do
  echo "  - $coord"
done
echo ""

build_url() {
  local group_id="$1"
  local artifact_id="$2"
  local version="$3"
  local group_path="${group_id//\.//}"
  echo "https://repo1.maven.org/maven2/${group_path}/${artifact_id}/${version}/${artifact_id}-${version}.pom"
}

elapsed=0

while [[ ${#pending_coords[@]} -gt 0 ]]; do
  if [[ $elapsed -ge $TIMEOUT ]]; then
    echo ""
    echo "Error: Timed out after ${TIMEOUT}s. The following artifacts are still not available:"
    for coord in "${pending_coords[@]}"; do
      echo "  - $coord"
    done
    exit 1
  fi

  still_pending=()

  for coord in "${pending_coords[@]}"; do
    IFS=':' read -r group_id artifact_id version <<< "$coord"
    url="$(build_url "$group_id" "$artifact_id" "$version")"

    if curl --head --fail --silent --output /dev/null "$url"; then
      echo "  Available: $coord"
    else
      still_pending+=("$coord")
    fi
  done

  pending_coords=("${still_pending[@]+"${still_pending[@]}"}")

  if [[ ${#pending_coords[@]} -eq 0 ]]; then
    break
  fi

  echo "[${elapsed}s/${TIMEOUT}s] Still waiting for ${#pending_coords[@]} artifact(s)..."
  sleep "$POLL_INTERVAL"
  elapsed=$((elapsed + POLL_INTERVAL))
done

echo ""
echo "All artifacts are available on Maven Central."
