#!/bin/bash

vagrant up
vagrant ssh bastion -c 'sudo -i -u cideploy ANSIBLE_CONFIG=/vagrant/ansible.cfg /opt/ansible/bin/ansible-playbook -i /vagrant/inventory/vagrant -v -e @/vagrant/secrets.yml -e ansible_user=ubuntu --skip-tags monitoring,letsencrypt /vagrant/install-ci.yml /vagrant/tests/files/validate-ci.yml "$@"'
