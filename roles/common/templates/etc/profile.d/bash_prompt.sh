#!/bin/sh
# shellcheck disable=2154
PROMPT_COMMAND="export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h[{{ environment_name }}]\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '"
