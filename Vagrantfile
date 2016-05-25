# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'getoptlong'

#http://stackoverflow.com/questions/14124234/how-to-pass-parameter-on-vagrant-up-and-have-it-in-the-scope-of-chef-cookbook
#http://stackoverflow.com/questions/14124234/how-to-pass-parameter-on-vagrant-up-and-have-it-in-the-scope-of-chef-cookbook
opts = GetoptLong.new(
  [ '--help', GetoptLong::NO_ARGUMENT ],
  [ '--eclipse-distro', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--eclipse-package', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--vmname', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--cpus', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--memory', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--nfs', GetoptLong::NO_ARGUMENT ]
)

eclipse_distro  = "mars"
eclipse_package = "java"
cpus = 2
memory = 2048
vmname = (0...8).map { (65 + rand(26)).chr }.join
nfs = false

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
--eclipse-distro: (default: #{eclipse_distro})
  the eclipse distribution
--eclipse-package: (default #{eclipse_package})
  the eclipse package (e.g. java, cpp, jee, php etc)
      EOF
      exit
    when '--eclipse-distro'
      eclipse_distro = arg
    when '--eclipse-package'
      eclipse_package = arg
    when '--cpus'
      cpus = arg.to_i
    when '--memory'
      memory = arg.to_i
  end # case
end # each

Vagrant.configure("2") do |config|
  # Configure the box to use
  config.vm.box       = 'ubuntu/trusty64'
#    config.vm.box       = 'bento/centos-7.1'

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box

    # OPTIONAL: If you are using VirtualBox, you might want to use that to enable
    # NFS for shared folders. This is also very useful for vagrant-libvirt if you
    # want bi-directional sync
#    config.cache.synced_folder_opts = {
#      type: :nfs,
#      # The nolock option can be useful for an NFSv3 client that wants to avoid the
#      # NLM sideband protocol. Without this option, apt-get might hang if it tries
#      # to lock files needed for /var/cache/* operations. All of this can be avoided
#      # by using NFSv4 everywhere. Please note that the tcp option is not the default.
#      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
#    }
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
  config.vm.network :private_network, ip:    "192.168.234.234"
  config.vm.network :forwarded_port,  guest: 80,    host: 9080
  config.vm.network :forwarded_port,  guest: 3306,  host: 3307

  # Configure shared folders
#  config.vm.synced_folder "." , "/vagrant", id: "vagrant-root", :nfs => true
#  config.vm.synced_folder "..", "/var/www", id: "application",  :nfs => true
  config.vm.synced_folder "." , "/vagrant", id: "vagrant-root", :nfs => nfs

  # configure the ssh connection
  config.ssh.forward_x11 = true

  # Configure VirtualBox environment
  config.vm.provider :virtualbox do |v|
#    v.name = (0...8).map { (65 + rand(26)).chr }.join
    v.name = vmname
    v.customize [ "modifyvm", :id, "--memory", memory ]
    v.customize [ "modifyvm", :id, "--cpus", cpus ]
  end

  # Provision the box
#  config.vm.provision :ansible do |ansible|
#      ansible.playbook = "ansible/site.yml"
#  end

  # Provision the box bootstrapping
  config.vm.provision :shell, path: "bootstrap.sh"
end
