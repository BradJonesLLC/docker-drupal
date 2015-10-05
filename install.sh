#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then echo "\nMust specify a project name.\n"; exit 1; fi
composer create-project drupal-composer/drupal-project:8.x-dev $1 --stability dev --no-interaction \
&& cd $1 \
&& wget https://github.com/BradJonesLLC/docker-drupal/archive/master.zip \
&& unzip -n master.zip -x docker-drupal-master/install.sh \
&& shopt -s dotglob && mv -n docker-drupal-master/* . \
&& rm -rf docker-drupal-master \
&& rm master.zip \
&& cat config/drupal/settings.php >> web/sites/default/settings.php \
&& cp config/drupal/settings.local.php web/sites/default \
&& cp config/drupal/development.services.yml web/sites \
&& cp .gitignore .dockerignore \
&& sed -i 's/PROJECT-NAME-PLACEHOLDER/$1/g' .envrc \
&& echo "\n\n=============================\n" \
&& echo "Your site is scaffolded. Run\n\t'cd $1 && make make-data && docker-compose up'\nto spin up for the first time.\n"
