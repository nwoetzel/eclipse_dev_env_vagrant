#!/usr/bin/env bash

# although it takes some time, the information in the box might not be up-to-date which causes problems with relocated servers (new ip-adresses)
apt-get update
apt-get -y install python-pip python-dev vim git libffi-dev libssl-dev build-essential --no-install-recommends
#pip install ansible
#git clone git://github.com/ansible/ansible.git /home/vagrant/ansible --recursive
pip install --requirement=/vagrant/pip_dependencies.txt

# using ansible playbook, install all necessary modules
# install roles using galaxy
cd /vagrant/ansible
ansible-galaxy install --role-file=roles/galaxy-roles.yml
#ansible-playbook -i inventory/hosts_local ansible/site.yml
