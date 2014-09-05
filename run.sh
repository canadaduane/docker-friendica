#!/bin/bash
if [ "$ENABLE_HTACCESS"x = 'Truex' ]; then
    /enable_htaccess.sh
fi

#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

if [ ! -f /.friendica_admin_created ]; then
    echo "\$a->config['admin_email'] = '$ADMIN_EMAIL';" >> /app/.htconfig.php
    echo "###############################################################"
    echo
    echo "open http://yourcontainer/register and register a new user."
    echo "Remember to user this email: $ADMIN_EMAIL !"
    echo
    echo "###############################################################"
    touch /.friendica_admin_created
fi

exec supervisord -n
