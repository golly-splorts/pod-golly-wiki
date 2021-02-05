#!/bin/bash
# 
# Copy skins directory from here into the MediaWiki container.
#
# For an explanation of why this script is necessary, see rant in
# fix_LocalSettings.php.
set -e

NAME="ambivalent_mw"
echo "Installing skins into $NAME"
docker exec -it $NAME /bin/bash -c 'rm -rf /var/www/html/skins'
docker cp mediawiki/skins $NAME:/var/www/html/skins
docker exec -it $NAME /bin/bash -c 'chown -R www-data:www-data /var/www/html/skins'
echo "Finished installing skins into $NAME"
