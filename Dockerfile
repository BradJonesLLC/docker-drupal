# Docker container for Drupal 8

FROM bradjonesllc/docker-drupal:php7-apache

COPY config/docker/web/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY . /var/www/html

RUN ln -s ~www-data/html/vendor/bin/drush /usr/local/bin/drush
RUN ln -s ~www-data/html/vendor/bin/drupal /usr/local/bin/drupal

ARG gitref=unknown
ENV GITREF $gitref
LABEL gitref $gitref
