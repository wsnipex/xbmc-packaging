#!/bin/bash

CLEANUP_AFTER="True" \
TAG=${TAG:-"1"} \
BRANCH="master" \
DISTS="raring quantal precise" \
PPA_UPLOAD="True" \
PPA="wsnipex-nightly" \
./build-xbmc-addons.sh

#BUILDER="debuild" \
#DEBUILD_OPTS="-S" \
#DPUT_TARGET="ppa:wsnipex/xbmc-nightly" \

