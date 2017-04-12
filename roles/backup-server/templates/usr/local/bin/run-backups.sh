#!/bin/bash

# {{ ansible_managed }}

# Copy stdout and stderr to log file
exec >> >(tee -a /var/log/backups/backup.log) 2>&1

echo "Starting backup run at $(date)"

{# unroll this for loop in jinja because it makes the data easier to work with #}
{% for host, paths in backup_sources.iteritems() %}

HOST={{ host }}
DEST={{ backup_home }}/${HOST}
if ! test -d ${DEST}
then
    echo "Creating destination directory ${DEST}"
    mkdir -p ${DEST}
fi

echo "Backing up ${HOST}"
rsync -PHaz {% for path in paths %}root@${HOST}:{{ path }} {% endfor %} ${DEST}/

{% endfor %}
