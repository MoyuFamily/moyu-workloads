#!/bin/sh
set -eu

ROOT="${MOYU_WORKLOAD_ROOT:?MOYU_WORKLOAD_ROOT is required}"
ARTIFACT_ROOT="${MOYU_ARTIFACT_ROOT:?MOYU_ARTIFACT_ROOT is required}"
: "${CHATGPT2API_AUTH_KEY:?CHATGPT2API_AUTH_KEY is required}"

umask 077
mkdir -p "${ROOT}/data"
if [ ! -f "${ROOT}/config.json" ]; then
    cp "${ARTIFACT_ROOT}/config.initial.json" "${ROOT}/config.json.tmp"
    mv "${ROOT}/config.json.tmp" "${ROOT}/config.json"
fi

# Upstream resolves these paths relative to /app. The manager supplies stable
# mounts independent of the Artifact release, so settings and accounts survive
# container recreation and Artifact upgrades.
rm -f /app/config.json
ln -s "${ROOT}/config.json" /app/config.json
if [ -d /app/data ] && [ ! -L /app/data ]; then
    rmdir /app/data
fi
rm -f /app/data
ln -s "${ROOT}/data" /app/data

cd /app
exec "$@"
