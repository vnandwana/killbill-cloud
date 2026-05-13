#!/bin/bash

set -ex

echo "STARTING KPM INSTALL"

$KPM_INSTALL_CMD $KILLBILL_CLOUD_ANSIBLE_ROLES/killbill_json_logging.yml

originalfile=$KILLBILL_INSTALL_DIR/config/shiro.ini.template
cat $originalfile | envsubst '${KB_ADMIN_PASSWORD}' > $KILLBILL_INSTALL_DIR/config/shiro.ini

echo "Starting Tomcat..."

/usr/share/tomcat/bin/catalina.sh run &

TOMCAT_PID=$!

echo "Waiting for MariaDB..."

until mysql --protocol=TCP -h127.0.0.1 -P3306 -uroot -pkillbill -e "SELECT 1"; do
  sleep 5
done

echo "Waiting for Kill Bill readiness..."

until curl -f http://127.0.0.1:8080/1.0/healthcheck; do
  sleep 10
done

echo "STARTING INSTALL_PLUGINS_CMD"

$INSTALL_PLUGINS_CMD

wait $TOMCAT_PID
