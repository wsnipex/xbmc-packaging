#!/bin/bash

ADDONS="visualization.waveform screensavers.rsxs" \
CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH="master" \
DISTS="raring quantal precise" \
PPA_UPLOAD="True" \
PPA="wsnipex-nightly" \
./build-xbmc-addons.sh

