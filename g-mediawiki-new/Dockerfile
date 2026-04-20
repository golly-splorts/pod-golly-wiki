FROM mediawiki:1.39

EXPOSE 8989

VOLUME ["/var/www/html"]

# Install ImageMagick
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update \
    && apt-get install -y --no-install-recommends apt-utils imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Extensions
COPY --chown=www-data:www-data mediawiki/extensions/ParserFunctions   /var/www/html/extensions/ParserFunctions
COPY --chown=www-data:www-data mediawiki/extensions/Scribunto         /var/www/html/extensions/Scribunto
COPY --chown=www-data:www-data mediawiki/extensions/Loops             /var/www/html/extensions/Loops
COPY --chown=www-data:www-data mediawiki/extensions/Variables         /var/www/html/extensions/Variables

# Skins
COPY --chown=www-data:www-data mediawiki/skins /var/www/html/skins

# Settings
COPY --chown=www-data:www-data mediawiki/LocalSettings.php /var/www/html/LocalSettings.php
RUN chmod 600 /var/www/html/LocalSettings.php

# Apache conf file
COPY apache/*.conf /etc/apache2/sites-enabled/
RUN a2enmod rewrite

# PHP conf file
COPY php/php.ini /usr/local/etc/php/

# Start
CMD apache2-foreground
