#!/bin/bash

CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH="master" \
DISTS="raring quantal precise" \
BUILDER="debuild" \
DEBUILD_OPTS="-S" \
PPA_UPLOAD="True" \
DPUT_TARGET="ppa:wsnipex/xbmc-nightly" \
./build-xbmc-addons.sh
