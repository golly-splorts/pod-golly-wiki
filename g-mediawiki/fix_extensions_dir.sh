#!/bin/bash
# 
# Copy extensions directory from here into the MediaWiki container.
#
# For an explanation of why this script is necessary, see rant in
# fix_LocalSettings.php.
set -e

NAME="tranquil_mw"
EXTENSIONS="ParserFunctions Loops Variables"

echo "Replacing existing versions of MediaWiki extensions..."

for EXTENSION in $EXTENSIONS; do
    echo "Removing old extension ${EXTENSION} from /var/www/html/extensions"
    set +e
    docker exec -it $NAME /bin/bash -c "test -d /var/www/html/extensions/${EXTENSION} && mv /var/www/html/extensions/${EXTENSION} /var/www/html/extensions/_${EXTENSION}"
    set -e
    echo "Copying new extension ${EXTENSION} from p-mediawiki/mediawiki/extensions (old extension dir will be at _${EXTENSION})"
    docker cp mediawiki/extensions/${EXTENSION} ${NAME}:/var/www/html/extensions
    echo "Fixing permissions on ${EXTENSION}"
    docker exec -it $NAME /bin/bash -c "chown www-data:www-data /var/www/html/extensions/${EXTENSION}"
    docker exec -it $NAME /bin/bash -c "chmod 755 /var/www/html/extensions/${EXTENSION}"
done

echo "Finished replacing extensions!"
