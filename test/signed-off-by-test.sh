#!/bin/bash

first_signed_off_commit="93a80b421560de540ecaf85850074e851cecf2b1"
success="true"

for commit in $(git log --pretty=oneline $first_signed_off_commit..HEAD | cut -d " " -f 1)
do
    if $(git show $commit | grep -q Signed-off-by ); then
        :
    else
        if $(git show --format='%s' | egrep '^Merge [0-9a-f]* into [0-9a-f]*$' >/dev/null); then
            echo "Github generated merge commit detected, skipping"
            continue
        fi
        echo "Commit $commit doesn't have a Signed-off-by"
        git show $commit
        success="false"
    fi

done

if [ "$success" = "true" ]; then
    echo "All commits have a Signed-off-by"
else
    echo "Some commits do not have a Signed-off-by, failing"
    echo "Fix is probably (git commit --amend -s)"
    exit 1
fi
