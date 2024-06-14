#!/usr/bin/env bash

set -euo pipefail

export MDM_PORT=8080
export MDM_APPLICATION_COMMIT=develop
export MDM_UI_COMMIT=develop
export MAURO_API_ENDPOINT=https://ec2-13-42-94-180.eu-west-2.compute.amazonaws.com/api
export CACHE_BURST=1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

docker compose down
