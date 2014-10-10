# Vagrant Apache Mysql WordPress #

A Vagrant box provisioned to automatically install Apache, Mysql, php5, wordpress, phpunit, wp-cli.  Wp-cli will also install default debuging plugins and import theme unit testing content.  Your hosts file (OS X and Linux) will automatically be updated to the specified domain allowing you to start developing right away.

### Versions ###

* Ubuntu 14.04 64-bit
* apache - 2.2
* php - 5.4.x
* mysql - 
* phpmyadmin - 4.2.7
* wordpress - latest
* phpunit - latest
* wp-cli - latest

### Setup ###

Make sure to have the latest version of [Vagrant](http://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed.

*Tested with Vagrant version 1.6.3 and Virtualbox version 4.3.14*

There are two Vagrant plugins that will make your life a little easier.
1. [Vagrant HostsUpdater](https://github.com/cogitatio/vagrant-hostsupdater)
  * This will automatically manage your hosts files as you vagrant up and down.
  * **Installation** `vagrant plugin install vagrant-hostsupdater`
2. [Vagrant VBGuest](https://github.com/dotless-de/vagrant-vbguest)
  * This plugin will automatically install VirtualBox guest additions on the guest machine.
  * **Installation** `vagrant plugin install vagrant-vbguest`

Within your **Vagrantfile**, update the `config.vm.hostname` and `config.hostsupdater.aliases` to your desired domain.  Make sure the domain matches for both entries.

```
#   Vagrantfile

# change to your custom domain
config.vm.hostname = "wordpress.dev" 
# change to your custom domain.  Should be the same domain as config.vm.hostname
config.hostsupdater.aliases = ["phpmyadmin.wordpress.dev"] 
```
