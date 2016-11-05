#!/bin/bash

printenv | sed 's/^\([a-zA-Z0-9_]*\)=\(.*\)$/export \1="\2"/g' > /cron-env

if [[ ! -f /etc/.htpasswd && -n "$HTPASSWD_PASSWORD" ]]; then
    printf "$HTPASSWD_USER:$(openssl passwd -crypt $HTPASSWD_PASSWORD)\n" >> /etc/.htpasswd
    printf "Enabled HTTP Basic Authentication.\n"
fi

for dn in `cat /var/www/html/config/docker/web/web-writeable.txt`; do
  [ -d /var/www/html/$dn ] || mkdir /var/www/html/$dn
  chown -R www-data /var/www/html/$dn
done

cd /var/www/html/web

rm /usr/local/etc/php/conf.d/xdebug.ini || true

/var/www/html/config/docker/web/wait-for-db.sh

if [[ -n "$DRUPAL_INSTALL" && ! `drush cget system.site uuid` ]]; then
  printf "Installing Drupal.\n"
  export INSTALL_ACTIVE=TRUE
  cmd="drush site-install -y minimal"
  CONFIG_DIR=/var/www/html/config/drupal/sync
  if [[ -f "${CONFIG_DIR}/system.site.yml" ]]; then cmd="$cmd --config-dir=${CONFIG_DIR}"; fi
  eval "$cmd"
  unset INSTALL_ACTIVE
fi

if [[ $ENVIRONMENT == 'DEV' ]]; then
  cp /var/www/html/config/docker/web/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
fi

apache2-foreground
