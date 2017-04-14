#!/bin/bash -e

docker pull ubuntu:xenial
echo -e "\nStarting container..."
docker run -d --name allinone --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro ubuntu:xenial systemd
echo -e "\nUpdating APT cache..."
docker exec -i allinone apt-get -qq update
echo -e "\nInstalling dependencies..."
docker exec -i allinone apt-get -qq install python-apt ca-certificates apt-transport-https sudo ssh > /dev/null
echo -e "\ntouching auth log for fail2ban"
docker exec -i allinone touch /var/log/auth.log
echo -e "\nRunning ansible deployment..."
ansible-playbook -i inventory/allinone install-ci.yml tests/files/validate-ci.yml -c docker -e @secrets.yml.example --skip-tags monitoring,not-on-docker,letsencrypt "$@"
