#!/bin/bash

set -ex

echo "STARTING INSTALL_PLUGINS_CMD"


# Run both the main playbook and the one enabling structured logging
$KPM_INSTALL_CMD $KILLBILL_CLOUD_ANSIBLE_ROLES/killbill_json_logging.yml

echo "STARTING INSTALL_PLUGINS_CMD..."

until mysql --protocol=TCP -h127.0.0.1 -P3306 -uroot -pkillbill -e "SELECT 1"; do
  echo "Waiting for MariaDB..."
  sleep 5
done

echo "$INSTALL_PLUGINS_CMD"

$INSTALL_PLUGINS_CMD

originalfile=$KILLBILL_INSTALL_DIR/config/shiro.ini.template
cat $originalfile | envsubst '${KB_ADMIN_PASSWORD}' > $KILLBILL_INSTALL_DIR/config/shiro.ini

exec /usr/share/tomcat/bin/catalina.sh run
