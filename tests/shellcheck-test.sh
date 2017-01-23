#!/bin/bash

sudo apt-get install -y shellcheck

find . -name '*.sh' -print0 | xargs -n1 -0 shellcheck -s bash
