#!/bin/bash -ex

echo "Running hoist ansible syntax test"
ansible-playbook -i /dev/null --syntax-check $(find . tests -maxdepth 1 -type f -name \*.yml -not -name .travis.yml)

echo "Running hoist ansible deployment test"
ansible-playbook -i inventory/nodepool.py install-ci.yml --skip-tags monitoring -e @secrets.yml.example
ansible-playbook -i inventory/nodepool.py tests/validate-ci.yml
