#!/bin/bash
#
# Clone or download each extension for MW 1.39 (REL1_39 branches)
set -eux

MW_DIR="${POD_GOLLY_WIKI_DIR}/g-mediawiki-new"
MW_CONF_DIR="${MW_DIR}/mediawiki"
EXT_DIR="${MW_CONF_DIR}/extensions"

mkdir -p ${EXT_DIR}

(
cd ${EXT_DIR}

##############################

Extension="SyntaxHighlight_GeSHi"
if [ ! -d ${Extension} ]
then
    git clone https://github.com/wikimedia/mediawiki-extensions-SyntaxHighlight_GeSHi.git SyntaxHighlight_GeSHi
    (
    cd ${Extension}
    git checkout --track remotes/origin/REL1_39
    )
else
    echo "Skipping ${Extension}"
fi

##############################

Extension="ParserFunctions"
if [ ! -d ${Extension} ]
then
    git clone https://github.com/wikimedia/mediawiki-extensions-ParserFunctions.git ${Extension}
    (
    cd ${Extension}
    git checkout --track remotes/origin/REL1_39
    )
else
    echo "Skipping ${Extension}"
fi

##############################

Extension="Math"
if [ ! -d ${Extension} ]
then
    git clone https://github.com/wikimedia/mediawiki-extensions-Math.git ${Extension}
    (
    cd ${Extension}
    git checkout REL1_39
    )
else
    echo "Skipping ${Extension}"
fi

##############################

Extension="Fail2banlog"
if [ ! -d ${Extension} ]
then
    git clone https://github.com/charlesreid1-docker/mw-fail2ban.git ${Extension}
    (
    cd ${Extension}
    git checkout master
    )
else
    echo "Skipping ${Extension}"
fi

##############################

# EmbedVideo skipped for MW 1.39 — add back later if needed

# fin
)
