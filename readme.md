# Vagrant Apache Mysql WordPress #

A Vagrant box provisioned to automatically install Apache, Mysql, php5, wordpress, phpunit, wp-cli, and php composer.  Wp-cli will also install default debuging plugins and import theme unit testing content.  Your hosts file (OS X and Linux) will automatically be updated to the specified domain allowing you to start developing right away.

### Versions ###

* linux - Ubuntu 14.04 LTS 64-bit
* apache - 2.6.x
* php - 7.0
* mysql - 5.5
* phpmyadmin - 4.6.2
* wordpress - latest
* phpunit - latest
* wp-cli - latest
* composer - latest

### Installation ###

This will require the use of command line.  If you are not comfortable with command line, this may not be for you.

1. Install VirtualBox [VirtualBox](https://www.virtualbox.org/)
2. Install Vagrant [Vagrant](http://www.vagrantup.com/)
3. Install Vagrant plugin [Vagrant HostsUpdater](https://github.com/cogitatio/vagrant-hostsupdater) `vagrant plugin install vagrant-hostsupdater`
4. Install Vagrant plugin [Vagrant VBGuest](https://github.com/dotless-de/vagrant-vbguest) `vagrant plugin install vagrant-vbguest`
5. Open a terminal.  The next steps use command line.
6. Clone this repo `git clone https://github.com/rfmeier/vagrant-apache-mysql-php-wordpress.git my-custom-directory-name`
7. Move into the directory `cd my-custom-directory-name`
8. Begin the build `vagrant up`
