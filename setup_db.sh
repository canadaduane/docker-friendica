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

if [ ! -f /.mysql_database_created ]; then
    echo "=> Starting MySQL Server"
    /usr/bin/mysqld_safe >/dev/null 2>&1 &

    RET=1
    while [[ RET -ne 0 ]]; do
        echo "=> Waiting for confirmation of MySQL service startup"
        sleep 5
        mysql -uroot -e "status" > /dev/null 2>&1
        RET=$?
    done

    echo "=> Create database $1"
    echo "CREATE DATABASE $1" | mysql -uroot

    echo "=> Importing SQL file"
    mysql -uroot "$1" < "$2"

    echo "=> Closing MySQL Server (setup)"
    mysqladmin -uroot shutdown

    touch /.mysql_database_created
fi

