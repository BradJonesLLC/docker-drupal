#!/usr/bin/env sh

set -e

cat config/drupal/settings.php >> web/sites/default/settings.php \
&& cp config/drupal/settings.local.php web/sites/default \
&& cp config/drupal/development.services.yml web/sites \
&& mv .idea-dist .idea && printf '%s\n' "${PWD##*/}" > .idea/.name \
&& mv .idea/.gitignore.dist .idea/.gitignore \
&& sed -i 's/\.idea/\#.idea/g' .gitignore \
&& printf "Your site is scaffolded. Run\n\t'docker-compose up --build'\nto spin up.\n"
