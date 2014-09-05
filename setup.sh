#!/bin/bash

# /create_db.sh friendica
/import_sql.sh friendica /app/database.sql


touch /app/php.log
touch /app/db.log
touch /app/friendica.log
chmod 666 /app/*.log

tee /app/.htconfig.php <<EOF

<?php

\$db_host = 'localhost';
\$db_user = 'root';
\$db_pass = '';
\$db_data = 'friendica';

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
