#!/usr/bin/env bash

set -euo pipefail

if ! docker info > /dev/null 2>&1; then
  echo "Ooops - looks like docker is not running"
  exit 1
fi

export MDM_PORT=8080
export MDM_APPLICATION_COMMIT=develop
export MDM_UI_COMMIT=develop
export MAURO_API_ENDPOINT=https://ec2-13-42-94-180.eu-west-2.compute.amazonaws.com/api

echo Setting the following environment variables:

echo "  MDM_PORT:               $MDM_PORT"
echo "  MDM_APPLICATION_COMMIT: $MDM_APPLICATION_COMMIT"
echo "  MDM_UI_COMMIT:          $MDM_UI_COMMIT"
echo "  MAURO_API_ENDPOINT:     $MAURO_API_ENDPOINT"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

echo Building container:
docker compose build --no-cache

echo Starting container:
docker compose up -d
