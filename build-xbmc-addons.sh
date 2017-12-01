#!/bin/bash
#
# Copyright (C) 2013 wsnipex, Team XBMC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published 
# by the Free Software Foundation; either version 2 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#

BRANCH=${BRANCH:-"master"}
TAG=${TAG:-"1"}
WORK_DIR=${WORKSPACE:-$(pwd)}
[[ $(which lsb_release) ]] && DISTS=${DISTS:-$(lsb_release -cs)} || DISTS=${DISTS:-"stable"}
ARCHS=${ARCHS:-$(dpkg --print-architecture)}
BUILDER=${BUILDER:-"debuild"}
DEBUILD_OPTS=${DEBUILD_OPTS:-""}
PDEBUILD_OPTS=${PDEBUILD_OPTS:-""}
PBUILDER_BASE=${PBUILDER_BASE:-"/var/cache/pbuilder"}
DPUT_TARGET=${DPUT_TARGET:-"local"}
PPA_UPLOAD=${PPA_UPLOAD:-"False"}
PPA=${PPA:-"wsnipex-xbmc-addons-unstable"}
URGENCY=${URGENCY:-"low"}
REBUILD=${REBUILD:-"False"}
CREATE_ZIP=${CREATE_ZIP:-"False"}
CREATE_TGZ=${CREATE_TGZ:-"False"}
ZIP_OUTPUT_DIR=${ZIP_OUTPUT_DIR:-$WORK_DIR}
CLEANUP_AFTER=${CLEANUP_AFTER:-"False"}
GITHUB_USER=${GITHUB_USER:-"xbmc"}
GITHUB_USER_PVR=${GITHUB_USER_PVR:-"kodi-pvr"}
GITHUB_USER_VIZ=${GITHUB_USER_VIZ:-"notspiff"}
GITHUB_USER_GAME=${GITHUB_USER_GAME:-"kodi-game"}
USE_META_REPO=${USE_META_REPO:-"True"}
META_REPO=${META_REPO:-"https://github.com/xbmc/repo-binary-addons"}
ADDON_FILTER=${ADDON_FILTER:-"visualization.milkdrop gameclient.snes9x"}
ADDONS_TO_BUILD=${ADDONS_TO_BUILD:-"all"}
USE_MULTIARCH=${USE_MULTIARCH:-"False"}

# Define a default list to cope with addons not yet in the meta repo.
# The ones existing in the meta repo will overwrite the defaults
AUDIO_ADDONS="
    ["audioencoder.vorbis"]="https://github.com/$GITHUB_USER/audioencoder.vorbis"
    ["audioencoder.flac"]="https://github.com/$GITHUB_USER/audioencoder.flac"
    ["audioencoder.lame"]="https://github.com/$GITHUB_USER/audioencoder.lame"
    ["audioencoder.wav"]="https://github.com/$GITHUB_USER/audioencoder.wav"
    ["audiodecoder.modplug"]="https://github.com/notspiff/audiodecoder.modplug"
    ["audiodecoder.nosefart"]="https://github.com/notspiff/audiodecoder.nosefart"
    ["audiodecoder.sidplay"]="https://github.com/notspiff/audiodecoder.sidplay"
    ["audiodecoder.snesapu"]="https://github.com/notspiff/audiodecoder.snesapu"
    ["audiodecoder.stsound"]="https://github.com/notspiff/audiodecoder.stsound"
    ["audiodecoder.timidity"]="https://github.com/notspiff/audiodecoder.timidity"
    ["audiodecoder.vgmstream"]="https://github.com/notspiff/audiodecoder.vgmstream"
"

