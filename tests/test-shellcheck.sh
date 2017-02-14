#!/bin/bash -e

sudo apt-get install -y shellcheck

echo -n "Testing shell linter..."

find . -name '*.sh' -print0 | xargs -n1 -0 shellcheck -s bash -e SC2046

echo "OK! :)"
