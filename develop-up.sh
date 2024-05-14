#!/usr/bin/env bash

set -euo pipefail

if ! docker info > /dev/null 2>&1; then
  echo "Ooops - looks like docker is not running"
  exit 1
fi

export MDM_PORT=80
export MDM_APPLICATION_COMMIT=develop
export MDM_UI_COMMIT=develop

echo Setting the following environment variables:

echo "  MDM_PORT: $MDM_PORT"
echo "  MDM_APPLICATION_COMMIT: $MDM_APPLICATION_COMMIT"
echo "  MDM_UI_COMMIT: $MDM_UI_COMMIT"

echo Starting container:
# docker compose up -d
docker compose up -d --no-deps --build

# docker compose logs -f
