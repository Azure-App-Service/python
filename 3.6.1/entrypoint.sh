#!/bin/bash
log(){
	while read line ; do
		echo "`date '+%D %T'` $line"
	done
}

set -e
logfile=/home/LogFiles/entrypoint.log
test ! -f $logfile && mkdir -p /home/LogFiles && touch $logfile
exec > >(log | tee -ai $logfile)
exec 2>&1

set_var_if_null(){
	local varname="$1"
	if [ ! "${!varname:-}" ]; then
		export "$varname"="$2"
	fi
}

python --version
pip --version

echo "INFO: starting SSH ..."
service ssh start

# setup nginx log dir
test ! -d "$NGINX_LOG_DIR" && echo "INFO: $NGINX_LOG_DIR not found, creating ..." && mkdir -p "$NGINX_LOG_DIR"

# setup uWSGI ini dir
test ! -d "$UWSGI_INI_DIR" && echo "INFO: $UWSGI_INI_DIR not found, creating ..." && mkdir -p "$UWSGI_INI_DIR"
echo "INFO: moving /tmp/uwsgi.ini"
mv --no-clobber /tmp/uwsgi.ini "$UWSGI_INI_DIR/"

# setup site home dir
test ! -d /home/site/wwwroot && echo "INFO: /home/site/wwwroot not found, creating ..." && mkdir -p /home/site/wwwroot
mv --no-clobber /tmp/index.py /home/site/wwwroot/
touch /home/uwsgi/project-master.pid

chown -R www-data:www-data "$NGINX_LOG_DIR"
chown -R www-data:www-data "$UWSGI_INI_DIR"
chown -R www-data:www-data /home/site/wwwroot

echo "INFO: creating /tmp/uwsgi.sock ..."
rm -f /tmp/uwsgi.sock
touch /tmp/uwsgi.sock
chown www-data:www-data /tmp/uwsgi.sock
chmod 664 /tmp/uwsgi.sock

echo "INFO: starting nginx ..."
nginx #-g "daemon off;"

echo "INFO: starting uwsgi ..."
uwsgi --uid www-data --gid www-data --ini=$UWSGI_INI_DIR/uwsgi.ini
