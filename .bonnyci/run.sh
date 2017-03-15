#!/bin/bash -xe

venv_dir=$(mktemp -d)
trap 'rm -rf $venv_dir' EXIT

virtualenv "$venv_dir"
source "$venv_dir"/bin/activate

# Install all requirements for tests to run
if test -r test-requirements.txt; then
    pip install -r test-requirements.txt
fi

if test -r requirements.txt; then
    pip install -r requirements.txt
fi

if test -r requirements.yml; then
    ansible-galaxy install -r install -r requirements.yml
fi

if ! run-parts --verbose --exit-on-error --regex '^test.*$' tests/; then
  rc=1
else
  rc=0
fi

./tests/debug_failure.py

exit $?
