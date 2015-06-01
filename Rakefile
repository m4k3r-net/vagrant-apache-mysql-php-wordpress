#
# Rakefile for Vagrant box
#

# local mysql database name, user, and password
mysql_database = "wordpress"
mysql_user     = "root"
mysql_password = "root_password"

# local backup paths
vagrant_dir = "/vagrant"
backup_dir  = "backups"

desc "List available backups"
task :list_backups do
    # list all .sql files with the newest at the top
    system "cd #{backup_dir} && ls -lht *.sql"
end

desc "Backup your current database, examples 'rake backup_db' or 'rake backup_db[my-backup-file-name]'"
task :backup_db, [:filename] do |t, args|
    # if the user is not within the vagrant directory, let them know
    if Dir.pwd != vagrant_dir
        puts "You are not within the vagrant machine, please 'vagrant ssh' into the machine or use 'vagrant exec rake backup_db'"
        next
    end

    # get the supplied file name
    if args.filename
        filename = args.filename.gsub /\s+/, "-"
    end

    # if the filename wasn't supplied, generate a unique one
    if ! filename
        timestamp = Time.new.strftime "%Y-%m-%d-%H-%M-%S"
        filename = "backup-#{timestamp}.sql"
    end

    # make sure the supplied name has a .sql extension
    if ! filename.end_with? ".sql"
        filename = "#{filename}.sql"
    end

    # create the backup path
    backup_path = "#{backup_dir}/#{filename}"

    # let the user know where the file is being backed up
    puts "Backing up mysqldump of #{mysql_database} to #{backup_path}" 

    # move into the backup directry and dump the backup
    system "cd #{backup_dir} && mysqldump -u#{mysql_user} -p#{mysql_password} #{mysql_database} > #{filename}"
end

desc "Import a backup file into your database, examples 'rake import_db' or 'rake import_db[my-backup-file-name]'"
task :import_db, [:filename] do |t, args|
    # if the user is not within the vagrant directory, let them know
    if Dir.pwd != vagrant_dir
        puts "You are not within the vagrant machine, please 'vagrant ssh' into the machine or use 'vagrant exec rake backup_db'"
        next
    end

    # did the user specify a file to backup?
    if args.filename
        filename = "backups/#{args.filename}"
    else
        filename = Dir["**/backups/*.sql"].max_by {|f| File.mtime(f)}
    end

    # make sure the supplied name has a .sql extension
    if ! filename.end_with? ".sql"
        filename = "#{filename}.sql"
    end

    # if the file doesn't exist notify the user
    if ! File.exist? filename
        puts "The file could not be found. Please use a file from the list 'rake list_backups' or export a backup 'rake backup_db'"
        next
    end

    # check for valid file
    if ! filename
        puts "There currently is not a backup file to be imported."
        next
    end

    # check for valid file size
    if ! File.size? filename
        puts "There current backup file has an invalid size."
        next
    end

    # get the file basename
    filename = File.basename filename

    puts "Importing #{filename} in #{mysql_database}"

    # import the mysql backup file
    system "cd #{backup_dir} && mysql -u#{mysql_user} -p#{mysql_password} #{mysql_database} < #{filename}"
end

desc "Update php composer.  See https://getcomposer.org/"
task :update_composer do
    # install composer (or update by override) 
    system "curl -sS https://getcomposer.org/installer | php && sudo mv composer.phar /usr/local/bin/composer && composer -V"
end

desc "Update php unit.  See https://phpunit.de/"
task :update_phpunit do
    # install php unit (or update by override)
    system "wget https://phar.phpunit.de/phpunit.phar && chmod +x phpunit.phar && sudo mv phpunit.phar /usr/local/bin/phpunit && phpunit --version"
end

desc "Update WP-CLI.  See http://wp-cli.org/"
task :update_wpcli do
    # install wp-cli (or update by override)
    system "curl -L https://raw.github.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > wp-cli.phar && chmod +x wp-cli.phar && sudo mv wp-cli.phar /usr/local/bin/wp && wp --info"
end
