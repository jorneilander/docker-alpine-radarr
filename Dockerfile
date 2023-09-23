# syntax =  docker/dockerfile:experimental
ARG ALPINE_VERSION

FROM --platform=${TARGETPLATFORM} alpine:${ALPINE_VERSION}
LABEL maintainer="Jorn Eilander <jorn.eilander@azorion.com>"
LABEL description="Sonarr"

# Define version of Sonarr
ARG RADARR_VERSION
ARG UID=7878
ARG GID=7878

# Install required base packages and remove any cache
RUN apk add --no-cache \
      bash \
      curl \
      icu-libs \
      krb5-libs \
      libgcc \
      libintl \
      libssl1.1 \
      libstdc++ \
      lttng-ust \
      numactl \
      sqlite \
      sqlite-libs \
      tini \
      zlib && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
      mediainfo && \
    # Create the 'radarr' user and group; ensure it owns all relevant directories
    addgroup -g ${GID} radarr && \
    adduser -D -G radarr -s /bin/sh -u ${UID} radarr && \
    mkdir /config; chown -R ${UID}:${GID} /config && \
    mkdir /media/downloads; chown -R ${UID}:${GID} /media/downloads && \
    mkdir /media/movies; chown -R ${UID}:${GID} /media/movies

ADD --chown=${UID}:${GID} Radarr.master.${RADARR_VERSION}.linux-musl-core-x64.tar.gz /opt

# Publish volumes, ports etc
ENV XDG_CONFIG_HOME="/config/xdg"
VOLUME ["/config", "/media/downloads", "/media/movies"]
EXPOSE 7878
USER ${UID}
WORKDIR /config

# Define default start command
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/opt/Radarr/Radarr", "/data=/config", "/nobrowser"]
