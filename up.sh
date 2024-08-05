#!/usr/bin/env bash

set -euo pipefail

if ! docker info > /dev/null 2>&1; then
  echo "Ooops - looks like docker is not running"
  exit 1
fi

export MDM_PORT=8080
export MDM_APPLICATION_COMMIT=develop
export MDM_UI_COMMIT=develop
export MAURO_ENDPOINT=https://mauro.uat.dataproducts.nhs.uk
export MAURO_API_ENDPOINT=$MAURO_ENDPOINT/api
export NHSD_DD_MAURO_BASEURL=$MAURO_ENDPOINT/api
export CACHE_BURST=1

echo Setting the following environment variables:

echo "  MDM_PORT:               $MDM_PORT"
echo "  MDM_APPLICATION_COMMIT: $MDM_APPLICATION_COMMIT"
echo "  MDM_UI_COMMIT:          $MDM_UI_COMMIT"
echo "  MAURO_ENDPOINT:         $MAURO_ENDPOINT"
echo "  NHSD_DD_MAURO_BASEURL:  $NHSD_DD_MAURO_BASEURL"
echo "  CACHE_BURST:            $CACHE_BURST"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

echo Building container:
docker compose build --no-cache

echo Starting container:
docker compose up -d
