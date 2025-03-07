#!/bin/bash

precompiledBuild(){
  echo 'Using pre-compiled source'

  if [[ $NHSD_DD_ORCHESTRATION_VERSION == *SNAPSHOT ]]
  then
    NHSD_DD_ORCHESTRATION_LIBRARY='artifacts-snapshots'
  else
    NHSD_DD_ORCHESTRATION_LIBRARY='artifacts'
  fi

  NHSD_DD_ORCHESTRATION_URL="https://mauro-repository.com/${NHSD_DD_ORCHESTRATION_LIBRARY}/mauroDataMapper/nhsd-datadictionary-orchestration/nhsd-datadictionary-orchestration-${NHSD_DD_ORCHESTRATION_VERSION}.tgz"

  echo "Downloading precompiled sources ${NHSD_DD_ORCHESTRATION_URL}"

  cd /opt || exit
  curl -LO "$NHSD_DD_ORCHESTRATION_URL"
  tar xzf "nhsd-datadictionary-orchestration-${NHSD_DD_ORCHESTRATION_VERSION}.tgz"
  mkdir "$NHSD_DD_ORCHESTRATION_BUILD_HOME"
  cp -r "nhsd-datadictionary-orchestration-${NHSD_DD_ORCHESTRATION_VERSION}"/* "$NHSD_DD_ORCHESTRATION_BUILD_HOME"

  find "$NHSD_DD_ORCHESTRATION_BUILD_HOME" -name main.*.js -exec sed \
  	-e "s|apiEndpoint:\"/nhsd-datadictionary/api\"|apiEndpoint:\"${NHSD_DD_ORCHESTRATION_API_ENDPOINT}\"|g" \
  	-e "s|mauroBaseUrl:\"https://modelcatalogue.cs.ox.ac.uk/nhsd-datadictionary/\"|mauroBaseUrl:\"$NHSD_DD_MAURO_BASEURL\"|g" \
  	-i {} \;                                                                 
}

precompiledBuild
