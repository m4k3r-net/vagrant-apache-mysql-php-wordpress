#!/bin/bash

#
#   provision variables
#
VAGRANT_DOMAIN="$1"
VAGRANT_URL="http://$VAGRANT_DOMAIN"

#
#   WordPress variables
#
WP_PATH="/vagrant/wordpress"
WP_URL="$VAGRANT_URL"
WP_TITLE="WordPress Dev"
WP_ADMIN_USER="admin"
WP_ADMIN_PASSWORD="password"
WP_ADMIN_EMAIL="rfmeier@gmail.com"

#
#   Install development packages
#
install_packages(){

    echo " "
    echo "********************************************************************"
    echo "Updating repository..."
    echo "********************************************************************"
    echo " "
    apt-get update

    #   install package so we can add independent repositories
    apt-get install -y python-software-properties

    #   add repository for php 5.4
    add-apt-repository -y ppa:ondrej/php5-oldstable

    # run update since we added a new ppa
    apt-get update

    echo " "
    echo "********************************************************************"
    echo "Installing additional tools..."
    echo "********************************************************************"
    echo " "
    apt-get install -y build-essential, make
    apt-get install -y nfs-common, portmap
    apt-get install -y vim
    apt-get install -y zip, unzip
    apt-get install -y curl
    apt-get install -y colordiff, git-core

    echo " "
    echo "********************************************************************"
    echo "Installing Apache..."
    echo "********************************************************************"
    echo " "
    apt-get install -y apache2

    #   enable mod_rewrite
    a2enmod rewrite

    echo " "
    echo "********************************************************************"
    echo "Installing mysql..."
    echo "********************************************************************"
    echo " "

    #   prevent mysql from asking user input
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y mysql-common
    apt-get install -y mysql-client
    apt-get install -y mysql-server

    #   set admin password
    mysqladmin -uroot password root_password

    #   grant admin privileges
    mysql -uroot -proot_password -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root_password' WITH GRANT OPTION; FLUSH PRIVILEGES;"

    #   create wordpress database
    mysql -uroot -proot_password -e "CREATE DATABASE wordpress;"

    #   set bind address value to 0.0.0.0 from 127.0.0.1
    sed -i 's/127.0.0.1/0.0.0.0/'  /etc/mysql/my.cnf

    #   comment out skip-external-locking
    sed -i 's/skip-external-locking/#skip-external-locking/'  /etc/mysql/my.cnf

    echo " "
    echo "********************************************************************"
    echo "Intsalling PHP and extensions..."
    echo "********************************************************************"
    echo " "
    apt-get install -y php5
    apt-get install -y php5-common
    apt-get install -y php5-dev
    apt-get install -y libapache2-mod-php5
    apt-get install -y php5-mcrypt
    apt-get install -y php5-curl
    apt-get install -y php5-gd
    apt-get install -y php5-xdebug
    apt-get install -y php5-mysql
    apt-get install -y php-pear

}

#
#   Enable php xdebug
#
#   Since xdebug is already compiled into php by default, we just have to
#   enable html_errors in order to see the pretty output by xdebug.
#
enable_xdebug(){

    #   create a variable for the php.ini path within /etc/php5/apache2
    PHP_INI_PATH=$( find /etc/php5/apache2 -name "php.ini" )

    #   if valid php.ini path...
    if [[ $PHP_INI_PATH ]]; then

        #   turn on html errors
        sed -i 's/html_errors = Off/html_errors = On/' $PHP_INI_PATH

        #   set the timezone to America/Chicago
        #   TODO: update timezone
        #   sed -i 's/\;date.timezone =/date.timezone = America/Chicago/' $PHP_INI_PATH

    fi

}

#
#   Install phpunit
#
install_phpunit(){

    #   if phpunit is not installed...
    if [[ ! -f /usr/local/bin/phpunit ]]; then

        #   download phpunit
        wget https://phar.phpunit.de/phpunit.phar

        #   make .phar file executable
        chmod +x phpunit.phar

        #   move phpunit into bin
        mv phpunit.phar /usr/local/bin/phpunit

    fi

    #   echo the version
    phpunit --version

}

