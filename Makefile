include common.mk

all:
	@echo "no default make rule defined"

help:
	@echo ""
	@echo ""
	@echo "pod-golly-wiki Makefile:"
	@echo ""
	@echo ""
	@echo "This Makefile contains rules for setting up pod-golly-wiki"
	@echo ""
	@echo "make help:           Get help"
	@echo ""
	@echo "--------------------------------------------------"
	@echo "                   Templates:"
	@echo ""
	@echo "make templates:      Render each .j2 template file in this and all subdirectories"
	@echo "                     (uses environment variables to populate Jinja variables)"
	@echo ""
	@echo "make list-templates: List each .j2 template file that will be rendered by a 'make template' command"
	@echo ""
	@echo "make clean-templates: Remove each rendered .j2 template"
	@echo ""
	@echo "--------------------------------------------------"
	@echo "                   Backups:"
	@echo ""
	@echo "make backups:        Create backups of every service (wiki database, wiki files) in ~/backups"
	@echo ""
	@echo "make clean-backups:  Remove files from ~/backups directory older than 30 days"
	@echo ""
	@echo "--------------------------------------------------"
	@echo "                   MediaWiki:"
	@echo ""
	@echo "make mw-build-extensions  Build the MediaWiki extensions directory"
	@echo ""
	@echo "make mw-fix-extensions    Copy the built extensions directory into the MW container"
	@echo ""
	@echo "make mw-fix-localsettings Copy the LocalSettings.php file into the MW container"
	@echo ""
	@echo "make mw-fix-skins         Copy the skins directory into the MW container"
	@echo ""
	@echo "--------------------------------------------------"
	@echo "                   Startup Services:"
	@echo ""
	@echo "make install:        Install and start systemd service to run pod-golly-wiki."
	@echo "                     Also install and start systemd service for pod-golly-wiki backup services"
	@echo "                     for each service (mediawiki/mysql) part of pod-golly-wiki."
	@echo ""
	@echo "make uninstall:      Remove all systemd startup services and timers part of pod-golly-wiki"
	@echo ""

# Templates

templates:
	@find * -name "*.service.j2" | xargs -I '{}' chmod 644 {}
	@find * -name "*.timer.j2" | xargs -I '{}' chmod 644 {}
	/home/charles/.pyenv/shims/python3 $(POD_GOLLY_WIKI_DIR)/scripts/apply_templates.py

list-templates:
	@find * -name "*.j2"

clean-templates:
	/home/charles/.pyenv/shims/python3 $(POD_GOLLY_WIKI_DIR)/scripts/clean_templates.py

# Backups

backups:
	$(POD_GOLLY_WIKI_DIR)/scripts/backups/wikidb_dump.sh
	$(POD_GOLLY_WIKI_DIR)/scripts/backups/wikifiles_dump.sh

clean-backups:
	$(POD_GOLLY_WIKI_DIR)/scripts/clean_templates.sh

# MediaWiki

mw-build-extensions:
	$(POD_GOLLY_WIKI_DIR)/scripts/mw/build_extensions_dir.sh

mw-fix-extensions: mw-build-extensions
	$(POD_GOLLY_WIKI_DIR)/scripts/mw/build_extensions_dir.sh

mw-fix-localsettings:
	$(POD_GOLLY_WIKI_DIR)/scripts/mw/fix_LocalSettings.sh

mw-fix-skins:
	$(POD_GOLLY_WIKI_DIR)/scripts/mw/fix_skins.sh

install:
ifeq ($(shell which systemctl),)
	$(error Please run this make command on a system with systemctl installed)
