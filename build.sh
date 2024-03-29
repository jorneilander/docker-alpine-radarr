#!/bin/bash
# set -x
set -o errexit

ALPINE_VERSION="latest"
IMAGE_NAME="failfr8er/radarr"

# Set Radarr release information
RADARR_RAW="$(curl -H "Accept: application/vnd.github.v3+json" -s https://api.github.com/repos/radarr/radarr/releases/latest)"

# Fetch Radarr asset
RADARR_ASSET=$(jq -r '.assets[] | select(.name | endswith(".linux-musl-core-x64.tar.gz")).browser_download_url' <<< "${RADARR_RAW}")
[[ -e "${RADARR_ASSET##*/}" ]] || wget "${RADARR_ASSET}"

# Set Radarr version
RADARR_VERSION=$(jq -r '.tag_name' <<< "${RADARR_RAW}")
RADARR_VERSION_MAJOR="${RADARR_VERSION%%.*}"
RADARR_VERSION_MINOR="${RADARR_VERSION%.*.*}"

# Output user relevant information
echo "Building: failfr8er/radarr:${RADARR_VERSION}"
echo "Tags: ['latest', '${RADARR_VERSION}', '${RADARR_VERSION_MAJOR}', ${RADARR_VERSION_MINOR}']"

docker buildx build \
  --file Dockerfile \
  --cache-from=type="local,src=/tmp/.buildx-cache" \
  --cache-to=type="local,dest=/tmp/.buildx-cache" \
  --tag "${IMAGE_NAME}:latest" \
  --tag "${IMAGE_NAME}:${RADARR_VERSION}" \
  --tag "${IMAGE_NAME}:${RADARR_VERSION_MAJOR}" \
  --tag "${IMAGE_NAME}:${RADARR_VERSION_MINOR}" \
  --"${1:-'load'}" \
  --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" \
  --build-arg "RADARR_VERSION=${RADARR_VERSION:1}" \
  --platform="linux/amd64" \
  .
