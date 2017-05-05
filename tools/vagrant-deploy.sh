#!/bin/bash

vagrant up
vagrant ssh -c "sudo -i -u cideploy /vagrant/tools/vagrant-run-ansible.sh $*" bastion
