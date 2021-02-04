#!/bin/bash
# 
# Copy LocalSettings.php from here into the MW container.
# 
# Run this script every time you edit LocalSettings.php.
# 
# Why not bind-mount LocalSetttings.php, you ask?
# Well, let me tell you.
# * The MediaWiki web root directory /var/www/html is mounted
#   using a Docker volume.
# * You can bind-mount directories into a Docker volume,
#   but you cannot bind-mount a file into a Docker volume.
# * For example: we can bind-mount mw-config into /var/www/html,
#   but we can't bind-mount LocalSettings.php into /var/www/html.
#
# One (stupid) solution is to re-build the entire docker container
# every time we change LocalSettings.php, or skins, or extensions,
# and re-copy them into the container. But even that wouldn't work,
# because they're being copied into /var/www/html, the contents of
# which will be wiped out when the Docker volume is mounted to 
# /var/www/html (if it already exists, which it will unless you're
# running the container for the first time - but then, you wouldn't
# be rebuilding, you would just be... building). Plus it takes forever.
# 
# Instead, we just copy LocalSettings.php into the container manually.
# 
# Okay, that's it. that's the rant.
set -e

NAME="tranquil_mw"
echo "Installing LocalSettings.php into $NAME"
docker cp mediawiki/LocalSettings.php $NAME:/var/www/html/LocalSettings.php
docker exec -it $NAME /bin/bash -c "chown www-data:www-data /var/www/html/LocalSettings.php"
docker exec -it $NAME /bin/bash -c "chmod 600 /var/www/html/LocalSettings.php"
echo "Finished installing LocalSettings.php into $NAME"

DIRS="/var/www/html/docs
/var/www/html/includes
/var/www/html/languages
/var/www/html/maintenance
/var/www/html/mw-config
/var/www/html/tests
/var/www/html/vendor"

for dir in $DIRS
do
    echo "Fixing permissions on $dir"
    docker exec -it $NAME /bin/bash -c "chown -R www-data:www-data $dir"
    docker exec -it $NAME /bin/bash -c "chmod 755 $dir"
    docker exec -it $NAME /bin/bash -c "chmod -R 755 $dir"
    echo "Finished fixing permissions on $dir"
done
