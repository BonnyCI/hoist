#!/bin/bash

set -eu

. /etc/default/cideploy-ansible

if [[ -z "${ANSIBLE_SERIALIZED:-}" ]] ; then
    export ANSIBLE_SERIALIZED=1
    exec run-one $0 "$@"
fi

set +u
. /opt/ansible/bin/activate
set -u

logtag=$(basename $ANSIBLE_PLAYBOOK)_$(date +%Y%m%m%H%M%S)

cd $ANSIBLE_ROOT
git pull
ansible-galaxy install -r requirements.yml
ansible-playbook -i $ANSIBLE_INVENTORY $ANSIBLE_PLAYBOOK >> /var/www/html/cron-logs/cideploy_$logtag.log 2>&1
