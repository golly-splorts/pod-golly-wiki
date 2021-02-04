#!/bin/bash
# 
# clone or download each extension
# and build o

mkdir -p extensions
(
cd extensions

##############################

Extension="ParserFunctions"
if [ ! -d ${Extension} ]
then
    git clone https://github.com/wikimedia/mediawiki-extensions-ParserFunctions.git ${Extension}
    (
    cd ${Extension}
    git checkout --track remotes/origin/REL1_34
    )
else
    echo "Skipping ${Extension}"
fi

Extension="Loops"
if [ ! -d ${Extension} ]
then
    git clone https://github.com/wikimedia/mediawiki-extensions-Loops.git ${Extension}
    (
    cd ${Extension}
    git checkout --track remotes/origin/REL1_34
    )
else
    echo "Skipping ${Extension}"
fi

Extension="Variables"
if [ ! -d ${Extension} ]
then
    git clone https://github.com/wikimedia/mediawiki-extensions-Variables.git ${Extension}
    (
    cd ${Extension}
    git checkout --track remotes/origin/REL1_34
    )
else
    echo "Skipping ${Extension}"
fi

Extension="Scribunto"
if [ ! -d ${Extension} ]
then
    git clone https://github.com/wikimedia/mediawiki-extensions-Scribunto.git ${Extension}
    (
    cd ${Extension}
    git checkout --track remotes/origin/REL1_34
    )
else
    echo "Skipping ${Extension}"
fi

)
