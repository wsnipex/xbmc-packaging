#!/bin/bash

#ADDONS=${ADDONS:-"pvr.demo pvr.iptvsimple pvr.njoy pvr.argustv pvr.hts pvr.dvbviewer pvr.vuplus pvr.mythtv pvr.mediaportal.tvserver pvr.nextpvr pvr.vdr.vnsi pvr.pctv pvr.filmon pvr.wmc pvr.dvblink pvr.stalker pvr.hdhomerun pvr.vbox"} \
#ADDONS_TO_BUILD=pvr \
CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH="Krypton" \
DISTS=${DISTS:-"artful zesty xenial trusty"} \
PPA_UPLOAD="True" \
PPA=${PPA:-"stable"} \
USE_MULTIARCH="True" \
./build-xbmc-addons.sh

