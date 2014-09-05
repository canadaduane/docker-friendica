#!/bin/bash
if [ "$ENABLE_HTACCESS"x = 'Truex' ]; then
    /enable_htaccess.sh
fi

if [ ! -f /.mysql_admin_created ]; then
    /create_mysql_admin_user.sh
    touch /.mysql_admin_created
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
