find . -mindepth 2 -name "*.gradle" -type f | sort | xargs shasum > gradle-checksums.txt
cat gradle-checksums.txt
date +"%Y/%m/%d" > date.txt