VIS_ADDONS="
    ["visualization.waveform"]="https://github.com/$GITHUB_USER_VIZ/visualization.waveform"
    ["visualization.goom"]="https://github.com/$GITHUB_USER_VIZ/visualization.goom"
    ["visualization.spectrum"]="https://github.com/$GITHUB_USER_VIZ/visualization.spectrum"
    ["visualization.projectm"]="https://github.com/$GITHUB_USER_VIZ/visualization.projectm"
    ["visualization.fishbmc"]="https://github.com/$GITHUB_USER_VIZ/visualization.fishbmc"
    ["visualization.shadertoy"]="https://github.com/$GITHUB_USER_VIZ/visualization.shadertoy"
    #["gameclient.snes9x"]="https://github.com/$GITHUB_USER/gameclient.snes9x"
"

SCR_ADDONS="
    ["screensavers.rsxs"]="https://github.com/$GITHUB_USER_VIZ/screensavers.rsxs"
"

PVR_ADDONS="
    ["pvr.demo"]="https://github.com/$GITHUB_USER_PVR/pvr.demo"
    ["pvr.iptvsimple"]="https://github.com/$GITHUB_USER_PVR/pvr.iptvsimple"
    ["pvr.njoy"]="https://github.com/$GITHUB_USER_PVR/pvr.njoy"
    ["pvr.argustv"]="https://github.com/$GITHUB_USER_PVR/pvr.argustv"
    ["pvr.hts"]="https://github.com/$GITHUB_USER_PVR/pvr.hts"
    ["pvr.dvbviewer"]="https://github.com/$GITHUB_USER_PVR/pvr.dvbviewer"
    ["pvr.vuplus"]="https://github.com/$GITHUB_USER_PVR/pvr.vuplus"
    ["pvr.mythtv"]="https://github.com/$GITHUB_USER_PVR/pvr.mythtv"
    ["pvr.mediaportal.tvserver"]="https://github.com/$GITHUB_USER_PVR/pvr.mediaportal.tvserver"
    ["pvr.nextpvr"]="https://github.com/$GITHUB_USER_PVR/pvr.nextpvr"
    ["pvr.vdr.vnsi"]="https://github.com/$GITHUB_USER_PVR/pvr.vdr.vnsi"
    ["pvr.pctv"]="https://github.com/$GITHUB_USER_PVR/pvr.pctv"
    ["pvr.filmon"]="https://github.com/$GITHUB_USER_PVR/pvr.filmon"
    ["pvr.wmc"]="https://github.com/$GITHUB_USER_PVR/pvr.wmc"
    ["pvr.dvblink"]="https://github.com/$GITHUB_USER_PVR/pvr.dvblink"
    ["pvr.vbox"]="https://github.com/$GITHUB_USER_PVR/pvr.vbox"
    ["pvr.stalker"]="https://github.com/$GITHUB_USER_PVR/pvr.stalker"
    ["pvr.hdhomerun"]="https://github.com/$GITHUB_USER_PVR/pvr.hdhomerun"
    ["pvr.zattoo"]="https://github.com/$GITHUB_USER_PVR/pvr.zattoo"
"

GAME_ADDONS="
    ["peripheral.joystick"]="https://github.com/$GITHUB_USER_GAME/peripheral.joystick"
"

eval "declare -A ALL_ADDONS=(
    $PVR_ADDONS $AUDIO_ADDONS $SCR_ADDONS $VIS_ADDONS $GAME_ADDONS ["kodi-platform"]="https://github.com/$GITHUB_USER/kodi-platform"
)"

declare -A PPAS=(
    ["nightly"]='ppa:team-xbmc/xbmc-nightly'
    ["unstable"]='ppa:team-xbmc/unstable'
    ["stable"]='ppa:team-xbmc/ppa'
    ["wsnipex-nightly"]='ppa:wsnipex/kodi-git'
    ["wsnipex-xbmc-addons-unstable"]='ppa:wsnipex/xbmc-addons-unstable'
    ["wsnipex-fernet-master"]='ppa:wsnipex/xbmc-fernetmenta-master'
)

declare -A ADDON_REVS

#------------------------------------------------------------------------------------------------------------#

