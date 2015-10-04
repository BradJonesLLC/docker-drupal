#!/bin/bash
for dn in `cat /docker/web-writeable.txt`; do
  [ -d /var/www/html/$dn ] || mkdir /var/www/html/$dn
  chown -R www-data /var/www/html/$dn
done

if [[ $SSL == 'FALSE' ]]; then a2dismod ssl; fi
if [[ $ENVIRONMENT == 'DEV' ]]; then
  cp /docker/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
fi

cd /var/www/html/web

if [[ $ENVIRONMENT == 'DEV' && -z $DRUPAL_NO_INSTALL && [[ -n "$SITE_UUID" ]] && ! `mysql -hdb -p"$DB_1_ENV_MYSQL_ROOT_PASSWORD" -e "select 1 from $DB_1_ENV_MYSQL_DATABASE.router limit 1"` ]]; then
  drush site-install minimal -y install_configure_form.update_status_module='array(FALSE,FALSE)' --keep-config --writable
  drush cset -y system.site uuid "$SITE_UUID"
  drush config-import -y
fi

drush updb -y

apache2-foreground
