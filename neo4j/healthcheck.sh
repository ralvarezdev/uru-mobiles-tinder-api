#!/bin/bash
set -e

# Execute healthcheck
cypher-shell -u "${NEO4JDB_DEFAULT_USERNAME}" -p "${NEO4JDB_DEFAULT_PASSWORD}" "RETURN 1" > /dev/null 2>&1
exit $?