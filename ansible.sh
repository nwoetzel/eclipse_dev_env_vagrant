#!/usr/bin/env bash
EXTRA_ARGS_FILE=$1

# using ansible playbook, install all necessary modules
# install roles using galaxy
cd /vagrant/ansible
ansible-galaxy install --role-file=roles/galaxy-roles.yml
ansible-playbook -i inventory --extra-vars="@../${EXTRA_ARGS_FILE}" site.yml
