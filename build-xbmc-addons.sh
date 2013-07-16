#!/bin/bash

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
PPA=${PPA:-"stable"}
URGENCY=${URGENCY:-"low"}
CREATE_ZIP=${CREATE_ZIP:-"False"}
ZIP_OUTPUT_DIR=${ZIP_OUTPUT_DIR:-$WORK_DIR}
CLEANUP_AFTER=${CLEANUP_AFTER:-"False"}
META_REPO=${META_REPO:-"https://github.com/cptspiff/xbmc-visualizations"}
ADDON_FILTER=${ADDON_FILTER:-"visualization.milkdrop"}

# Define a default list to cope with addons not yet in the meta repo.
# The ones existing in the meta repo will overwrite the defaults
declare -A ALL_ADDONS=(
    ["visualization.waveform"]="https://github.com/cptspiff/visualization.waveform"
    ["visualization.goom"]="https://github.com/cptspiff/visualization.goom"
    ["visualization.spectrum"]="https://github.com/cptspiff/visualization.spectrum"
    ["gameclient.snes9x"]="https://github.com/cptspiff/gameclient.snes9x/archive"
    ["screensavers.rsxs"]="https://github.com/cptspiff/screensavers.rsxs/archive"
    ["xbmc-platform"]="https://github.com/cptspiff/xbmc-platform"
    ["pvr.demo"]="https://github.com/cptspiff/pvr.demo"
    ["pvr.iptvsimple"]="https://github.com/cptspiff/pvr.iptvsimple"
    ["pvr.njoy"]="https://github.com/cptspiff/pvr.njoy"
    ["pvr.argustv"]="https://github.com/cptspiff/pvr.argustv"
    ["pvr.hts"]="https://github.com/cptspiff/pvr.hts"
    ["pvr.dvbviewer"]="https://github.com/cptspiff/pvr.dvbviewer"
    ["pvr.vuplus"]="https://github.com/cptspiff/pvr.vuplus"
)



ADDONS=${ADDONS:-${!ALL_ADDONS[@]}}

declare -A PPAS=(
    ["nightly"]='ppa:team-xbmc/xbmc-nightly'
    ["unstable"]='ppa:team-xbmc/unstable'
    ["stable"]='ppa:team-xbmc/ppa'
    ["wsnipex-nightly"]='ppa:wsnipex/xbmc-nightly'
)


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
            [[ "$DPUT_TARGET" == "local" ]] && DPUT_TARGET=${PPAS["$PPA"]}
            [[ -z $DEBUILD_OPTS ]] && DEBUILD_OPTS="-S"
        fi
    fi
    echo "DEBUILD_OPTS: $DEBUILD_OPTS"
    echo "DPUT_TARGET: $DPUT_TARGET"
    echo "#-------------------------------#"
}

function getAllAddons {
    local name
    local url
    
    wget -T 10 $META_REPO/raw/master/.gitmodules -O addon-list
    while read -r name url 
    do
       ALL_ADDONS[$name]=$url 
    done < <(cat addon-list  | paste - - - | awk '{gsub("git:", "https:"); print $5, $8}')
}

function prepareBuild {
    for addon in ${ADDONS[*]}
    do
        [[ "$addon" =~ "$ADDON_FILTER" ]] && echo "WARNING: found $addon in ADDON_FILTER, skipping build" && continue
        cd $WORK_DIR || exit 1
        echo "\n#-------------------------------------------------------#"
        echo "INFO: building $addon"
        url=${ALL_ADDONS["$addon"]}
        [ -d ${addon}.tmp ] && rm -rf ${addon}.tmp
        mkdir ${addon}.tmp && cd ${addon}.tmp || exit 1
        wget $url/archive/${BRANCH}.tar.gz
        tar xzf ${BRANCH}.tar.gz
        if [[ "$CREATE_ZIP" == "True" ]]
        then
            createZipPackages
        else
            getPackageDetails
            mv ${BRANCH}.tar.gz ${PACKAGENAME}_${PACKAGEVERSION}.orig.tar.gz
            cd ${addon}-${BRANCH} 
            sed -e "s/#PACKAGEVERSION#/${PACKAGEVERSION}/g" -e "s/#TAGREV#/${TAG}/g" debian/changelog.in > debian/changelog.tmp
            buildDebianPackages
            [[ "$PPA_UPLOAD" == "True" ]] && cd .. && uploadPkg
        fi
    done
}

function createZipPackages {
    cd ${addon}-${BRANCH}
    cmake -DCMAKE_BUILD_TYPE=Release -DPACKAGE_ZIP=ON -DBUILD_SHARED_LIBS=1 && make package
    mv ${addon}*.zip $ZIP_OUTPUT_DIR
}

function getPackageDetails {
    PACKAGENAME=$(awk '{if(NR==1){ print $1}}' ${addon}-${BRANCH}/debian/changelog.in)
    addonxml=$(find ${addon}-${BRANCH} -name addon.xml)
    if [ -f ${addon}-${BRANCH}/${addon}/addon.xml ]
    then
        PACKAGEVERSION=$(awk -F'=' '!/<?xml/ && /version/ && !/>/ {gsub("\"",""); print $2}' ${addon}-${BRANCH}/${addon}/addon.xml)
    elif [ -n "$addonxml" ]
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
getAllAddons
prepareBuild
[[ "$CLEANUP_AFTER" == "True" ]] && [[ $UPLOAD_DONE -eq 0 ]] && cleanup

