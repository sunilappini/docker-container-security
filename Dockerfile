#FROM alpine:latest
FROM alpine:3.13.0

SHELL ["/bin/ash","-o","pipefail","-c"]

RUN apk add --no-cache \
    curl \
    git \
    openssh-client \
    rsync

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

EXPOSE 1313
HEALTHCHECK CMD curl --fail http://localhost:1313/ || exit 1
