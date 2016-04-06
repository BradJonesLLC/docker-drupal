#!/bin/bash
for dn in `cat /docker/web-writeable.txt`; do
  [ -d /var/www/html/$dn ] || mkdir /var/www/html/$dn
  chown -R www-data /var/www/html/$dn
done

if [[ $ENVIRONMENT == 'DEV' ]]; then
  cp /docker/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
else
  rm /usr/local/etc/php/conf.d/xdebug.ini
fi

cd /var/www/html/web

/docker/wait-for-db.sh

if [[ -n "$DRUPAL_INSTALL" && ! `mysql -hdb -p"$DB_1_ENV_MYSQL_ROOT_PASSWORD" -e "select 1 from $DB_1_ENV_MYSQL_DATABASE.router limit 1"` ]]; then
  printf "Installing Drupal.\n"
  export INSTALL_ACTIVE=TRUE
  cmd="drush site-install -y minimal install_configure_form.update_status_module='array(FALSE,FALSE)'"
  CONFIG_DIR=/var/www/html/config/drupal/sync
  if [[ -f "${CONFIG_DIR}/system.site.yml" ]]; then cmd="$cmd --config-dir=${CONFIG_DIR}"; fi
  eval "$cmd"
  unset INSTALL_ACTIVE
fi

drush updb -y
drush entity-updates -y

apache2-foreground
