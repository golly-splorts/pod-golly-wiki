#!/bin/bash
#
# Switch nginx from blue (old MW 1.35 + MySQL 5.7) to green (MW 1.39 + MySQL 8.0).
# Downtime is ~2 seconds (nginx reload).
set -eux

NGINX_CONF_DIR="${POD_GOLLY_WIKI_DIR}/g-nginx/conf.d"
CONF="https.wiki.golly.life.conf"

echo "Backing up current nginx config..."
cp "${NGINX_CONF_DIR}/${CONF}" "${NGINX_CONF_DIR}/${CONF}.blue"

echo "Switching to green stack config..."
cp "${NGINX_CONF_DIR}/${CONF}.green" "${NGINX_CONF_DIR}/${CONF}"

echo "Reloading nginx..."
docker exec ambivalent_nginx nginx -s reload

echo ""
echo "Switchover complete. Wiki is now served by MW 1.39 + MySQL 8.0 (green stack)."
echo "To roll back: run scripts/rollback_to_blue.sh"
echo ""
