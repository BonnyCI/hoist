#!/bin/bash

SCRIPT_NAME=$(basename "$0")

print_help(){
cat << EOF
Usage: $SCRIPT_NAME
   or: $SCRIPT_NAME [OPTIONS]
   or: $SCRIPT_NAME [OPTIONS] --ansible-args [ANSIBLE OPTIONS]
Deploy Vagrant-based development environment.

      --exit-on-fail           exit non-zero if anything fails
      --force-vagrant          force vagrant destroy and vagrant up on VMs that are
                                 in neither "running" nor "poweroff"
      --nuke-vagrant           force vagrant destroy and vagrant up of ALL VMs
                                 NOTE: this destructive step will destroy running VMs
      --skip-anisble           do not run anisble deployment
      --skip-vagrant           do not run vagrant deployment
                                 NOTE: this option supercedes both --force-vagrant and
                                       --nuke-vagrant
      --ansible-args           additional arguements are passed to ansible-playbook
                                 NOTE: this option must be placed after all other
                                       non-anisble arguments

  -h, --help     display this help and exit
EOF
}

vagrant_deploy(){
    if [[ ! -z $NUKE_VAGRANT && $NUKE_VAGRANT ]]; then
        vagrant destroy -f
        vagrant up
    else
        VAGRANT_STATUS=$(vagrant status | awk '/virtualbox/ { print $1","$2 }')

        for line in $VAGRANT_STATUS; do
            VM_NAME="$(echo "$line" | cut -d ',' -f1)"
            VM_STATE="$(echo "$line" | cut -d ',' -f2)"

            if [[ "$VM_STATE" == "running" ]]; then
                echo "$VM_NAME is already running..."
                continue
            elif [[ "$VM_STATE" == "poweroff" || "$VM_STATE" == "not" ]]; then
                vagrant up "$VM_NAME"
            else
                if [[ ! -z "$FORCE_VAGRANT" && $FORCE_VAGRANT ]]; then
                    vagrant destroy -f "$VM_NAME"
                    vagrant up "$VM_NAME"
                else
                    echo "$VM_NAME is in state '$VM_STATE'."
                    echo "To force a vagrant destroy and bring it up, try '$SCRIPT_NAME --force-vagrant'."
                fi
            fi
        done
    fi
}

ansible_deploy(){
    vagrant ssh -c "sudo -i -u cideploy /vagrant/tools/vagrant-run-ansible.sh $*" bastion
}

main(){
    for arg in "$@"; do
        case $arg in
            -h|--help)
                print_help
                exit 0
                ;;
            --exit-on-fail)
                set -e
                shift
                ;;
            --force-vagrant)
                FORCE_VAGRANT=true
                shift
                ;;
            --nuke-vagrant)
                NUKE_VAGRANT=true
                shift
                ;;
            --skip-ansible)
                SKIP_ANSIBLE=true
                shift
                ;;
            --skip-vagrant)
                SKIP_VAGRANT=true
                shift
                ;;
            --ansible-args)
                shift
                ANSIBLE_ARGS="$*"
                break
                ;;
            *)
                echo "$SCRIPT_NAME: invalid option -- '$arg'"
                echo "Try '$SCRIPT_NAME --help' for more information."
                exit 1
                ;;
        esac
    done

    if [[ ! -z $SKIP_VAGRANT && ! -z $SKIP_ANSIBLE ]]; then
        echo "$SCRIPT_NAME: nothing to do"
        echo "Try '$SCRIPT_NAME --help' for more information."
        exit 1
    fi

    if [[ -z $SKIP_VAGRANT ]]; then
        vagrant_deploy
    fi

    if [[ -z $SKIP_ANSIBLE ]]; then
        if [[ ! -z $ANSIBLE_ARGS ]]; then
            ansible_deploy "$ANSIBLE_ARGS"
        else
            ansible_deploy
        fi
    fi
}

main "$@"
