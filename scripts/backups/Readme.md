# backup scripts

This directory contains several files for several services:

* Systemd .service file (Jinja template) to define a service that backs up files
* Systemd .timer file (Jinja template) to define a timer that runs the service on a schedule
* Shell script .sh that actually performs the backup operation and is called by the .service file

Use `make templates` in the top level of this repo to render
the Jinja templates using the environment variables in the
evnrionment file. That fixes the locations of the scripts
for the systemd service.

Use `make install` in the top level of this repo to install
the rendered service and timer files.

## syslog filtering

Due to a bug in systemd bundled with Ubuntu 18.04, we can't just use the nice easy solution of
directing output and error to a specific file.

Instead, the services all send their stderr and stdout to the system log, and then rsyslog
filters those messages and collects them into a separate log file.

First, install the services.

Then, install the following rsyslog config file:

`/etc/rsyslog.d/10-pod-golly-wiki-rsyslog.conf`:

```
if $programname == 'pod-golly-wiki-canary' then /var/log/pod-golly-wiki-canary.service.log
if $programname == 'pod-golly-wiki-canary' then stop

if $programname == 'pod-golly-wiki-backups-aws' then /var/log/pod-golly-wiki-backups-aws.service.log
if $programname == 'pod-golly-wiki-backups-aws' then stop

if $programname == 'pod-golly-wiki-backups-cleanolderthan' then /var/log/pod-golly-wiki-backups-cleanolderthan.service.log
if $programname == 'pod-golly-wiki-backups-cleanolderthan' then stop

if $programname == 'pod-golly-wiki-backups-gitea' then /var/log/pod-golly-wiki-backups-gitea.service.log
if $programname == 'pod-golly-wiki-backups-gitea' then stop

if $programname == 'pod-golly-wiki-backups-wikidb' then /var/log/pod-golly-wiki-backups-wikidb.service.log
if $programname == 'pod-golly-wiki-backups-wikidb' then stop

if $programname == 'pod-golly-wiki-backups-wikifiles' then /var/log/pod-golly-wiki-backups-wikifiles.service.log
if $programname == 'pod-golly-wiki-backups-wikifiles' then stop
```

