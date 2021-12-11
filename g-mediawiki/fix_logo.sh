#!/bin/bash
# 
# Copy logo file from here into the MediaWiki container.
#
set -e

NAME="ambivalent_mw"
echo "Installing logo into $NAME"
docker exec -it $NAME /bin/bash -c "mkdir -p /var/www/html/assets"
docker cp mediawiki/gollylogo.png $NAME:/var/www/html/assets/.
echo "Finished installing logo into $NAME"
