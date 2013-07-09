#!/bin/bash

ADDONS=${ADDONS:-"visualization.waveform visualization.goom visualization.spectrum screensavers.rsxs"} \
CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH="master" \
DISTS="raring quantal precise" \
PPA_UPLOAD="True" \
PPA="wsnipex-nightly" \
./build-xbmc-addons.sh

