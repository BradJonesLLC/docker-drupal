# Docker container for Drupal 8

FROM bradjonesllc/docker-drupal:php7-apache

RUN apt-get update && apt-get install -yqq --no-install-recommends \
  rsync \
  git \
  && apt-get clean autoclean && apt-get autoremove -y

COPY config/docker/web/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY config/docker/web/crontab.txt /var/crontab.txt
RUN crontab /var/crontab.txt && chmod 600 /etc/crontab

COPY . /var/www/html

RUN php -r "readfile('https://getcomposer.org/installer');" | php && mv composer.phar /usr/local/bin/composer
RUN composer install -d /var/www/html
RUN ln -s ~www-data/html/vendor/bin/drush /usr/local/bin/drush
RUN ln -s ~www-data/html/vendor/bin/drupal /usr/local/bin/drupal

COPY config/docker/web/drushrc.php /etc/drush/drushrc.php
COPY config/docker/web/php.ini /usr/local/etc/php/php.ini
