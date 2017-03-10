#!/bin/bash

export ANSIBLE_CONFIG=/vagrant/ansible.cfg
export ANSIBLE_INVENTORY=/vagrant/inventory/vagrant
/opt/ansible/bin/ansible-playbook -v -e @/vagrant/secrets.yml -e ansible_user=ubuntu --skip-tags monitoring,letsencrypt /vagrant/install-ci.yml "$@"
/opt/ansible/bin/ansible-playbook -v -e @/vagrant/secrets.yml -e ansible_user=ubuntu /vagrant/tests/validate-ci.yml "$@"
