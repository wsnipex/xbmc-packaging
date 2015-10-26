#!/bin/bash

ADDONS=${ADDONS:-"pvr.demo pvr.iptvsimple pvr.njoy pvr.argustv pvr.hts pvr.dvbviewer pvr.vuplus pvr.mythtv pvr.mediaportal.tvserver pvr.nextpvr pvr.vdr.vnsi pvr.pctv pvr.filmon pvr.wmc pvr.dvblink pvr.stalker pvr.vbox"} \
CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH="Isengard" \
DISTS="wily vivid trusty" \
PPA_UPLOAD="True" \
PPA="unstable" \
./build-xbmc-addons.sh

