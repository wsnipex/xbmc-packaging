#!/bin/bash

#ADDONS=${ADDONS:-"visualization.waveform visualization.goom visualization.spectrum screensavers.rsxs"} \
CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH="master" \
DISTS="saucy raring quantal precise" \
PPA_UPLOAD="True" \
PPA="wsnipex-xbmc-addons-unstable" \
./build-xbmc-addons.sh

