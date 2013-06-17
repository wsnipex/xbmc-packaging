#!/bin/bash

PPA=${PPA:-"stable"}
DISTS=${DISTS:-"raring quantal precise"}
ARCHS=${ARCHS:-"i386 amd64"}
WORK_DIR=${WORKSPACE:-$(pwd)}
WATCH=${WATCH:-"$WORK_DIR/watch"}

declare -A PPAS=(
    ["nightly"]='http://ppa.launchpad.net/team-xbmc/xbmc-nightly/ubuntu/dists/#dist#/main/binary-#arch#/Packages'
    ["unstable"]='http://ppa.launchpad.net/team-xbmc/unstable/ubuntu/dists/#dist#/main/binary-#arch#/Packages'
    ["stable"]='http://ppa.launchpad.net/team-xbmc/ppa/ubuntu/dists/#dist#/main/binary-#arch#/Packages'
    ["wsnipex-nightly"]='http://ppa.launchpad.net/wsnipex/xbmc-nightly/ubuntu/dists/#dist#/main/binary-#arch#/Packages'
)

function checkPpaVersion {
    declare -A PPA_PACKAGES
    #for DIST in $DISTS
    #do
        #declare -A PPA_PACKAGES_${DIST}
        for ARCH in $ARCHS
        do
            PACKAGES=$(echo ${PPAS["$PPA"]} | sed -e "s/#dist#/$DIST/" -e "s/#arch#/$ARCH/")
            wget $PACKAGES -O Packages.${PPA}.${DIST}.${ARCH}
            grep -E "Package|Version" Packages.${PPA}.${DIST}.${ARCH} | sed -e 's/Package: //g' -e 's/Version: //g' | paste - - | while read line
            do 
                package=$(echo $line | awk '{print $1}')
                version=$(echo $line | awk '{print $2}')
                ${PPA_PACKAGES["$package"]}=$version
            done
        done
    #done
}

function verifyBuild {
    cd $WATCH || exit 1
    for DIST in $(ls)
    do
        checkPpaVersion
        cd $DIST || exit 2
        for package in $(ls)
        do
            version=$(cat $package)
        done
    done
}

