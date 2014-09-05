#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <database> </path/to/sql_file.sql>"
	exit 1
fi

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
else
    echo "=> Using an existing volume of MySQL"
fi

if [ ! -f /.mysql_admin_created ]; then
    echo "=> Starting MySQL Server"
    /usr/bin/mysqld_safe > /dev/null 2>&1 &
    sleep 5
    echo "   Started with PID $!"

    echo "=> Create mysql admin user"
    /create_mysql_admin_user.sh

    echo "=> Create database $1"
    echo "CREATE DATABASE $1" | mysql -uroot

    echo "=> Importing SQL file"
    mysql -uroot "$1" < "$2"

    echo "=> Stopping MySQL Server"
    mysqladmin -uroot shutdown

    echo "=> Done!"
    touch /.mysql_admin_created
fi

