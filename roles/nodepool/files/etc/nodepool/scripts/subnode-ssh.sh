#!/bin/bash -xe

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

# When setting up subnodes nodepool will drop an ssh key and information into
# /etc/nodepool. This doesn't actually set the nodes up to communicate with
# each other though. This script just copies the ssh keys from /etc/nodepool
# into the appropriate authorized_keys and ssh directories.

ROLE=$(cat /etc/nodepool/role)


function sub_node {
    # allow login to the subnode from the primary
    cat /etc/nodepool/id_rsa.pub >> ~/.ssh/authorized_keys
}


function primary_node {
    # install the ssh key into the user
    cp /etc/nodepool/id_rsa /etc/nodepool/id_rsa.pub ~/.ssh
    chmod 600 ~/.ssh/id_rsa ~/.ssh/id_rsa.pub

    # put the subnodes into known_hosts
    ssh-keyscan -H -f /etc/nodepool/sub_nodes >> ~/.ssh/known_hosts
}


if [[ "$ROLE" == "sub" ]]; then
    sub_node
elif [[ "$ROLE" == "primary" ]]; then
    primary_node
else
    echo "Script failure. Unknown role: $ROLE"
    exit 1
fi
