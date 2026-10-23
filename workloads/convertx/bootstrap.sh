#!/bin/sh
set -eu
ROOT="${MOYU_WORKLOAD_ROOT:?MOYU_WORKLOAD_ROOT is required}"
: "${PUID:?PUID is required}"
: "${PGID:?PGID is required}"
: "${JWT_SECRET:?JWT_SECRET is required}"
umask 077
mkdir -p "${ROOT}/data"
# Preserve /app as the upstream working directory while storing all mutable
# state in the manager's stable bind mount, independent of release versions.
if [ -d /app/data ] && [ ! -L /app/data ]; then
    rmdir /app/data
fi
if [ -L /app/data ]; then
    rm /app/data
fi
ln -s "${ROOT}/data" /app/data
chown "${PUID}:${PGID}" "${ROOT}/data"
cd /app
exec /entrypoint.sh "$@"
