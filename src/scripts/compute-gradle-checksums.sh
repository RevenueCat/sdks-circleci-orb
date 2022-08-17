#!/bin/bash
# This finds all *.gradle files (apart from the root build.gradle) and generates checksums for caching
find . -mindepth 2 -name "*.gradle" -type f | sort | xargs shasum > gradle-checksums.txt
cat gradle-checksums.txt
# Output the current date in order to prevent a very stale cache
date +"%Y/%m/%d" > date.txt