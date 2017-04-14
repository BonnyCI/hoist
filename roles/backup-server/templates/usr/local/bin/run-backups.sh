#!/bin/bash -e

# {{ ansible_managed }}

# Copy stdout and stderr to log file
exec >> >(tee -a /var/log/backups/backup.log) 2>&1

TODAY=$(date -I)
echo "Starting backup run for ${TODAY}"

{# unroll this for loop in jinja because it makes the data easier to work with #}
{% for host, paths in backup_sources.iteritems() %}

HOST={{ host }}
REPO={{ backup_home }}/{{ host }}
SSHFS={{ sshfs_base }}/{{ host }}

if ! test -d ${REPO}
then
    echo "Creating borg repo for host ${HOST}"
    borg init --encryption=none ${REPO}  # TODO: enable encryption
fi

if ! test -d ${SSHFS}
then
    echo "Creating sshfs mount-point ${SSHFS}"
    mkdir -p ${SSHFS}
fi

echo "Mounting ${HOST}:/ at ${SSHFS}"
sshfs root@${HOST}:/ ${SSHFS}

echo "Creating backup ${REPO}::${TODAY}"
borg create --verbose --stats --compression zlib,4 ${REPO}::${TODAY} {% for path in paths %}${SSHFS}/{{ path }} {% endfor %}

echo "Unmounting ${SSHFS}"
fusermount -u ${SSHFS}

{% endfor %}
