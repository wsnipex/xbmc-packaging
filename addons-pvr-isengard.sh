#!/bin/bash

ADDONS=${ADDONS:-"pvr.demo pvr.iptvsimple pvr.njoy pvr.argustv pvr.hts pvr.dvbviewer pvr.vuplus pvr.mythtv pvr.mediaportal.tvserver pvr.nextpvr pvr.vdr.vnsi pvr.pctv pvr.filmon pvr.wmc pvr.dvblink pvr.stalker pvr.vbox"} \
CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH="Isengard" \
DISTS="vivid utopic trusty" \
PPA_UPLOAD="True" \
PPA="wsnipex-xbmc-addons-unstable" \
./build-xbmc-addons.sh

