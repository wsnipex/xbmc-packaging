#!/bin/bash

PPA=${PPA:-"stable"}
DISTS=${DISTS:-"raring quantal precise"}
ARCHS="i386 amd64"
WORK_DIR=${WORKSPACE:-$(pwd)}
WATCH=${WATCH:-"$WORK_DIR/watch"}

declare -A PPAS=(
    ["nightly"]='http://ppa.launchpad.net/team-xbmc/xbmc-nightly/ubuntu/dists/#dist#/main/binary-#arch#/Packages'
    ["unstable"]='http://ppa.launchpad.net/team-xbmc/unstable/ubuntu/dists/#dist#/main/binary-#arch#/Packages'
    ["stable"]='http://ppa.launchpad.net/team-xbmc/ppa/ubuntu/dists/#dist#/main/binary-#arch#/Packages'
    ["wsnipex-nightly"]='http://ppa.launchpad.net/wsnipex/xbmc-nightly/ubuntu/dists/#dist#/main/binary-#arch#/Packages'
)


declare -A PPAPACKAGES_i386
declare -A PPAPACKAGES_amd64

function checkPpaVersion {
    
    for arch in $ARCHS
    do
        PACKAGES=$(echo ${PPAS["$PPA"]} | sed -e "s/#dist#/$DIST/" -e "s/#arch#/$arch/")
        wget $PACKAGES -O Packages.${PPA}.${DIST}.${arch} >/dev/null 2>&1
        while read -r pack vers
        do 
            [[ $arch == "i386" ]] && PPAPACKAGES_i386[$pack]=$vers || PPAPACKAGES_amd64[$pack]=$vers
        done < <( grep -E "Package|Version" Packages.${PPA}.${DIST}.${arch} | sed -e 's/Package: //g' -e 's/Version: //g' | paste - - )
    done
}

function verifyBuild {
    local package
    local version

    cd $WATCH || exit 1
    for DIST in $DISTS
    do
        checkPpaVersion
        #[ -d $DIST ] && cd $DIST || continue
        echo ; echo "checking uploads in dist: $DIST"
        while read package version
        do
            #version=$(cat $package)
            echo -n "Package: $package Version: $version PPA_version: ${PPAPACKAGES_i386["$package"]:-"none"}"
            if [[ "${PPAPACKAGES_i386["$package"]}" == "$version" ]] && [[ "${PPAPACKAGES_amd64["$package"]}" == "$version" ]]
            then
                echo " Upload: success"
                uploadAddonXml
            else
                echo " Upload: failed"
            fi
        done < <(cat ${DIST}.addon.list)
        #cd ..
    done
}

function uploadAddonXml {
    echo "Uploading addon.zip to xbmc addon repo"
}

###
# Main
###
if ! [ -d $WATCH ]
then
    echo "Watch dir not found" 
    exit 0
fi

verifyBuild
