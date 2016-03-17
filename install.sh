#!/usr/bin/env bash

set -e

# composer create-project drupal-composer/drupal-project:8.x-dev $1 --stability dev --no-interaction
cat config/drupal/settings.php >> web/sites/default/settings.php \
&& cp config/drupal/settings.local.php web/sites/default \
&& cp config/drupal/development.services.yml web/sites \
&& mv .idea-dist .idea && echo "$1" > .idea/.name \
&& mv .idea/.gitignore.dist .idea/.gitignore \
&& sed -i 's/\.idea/\#.idea/g' .gitignore \
&& cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 74 | head -n 1 > config/docker/web/drupal-salt.txt \
&& printf "\n=============================\n" \
&& printf "Your site is scaffolded. Run\n\t'cd $1 && make make-data && docker-compose up'\nto spin up for the first time.\n"
