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

if [[ -n "$DRUPAL_INSTALL" && ! `drush cget system.site.uuid` ]]; then
  printf "Installing Drupal.\n"
  export INSTALL_ACTIVE=TRUE
  cmd="drush site-install -y minimal --db-url=mysql://drupal:drupalpw@db:3306/drupal"
  CONFIG_DIR=/var/www/html/config/drupal/sync
  if [[ -f "${CONFIG_DIR}/system.site.yml" ]]; then cmd="$cmd --config-dir=${CONFIG_DIR}"; fi
  eval "$cmd"
  unset INSTALL_ACTIVE
fi

drush updb -y
drush entity-updates -y

apache2-foreground
