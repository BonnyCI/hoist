#!/bin/bash

vagrant up
vagrant ssh bastion -c 'sudo -i -u cideploy /vagrant/tools/vagrant-run-ansible.sh "$@"'
