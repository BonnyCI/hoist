#!/bin/bash
if ! which python ; then
    apt-get update
    apt-get -y install python
fi

if ! which pip ; then
    wget -O get-pip.py https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
fi
