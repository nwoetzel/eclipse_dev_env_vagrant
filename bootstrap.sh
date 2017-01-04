#!/usr/bin/env bash

# although it takes some time, the information in the box might not be up-to-date which causes problems with relocated servers (new ip-adresses)
apt-get update
apt-get -y install python-pip python-dev vim git libffi-dev libssl-dev build-essential --no-install-recommends
pip install --upgrade pip
pip install -U setuptools
pip install --requirement=/vagrant/pip_dependencies.txt
