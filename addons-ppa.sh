#!/bin/bash

#ADDONS=${ADDONS:-"visualization.waveform visualization.goom visualization.spectrum screensavers.rsxs"} \
CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH=${BRANCH:-"master"} \
DISTS=${DISTS:-"zesty yakkety xenial vivid trusty"} \
PPA_UPLOAD="True" \
PPA=${PPA:-"nightly"} \
USE_MULTIARCH="True" \
./build-xbmc-addons.sh

