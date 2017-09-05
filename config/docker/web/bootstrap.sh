#!/bin/bash

set -e

if [[ ! -f /etc/.htpasswd && -n "$HTPASSWD_PASSWORD" ]]; then
    printf "$HTPASSWD_USER:$(openssl passwd -crypt $HTPASSWD_PASSWORD)\n" >> /etc/.htpasswd
    printf "Enabled HTTP Basic Authentication.\n"
fi

cd /var/www/html/web

rm /usr/local/etc/php/conf.d/xdebug.ini || true

/var/www/html/config/docker/web/wait-for-db.sh

if [[ -n "$DRUPAL_INSTALL" && ! `drush cget system.site uuid` ]]; then
  printf "Installing Drupal.\n"
  export INSTALL_ACTIVE=TRUE
  cmd="drupal site:install --force --no-interaction --no-ansi minimal"
  CONFIG_DIR=/var/www/html/config/drupal/sync
  if [[ -f "${CONFIG_DIR}/system.site.yml" ]]; then
    uuid=`drupal yaml:get:value ${CONFIG_DIR}/system.site.yml uuid`
    cmd="$cmd && drush cset -y system.site uuid $uuid && drush config-import -y"
  else
    # Not entirely contingent on having an exported config but implies that
    # The site has not been fully scaffolded.
    hash_salt=`drush php-eval "echo Drupal\Component\Utility\Crypt::randomBytesBase64(55);"`
    echo "\$settings['hash_salt'] = \"$hash_salt\";" >> /var/www/html/web/sites/default/settings.php
  fi
  eval "$cmd"
  unset INSTALL_ACTIVE
fi

for dn in `cat /var/www/html/config/docker/web/web-writeable.txt`; do
  [ -d /var/www/html/$dn ] || mkdir /var/www/html/$dn
  chown -R www-data /var/www/html/$dn
done

if [[ $ENVIRONMENT == 'DEV' ]]; then
  cp /var/www/html/config/docker/web/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
else
  export CRON_OK=TRUE
fi

printenv | sed 's/^\([a-zA-Z0-9_]*\)=\(.*\)$/export \1="\2"/g' > /cron-env

apache2-foreground
