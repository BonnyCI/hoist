#!/bin/bash
pip install shyaml
PUBKEY=$(cat /vagrant/secrets.yml.example | shyaml get-value secrets.ssh_keys.cideploy.public)

if grep -q "$PUBKEY" ~ubuntu/.ssh/authorized_keys ; then
    echo Key already authorized
else
    echo "$PUBKEY" >> ~ubuntu/.ssh/authorized_keys
fi
