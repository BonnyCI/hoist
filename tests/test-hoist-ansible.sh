#!/bin/bash -ex

echo "Running hoist ansible syntax test"
ansible-playbook -i tests/files/test-inventory --syntax-check $(find . tests -maxdepth 1 -type f -name \*.yml -not -name .travis.yml)

echo "Running hoist ansible deployment test"
ansible-playbook -i inventory/nodepool.py install-ci.yml --skip-tags monitoring,letsencrypt -e @secrets.yml.example
ansible-playbook -i inventory/nodepool.py tests/files/validate-ci.yml
