# Docker container for Drupal 8

FROM bradjonesllc/docker-drupal:php7-apache

COPY . /var/www/html

RUN ln -s ~www-data/html/vendor/bin/drush /usr/local/bin/drush
RUN ln -s ~www-data/html/vendor/bin/drupal /usr/local/bin/drupal
