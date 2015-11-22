#!/bin/bash
for dn in `cat /docker/web-writeable.txt`; do
  [ -d /var/www/html/$dn ] || mkdir /var/www/html/$dn
  chown -R www-data /var/www/html/$dn
done

if [[ $SSL == 'FALSE' ]]; then a2dismod ssl; fi
if [[ $ENVIRONMENT == 'DEV' ]]; then
  cp /docker/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
  chown -R :www-data /var/www/html/config/drupal/sync
  chmod -R g+w /var/www/html/config/drupal/sync
fi

cd /var/www/html/web

if [[ $ENVIRONMENT == 'DEV' && -z $DRUPAL_NO_INSTALL && ! `mysql -hdb -p"$DB_1_ENV_MYSQL_ROOT_PASSWORD" -e "select 1 from $DB_1_ENV_MYSQL_DATABASE.router limit 1"` ]]; then
  drush site-install minimal -y install_configure_form.update_status_module='array(FALSE,FALSE)' --keep-config
  if [[ -n "$SITE_UUID" ]]; then drush cset -y system.site uuid "$SITE_UUID" && drush config-import -y; fi
fi

drush updb -y

apache2-foreground
