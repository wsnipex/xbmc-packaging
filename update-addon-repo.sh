#!/bin/bash

PPA=${PPA:-"stable"}
DISTS=${DISTS:-"raring quantal precise"}
ARCHS=${ARCHS:-"i386 amd64"}

declare -A PPAS=(
    ["nightly"]='http://ppa.launchpad.net/team-xbmc/xbmc-nightly/ubuntu/dists/#dist#/main/binary-#arch#/Packages'
    ["unstable"]='http://ppa.launchpad.net/team-xbmc/unstable/ubuntu/dists/#dist#/main/binary-#arch#/Packages'
    ["stable"]='http://ppa.launchpad.net/team-xbmc/ppa/ubuntu/dists/#dist#/main/binary-#arch#/Packages'
    ["wsnipex-nightly"]='http://ppa.launchpad.net/wsnipex/xbmc-nightly/ubuntu/dists/#dist#/main/binary-#arch#/Packages'
)

function checkVersion {
    for DIST in $DISTS
    do
        for ARCH in $ARCHS
        do
            PACKAGES=$(echo ${PPAS["$PPA"]} | sed -e "s/#dist#/$DIST/" -e "s/#arch#/$ARCH/")
            wget $PACKAGES -O Packages.${PPA}.${DIST}.${ARCH}
            grep -E "Package|Version" Packages.${PPA}.${DIST}.${ARCH} | sed -e 's/Package: //g' -e 's/Version: //g' | paste - - | while read line
            do 
                package=$(echo $line | awk '{print $1}')
                version=$(echo $line | awk '{print $2}')
                echo "$package => $version"
            done
        done
    done
}

checkVersion

