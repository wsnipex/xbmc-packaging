#!/bin/bash

#ADDONS=${ADDONS:-"pvr.demo pvr.iptvsimple pvr.njoy pvr.argustv pvr.hts pvr.dvbviewer pvr.vuplus pvr.mythtv pvr.mediaportal.tvserver pvr.nextpvr pvr.vdr.vnsi pvr.pctv pvr.filmon pvr.wmc pvr.dvblink pvr.stalker pvr.hdhomerun pvr.vbox"} \
ADDONS_TO_BUILD="pvr" \
CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH=${BRANCH:-"master"} \
DISTS=${DISTS:-"yakkety xenial wily vivid trusty"} \
PPA_UPLOAD="True" \
PPA=${PPA:-"nightly"} \
USE_MULTIARCH="True" \
./build-xbmc-addons.sh

