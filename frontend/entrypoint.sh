#!/bin/sh
set -e

cd /app
yarn install

exec "$@"
