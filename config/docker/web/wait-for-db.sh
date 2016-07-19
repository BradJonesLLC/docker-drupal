#!/usr/bin/env bash

# see https://github.com/docker/compose/issues/374#issuecomment-174506025
set -e

echoerr() { echo "$@" 1>&2; }

echoerr wait-for-db: waiting for db:3306

TIMEOUT=60
timeout "$TIMEOUT" bash <<EOT
while ! (echo > /dev/tcp/db/3306) >/dev/null 2>&1;
    do sleep 1;
done;
EOT
RESULT=$?

if [ $RESULT -eq 0 ]; then
  # sleep another second for so that we don't get a "the database system is starting up" error
  sleep 1
  echoerr wait-for-db: done
else
  echoerr wait-for-db: timeout out after "$TIMEOUT" seconds waiting for db:3306
fi