endif
	@/home/charles/.pyenv/shims/python3 -c 'import botocore' || (echo "Please install the botocore library using python3 or pip3 binary"; exit 1)
	@/home/charles/.pyenv/shims/python3 -c 'import boto3' || (echo "Please install the boto3 library using python3 or pip3 binary"; exit 1)

	sudo cp $(POD_GOLLY_WIKI_DIR)/scripts/pod-golly-wiki.service /etc/systemd/system/pod-golly-wiki.service
	sudo cp $(POD_GOLLY_WIKI_DIR)/scripts/backups/pod-golly-wiki-backups-wikidb.{service,timer} /etc/systemd/system/.
	sudo cp $(POD_GOLLY_WIKI_DIR)/scripts/backups/pod-golly-wiki-backups-wikifiles.{service,timer} /etc/systemd/system/.
	sudo cp $(POD_GOLLY_WIKI_DIR)/scripts/backups/pod-golly-wiki-backups-aws.{service,timer} /etc/systemd/system/.
	sudo cp $(POD_GOLLY_WIKI_DIR)/scripts/backups/pod-golly-wiki-backups-cleanolderthan.{service,timer} /etc/systemd/system/.
	sudo cp $(POD_GOLLY_WIKI_DIR)/scripts/backups/canary/pod-golly-wiki-canary.{service,timer} /etc/systemd/system/.
	sudo cp $(POD_GOLLY_WIKI_DIR)/scripts/certbot/pod-golly-wiki-certbot.{service,timer} /etc/systemd/system/.

	sudo cp $(POD_GOLLY_WIKI_DIR)/scripts/backups/11-pod-golly-wiki-rsyslog.conf /etc/rsyslog.d/.

	sudo chmod 664 /etc/systemd/system/pod-golly-wiki*
	sudo systemctl daemon-reload

	sudo systemctl restart rsyslog

	sudo systemctl enable pod-golly-wiki
	sudo systemctl enable pod-golly-wiki-backups-wikidb.timer
	sudo systemctl enable pod-golly-wiki-backups-wikifiles.timer
	sudo systemctl enable pod-golly-wiki-backups-aws.timer
	sudo systemctl enable pod-golly-wiki-backups-cleanolderthan.timer
	sudo systemctl enable pod-golly-wiki-canary.timer
	sudo systemctl enable pod-golly-wiki-certbot.timer

	sudo systemctl start pod-golly-wiki-backups-wikidb.timer
	sudo systemctl start pod-golly-wiki-backups-wikifiles.timer
	sudo systemctl start pod-golly-wiki-backups-aws.timer
	sudo systemctl start pod-golly-wiki-backups-cleanolderthan.timer
	sudo systemctl start pod-golly-wiki-canary.timer
	sudo systemctl start pod-golly-wiki-certbot.timer

	sudo chown syslog:syslog /var/log/pod-golly-wiki-backups-aws.service.log
	sudo chown syslog:syslog /var/log/pod-golly-wiki-backups-cleanolderthan.service.log
	sudo chown syslog:syslog /var/log/pod-golly-wiki-backups-wikidb.service.log
	sudo chown syslog:syslog /var/log/pod-golly-wiki-backups-wikifiles.service.log
	sudo chown syslog:syslog /var/log/pod-golly-wiki-canary.service.log

uninstall:
ifeq ($(shell which systemctl),)
	$(error Please run this make command on a system with systemctl installed)
endif
	-sudo systemctl disable pod-golly-wiki
	-sudo systemctl disable pod-golly-wiki-backups-wikidb.timer
	-sudo systemctl disable pod-golly-wiki-backups-wikifiles.timer
	-sudo systemctl disable pod-golly-wiki-backups-aws.timer
	-sudo systemctl disable pod-golly-wiki-backups-cleanolderthan.timer
	-sudo systemctl disable pod-golly-wiki-canary.timer
	-sudo systemctl disable pod-golly-wiki-certbot.timer

	# Leave the pod running!
	# -sudo systemctl stop pod-golly-wiki
	-sudo systemctl stop pod-golly-wiki-backups-wikidb.timer
	-sudo systemctl stop pod-golly-wiki-backups-wikifiles.timer
	-sudo systemctl stop pod-golly-wiki-backups-aws.timer
	-sudo systemctl stop pod-golly-wiki-backups-cleanolderthan.timer
	-sudo systemctl stop pod-golly-wiki-canary.timer
	-sudo systemctl stop pod-golly-wiki-certbot.timer

	-sudo rm -f /etc/systemd/system/pod-golly-wiki.service
	-sudo rm -f /etc/systemd/system/pod-golly-wiki-backups-wikidb.{service,timer}
	-sudo rm -f /etc/systemd/system/pod-golly-wiki-backups-wikifiles.{service,timer}
	-sudo rm -f /etc/systemd/system/pod-golly-wiki-backups-aws.{service,timer}
	-sudo rm -f /etc/systemd/system/pod-golly-wiki-backups-cleanolderthan.{service,timer}
	-sudo rm -f /etc/systemd/system/pod-golly-wiki-canary.{service,timer}
	-sudo rm -f /etc/systemd/system/pod-golly-wiki-certbot.{service,timer}
	sudo systemctl daemon-reload

	-sudo rm -f /etc/rsyslog.d/11-pod-golly-wiki-rsyslog.conf
	-sudo systemctl restart rsyslog

.PHONY: help
