#!/bin/bash
#
# Run the update.php script to update the database
# after a version upgrade. Runs in the NEW (green stack) container.
set -eux

function usage {
    echo ""
    echo "update_wikidb_new.sh script:"
    echo "Run update.php to update a database"
    echo "after a MediaWiki version upgrade."
    echo "Runs in the ambivalent_mw_new container"
    echo ""
    echo "       ./update_wikidb_new.sh"
    echo ""
    exit 1;
}

if [[ "$#" -eq 0 ]];
then

    NAME="ambivalent_mw_new"

	echo "Checking that container exists"
	docker ps --format '{{.Names}}' | grep ${NAME} || exit 1;

	echo "Updating wiki database for version upgrade"
    docker exec -it ${NAME} php /var/www/html/maintenance/update.php --quick

else
    usage
fi
