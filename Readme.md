# pod-golly-wiki

A docker pod for running the golly.life wiki.

# templates

Note that several important files in this repo are Jinja2 templates.

This repo is intended to be used with Ansible, which turns the Jinja templates into real files.

# setup

## network

- containers are connected using the default docker network
- nginx is only external listening container
- docker binds nginx to host network interface

## domain

The domain for the wiki is <https://wiki.golly.life>

The certificate is for the same (via certbot - still manual renewal).

## mediawiki

The centerpiece of the wiki is the mediawiki container.

This is configured using files in the `g-mediawiki` directory.

The `Dockerfile` used to create the mediawiki container is at `g-mediawiki/Dockerfile`.

Summary of build process:
* we have a script to clone any extensions that are needed - that should be run before building
* the container mounts `/var/www/html` (the mediawiki root web directory) to a docker volume
* the dockerfile copies LocalSettings, extensions, and skins into the docker volume
* (note: if these are updated after the fact, use the scripts to copy the new versions into the container, instead of rebuilding the container)

Summary of MySQL credentials for MediaWiki:
* MySQL password must be passed to MediaWiki via the LocalSettings.php file
* LocalSettings.php file at `g-mediawiki/mediawiki/LocalSettings.php` gets the MySQL server details from
  environment variables
* `MYSQL_HOST`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`
* these environment variables are set via the `docker-compose.yml` file
* this file is not under version control, we provide a Jinja template that fills in the MySQL details in the
  environment variable definitions

There are some initial setup steps involved, when you first spin up the pod:

## mysql

The mysql container stores all the data for the wiki.

The MySQL password is set in the `docker-compose.yml` file. This file is not under version control.

Instead, we provide a Jinja2 template where there is a stand-in variable for the MySQL variable.

## nginx

Nginx requires that certificates for the domain be set up in advance. It bind-mounts `/etc/letsencrypt` into
the container, and the nginx configuration file points to the appropriate certs for the domain at this directory.

Ansible is used to set up the certificates before this pod is installed and started.

## nginx exporter

for telemetry purposes

# post-setup

## mediawiki database initialization

Because the database was not restored from backup, and therefore has no structure to start with,
MediaWiki installation files are needed to configure the database.

To do this, download a release of mediawiki from mediawiki.org and copy the `mw-config` directory
into the root directory of the wiki.

You can put the `mw-config` directory at `g-mediawiki/mediawiki/mw-config` and bind-mount it to the
correct location inside the container like so:

(excerpt from `docker-compose.yml`)

```
  tranquil_mw:
    volumes:
      - "./g-mediawiki/mediawiki/mw-config:/var/www/html/mw-config"
```

then visit <https://127.0.0.1/wiki/mw-config/index.php>

## mediawiki images directory

- need to make a temp dir for MediaWiki images
- run the following commands inside the MediaWiki container once it is up:

```
mkdir /var/hwww/html/images/tmp
chown www-data:www-data /var/www/html/images/tmp
```
