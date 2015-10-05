# Docker Scaffolding for Drupal 8

## Purpose
This script is intended for one-time, initial scaffolding of a new [Drupal 8](http://drupal.org) project,
which would then be self-contained. It utilizes the [drupal-project composer template](https://github.com/drupal-composer/drupal-project)
to pull in Drupal core, and provides additional helpful Docker-focused functionality.
Drupal 8, with its robust exportable configuration file management and composer integration,
is uniquely suited for containerized development.

## Usage/Quick-Start
`curl -sS https://raw.githubusercontent.com/BradJonesLLC/docker-drupal/master/install.sh | bash -s PROJECT-NAME`

...Will install into a new directory named PROJECT-NAME and configure certain docker-compose helpers with that
same name.

## Features
Your new Drupal 8 site comes with a number of helper scripts and config files that
speed development in a containerized environment and production deployment.
+ A Dockerfile that includes all required and some suggested PHP extensions for Drupal 8
  (including the [Twig extension](http://twig.sensiolabs.org/doc/installation.html#installing-the-c-extension))
+ A quick-start [Docker Compose](https://docs.docker.com/compose/) file, which provides
  an Apache/PHP web container and mysql container
+ Scripts respond to environment variables, with defaults in the docker-compose.yml file:
  - `ENVIRONMENT`, if set to `DEV`, enables Mailcatcher, and Xdebug for Apache
  - `SSL`, if set to `FALSE`, disables SSL support (useful for development environments.)
+ Native SSL support (see below.)
+ A Makefile for quickly creating a data container for the mysql container (run `make make-data`)
+ A wrapper script for executing [drush](https://github.com/drush-ops/drush)
  inside the web container, and a starter global drushrc.php file
+ Xdebug for development, and all invocations of the `ddrush` helper script
+ [Mailcatcher](http://mailcatcher.me/) for debugging sent mail.

### Why ship with Xdebug and Mailcatcher? Won't they waste resources in production?
Xdebug and Mailcatcher are not loaded/started when `ENVIRONMENT` is not set to `DEV`,
so while you are shipping a slightly-larger container, this setup avoids the need for
a "Development-only" Dockerfile.

## SSL Support
To enable SSL, make sure your `SSL` environment variable is not `FALSE` (as is default
in the shipped docker-compose.yml file) and [mount](https://docs.docker.com/userguide/dockervolumes)
`server.key` and `server.crt` files into the container at `/usr/local/apache2/ssl/`.

## Requirements
- [Docker](https://docker.com)

## Highly Recommended
- [Docker Compose](https://docs.docker.com/compose/)
- [direnv](http://direnv.net/) for zero-config use of `ddrush` drush wrapper
- A local installation of [composer](http://getcomposer.org/)

## Contributing
Pull requests welcome; Both Drupal 8 and Docker are relatively new and fast-moving projects.
There doesn't appear to be many other comprehensive starterkits for Docker and Drupal,
so this is my effort at helping others avoid my steep learning curve on this front.