#
#   This function will run after setup().
#
package_cleanup(){

    echo " "
    echo "********************************************************************"
    echo "Running package package cleanup..."
    echo "********************************************************************"
    echo " "

    #   fix packages... if necessary and clean out cache
    echo "Fixing packages..."
    apt-get -f -y install
    apt-get clean

    #   remove the default /var/www directory
    echo "Removing /var/www for symlink..."
    rm -rf /var/www

    #   if wordpress directory does not exist...
    if [ ! -d /vagrant/wordpress ]; then

        #   create the wordpress directory
        mkdir -p /vagrant/wordpress

    fi

    #   create a symlink for /vagrant/wordpress to point at /var/www
    echo "Symlinking /vagrant/wordpress /var/www..."
    ln -fs /vagrant/wordpress /var/www

    #   if the custom apache default file exists...
    if [ -f /vagrant/config/default ]; then

        #   copy custom default file over
        cp -v /vagrant/config/default /etc/apache2/sites-available/default

        sed -i "s#VAGRANT_DOMAIN#${VAGRANT_DOMAIN}#g" /etc/apache2/sites-available/default

    fi

    #   restart apache to activate the php addons
    echo "Restarting apache..."
    service apache2 restart

    #   restart mysql
    echo "Restarting mysql..."
    service mysql restart

}

#
#   Install phpmyadmin
#
install_phpmyadmin(){

    #todo install phpmyadmin
    echo " "
    echo "********************************************************************"
    echo "  Install phpmyadmin"
    echo "********************************************************************"
    echo " "

    #   if the /vagrant/phpmyadmin directory does not exist...
    if [[ ! -d /vagrant/phpmyadmin ]]; then

        #   get a copy of phpmyadmin
        wget http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.2.7/phpMyAdmin-4.2.7-english.tar.gz

        #   decompress
        tar -xzvf phpMyAdmin-4.2.7-english.tar.gz

        #   remove the old file
        rm -rf phpMyAdmin-4.2.7-english.tar.gz

        #   move contnest to phpmyadmin
        mv phpMyAdmin-4.2.7-english /vagrant/phpmyadmin

        #   if phpmyadmin config file exists...
        if [[ -f /vagrant/config/config.inc.php ]]; then

            #   copy custom config file to phpmyadmin directory
            cp /vagrant/config/config.inc.php /vagrant/phpmyadmin/config.inc.php

        fi

        #   create a symlink for /vagrant/phpmyadmin to point at /var/phpmyadmin
        echo "Symlinking /vagrant/phpmyadmin /var/phpmyadmin..."
        ln -fs /vagrant/phpmyadmin /var/phpmyadmin

        #   if the custom apache default file exists...
        if [[ -f /vagrant/config/phpmyadmin ]]; then

            #   copy custom default file over
            cp -v /vagrant/config/phpmyadmin /etc/apache2/sites-available/phpmyadmin

            sed -i "s#VAGRANT_DOMAIN#${VAGRANT_DOMAIN}#g" /etc/apache2/sites-available/phpmyadmin

        fi

        #   enable phpmyadmin
        echo "enabling phpmyadmin..."
        a2ensite phpmyadmin

        #   restart apache to activate the php addons
        echo "Restarting apache..."
        service apache2 restart

    fi

}

#
#   Final cleanup function
#
provision_cleanup(){

    #   if the phpinfo source file exists and has yet been moved...
    if [ -f /vagrant/config/phpinfo.php -a ! -f /vagrant/wordpress/phpinfo.php ]; then

        #   move phpinfo.php into wordpress directory
        cp /vagrant/config/phpinfo.php /vagrant/wordpress/phpinfo.php

        #   move phpinfo.php into phpmyadmin directory
        cp /vagrant/config/phpinfo.php /vagrant/phpmyadmin/phpinfo.php

    fi

    #   create generic installed file to know the install was already provision_cleanup() function was already ran
    echo "Creating generic 'installed' flag file..."
    touch ~/installed

}

#   check if generic installed file was created...
if [[ ! -f ~/installed ]]; then

    #   install devlopment packages
    install_packages

    #   configure php for xdebug
    enable_xdebug

    #   install phpunit
    install_phpunit

    #   run the package_cleanup function
    package_cleanup

    #   install phpmyadmin
    install_phpmyadmin

    #   run provision cleanup
    provision_cleanup

fi
