#!/bin/bash

success="true"

for commit in $(git cherry master | cut -d " " -f 2)
do
    if ! git show -s "$commit" | grep -q 'Signed-off-by:'; then
        echo "Commit $commit doesn't have a Signed-off-by"
        git show "$commit"
        success="false"
    fi
done

if [ "$success" = "true" ]; then
    echo "All commits have a Signed-off-by"
else
    echo "Some commits do not have a Signed-off-by, failing..."
    echo "Fix is probably (git commit --amend -s)"
    exit 1
fi
