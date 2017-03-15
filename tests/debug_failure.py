#!/usr/bin/python

import subprocess
import json


def get_inventory_hosts():
    cmd = ['./inventory/nodepool.py', '--list']
    inventory = json.loads(subprocess.check_output(cmd))
    inv_hosts = set()
    for group, hosts in inventory.items():
        inv_hosts.update(hosts['hosts'])
    return inv_hosts


def get_host_addr(host):
    cmd = ['./inventory/nodepool.py', '--host', host]
    host = json.loads(subprocess.check_output(cmd))
    return host['ansible_host']


def check_ssh(host):
    print 'Ensuring SSH connection to %s...' % host
    subprocess.check_output(['ssh-keyscan', host])


hosts = get_inventory_hosts()
for host in hosts:
    check_ssh(get_host_addr(host))