function usage {
    echo "$0: this script builds xbmc addon debian packages."
    echo "The build is controlled by ENV variables, which van be overridden as appropriate:"
    echo "BUILDER is either debuild(default) or pdebuild(needs a proper pbuilder setup)"
    echo "If CREATE_ZIP is True, addons are compiled directly and packaged as zip files"
    checkEnv
    exit 2
}

function checkEnv {
    echo "#------ build environment ------#"
    echo "Building following addons: $ADDONS"
    echo "Using Meta Repo: $META_REPO"
    echo "WORK_DIR: $WORK_DIR"
    [[ -n $TAG ]] && echo "TAG: $TAG"
    echo "DISTS: $DISTS"
    echo "ARCHS: $ARCHS"
    echo "CONFIGURATION: $Configuration"
    [[ "$CREATE_ZIP" == "True" ]] && echo "Creating ZIPs only" && return
    [[ "$CREATE_TGZ" == "True" ]] && echo "Creating tarballs only" && return
    echo "BUILDER: $BUILDER"
    
    if ! [[ $(which $BUILDER) ]]
    then
        echo "Error: can't find ${BUILDER}, consider using full path to [debuild|pdebuild]"
        exit 1
    fi

    if [[ "$BUILDER" =~ "pdebuild" ]]
    then
        if ! [[ -d $PBUILDER_BASE ]] ; then echo "Error: $PBUILDER_BASE does not exist"; exit 1; fi
        echo "PBUILDER_BASE: $PBUILDER_BASE"
        echo "PDEBUILD_OPTS: $PDEBUILD_OPTS"
    else
        
        if [[ "$PPA_UPLOAD" == "True" ]]
        then
            echo "PPA_UPLOAD: $PPA_UPLOAD"
            echo "PPA: $PPA"
            rm -rf $WORK_DIR/watch/$PPA >/dev/null 2>&1
            echo "URGENCY: $URGENCY"
            echo "REBUILD: $REBUILD"
            [[ "$DPUT_TARGET" == "local" ]] && DPUT_TARGET=${PPAS["$PPA"]}
            [[ -z $DEBUILD_OPTS ]] && DEBUILD_OPTS="-S"
            [[ -z $DPUT_TARGET ]] && echo "ERROR: empty PPA, refusing build" && exit 4
        fi
    fi
    echo "DEBUILD_OPTS: $DEBUILD_OPTS"
    echo "DPUT_TARGET: $DPUT_TARGET"
    echo "#-------------------------------#"

}

function getAllAddons {
    local name
    local url
    local rev

    rm -r ${BRANCH}.tar.gz 
    [ -d $(basename $META_REPO)* ] && rm -rf $(basename $META_REPO)*

    wget $META_REPO/archive/${BRANCH}.tar.gz && tar xzvf ${BRANCH}.tar.gz

    TXTFILES=$(find $(basename $META_REPO)* -name "*.txt" -not -name "platforms.txt")
    for FILE in $TXTFILES
    do
        PLAT=$(dirname $FILE)/platforms.txt
        read -r name url rev < $FILE
        echo "name: $name - url: $url - rev: $rev - platform: $PLAT"
        [ "$GITHUB_USER" == "xbmc" ] && { ! grep -Ewq '!linux' $PLAT || grep -Ewq "linux|all" $PLAT ; } && ALL_ADDONS[$name]=$url && ADDON_REVS[$name]=$rev || echo "skipping $name"
    done


    ADDONS=${ADDONS:-${!ALL_ADDONS[@]}}
}

