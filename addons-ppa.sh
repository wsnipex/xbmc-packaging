#!/bin/bash

#ADDONS=${ADDONS:-"visualization.waveform visualization.goom visualization.spectrum screensavers.rsxs"} \
CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH=${BRANCH:-"master"} \
DISTS=${DIST:-"saucy raring quantal precise"} \
PPA_UPLOAD="True" \
PPA=${PPA:-"wsnipex-xbmc-addons-test"} \
URGENCY=${URGENCY:-"low"} \
./build-xbmc-addons.sh

