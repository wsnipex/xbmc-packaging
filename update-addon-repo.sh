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

declare -A PPAPACKAGES

function checkPpaVersion {
    
    for ARCH in $ARCHS
    do
        PACKAGES=$(echo ${PPAS["$PPA"]} | sed -e "s/#dist#/$DIST/" -e "s/#arch#/$ARCH/")
        wget $PACKAGES -O Packages.${PPA}.${DIST}.${ARCH} >/dev/null 2>&1
        while read -r pack vers
        do 
            PPAPACKAGES[$pack]=$vers
        done < <( grep -E "Package|Version" Packages.${PPA}.${DIST}.${ARCH} | sed -e 's/Package: //g' -e 's/Version: //g' | paste - - )
        #echo "PACKAGES: ${!PPAPACKAGES[*]}"
        done
}

function verifyBuild {
    local package
    local version

    cd $WATCH || exit 1
    for DIST in $DISTS
    do
        checkPpaVersion
        [ -d $DIST ] || continue
        for package in $(ls $DIST/)
        do
            version=$(cat $DIST/$package)
            echo "Package: $package - Looking for $version - Version in PPA: ${PPAPACKAGES["$package"]}"
            if [[ "${PPAPACKAGES["$package"]}" == "$version" ]]
            then
                echo "Package $DIST/$package found on PPA - uploading addon.xml"
            fi
        done
    done
}

verifyBuild
