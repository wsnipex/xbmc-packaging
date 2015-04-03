#!/bin/bash

ADDONS=${ADDONS:-"pvr.demo pvr.iptvsimple pvr.njoy pvr.argustv pvr.hts pvr.dvbviewer pvr.vuplus pvr.mythtv pvr.mediaportal.tvserver pvr.nextpvr pvr.vdr.vnsi pvr.pctv pvr.filmon pvr.wmc pvr.dvblink"} \
CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH="master" \
DISTS="vivid utopic trusty precise" \
PPA_UPLOAD="True" \
PPA="wsnipex-nightly" \
./build-xbmc-addons.sh

