#!/bin/bash

apt-get update
apt-get -y install build-essential python python-dev libffi-dev libssl-dev
pip install ansible
