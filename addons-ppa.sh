#!/bin/bash

#ADDONS=${ADDONS:-"visualization.waveform visualization.goom visualization.spectrum screensavers.rsxs"} \
CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH=${BRANCH:-"master"} \
#DISTS=${DISTS:-"artful zesty xenial trusty"} \
DISTS=${DISTS:-"artful zesty xenial"} \
PPA_UPLOAD="True" \
PPA=${PPA:-"nightly"} \
USE_MULTIARCH="True" \
./build-xbmc-addons.sh

