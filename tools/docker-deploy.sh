#!/bin/bash -e

SCRIPT_NAME=$(basename "$0")

print_help(){
cat << EOF
Usage: $SCRIPT_NAME
   or: $SCRIPT_NAME [OPTIONS] [ANSIBLE OPTIONS]
Deploy Docker-based development environment.

      --with-ansible           run ansible deploy
                                 additional arguements are passed to ansible-playbook

  -h, --help     display this help and exit
EOF
}

deploy_ansible(){
    echo -e "\nRunning ansible deployment..."
    ansible-playbook -i inventory/allinone install-ci.yml tests/files/validate-ci.yml -c docker -e @secrets.yml.example --skip-tags monitoring,not-on-docker,letsencrypt "$@"
}

deploy_docker(){
    docker pull ubuntu:xenial
    echo -e "\nStarting container..."
    docker run -d --name allinone --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro ubuntu:xenial systemd
    echo -e "\nUpdating APT cache..."
    docker exec -i allinone apt-get -qq update
    echo -e "\nInstalling dependencies..."
    docker exec -i allinone apt-get -qq install python-apt ca-certificates apt-transport-https sudo ssh > /dev/null
    echo -e "\ntouching auth log for fail2ban"
    docker exec -i allinone touch /var/log/auth.log

    if [[ ! -z $WITH_ANSIBLE && $WITH_ANSIBLE ]]; then
        deploy_ansible "$@"
    fi
}

main(){
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                print_help
                exit 0
                ;;
            --with-ansible)
                WITH_ANSIBLE=true
                shift
                break
                ;;
            *)
                echo "$SCRIPT_NAME: invalid option -- '$arg'"
                echo "Try '$SCRIPT_NAME --help' for more information."
                exit 1
                ;;
        esac
    done

    deploy_docker "$@"
}

main "$@"
