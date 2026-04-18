#!/bin/bash
#
# Migrate wikidb from old MySQL 5.7 (ambivalent_mysql) to new MySQL 8.0 (ambivalent_mysql_new).
# This dumps from the old container and loads into the new one.
set -eux

OLD_MYSQL="ambivalent_mysql"
NEW_MYSQL="ambivalent_mysql_new"

echo "Checking that both containers exist..."
docker ps --format '{{.Names}}' | grep ${OLD_MYSQL} || exit 1;
docker ps --format '{{.Names}}' | grep ${NEW_MYSQL} || exit 1;

DUMP_FILE="/tmp/wikidb_for_upgrade.sql"

echo ""
echo "Step 1: Dumping wikidb from old MySQL container (${OLD_MYSQL})..."
echo ""

set +x
MYSQL_PWD="$(docker exec "${OLD_MYSQL}" printenv MYSQL_ROOT_PASSWORD)"
export MYSQL_PWD
set -x

docker exec -i \
    -e MYSQL_PWD \
    "${OLD_MYSQL}" \
    sh -c 'exec mysqldump \
              --user=root \
              --single-transaction \
              --quick \
              --routines \
              --triggers \
              --events \
              --default-character-set=binary \
              --databases wikidb' \
    > "${DUMP_FILE}"

unset MYSQL_PWD

if ! tail -c 200 "${DUMP_FILE}" | grep -q 'Dump completed on'; then
    echo "ERROR: dump file is missing the completion trailer." >&2
    exit 2
fi

size=$(stat -c %s "${DUMP_FILE}")
echo "Dump OK: ${DUMP_FILE} (${size} bytes)"

echo ""
echo "Step 2: Loading dump into new MySQL container (${NEW_MYSQL})..."
echo ""

set +x
MYSQL_PWD="$(docker exec "${NEW_MYSQL}" printenv MYSQL_ROOT_PASSWORD)"
export MYSQL_PWD
set -x

docker exec -i \
    -e MYSQL_PWD \
    "${NEW_MYSQL}" \
    sh -c 'exec mysql --user=root' \
    < "${DUMP_FILE}"

unset MYSQL_PWD

echo ""
echo "Database migration complete."
echo "Next step: run update_wikidb_new.sh to upgrade the DB schema for MW 1.39."
echo ""
