#!/bin/bash
#
# renew/run certbot on krash
set -eux

SERVICE="pod-golly-wiki"

function usage {
    set +x
    echo ""
    echo "renew_golly_wiki_certs.sh script:"
    echo ""
    echo "Renew all certs used in the golly wiki pod"
    echo ""
    echo "       ./renew_golly_wiki_certs.sh"
    echo ""
    exit 1;
}

if [ "$(id -u)" != "0" ]; then
    echo ""
    echo ""
    echo "This script should be run as root."
    echo ""
    echo ""
    exit 1;
fi

if [ "$#" == "0" ]; then

    # disable system service that will re-spawn docker pod
    echo "Disable and stop system service ${SERVICE}"
    sudo systemctl disable ${SERVICE}
    sudo systemctl stop ${SERVICE}
    
    echo "Stop pod"
    docker-compose -f /docker-compose.yml down
    
    echo "Run certbot renew"
    DOMS="wiki.golly.life"

    # subdomains
    for SUB in $SUBS; do
        for DOM in $DOMS; do
            certbot certonly \
                --standalone \
                --non-interactive \
                --agree-tos \
                --email ch4zm.of.hellmouth@gmail.com \
                -d ${SUB}.${DOM}
        done
    done
    
    echo "Start pod"
    docker-compose -f /docker-compose.yml up -d
    
    echo "Enable and start system service ${SERVICE}"
    sudo systemctl enable ${SERVICE}
    sudo systemctl start ${SERVICE}

    echo "Done"

else
    usage
fi