#!/bin/bash -e

sudo apt-get install -y shellcheck

echo -n "Testing shell linter..."

if ! find . -name '*.sh' -print0 | xargs -n1 -0 shellcheck -s bash; then
    echo "ERROR! :("
    exit 1
fi

echo "OK! :)"
