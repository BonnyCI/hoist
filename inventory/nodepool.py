#!/usr/bin/env python

# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

import argparse
import json
import os
import sys

_DESC = 'Parse a nodepool subnodes file and generate a hoist inventory from it'


def main(argv):
    parser = argparse.ArgumentParser(description=_DESC)

    parser.add_argument('--list', action='store_true', help='List all hosts')
    parser.add_argument('--host', type=str, help='Show a host information')

    parser.add_argument('--subnodes',
                        dest='subnodes_filename',
                        default=os.environ.get('SUBNODES_FILE',
                                               '/etc/nodepool/sub_nodes'),
                        type=str,
                        help='The subnodes file to parse')

    args = parser.parse_args(argv)

    try:
        with open(args.subnodes_filename, 'r') as f:
            subnodes = f.read().split()

    except IOError as e:
        fail("Couldn't open file for processing: %s" % args.subnodes_filename)

    if args.list:
        output = get_inventory(subnodes)

    elif args.host:
        output = get_variables(subnodes, args.host)

    else:
        fail("Inventory script should be called with --list or --host")

    sys.stdout.write('%s\n' % json.dumps(output))


def fail(msg):
    sys.stderr.write('%s\n' % msg)
    sys.exit(1)


def get_inventory(subnodes):
    output = {}

    if not subnodes:
        fail("No subnodes found in the file")

    output['nodepool'] = {'hosts': ['nodepool.multinode']}
    output['zookeeper'] = {'hosts': ['nodepool.multinode']}
    output['zuul-server'] = {'hosts': ['zuul.multinode']}
    output['zuul-launcher'] = {'hosts': ['zuul.multinode']}
    output['zuul-merger'] = {'hosts': ['zuul.multinode']}
    output['mysql'] = {'hosts': ['zuul.multinode']}
    output['log'] = {'hosts': ['logs.multinode']}
    output['monitoring'] = {'hosts': ['logs.multinode']}
    output['backups'] = {'hosts': ['logs.multinode']}
    output['multinode'] = {'hosts': ['nodepool.multinode',
                                     'zuul.multinode',
                                     'logs.multinode',
                                     ]}

    return output


def get_variables(subnodes, host):
    output = {}

    if host == 'nodepool.multinode':
        output['ansible_host'] = subnodes[0]

    elif host == 'zuul.multinode':
        output['ansible_host'] = subnodes[1]

    elif host == 'logs.multinode':
        output['ansible_host'] = subnodes[2]

    else:
        fail("Unknown host %s found in inventory" % host)

    return output


if __name__ == '__main__':
    main(sys.argv[1:])
