#!/bin/bash

#
# provision variables
#
VAGRANT_DOMAIN="$1"
VAGRANT_URL="http://$VAGRANT_DOMAIN"

#
# WordPress variables
#
WP_PATH="/vagrant/wordpress"
WP_URL="$VAGRANT_URL"
WP_TITLE="WordPress Dev"
WP_ADMIN_USER="admin"
WP_ADMIN_PASSWORD="password"
WP_ADMIN_EMAIL="youremail@yourdomain.com"

#
# Install development packages
#
install_packages(){

    # run update since we added a new ppa
    apt-get update
    
    # install package so we can add independent repositories
    apt-get install -y python-software-properties

    # add repository ppa for php 5.6
    add-apt-repository ppa:ondrej/php5-5.6
    
    # re-run the repository update
    apt-get update

    echo " "
    echo "********************************************************************"
    echo "Installing additional tools..."
    echo "********************************************************************"
    echo " "
    apt-get install -y build-essential
    apt-get install -y make
    apt-get install -y nfs-common
    apt-get install -y portmap
    apt-get install -y vim
    apt-get install -y unzip
    apt-get install -y curl
    apt-get install -y git-core
    apt-get install -y rake
    apt-get install -y subversion

}

#
# Install apache
#
install_apache(){

    echo " "
    echo "********************************************************************"
    echo "Installing Apache..."
    echo "********************************************************************"
    echo " "
    apt-get install -y apache2

    # enable mod_rewrite
    a2enmod rewrite

}

configure_sites(){

    # remove the default /var/www directory
    echo "Removing /var/www for symlink..."
    rm -rf /var/www

    # if wordpress directory does not exist...
    if [[ ! -d /vagrant/wordpress ]]; then

        # create the wordpress directory
        mkdir -p /vagrant/wordpress

    fi

    # if the custom apache default file exists...
    if [[ -f /vagrant/config/default.conf ]]; then

        # copy custom default file over
        cp -v /vagrant/config/default.conf /etc/apache2/sites-available/default.conf

        sed -i "s#VAGRANT_DOMAIN#${VAGRANT_DOMAIN}#g" /etc/apache2/sites-available/default.conf

    fi

    # disable the default site
    a2dissite 000-default

    # enable our site
    a2ensite default.conf

    # restart apache to activate the php addons
    echo "Restarting apache..."
    service apache2 restart

}

#
# Install mysql
#
install_mysql(){

    echo " "
    echo "********************************************************************"
    echo "Installing mysql..."
    echo "********************************************************************"
    echo " "

    # prevent mysql from asking user input
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y mysql-common
    apt-get install -y mysql-client
    apt-get install -y mysql-server

    # set admin password
    mysqladmin -uroot password root_password

    # grant admin privileges
    mysql -uroot -proot_password -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root_password' WITH GRANT OPTION; FLUSH PRIVILEGES;"

    # create wordpress database
    mysql -uroot -proot_password -e "CREATE DATABASE wordpress;"

    # set bind address value to 0.0.0.0 from 127.0.0.1
    sed -i 's/127.0.0.1/0.0.0.0/'  /etc/mysql/my.cnf

    # comment out skip-external-locking
    sed -i 's/skip-external-locking/#skip-external-locking/'  /etc/mysql/my.cnf

}

#
# Install php5
#
install_php(){

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
# Enable php xdebug
#
# Since xdebug is already compiled into php by default, we just have to
# enable html_errors in order to see the pretty output by xdebug.
#
configure_php(){

    # if valid php.ini path...
    if [[ -f /vagrant/config/php.ini ]]; then

        # copy over the custom ini config file
        cp /vagrant/config/php.ini /etc/php5/apache2/php.ini

    fi

    # restart apache with our new .ini file
    service apache2 restart

}

#
# Install phpunit
#
install_phpunit(){

    # download phpunit
    wget https://phar.phpunit.de/phpunit.phar

    # make .phar file executable
    chmod +x phpunit.phar

    # move phpunit into bin
    mv phpunit.phar /usr/local/bin/phpunit

    # echo the version
    phpunit --version

}

#
# Install php composer
# 
# https://getcomposer.org
#
install_composer(){

    # download and execute composer
    curl -sS https://getcomposer.org/installer | php

    # move composer into usr bin
    mv composer.phar /usr/local/bin/composer

    # echo composer information
    composer -V

}

#
# Install phpmyadmin
#
install_phpmyadmin(){

    echo " "
    echo "********************************************************************"
    echo "  Install phpmyadmin"
    echo "********************************************************************"
    echo " "

    # if the /vagrant/phpmyadmin directory does not exist...
    if [[ ! -d /vagrant/phpmyadmin ]]; then

        # get a copy of phpmyadmin
        wget https://files.phpmyadmin.net/phpMyAdmin/4.5.3.1/phpMyAdmin-4.5.3.1-english.tar.gz --no-check-certificate

        # decompress
        tar -xzvf phpMyAdmin-4.5.3.1-english.tar.gz

        # remove the old file
        rm -rf phpMyAdmin-4.5.3.1-english.tar.gz

        # move contnest to phpmyadmin
        mv phpMyAdmin-4.5.3.1-english /vagrant/phpmyadmin

        # if phpmyadmin config file exists...
        if [[ -f /vagrant/config/config.inc.php ]]; then

            # copy custom config file to phpmyadmin directory
            cp /vagrant/config/config.inc.php /vagrant/phpmyadmin/config.inc.php

        fi

        # if the custom apache default file exists...
        if [[ -f /vagrant/config/phpmyadmin.conf ]]; then

            # copy custom default file over
            cp -v /vagrant/config/phpmyadmin.conf /etc/apache2/sites-available/phpmyadmin.conf

            sed -i "s#VAGRANT_DOMAIN#${VAGRANT_DOMAIN}#g" /etc/apache2/sites-available/phpmyadmin.conf

        fi

        # enable phpmyadmin
        echo "enabling phpmyadmin..."
        a2ensite phpmyadmin.conf

        # restart apache to activate the php addons
        echo "Restarting apache..."
        service apache2 restart

    fi

}

#
# Final cleanup function
#
provision_cleanup(){

    # fix packages... if necessary and clean out cache
    echo "Fixing packages..."
    apt-get -f -y install
    apt-get clean

    # restart mysql
    echo "Restarting mysql..."
    service mysql restart

    echo "Creating generic 'installed' flag file..."
    touch ~/installed

}

# check if generic installed file was created...
if [[ ! -f ~/installed ]]; then

    # install devlopment packages
    install_packages

    # install apache web server
    install_apache

    # configure websites
    configure_sites

    # install mysql
    install_mysql

    # install php5
    install_php

    # configure php for xdebug
    configure_php

    # install phpunit
    install_phpunit

    # install composer
    install_composer

    # install phpmyadmin
    install_phpmyadmin

    # run provision cleanup
    provision_cleanup

fi
