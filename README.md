Vagrant Development environment with eclipse
============================================

This repository can be used as a submodule in any project, that requires a reproducable development environment.
It uses [vagrant](https://www.vagrantup.com/) to manage the lifecycle of a virtual machine. While this project gives you a few possibilitites to change the 'hardware setup' of the virtual machine, it will work right out of the box.
The machine is provisioned (installation and setup of software, libraries and your project) using [ansible](https://www.vagrantup.com/). Many default setups are available through predefined playbooks and variables in files and inventories. But you can have your own or combine it with the available setups for your own project.

## Prerequisites

[VirtualBox](https://www.virtualbox.org/)
[vagrant](https://www.vagrantup.com/)

## Optional

To speed up repeated installation for the same and even different projects:
[vagrant-cachier](https://github.com/fgrehm/vagrant-cachier#installation)
[vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest#installation)
<pre>
vagrant plugin install vagrant-cachier
vagrant plugin install vagrant-vbguest
</pre>

## Mount points

There are two default mount-points in the virtual machine.
* .  -> /vagrant
* .. -> /project

They are critical for this setup and will not be changed in the future. 

## sample command lines to setup a virtual machine

### flags to change the virtual machine

Create a virtual machine with name "ECLIPSE", 2 cpus, 2GB of memroy and mount using nfs (usually requires root/sudo rights on the host, since nfs exports need to be written):
<pre>
vagrant --vmname=ECLIPSE --cpus=2 --memory=2048 --nfs up
</pre>

### eclipse for C++ development

provision:
<pre>
vagrant --ansible-playbook=ansible/site.yml --extra-vars-file=ansible/extra-vars/eclipse_cpp.yml up
</pre>

provision again after machine was created
<pre>
vagrant --ansible-playbook=ansible/site.yml --extra-vars-file=ansible/extra-vars/eclipse_cpp.yml up --provision
</pre>

### eclipse for R development
provision:
<pre>
vagrant --ansible-playbook=ansible/site.yml --extra-vars-file=ansible/extra-vars/eclipse_r.yml up
</pre>