function prepareBuild {
    for addon in ${ADDONS[*]}
    do
        [[ "$ADDON_FILTER" =~ "$addon" ]] && echo "WARNING: found $addon in ADDON_FILTER, skipping build" && continue
        [[ ! "$addon" =~ "$ADDONS_TO_BUILD" ]] && [[ "$ADDONS_TO_BUILD" != "all" ]] &&  continue
        cd $WORK_DIR || exit 1
        echo "\n#-------------------------------------------------------#"
        echo "INFO: building $addon"
        url=${ALL_ADDONS["$addon"]}
        [ -n "${ADDON_REVS["$addon"]}" ] && rev=${ADDON_REVS["$addon"]} || rev=${BRANCH}
        [ -d ${addon}.tmp ] && rm -rf ${addon}.tmp
        mkdir ${addon}.tmp && cd ${addon}.tmp || exit 1
        wget -T 10 -t 5 $url/archive/${rev}.tar.gz
        ! [ -r ${rev}.tar.gz ] && echo "ERROR: download of ${rev}.tar.gz failed" && continue
        tar xzf ${rev}.tar.gz
        if [[ "$CREATE_ZIP" == "True" ]]
        then
            createZipPackages
        elif [[ "$CREATE_TGZ" == "True" ]]
        then
            createTgzPackages
        else
            getPackageDetails
            if [[ "$REBUILD" == "True" ]]
            then
                orig=$(echo ${PPAS["$PPA"]} | sed -e 's%/%/+archive/%' -e 's%ppa:%https://launchpad.net/~%')
                wget -T 10 -t 5 ${orig}/+files/${PACKAGENAME}_${PACKAGEVERSION}.orig.tar.gz
            else
                mv ${BRANCH}.tar.gz ${PACKAGENAME}_${PACKAGEVERSION}.orig.tar.gz || mv ${rev}.tar.gz ${PACKAGENAME}_${PACKAGEVERSION}.orig.tar.gz
            fi
            cd ${addon}-${BRANCH} || cd ${addon}-${ADDON_REVS[$addon]} || cd ${addon}-*
            sed -e "s/#PACKAGEVERSION#/${PACKAGEVERSION}/g" -e "s/#TAGREV#/${TAG}/g" debian/changelog.in > debian/changelog.tmp
            [[ "$USE_MULTIARCH" == "True" ]] && [ "${addon}" != "kodi-platform" ] && patchMultiArch
            buildDebianPackages
            [[ "$PPA_UPLOAD" == "True" ]] && cd .. && uploadPkg
        fi
    done
}

function patchMultiArch {
    install_file="$(ls debian/*.install 2>/dev/null | head -1)" 
    [ -f $install_file ] && cat > $install_file <<< 'usr/lib
usr/share'
}

function createZipPackages {
    cd ${addon}-${BRANCH}
    cmake -DCMAKE_BUILD_TYPE=Release -DPACKAGE_ZIP=ON -DBUILD_SHARED_LIBS=1 && make package
    mv ${addon}*.zip $ZIP_OUTPUT_DIR
}

function createTgzPackages {
    cd ${addon}-${BRANCH}
    cmake -DCMAKE_BUILD_TYPE=Release -DPACKAGE_TGZ=ON -DBUILD_SHARED_LIBS=1 && make package
    mv ${addon}*.tar.gz $ZIP_OUTPUT_DIR
}

function getPackageDetails {
    if [ "${addon}" == "kodi-platform" ]
    then
        PACKAGEVERSION="$(head -1 ${addon}-${BRANCH}/debian/changelog.in | sed 's/^.* (\(.*\)~#DIST#) .*$/\1/')"
        PACKAGENAME="kodiplatform"
        return
    fi

    if [ -f ${addon}-${BRANCH} ]
    then
        PACKAGENAME=$(awk '{if(NR==1){ print $1}}' ${addon}-${BRANCH}/debian/changelog.in) 
        addonxml=$(find ${addon}-${BRANCH} -name addon.xml.in)
    else
        PACKAGENAME=$(awk '{if(NR==1){ print $1}}' ${addon}-*/debian/changelog.in)
        addonxml=$(find ${addon}-* -name addon.xml.in)
    fi
    [ -z ${addonxml} ] && addonxml=$(find ${addon}-* -name addon.xml)

    if [ -f ${addonxml} ]
    then
        PACKAGEVERSION=$(awk -F'=' '!/<?xml/ && /version/ && !/>/ {gsub("\"",""); print $2}' ${addonxml})
    elif [ -n "${addonxml}" ]
    then
        # some addons don't follow the file system structure 100%, try our best to find an addon.xml
        PACKAGEVERSION=$(awk -F'=' '!/<?xml/ && /version/ && !/>/ {gsub("\"",""); VER=$2} END {print VER}' ${addon}-${BRANCH}/${addon:0:5}*/addon.xml)
    else
        # try CmakeLists as a final effort
        PACKAGEVERSION=$(grep -E "PROPERTIES.*VERSION" ${addon}-${BRANCH}/CMakeLists.txt | grep -oE "[0-9\.]+")
    fi

    [[ -z $PACKAGEVERSION ]] && echo "ERROR: could not determine version of $addon" && break
}

