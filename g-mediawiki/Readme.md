# g-mediawiki

This folder contains files to set up the MediaWiki container for the
golly wiki docker pod.

## mw-config dir

The `mw-config` dir contains files used for a one-time initialization of a new MySQL database.

See main repo [Readme.md](../Readme.md) for details about `mw-config` dir.

## php

The included `php.ini` files will increase the size limit for uploaded files from 2 MB to 100 MB.

## what are the `fix_*` scripts for?

See rant in `fix_LocalSettings.php`.
