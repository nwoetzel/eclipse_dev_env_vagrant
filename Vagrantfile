# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.require_version ">= 1.9.1"
require 'getoptlong'

#http://stackoverflow.com/questions/14124234/how-to-pass-parameter-on-vagrant-up-and-have-it-in-the-scope-of-chef-cookbook
opts = GetoptLong.new(
  [ '--help', GetoptLong::NO_ARGUMENT ],
  [ '--vmname', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--cpus', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--memory', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--nfs', GetoptLong::NO_ARGUMENT ],
  [ '--forward-port', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--private-ip', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--ansible-playbook', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--extra-vars-file', GetoptLong::REQUIRED_ARGUMENT ]
)

cpus = 2
memory = 4096
vmname = (0...8).map { (65 + rand(26)).chr }.join
nfs = false
private_ip = "192.168.234.234"
extra_vars_file = "ansible/extra-vars/eclipse_cpp.yml"
ansible_playbook = "ansible/site.yml"
forward_ports = []

begin
  opts.each do |opt, arg|
    case opt
      when '--help'
        puts <<-EOF
There are some additional arguments available specifically for this Vagrantfile for deployment.

--help:
  show help

--cpus: (default: #{cpus})
  number fo cpus for the virtual machine
--memory: (default: #{memory})
  memory of the virtual machine in [MB]
--vmname: (default: randomly assigned)
  the name of the virtualmachine for the virtual machine provider (e.g. VirtualBox)
--nfs: (default: #{nfs})
  mount through nfs
--private-ip: (default: #{private_ip})
  ip for the private network
--forward-port:
  forward port from guest to host in the form "guest:host"
--ansible-playbook: (default: #{ansible_playbook})
  the file containing the ansible deployment playbook
--extra-vars-file: (default: #{extra_vars_file})
  ansible vars in a vars-file (either json or yaml) for provisiong the environment
  use a relative path in this tree
  http://docs.ansible.com/ansible/playbooks_variables.html#passing-variables-on-the-command-line
        EOF
      when '--cpus'
        cpus = arg.to_i
      when '--memory'
        memory = arg.to_i
      when '--nfs'
        nfs = true
      when '--private-ip'
        private_ip = arg
      when '--forward-port'
        forward_ports << arg
      when '--vmname'
        vmname = arg
      when '--ansible-playbook'
        ansible_playbook = arg
      when '--extra-vars-file'
        extra_vars_file = arg
    end # case
  end # each
rescue GetoptLong::InvalidOption => invalid_option
  puts "there are options that are not handled by that Vagrantfile, but might be handled upstream by vagrant"
  puts "if they cannot be handled by vagrant, they will cause termination"
end

# prepend extra_vars_
extra_vars_file = File.basename( Dir.pwd ) + "/" + extra_vars_file
ansible_playbook = File.basename( Dir.pwd ) + "/" + ansible_playbook

Vagrant.configure("2") do |config|
  # Configure the box to use
  config.vm.box       = 'bento/ubuntu-16.04'
#    config.vm.box       = 'bento/centos-7.1'

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box

    config.cache.enable :apt
    config.cache.enable :apt_lists
    config.cache.enable :composer
    config.cache.enable :gem
#    config.cache.enable :pip
    config.cache.enable :generic, {
      "ivy2" => { cache_dir: "/home/vagrant/.ivy2" },
      "sbt" => { cache_dir: "/home/vagrant/.sbt" },
      "ansible_download" => { cache_dir: "/tmp/ansible_download" },
    }

    # OPTIONAL: If you are using VirtualBox, you might want to use that to enable
    # NFS for shared folders. This is also very useful for vagrant-libvirt if you
    # want bi-directional sync
    config.cache.synced_folder_opts = {
      type: nfs ? :nfs : nil,
#      # The nolock option can be useful for an NFSv3 client that wants to avoid the
#      # NLM sideband protocol. Without this option, apt-get might hang if it tries
#      # to lock files needed for /var/cache/* operations. All of this can be avoided
#      # by using NFSv4 everywhere. Please note that the tcp option is not the default.
#      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
    # For more information please check http://docs.vagrantup.com/v2/synced-folders/basic_usage.html
  end

  if Vagrant.has_plugin?("vagrant-vbguest")
    # set auto_update to false, if you do NOT want to check the correct 
    # additions version when booting this machine
    config.vbguest.auto_update = true

    # do NOT download the iso file from a webserver
    config.vbguest.no_remote = false

    config.vbguest.installer_arguments = ['--nox11']
  end

  # Configure the network interfaces
  config.vm.network :private_network, ip: private_ip
  forward_ports.each do |forward|
    guest,host = forward.split ":"
    config.vm.network :forwarded_port, guest: guest, host: host
  end
  # Configure shared folders
  if nfs
    config.vm.synced_folder "." , "/vagrant", id: "vagrant-root", :nfs => true, :mount_options => ['nfsvers=3', 'vers=3', 'actimeo=1', 'rsize=8192', 'wsize=8192', 'timeo=14', :nolock, :udp, :intr, :auto, :exec, :rw]
    config.vm.synced_folder ".." , "/project", id: "project-root", :nfs => true, :mount_options => ['nfsvers=3', 'vers=3', 'actimeo=1', 'rsize=8192', 'wsize=8192', 'timeo=14', :nolock, :udp, :intr, :auto, :exec, :rw]
  else
    config.vm.synced_folder "." , "/vagrant", id: "vagrant-root"
    config.vm.synced_folder ".." , "/project", id: "project-root"
  end

  # configure the ssh connection
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  # Configure VirtualBox environment
  config.vm.provider :virtualbox do |v|
    v.name = vmname
    v.customize [ "modifyvm", :id, "--memory", memory ]
    v.customize [ "modifyvm", :id, "--cpus", cpus ]
  end

  # Provision the box
#  config.vm.provision :ansible do |ansible|
#      ansible.playbook = "ansible/site.yml"
#  end

  # Provision the box bootstrapping
  config.vm.provision "shell" do |s|
    s.path = "bootstrap.sh"
#    s.args = [extra_vars_file]
  end
  config.vm.provision "shell" do |s|
    s.path = "ansible.sh"
    s.args = [ansible_playbook,extra_vars_file]
    s.privileged = false
  end
end
