FROM mediawiki:1.35

EXPOSE 8989

VOLUME ["/var/www/html"]

# Install ImageMagick
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y build-essential \
            imagemagick

# MediaWiki needs everything to be in one www folder
# The www folder is a docker volume
# Docker cannot bind-mount a single file into a docker volume
# LocalSettings.php must be manually copied in with fix_LocalSettings.sh
# Skins must be manually copied in with fix_skins.sh
# Extensions must be manually updated with fix_extensions.sh

# Extensions
COPY mediawiki/extensions/ParserFunctions   /var/www/html/extensions/ParserFunctions
COPY mediawiki/extensions/Scribunto         /var/www/html/extensions/Scribunto
COPY mediawiki/extensions/Loops             /var/www/html/extensions/Loops
COPY mediawiki/extensions/Variables         /var/www/html/extensions/Variables
RUN chown -R www-data:www-data /var/www/html/*

# Skins
COPY mediawiki/skins /var/www/html/skins
RUN chown -R www-data:www-data /var/www/html/skins

# Settings
COPY mediawiki/LocalSettings.php /var/www/html/LocalSettings.php
RUN chown -R www-data:www-data /var/www/html/LocalSettings*
RUN chmod 600 /var/www/html/LocalSettings.php

# Apache conf file
COPY apache/*.conf /etc/apache2/sites-enabled/
RUN a2enmod rewrite
RUN service apache2 restart

# PHP conf file
# https://hub.docker.com/_/php/
COPY php/php.ini /usr/local/etc/php/

# Start
CMD apache2-foreground
