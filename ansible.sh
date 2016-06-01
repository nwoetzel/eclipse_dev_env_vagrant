#!/usr/bin/env bash

# this file needs to be passed relative to the vagrant folder, so that this provisioning works
EXTRA_ARGS_FILE=$1

# using ansible playbook, install all necessary modules
# install roles using galaxy
cd /vagrant/ansible
ansible-galaxy install --role-file=roles/galaxy-roles.yml
ansible-playbook -i inventory --extra-vars="@/project/${EXTRA_ARGS_FILE}" site.yml
