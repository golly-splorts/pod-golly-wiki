#!/bin/bash
#
# Roll back nginx from green (MW 1.39 + MySQL 8.0) to blue (old MW 1.35 + MySQL 5.7).
# Downtime is ~2 seconds (nginx reload).
set -eux

NGINX_CONF_DIR="${POD_GOLLY_WIKI_DIR}/g-nginx/conf.d"
CONF="https.wiki.golly.life.conf"

if [ ! -f "${NGINX_CONF_DIR}/${CONF}.blue" ]; then
    echo "ERROR: No blue config backup found at ${NGINX_CONF_DIR}/${CONF}.blue" >&2
    echo "Cannot roll back without the original config." >&2
    exit 1
fi

echo "Restoring blue stack config..."
cp "${NGINX_CONF_DIR}/${CONF}.blue" "${NGINX_CONF_DIR}/${CONF}"

echo "Making sure old containers are running..."
docker compose -f "${POD_GOLLY_WIKI_DIR}/docker-compose.yml" start ambivalent_mysql ambivalent_mw || true

echo "Reloading nginx..."
docker exec ambivalent_nginx nginx -s reload

echo ""
echo "Rollback complete. Wiki is now served by MW 1.35 + MySQL 5.7 (blue stack)."
echo ""
