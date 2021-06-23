#!/bin/sh
set -e

TZ=${TZ:-Asia/Hong_Kong}
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

_term() {
  kill -TERM "$child" 2>/dev/null
  #/etc/init.d/freeradius stop
  /etc/init.d/apache2 stop
  /etc/init.d/mysql stop
  while [ `ps -ef | grep 'mysql\|apache2' | grep -v grep | wc -l` -gt 0 ]; do
    echo Sleep 1 sec and waiting for process exit ...
    sleep 1
  done
}

# Start Services
echo "Starting server..."
/etc/init.d/mysql start

# if mysql not init.
if [ ! -d /var/lib/mysql/mysql ]; then
  chown mysql:mysql /var/lib/mysql
  chmod 750 /var/lib/mysql
  mysqld --initialize --user=mysql
fi

# if motp_schema not init.
if [ ! -d /var/lib/mysql/motp ]; then
  mysql < /MOTP/Setup/MySQL/motp_schema.sql
fi

/etc/init.d/apache2 start

# Start freeradius
#/etc/init.d/freeradius start
#sleep infinity &
freeradius -f &
child=$!
wait "$child"
