#!/bin/bash
# Credits: https://github.com/hellofresh/ansible-docker-ci/blob/master/build.sh
set -e

# This dir
SETUP_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $SETUP_DIR
LINK_TO_LATEST=${LINK_TO_LATEST-0}
# Current Version
version="$(cat files/VERSION)"
# We use quay
repo_name="$(cat files/REPO-NAME)"
DOCKER_VERSION="${repo_name}:${version}"
DOCKER_LATEST="${repo_name}:latest"
major=( ${version//./ } )
echo "******* UPDATING COMPONENTS VERSION to ${a[0]} and $version *******"
sed -i '' -e "s|\-[0-9].|-${major[0]}|" files/android-components-versions.sh
sed -i '' -e "s|[0-9]*\.[0-9]*\.[0-9]*|$version|" files/android-components-versions.sh
echo "******* BUILDING *******"
docker build -t ${DOCKER_VERSION} -t ${DOCKER_LATEST} -f Dockerfile .
echo ""

echo "******* PUSHING ${DOCKER_VERSION} *******"
docker push ${DOCKER_VERSION}

if [ "${LINK_TO_LATEST}" == "0" ]; then
    echo "Not linking to latest"
else
    echo "******* PUSHING ${DOCKER_LATEST} *******"
    docker push ${DOCKER_LATEST}
    exit 0
fi