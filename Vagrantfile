# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "hashicorp/precise64"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: "192.168.33.10"
  config.vm.hostname = "wordpress.dev"
  config.hostsupdater.aliases = ["phpmyadmin.wordpress.dev"]

  # Execute the boostrap.sh shell file
  config.vm.provision :shell, :path => "provision.sh", :args => config.vm.hostname
  config.vm.provision :shell, :path => "provision-nopriv.sh", :privileged => false, :args => config.vm.hostname

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.

  # NFS configuration - NFS, for the most part will increase performance
  # NOTE: A password will be prompted for OS X, not available on Windoze
  config.vm.synced_folder "./", "/vagrant", :nfs => true

  # Non-NFS configuration
  # Note: Using 'vagrant' as the owner, will allow wp-cli to work properly, but WP cannot install plugins/themes
  # config.vm.synced_folder "./", "/vagrant", owner: "vagrant", group: "www-data"

  # config.vm.synced_folder "./", "/vagrant", type: "rsync", rsync__args: ["--verbose", "--archive", "--compress"]

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:

  config.vm.provider :virtualbox do |vb|

      # set the memory limit
      vb.customize ["modifyvm", :id, "--memory", "1024"]

      # set cpu max exection
      vb.customize ["modifyvm", :id, "--cpuexecutioncap", "95"]

      # enable more than 1 cpu on the virtual machine
      vb.customize ["modifyvm", :id, "--cpus", "2"]

      # if you are using a 64-bit OS, set --ioapic to on to enable a multi-cpu box
      # see http://stackoverflow.com/questions/17117063/how-can-i-create-a-vm-in-vagrant-with-virtualbox-with-two-cpus
      vb.customize ["modifyvm", :id, "--ioapic", "on"]

      # the two following options help with slow internet connections in VirtualBox
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

  end

end
