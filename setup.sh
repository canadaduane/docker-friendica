#!/bin/bash

INSTANCE=${1:-friendica}
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

/import_sql.sh $INSTANCE /app/database.sql

touch /app/php.log
touch /app/db.log
touch /app/$INSTANCE.log

chmod 666 /app/*.log

tee /app/.htconfig.php <<EOF

<?php

\$db_host = 'localhost';
\$db_user = 'root';
\$db_pass = '';
\$db_data = '$INSTANCE';

\$a->path = '';

\$default_timezone = 'Europe/Rome';

\$a->config['sitename'] = "Friendica";

\$a->config['register_policy'] = REGISTER_OPEN;
\$a->config['register_text'] = '';

\$a->config['max_import_size'] = 200000;

\$a->config['system']['maximagesize'] = 800000;

\$a->config['php_path'] = '/usr/bin/php';

\$a->config['system']['directory_submit_url'] = ''; # 'http://dir.friendica.com/submit';
\$a->config['system']['directory_search_url'] = 'http://dir.friendica.com/directory?search=';

\$a->config['system']['huburl'] = 'http://pubsubhubbub.appspot.com';

\$a->config['system']['rino_encrypt'] = true;

\$a->config['system']['theme'] = 'duepuntozero';

\$a->config['system']['db_log'] = 'db.log';

error_reporting( E_ALL & ~E_NOTICE );
ini_set('error_log','/app/php.log');
ini_set('log_errors','1');
ini_set('display_errors', '0');


EOF
