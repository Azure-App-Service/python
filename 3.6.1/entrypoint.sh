#!/bin/bash
set -e

python --version
pip --version

echo "INFO: starting SSH ..."
service ssh start

# setup nginx log dir
# http://nginx.org/en/docs/ngx_core_module.html#error_log
sed -i "s|error_log /var/log/nginx/error.log;|error_log stderr;|g" /etc/nginx/nginx.conf

# setup uWSGI dir
echo "INFO: moving /tmp/uwsgi.ini"
mv --no-clobber /tmp/uwsgi.ini "$UWSGI_DIR/"
touch $UWSGI_DIR/project-master.pid

# setup server root
mkdir -p "$HOME_SITE"
mv --no-clobber /tmp/index.py "$HOME_SITE/"

chown -R www-data:www-data "$HOME_SITE/"
chown -R www-data:www-data "$UWSGI_DIR"

echo "INFO: creating /tmp/uwsgi.sock ..."
rm -f /tmp/uwsgi.sock
touch /tmp/uwsgi.sock
chown www-data:www-data /tmp/uwsgi.sock
chmod 664 /tmp/uwsgi.sock

echo "INFO: starting nginx ..."
nginx #-g "daemon off;"

echo "INFO: starting uwsgi ..."
uwsgi --uid www-data --gid www-data --ini=$UWSGI_DIR/uwsgi.ini
