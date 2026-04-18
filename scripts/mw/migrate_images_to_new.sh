#!/bin/bash
#
# Copy uploaded images from the old MW volume to the new MW volume.
set -eux

echo "Copying images from ambivalent_mw_data to ambivalent_mw_new_data..."

docker run --rm \
    -v ambivalent_mw_data:/old:ro \
    -v ambivalent_mw_new_data:/new \
    alpine sh -c 'cp -a /old/images/. /new/images/ 2>/dev/null; echo done'

echo "Image migration complete."
