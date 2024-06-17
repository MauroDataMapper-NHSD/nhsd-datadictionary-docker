#!/usr/bin/env bash

set -euo pipefail

BRANCH_TAG=TEST
GROUP_NAME=id
REPOSITORY=https://github.com/MauroDataMapper-NHSD/nhsd-datadictionary-docker

DOCKER_DIR=nhsd-datadictionary-docker
TARBALL=temp.tar.bz

DATESTR=$(date '+%Y%m%d%H%M')
ARCHIVED_DIR="${DOCKER_DIR}_archived_${DATESTR}"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

trap "rm -f $TARBALL" EXIT

cd "$SCRIPT_DIR"

echo "getting sources from: \"$REPOSITORY/tarball/$BRANCH_TAG\""
curl -L -s -o "$TARBALL" "$REPOSITORY/tarball/$BRANCH_TAG"

# If there is an existing directory then bring the container down.
if [ -d "$DOCKER_DIR" ]; then
  echo "Attempting to stop the existing docker container..."
	"$DOCKER_DIR/down.sh"

	# Don't delete the (presumably) working copy just in case the update fails
	echo "Ranaming \"$DOCKER_DIR\" to \"$ARCHIVED_DIR\""
	mv "$DOCKER_DIR" "$ARCHIVED_DIR"
fi

# At this point there should be no $DOCKER_DIR directory so create one and expand
# the contents of the tarball into it (stripping of the root directory).
mkdir "$DOCKER_DIR"
tar xf "$TARBALL" --strip-components=1 --directory="$DOCKER_DIR"

# The scripts contained in the sources will not be runnable so fix that
#
if [ -n "$GROUP_NAME" ]; then
	echo "Setting group \"$GROUP_NAME\" on \"$DOCKER_DIR\""
	chgrp -R "$GROUP_NAME" "$DOCKER_DIR"
	chmod -R g+rws "$DOCKER_DIR"	
fi

echo "Making the up & down scripts executable"
chmod ug+x "$DOCKER_DIR/up.sh" "$DOCKER_DIR/down.sh"

echo "Building and starting the containers"
"$DOCKER_DIR/up.sh"
