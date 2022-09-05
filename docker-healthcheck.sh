#!/usr/bin/env bash

SYSPROPS_FILE=${DATADIR}/system.properties
if [ -f "${SYSPROPS_FILE}" ]; then
    SYSPROPS_PORT=`grep "^unifi.https.port=" ${SYSPROPS_FILE} | cut -d'=' -f2`
    echo "SYSPROPS_PORT: ${SYSPROPS_PORT}"
fi
PORT=${SYSPROPS_PORT:-8443}
echo "PORT: ${PORT}"

curl --max-time 5 -kIL --fail https://localhost:${PORT}

echo "*** 1 ***"
ls /var/log/mongodb/
echo "*** 2 ***"
ls /var/log/unifi/
echo "*** 3 ***"
cat /usr/lib/unifi/logs/migration.log
echo "*** 4 ***"
cat /usr/lib/unifi/logs/server.log

exit 1
