#!/bin/bash
pip install shyaml
PUBKEY=$(shyaml get-value secrets.ssh_keys.cideploy.public < /vagrant/secrets.yml.examle)

if grep -q "$PUBKEY" ~ubuntu/.ssh/authorized_keys ; then
    echo Key already authorized
else
    echo "$PUBKEY" >> ~ubuntu/.ssh/authorized_keys
fi
