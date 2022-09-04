#!/usr/bin/env bash

SYSPROPS_FILE=${DATADIR}/system.properties
if [ -f "${SYSPROPS_FILE}" ]; then
    SYSPROPS_PORT=`grep "^unifi.https.port=" ${SYSPROPS_FILE} | cut -d'=' -f2`
    echo "SYSPROPS_PORT: ${SYSPROPS_PORT}"
fi
PORT=${SYSPROPS_PORT:-8443}
echo "PORT: ${PORT}"

curl --max-time 5 -kIL --fail https://localhost:${PORT}
