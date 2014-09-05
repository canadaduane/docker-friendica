#!/bin/bash

/setup_db.sh $DATABASE /app/database.sql

mkdir /logs

touch /logs/php.log
touch /logs/db.log
touch /logs/friendica.log

chmod 666 /logs/*.log

if [ ! -f /app/.htconfig.php ]; then
tee /app/.htconfig.php <<EOF

<?php

\$db_host = 'localhost';
\$db_user = 'root';
\$db_pass = '';
\$db_data = '$DATABASE';

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

\$a->config['system']['db_log'] = '/logs/db.log';

error_reporting( E_ALL & ~E_NOTICE );
ini_set('error_log','/logs/php.log');
ini_set('log_errors','1');
ini_set('display_errors', '0');
EOF
fi

if [ "$ENABLE_HTACCESS"x = 'Truex' ]; then
    /enable_htaccess.sh
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
