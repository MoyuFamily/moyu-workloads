#!/bin/sh
set -eu

ROOT="${MOYU_WORKLOAD_ROOT:?MOYU_WORKLOAD_ROOT is required}"
ARTIFACT_ROOT="${MOYU_ARTIFACT_ROOT:?MOYU_ARTIFACT_ROOT is required}"
CONFIG="${ROOT}/config.yaml"

mkdir -p "${ROOT}/auths" "${ROOT}/plugins"
if [ ! -f "${CONFIG}" ]; then
    escaped_root="$(printf '%s' "${ROOT}" | sed -e 's/[\\&|]/\\&/g')"
    umask 077
    sed "s|@MOYU_WORKLOAD_ROOT@|${escaped_root}|g" \
        "${ARTIFACT_ROOT}/config.initial.yaml" > "${CONFIG}.tmp"
    chmod 600 "${CONFIG}.tmp"
    mv "${CONFIG}.tmp" "${CONFIG}"
fi

exec "${ARTIFACT_ROOT}/cli-proxy-api" --config "${CONFIG}"
