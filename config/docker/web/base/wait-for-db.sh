#!/usr/bin/env bash

# Only here for backwards-compatibility.

echo "Calling /wait-for-db.sh is deprecated. Use dockerize instead.\n"
dockerize -wait tcp://db:3306 -timeout 60s
