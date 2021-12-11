#!/bin/bash
# 
# fix skins in the mediawiki container.

set -eux

NAME="ambivalent_mw"

MW_DIR="${POD_GOLLY_WIKI_DIR}/g-mediawiki"
MW_CONF_DIR="${MW_DIR}/mediawiki"
SKINS_DIR="${MW_CONF_DIR}/skins"

echo "Checking that container exists"
docker ps --format '{{.Names}}' | grep ${NAME} || exit 1;

echo "Checking that skins dir exists"
test -d ${SKINS_DIR}

echo "Installing skins into $NAME"
docker exec -it $NAME /bin/bash -c 'rm -rf /var/www/html/skins'
docker cp ${SKINS_DIR} $NAME:/var/www/html/skins
docker exec -it $NAME /bin/bash -c 'chown -R www-data:www-data /var/www/html/skins'

echo "Finished installing skins into $NAME"
