# Docker container for Drupal 8

FROM bradjonesllc/docker-drupal:php7-apache

COPY . /var/www/html
