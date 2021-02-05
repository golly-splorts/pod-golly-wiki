#!/bin/bash
# 
# Copy logo file from here into the MediaWiki container.
#
set -e

NAME="ambivalent_mw"
echo "Installing logo into $NAME"
docker cp mediawiki/gollylogo.png $NAME:/var/www/html/assets/.
echo "Finished installing logo into $NAME"
