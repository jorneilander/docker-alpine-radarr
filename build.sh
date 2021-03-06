#!/bin/bash
# set -x
set -e

ALPINE_VERSION=3.12
IMAGE_NAME=failfr8er/radarr
RADARR_RAW=$(curl -H "Accept: application/vnd.github.v3+json" -s https://api.github.com/repos/radarr/radarr/releases/latest)
RADARR_VERSION=$(echo "${RADARR_RAW}" | jq -r '.tag_name')
RADARR_ASSET=$(echo "${RADARR_RAW}" | jq -r '.assets[] | select(.name | endswith(".linux-musl-core-x64.tar.gz")).browser_download_url')

[[ -e "${RADARR_ASSET##*/}" ]] || wget "${RADARR_ASSET}"

docker buildx build \
  --file Dockerfile \
  --cache-from=type=local,src=/tmp/.buildx-cache \
  --cache-to=type=local,dest=/tmp/.buildx-cache \
  --tag ${IMAGE_NAME}:latest \
  --tag ${IMAGE_NAME}:3 \
  --tag ${IMAGE_NAME}:${RADARR_VERSION} \
  --${1:-"load"} \
  --build-arg ALPINE_VERSION=${ALPINE_VERSION} \
  --build-arg RADARR_VERSION="${RADARR_VERSION:1}" \
  --platform=linux/amd64 \
  .
