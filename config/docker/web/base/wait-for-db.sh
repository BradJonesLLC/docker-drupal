#!/usr/bin/env bash

# Only here for backwards-compatibility.

echo "Calling /wait-for-db.sh is deprecated. Use dockerize instead.\n"
HOST=${DRUPAL_DATABASE_HOST:-db}
dockerize -wait tcp://$HOST:3306 -timeout 60s
