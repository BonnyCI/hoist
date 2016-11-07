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

playbook=$(basename $SYS_ANSIBLE_PLAYBOOK)
timestamp=$(date +%Y%m%d%H%M%S)
logfile="/var/www/html/cron-logs/ansible_${playbook}_${timestamp}.log"

cd $SYS_ANSIBLE_ROOT
git pull
ansible-galaxy install -r requirements.yml
ansible-playbook -i $SYS_ANSIBLE_INVENTORY $SYS_ANSIBLE_PLAYBOOK >> $logfile 2>&1

rm -f /var/www/html/cron-logs/ansible_${playbook}_latest.log
ln -s $logfile /var/www/html/cron-logs/ansible_${playbook}_latest.log
