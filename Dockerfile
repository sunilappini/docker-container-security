
#FROM alpine:latest
FROM alpine:3.7

ARG CREATED=x

LABEL Name=SunilAppini \
      Version=1.0 \
      Maintainer="Sunil"

SHELL ["/bin/ash","-o","pipefail","-c"]

RUN apk add --no-cache \
    curl=7.61.1-r3 \
    git=2.15.4-r0 \
    openssh-client=7.5_p1-r10 \
    rsync=3.1.3-r0

ENV VERSION 0.64.0
WORKDIR /usr/local/src
RUN curl -L \
      https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_linux-64bit.tar.gz --output hugo_${VERSION}_Linux-64bit.tar.gz \
    && curl -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_checksums.txt | grep hugo_${VERSION}_Linux-64bit.tar.gz | sha256sum -c \
    && tar -xzf hugo_${VERSION}_Linux-64bit.tar.gz\
    && mv hugo /usr/local/bin/hugo \
    && addgroup -Sg 1000 hugo \
    && adduser -SG hugo -u 1000 -h /src hugo

WORKDIR /src

USER hugo
CMD ["/bin/ash"]

EXPOSE 1313

HEALTHCHECK --interval=10s --timeout=10s --start-period=15s CMD hugo env || exit 1

LABEL org.opencontainers.image.title="Hugo Builder"
LABEL org.opencontainers.image.created="$CREATED_AT"
LABEL org.opencontainers.image.source="https://github.com/sunilappini/docker-container-security"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.revision=1.0.1"
LABEL org.opencontainers.image.licenses="SMARSH"
LABEL org.opencontainers.image.url="http://www.smarsh.com"

