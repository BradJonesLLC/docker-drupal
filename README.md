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
composer create-project bradjonesllc/docker-drupal:master project-dir --stability dev --no-interaction
```
...Will install into a new directory named `project-dir`.
```
cd project-dir && ./install.sh
```
...Will run some additional helpful development scaffolding (see below.) This step
is optional but may help in kickstarting your development.

### Default addresses and command examples
- Start for first time; create data container, install Drupal: `make make-data && docker-compose up`
- Web: `http://localhost:8082`
- Get a login for uid 1, after install: `ddrush uli`

## Features
Your new Drupal 8 site comes with a number of helper scripts and config files that
speed development in a containerized environment and production deployment.
+ A `Dockerfile` that includes all required and some suggested PHP extensions for Drupal 8
  (including the [Twig extension](http://twig.sensiolabs.org/doc/installation.html#installing-the-c-extension))
+ A quick-start [Docker Compose](https://docs.docker.com/compose/) file, which provides
  an Apache/PHP web container and mysql container
+ Site installation with:
  - Optional force-set of an existing site UUID and import of configuration files,
    if present.
  - Sensible default `settings.php`, `settings.local.php` and `development.services.yml` files.
+ Scripts respond to environment variables, with defaults in the docker-compose.yml file:
  - In development mode, enables Xdebug for Apache, and
    toggles inclusion of `settings.local.php` and `development.services.yml`
+ A `Makefile` for quickly creating a data container for the mysql container (run `make make-data`)
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

### Why ship with Xdebug? Won't it waste resources in production?
Xdebug is not loaded/started when in development mode (see below),
so while you are shipping a slightly-larger container, this setup avoids the need for
a "Development-only" Dockerfile.

## Development Workflow
**TL;DR:** Leverage composer as much as possible for managing your project. The
drupal-project README is very helpful on this point (see above.)

While a wrapper is provided for running drush inside the container, avoid using
commands like `drush dl`. When using the default `docker-compose.yml` file, we
inject the entire file structure on the host into the container, so your local
file changes are reflected in real time. Asking drush to make filesystem changes
outside the `sites/*/files` directory (`drush cache-rebuild` should be OK) may
result in permissions errors and other weirdness.

### Development Mode
Enable development mode (on by default) by setting the `ENVIRONMENT` environment
variable == `DEV`.

### Version control notes
**The proper way to include projects and other dependencies**, when using composer,
is to add them as requirements in `composer.json` and then running `composer update`.

As noted above, the contents of those dependencies are excluded by default in
`.gitignore`, so you should only be versioning code custom to your site.

### `ddrush` helper script
Paired with the environment variable/PATH set with direnv (see above), you may execute
most Drush commands inside the web container by typing `ddrush your-command` inside
the project. (You may need to run `direnv allow`) in your shell, before starting work.
More complex commands involving quoting are not passed through verbatim; run `dbash`
first, then your `drush` command directly inside the container.

### Xdebug Usage on same host as Docker container
[Toggle Xdebug](http://xdebug.org/docs/remote#starting) in your browser or HTTP
request, and initiate a corresponding listening session in your IDE on port 9000.
The provided PhpStorm configuration means you can just click the phone icon and go!

### Updating Drupal core
drupal-project's post-install command will ensure your Drupal core "scaffolding"
files are kept in sync with upstream. See drupal-project's README.

### What about Drupal 8 configuration?
To ship/version a copy of your site with exported configuration, dump the config
to disk - `ddrush config-export` - and your config will be dumped to `config/drupal/sync`.
That directory is set as writable by the Apache user in development mode, for ease
of export. In a production environment, import your configuration with drush or the web UI.

### Patching
Check out [composer-patches](https://github.com/cweagans/composer-patches) for an easy
solution.

#### Configuration management in development mode
When the web container starts in with the environment variable `DRUPAL_INSTALL = TRUE`,
the bootstrap script attempts to determine the presence of an installed Drupal database.
If not found, the script will attempt to install Drupal, set the site UUID, and import
any existing configuration. Thus you can re-use (or, not) a development database even
across web container rebuilds.

#### Database management in development mode
As noted above, the bootstrap script contains some safeguards against installing
over an existing database. Should you wish to (re-)start from scratch (or a fresh
import of your exported configuration files), remove the `db` database container,
then the `drupal_data` container.

## SSL Support
SSL termination is no longer bundled. In the spirit of Docker containers doing
one task well, consider using [a proxy container](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion)
in conjunction with a free [Let's Encrypt](https://letsencrypt.org/) certificate.

## Production Deployment
### Data Permanence
With development mode off, Drupal will expect to find an installed database at the
`db` alias. Also, it's strongly suggested you mount host directories into the container
at the locations in [`web-writeable.txt`](https://github.com/BradJonesLLC/docker-drupal/blob/master/config/docker/web/web-writeable.txt)
so user and system-generated files are preserved.

## Requirements
- [Docker](https://docker.com)
- [Docker Compose](https://docs.docker.com/compose/), for running containers locally.
- Linux or similar virtualized environment with bash shell. Perhaps [Docker Toolbox](https://docs.docker.com/toolbox/overview/) will help if you're on Windows or Mac?
- A local installation of [composer](http://getcomposer.org/)

### Highly Recommended
- [direnv](http://direnv.net/) for zero-config use of `ddrush` drush wrapper and scripts in `vendor/bin`.

## Contributing
Issues and pull requests welcome; Both Drupal 8 and Docker are relatively new and
fast-moving projects. There doesn't appear to be many other comprehensive starterkits
for Docker and Drupal, so this is my effort at helping others avoid my steep learning
curve on this front.

### Known Issues
See the [confirmed bugs in the issue queue](https://github.com/BradJonesLLC/docker-drupal/labels/bug).

## See Also
### Other Projects
There are a few other Drupal/Docker projects, though most appear focused on Drupal 7:
- [dropdock](https://github.com/twinbit/dropdock)
- [drude](https://github.com/blinkreaction/drude)
- [bowline](https://github.com/davenuman/bowline)

A few options for production deployment:
- [Docker Machine](https://docs.docker.com/machine/)
- [Docker Swarm](https://docs.docker.com/swarm/install-w-machine/)

### Groups and Resources
- [Docker group on groups.drupal.org](https://groups.drupal.org/docker)

## Copyright and License
&copy; Brad Jones LLC. Licensed under GPL 2.
