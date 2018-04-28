# Docker Scaffolding for Drupal 8

## Purpose
This script is intended for one-time, initial scaffolding of a new [Drupal 8](http://drupal.org) project,
which would then be self-contained. It uses a `composer.json` file derived from [drupal-project](https://github.com/drupal-composer/drupal-project)
to pull in Drupal core, and provides additional helpful Docker-focused functionality.
The drupal-project `composer.json` file and helper scripts can then be used to manage
core updates, contrib modules and more. Drupal 8, with its robust exportable configuration
file management and composer integration, is uniquely suited for containerized development.

## Usage/Quick-Start
```
composer create-project bradjonesllc/docker-drupal:master project-dir --no-interaction
```
...Will install into a new directory named `project-dir`.

### Default addresses and command examples
- Start for first time; create data container, install Drupal: `docker-compose up`
- Web: `http://localhost:8082`
- Get a login for uid 1, after install: `docker-compose exec web drush uli` (See below for shortcut options)

## Features
Your new Drupal 8 site comes with a number of helper scripts and config files that
speed development in a containerized environment and production deployment.
+ A `Dockerfile` that includes all required PHP extensions for Drupal 8
+ A quick-start [Docker Compose](https://docs.docker.com/compose/) file, which provides
  an Apache/PHP web container, mysql container and data volume.
+ Site installation with:
  - Optional force-set of an existing site UUID and import of configuration files,
    if present.
  - Sensible default `settings.php`, `settings.local.php` and `development.services.yml` files.
+ Scripts respond to environment variables, with defaults in the docker-compose.yml file:
  - In development mode, enables Xdebug for Apache, and
    toggles inclusion of `settings.local.php` and `development.services.yml`
+ Wrapper scripts:
  - `ddrush`, for executing [drush](https://github.com/drush-ops/drush) inside the
    web container, with a starter global `/etc/drush/drushrc.php` file.
  - `dbash`, a shortcut for getting a bash shell inside the web container (as *www-data*)
+ An `.envrc` file, for use with [direnv](http://direnv.net/), that:
  - Tells wrapper scripts the correct container to execute against (by pattern).
  - Includes the wrapper script and the `vendor/bin` directory into the PATH.
+ Xdebug for development, and all invocations of the `ddrush` helper script
+ `.dockerignore` excludes VCS and uploaded files. Docker runs `composer install`
  inside the container on build, though if your development environment includes
  many of those files, having them copied into the container saves some time on
  build. See *Development Workflow*, below.
+ All processes in the web container log to `STDOUT`; this is useful if you wish to
  aggregate your Docker container logs or integrate with an external log service
  such as [Logentries](https://logentries.com/learnmore?code=e500f810).
+ An optional `rsyslog.json.conf` file, which will format log output in JSON format;
  this expects JSON output directly from Drupal; consider using a module like
  [Syslog JSON](https://www.drupal.org/sandbox/bradjones1/2569795)
+ Default configuration files for [PhpStorm](https://www.jetbrains.com/phpstorm/),
  including a server configuration and path mapping for Xdebug and setting max
  debug connections == 10 for [compatibility with](https://github.com/drush-ops/drush/issues/1534)
  Drush's subrequests.
+ A default cron implementation via crontab, which runs only when not in
  development mode. Set the `SITE_URL` environment variable, so Drupal constructs
  appropriate self-referential URLs during cron.

## Requirements
- [Docker](https://docker.com)
- [Docker Compose](https://docs.docker.com/compose/), for running containers locally.
- Linux or similar virtualized environment with bash shell. Perhaps [Docker Toolbox](https://docs.docker.com/toolbox/overview/) will help if you're on Windows or Mac?
- A local installation of [composer](http://getcomposer.org/)

## Contributing
Issues and pull requests welcome; Both Drupal 8 and Docker are relatively new and
fast-moving projects. There doesn't appear to be many other comprehensive starterkits
for Docker and Drupal, so this is my effort at helping others avoid my steep learning
curve on this front.

## Copyright and License
&copy; 2016, Brad Jones LLC. Licensed under GPL 2.
