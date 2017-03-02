#!/bin/bash

export ANSIBLE_CONFIG=/vagrant/ansible.cfg
export ANSIBLE_INVENTORY=/vagrant/inventory/vagrant
ansible-playbook -v -e @/vagrant/secrets.yml -e ansible_user=ubuntu --skip-tags monitoring /vagrant/install-ci.yml "$@"
