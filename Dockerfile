# syntax =  docker/dockerfile:experimental
ARG ALPINE_VERSION

FROM --platform=${TARGETPLATFORM} alpine:${ALPINE_VERSION}
LABEL maintainer="Jorn Eilander <jorn.eilander@azorion.com>"
LABEL Description="Sonarr"

# Define version of Sonarr
ARG RADARR_VERSION
ARG UID=7878
ARG GID=7878

# Install required base packages and remove any cache
RUN apk add --no-cache \
      tini \
      ca-certificates && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
      mono \
      gosu \
      curl && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
      mediainfo \
      tinyxml2 && \
    rm -rf /var/tmp/* /var/cache/apk/* && \
    cert-sync /etc/ssl/certs/ca-certificates.crt && \
    # Create the 'radarr' user and group; ensure it owns all relevant directories
    addgroup -g ${GID} radarr && \
    adduser -D -G radarr -s /bin/sh -u ${UID} radarr && \
    mkdir /config; chown -R ${UID}:${GID} /config && \
    mkdir /media/downloads; chown -R ${UID}:${GID} /media/downloads && \
    mkdir /media/movies; chown -R ${UID}:${GID} /media/movies && \
    mkdir -p /tmp/.mono; chown -R ${UID}:${GID} /tmp/.mono

ADD --chown=${UID}:${GID} Radarr.master.${RADARR_VERSION}.linux.tar.gz /opt

# Publish volumes, ports etc
ENV XDG_CONFIG_HOME=/tmp
ENV XDG_CONFIG_DIR=/tmp
VOLUME ["/config", "/media/downloads", "/media/movies"]
EXPOSE 7878
USER ${UID}
WORKDIR /config

# Define default start command
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["mono", "/opt/Radarr/Radarr.exe", "-data /config", "", "-l", "-nobrowser"]


