#!/bin/bash
set -e

TZ=${TZ:-Asia/Hong_Kong}
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

_term() {
  kill -TERM "$child" 2>/dev/null
  pkill mysqld
  while [ `ps -ef | grep mysqld | grep -v grep | wc -l` -gt 0 ]; do
    echo Sleep 1 sec and waiting for process exit ...
    sleep 1
  done
}

trap _term SIGTERM

# if mysql not init.
if [ ! -d /var/run/mysqld ]; then
  mkdir -p /var/run/mysqld
  chown mysql:mysql /var/run/mysqld
fi
if [ ! -d /var/lib/mysql/mysql ]; then
  chown mysql:mysql /var/lib/mysql
  chmod 750 /var/lib/mysql
  mysqld --initialize-insecure
fi

echo "Starting mysql ..."
mysqld_safe &

# if motp_schema not init.
if [ ! -d /var/lib/mysql/motp ]; then
  sleep 5
  mysql < /MOTP/Setup/MySQL/motp_schema.sql
fi

echo "Starting apache2 ..."
apachectl -D FOREGROUND &

# Start freeradius
#/etc/init.d/freeradius start
#sleep infinity &
echo "Starting freeradius ..."
freeradius -f &
child=$!
wait "$child"
