# Docker container for Drupal 8

FROM bradjonesllc/docker-drupal:php7-apache as base

FROM base as deploy

COPY . /var/www/html
