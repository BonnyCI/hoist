#!/bin/bash
# Runs system wide ansible configured in /etc
set -eu

. /etc/default/$1

if [[ -z "${ANSIBLE_SERIALIZED:-}" ]] ; then
    export ANSIBLE_SERIALIZED=1
    exec run-one $0 "$@"
fi

set +u
. /opt/ansible/bin/activate
set -u

playbook=$(basename $ANSIBLE_PLAYBOOK)
logfile="/var/www/html/cron-logs/ansible_${playbook}_$(date +%Y%m%d%H%M%S).log"

cd $ANSIBLE_ROOT
trap "rm -f /var/www/html/cron-logs/ansible_${playbook}_latest.log; ln -s $logfile /var/www/html/cron-logs/ansible_${playbook}_latest.log" EXIT

git pull >> $logfile 2>&1
ansible-galaxy install -r requirements.yml >> $logfile 2>&1
ansible-playbook -i $ANSIBLE_INVENTORY $ANSIBLE_PLAYBOOK >> $logfile 2>&1
