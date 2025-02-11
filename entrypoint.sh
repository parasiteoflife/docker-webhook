#!/bin/sh
set -e

if [ -d "/usr/local/share/ca-certificates" ] && [ "$(ls -A /usr/local/share/ca-certificates)" ]; then
  echo "Updating CA certificates..."
  update-ca-certificates
fi

exec /sbin/tini -- /usr/local/bin/webhook "$@"
