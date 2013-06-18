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

declare -A REPOS=(
    ["nightly"]='ftp://nightlyrepo.xbmc.org'
    ["unstable"]='ftp://unstablerepo.xbmc.org'
    ["stable"]='ftp://stablerepo.xbmc.org'
    ["wsnipex-nightly"]='ftp://nightlyrepows.xbmc.org'
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

    cd $WATCH || exit 1
    for DIST in $DISTS
    do
        checkPpaVersion
        echo ; echo "checking uploads in dist: $DIST"
        while read PACKAGE VERSION
        do
            echo -n "Package: $PACKAGE Version: $VERSION PPA_VERSION: ${PPAPACKAGES_i386["$PACKAGE"]:-"none"}"
            if [[ "${PPAPACKAGES_i386["$PACKAGE"]}" == "$VERSION" ]] && [[ "${PPAPACKAGES_amd64["$PACKAGE"]}" == "$VERSION" ]]
            then
                echo " Upload: verified"
                zipname=$(echo $PACKAGE | sed -e "s/xbmc-//" -e "s/-/\./g")".zip"
                uploadAddonXml
                [[ $UPLOAD_DONE == "True" ]] && removeFromList
            else
                echo " Upload: failed"
                checkSuperseded
                unset PACKAGE VERSION
            fi
        done < <(cat ${DIST}.addon.list)
    done
}

function uploadAddonXml {
    UPLOAD_DONE="False"
    if [ -r $DIST/$zipname ]
    then
        echo "Uploading $zipname to ${REPOS["$PPA"]}"
        #TODO: some FTP/HTTP foo
        [ $? -eq 0 ] && UPLOAD_DONE="True"
    else
        echo "Error $zipname not found"
    fi    
}

function removeFromList {
    sed -i "/^$PACKAGE.*/d" ${DIST}.addon.list
    #rm $DIST/$zipname
    unset zipname
}

function checkSuperseded {
    if [[ "${PPAPACKAGES_i386["$PACKAGE"]}" ]] && [[ "${PPAPACKAGES_i386["$PACKAGE"]}" == "${PPAPACKAGES_amd64["$PACKAGE"]}" ]]
    then
        dpkg --compare-versions ${PPAPACKAGES_i386["$PACKAGE"]} gt $VERSION
        if [ $? -eq 0 ]
        then
            echo "Version in PPA greater then ${VERSION}, removing superseded package from list"
            removeFromList
        fi
    fi
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
