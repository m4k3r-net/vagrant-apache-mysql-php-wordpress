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
WP_ADMIN_EMAIL="youremail@yourdomain.com"

#
#   Install wp-cli
#   
#   http://wp-cli.org/
#
install_wpcli(){

    #   if wp-cli not installed...
    if [[ ! -f /usr/local/bin/wp ]]; then

        #   get a copy of wp-cli
        curl -L https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > wp-cli.phar

        #   make .phar file executable
        chmod +x wp-cli.phar

        #   move phpunit into bin
        sudo mv wp-cli.phar /usr/local/bin/wp

        #   if the ~/.wp-cli directory does not exist...
        if [[ ! -d ~/.wp-cli ]]; then

            #   make the wp-cli default directory
            mkdir -p ~/.wp-cli

        fi

        #   move the wp-cli global config
        cp /vagrant/config/config.yml ~/.wp-cli/config.yml

        #   replace vagrant variables within the config file.
        sed -i "s#WP_PATH#${WP_PATH}#g" ~/.wp-cli/config.yml
        sed -i "s#WP_URL#${WP_URL}#g" ~/.wp-cli/config.yml 

    fi

    #   echo wp-cli info
    wp --info

}

#
#   Download and install WordPress
#
install_wordpress(){

    #   use wp-cli to download WordPress
    wp core download

    #   if wordpress does not have a .htaccess file...
    if [[ ! -f /vagrant/wordpress/.htaccess ]]; then

        #   if config .htaccess file exists...
        if [[ -f /vagrant/config/.htaccess ]]; then

            echo "Moving /vagrant/config/.htaccess file into /vagrant/wordpress directory..."

            #   copy the .htaccess file to the wordpress directory
            cp /vagrant/config/.htaccess /vagrant/wordpress/.htaccess

        fi

    fi

    #   if wordpress does not have a wp-config file...
    if [[ ! -f /vagrant/wordpress/wp-config.php ]]; then

        #   if config wp-config.php file exists...
        if [[ -f /vagrant/config/wp-config.php ]]; then

            echo "Moving /vagrant/config/wp-config.php file into /vagrant/wordpress directory..."

            #   copy the wp-config file to the wordpress directory
            cp /vagrant/config/wp-config.php /vagrant/wordpress/wp-config.php

        fi

    fi

    wp core install --title="$WP_TITLE" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL"

}

#
#   Install default debugging plugins for WordPress
#
install_wordpress_plugins(){

    #   if the wordpres_plugins_installed flag does not exist...
    if [[ ! -f ~/wordpress_plugins_installed ]]; then

        #   list of plugins to install
        plugins=( "debug-bar" "debug-bar-transients" "debug-bar-constants" "debug-bar-post-types" "debug-bar-cron" "tdd-debug-bar-post-meta" "debug-bar-screen-info" "debug-bar-super-globals" "debug-bar-console" "debug-bar-actions-and-filters-addon" "regenerate-thumbnails" "wp-mail-smtp" )

        #   iterate through plugin zip file names...
        for i in "${plugins[@]}"
        do

            wp plugin install "$i" --activate

        done

        #   list of plugins to deactivate
        deactivate_plugins=( "regenerate-thumbnails" "wp-mail-smtp" )

        for d in "${deactivate_plugins[@]}"
        do

            wp plugin deactivate "$d"

        done

        #   uninstall 'Hello World' plugin
        wp plugin uninstall hello

        #   update all plugins
        wp plugin update --all

        #   show plugin status
        wp plugin status

        #   create the wordpres_plugins_installed flag file
        touch ~/wordpress_plugins_installed

    fi

}

#
#   Install and configure WordPress themes
#
install_wordpress_themes(){

    #   if the wordpress_themes_installed flag does not exist...
    if [[ ! -f ~/wordpress_themes_installed ]]; then

        #   slug for theme to activate
        default_theme="twentyfifteen"

        #   update all themes
        wp theme update --all

        #   activate the default theme
        wp theme activate "$default_theme"

        #   display a theme status
        wp theme status

        #   create the wordpres_plugins_installed flag file
        touch ~/wordpress_themes_installed

    fi

}

#
#   Set default WordPress options and configurations
#
update_wordpress_options(){

    permlink_structure="/%postname%/"

    #   if the wordpress_configured flag does not exist...
    if [[ ! -f ~/wordpress_configured ]]; then

        if [[ -d /vagrant/wordpress ]]; then

            #   update the permalink structure
            wp rewrite structure "$permlink_structure"

            #   flush the rewrite rules
            wp rewrite flush

        fi

        touch ~/wordpress_configured

    fi

}

#
#   Import default content.
#
import_wordpress_data(){

    #   check if theme test data exists...
    if [[ -f /vagrant/tools/theme-unit-test-data.xml ]]; then

        #   install the wordpress importer
        wp plugin install wordpress-importer --activate

        #   import test content
        wp import "/vagrant/tools/theme-unit-test-data.xml" --authors="create"

        #   deactivate the wordpress importer
        wp plugin deactivate wordpress-importer

        #   uninstall the wordpress importer
        wp plugin uninstall wordpress-importer

    fi

}

#
#   Final cleanup function
#
provision_nopriv_cleanup(){

    #   create generic installed file to know the install was already provision_cleanup() function was already ran
    echo "Creating generic 'no priveleges installed' flag file..."
    touch ~/nopriv_installed

}

#   check if generic installed file was created...
if [[ ! -f ~/nopriv_installed ]]; then

    install_wpcli

    install_wordpress

    install_wordpress_plugins

    install_wordpress_themes

    update_wordpress_options

    import_wordpress_data

    provision_nopriv_cleanup

fi