function buildDebianPackages {
    for dist in $DISTS
    do
        sed "s/#DIST#/${dist}/g" debian/changelog.tmp > debian/changelog
        [[ -r ${addon}/changelog.txt ]] && dch -a $(cat ${addon}/changelog.txt) || dch -a "no upstream changelog available"
        dch --release -u $URGENCY ""
        for arch in $ARCHS
        do
            echo "building: DIST=$dist ARCH=$arch"
            if [[ "$BUILDER" =~ "pdebuild" ]]
            then
                DIST=$dist ARCH=$arch $BUILDER $PDEBUILD_OPTS
                [ $? -eq 0 ] && uploadPkg || exit 1
            else
                $BUILDER $DEBUILD_OPTS
                [ $? -eq 0 ] && [[ "$PPA_UPLOAD" == "True" ]] && createPpaCheckFiles
            fi
        done
    done
}

function createPpaCheckFiles {
    local builtpackage
    local zipname
    local watchdir="$WORK_DIR/watch/${PPA}/${dist}"
    local watchfile="${watchdir}.addon.list"
    mkdir -p $watchdir
    grep Package debian/control | sed 's/Package: //g' | while read builtpackage
    do
        echo "${builtpackage} ${PACKAGEVERSION}-${TAG}~${dist}" >> $watchfile
        zipname=$(echo ${builtpackage} | sed -e "s/xbmc-//" -e "s/-/\./g")
        [ -d ${zipname} ] && zip ${zipname}.zip ${zipname}/* && mv ${zipname}.zip $watchdir
    done

}

function uploadPkg {
    if [[ "$BUILDER" =~ "pdebuild" ]]
    then
        local changes="${PACKAGENAME}_${PACKAGEVERSION}-${TAG}~${dist}_${arch}.changes"
        PKG="${PBUILDER_BASE}/${dist}-${arch}/result/${changes}"
        echo "INFO: signing package"
        debsign $PKG
        echo "INFO: uploading $PKG to $DPUT_TARGET"
        dput $DPUT_TARGET $PKG
        UPLOAD_DONE=$?
    elif [[ "$PPA_UPLOAD" == "True" ]]
    then
        local changes="${PACKAGENAME}_${PACKAGEVERSION}-${TAG}*.changes"
        echo "INFO: uploading $changes to $DPUT_TARGET"
        dput $DPUT_TARGET $changes
        UPLOAD_DONE=$?
    else
        echo "INFO: Build produced following packages:"
        ls -l *.deb
    fi
}

function cleanup {
    cd $WORK_DIR || exit 1
    for addon in ${ADDONS[*]}
    do
        rm -rf ${addon}.tmp
    done
}

###
# main
###
if [[ $1 = "-h" ]] || [[ $1 = "--help" ]]
then
    usage
    exit
fi

checkEnv
[ "$USE_META_REPO" == "True" ] && getAllAddons
prepareBuild
[[ "$CLEANUP_AFTER" == "True" ]] && [[ $UPLOAD_DONE -eq 0 ]] && cleanup

