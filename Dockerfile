# Docker container for Drupal 8

FROM bradjonesllc/docker-drupal:php7-apache

COPY config/docker/web/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY config/docker/web/crontab.txt /var/crontab.txt
RUN crontab /var/crontab.txt && chmod 600 /etc/crontab && touch /cron-env

COPY . /var/www/html

RUN ln -s ~www-data/html/vendor/bin/drush /usr/local/bin/drush
RUN ln -s ~www-data/html/vendor/bin/drupal /usr/local/bin/drupal

COPY config/docker/web/php.ini /usr/local/etc/php/php.ini

ARG gitref=unknown
ENV GITREF $gitref
LABEL gitref $gitref
