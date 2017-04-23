#!/bin/bash -ex

EXPECTED_CHANGE_NUMBER="logs.multinode changed=0, nodepool.multinode changed=2, zuul.multinode changed=0"
touch second_run.txt
trap 'rm second_run.out' EXIT

echo "Running hoist ansible syntax test"
# shellcheck disable=2046
ansible-playbook -vvvvv -i tests/files/test-inventory --syntax-check $(find . tests -maxdepth 1 -type f -name \*.yml -not -name .travis.yml)

echo "Running hoist ansible deployment test"
ansible-playbook -i inventory/nodepool.py install-ci.yml --skip-tags monitoring,letsencrypt -e @secrets.yml.example
ansible-playbook -vvvv -i inventory/nodepool.py tests/files/validate-ci.yml

echo "Running hoist ansible deployment test again, and check for expected number of changes"
ansible-playbook -i inventory/nodepool.py install-ci.yml --skip-tags monitoring,letsencrypt -e @secrets.yml.example | tee second_run.out
# shellcheck disable=SC2016
ACTUAL_CHANGE_NUMBER=$(grep "changed=" second_run.out | awk '{ print $1" "$4 }' |  sed -n -e 'H;${x;s/\n/, /g;s/^, //;p;}')
if ! [[ "$ACTUAL_CHANGE_NUMBER" == "$EXPECTED_CHANGE_NUMBER" ]]; then
    echo "We expected \"$EXPECTED_CHANGE_NUMBER\" of items to change on a second run, but found \"$ACTUAL_CHANGE_NUMBER\"."
    exit 1
fi
