#!/bin/bash
#
# Restore wiki files from a tar file
# into the mediawiki docker container.
set -eu

CONTAINER_NAME="${GOLLY_WIKI_MW_CONTAINER:-ambivalent_mw}"

function usage {
    echo ""
    echo "wikifiles_restore.sh script:"
    echo "Restore wiki files from a tar file"
    echo "into the ${CONTAINER_NAME} container"
    echo ""
    echo "       ./wikifiles_restore.sh <tar-file>"
    echo ""
    echo "Example:"
    echo ""
    echo "       ./wikifiles_restore.sh /path/to/wikifiles.tar.gz"
    echo ""
    echo ""
    exit 1;
}

# NOTE:
# I assume images/ is the only directory to back up/restore.
# If there are more I forgot, add them back in here.
# (skins and extensions are static, added into image at build time.)

if [[ "$#" -eq 1 ]];
then

    DOCKER=$(which docker)
    TAR=$(basename "$1")

    echo "Checking that container ${CONTAINER_NAME} exists"
    ${DOCKER} ps --format '{{.Names}}' | grep ${CONTAINER_NAME} || exit 1;

    echo "Copying dir $1 into container ${CONTAINER_NAME}"
    set -x
    ${DOCKER} cp $1 ${CONTAINER_NAME}:/tmp/${TAR}
    ${DOCKER} exec -it ${CONTAINER_NAME} rm -rf /var/www/html/images.old
    ${DOCKER} exec -it ${CONTAINER_NAME} mv /var/www/html/images /var/www/html/images.old
    ${DOCKER} exec -it ${CONTAINER_NAME} tar -xf /tmp/${TAR} -C / && rm -f /tmp/${TAR}
    ${DOCKER} exec -it ${CONTAINER_NAME} chown -R www-data:www-data /var/www/html/images

else
    usage
fi
