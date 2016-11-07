#!/bin/bash
# Runs system wide ansible configured in /etc
set -eu

. /etc/default/system-ansible

if [[ -z "${SYS_ANSIBLE_SERIALIZED:-}" ]] ; then
    export SYS_ANSIBLE_SERIALIZED=1
    exec run-one $0 "$@"
fi

set +u
. /opt/ansible/bin/activate
set -u

logtag=$(basename $SYS_ANSIBLE_PLAYBOOK)_$(date +%Y%m%m%H%M%S)

cd $SYS_ANSIBLE_ROOT
git pull
ansible-galaxy install -r requirements.txt
ansible-playbook -i $SYS_ANSIBLE_INVENTORY $SYS_ANSIBLE_PLAYBOOK >> /var/www/html/cron-logs/ansible_$logtag.log 2>&1
