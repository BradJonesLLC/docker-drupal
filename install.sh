#!/usr/bin/env sh

composer create-project drupal-composer/drupal-project:8.x-dev $1 --stability dev --no-interaction
cd $1
wget https://github.com/BradJonesLLC/docker-drupal/archive/master.zip
unzip master.zip
rm install.sh
rm master.zip
