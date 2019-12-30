# GitHub:       https://github.com/gohugoio
# Twitter:      https://twitter.com/gohugoio
# Website:      https://gohugo.io/

FROM golang:1.13-alpine3.10 AS build

# Optionally set HUGO_BUILD_TAGS to "extended" when building like so:
#   docker build --build-arg HUGO_BUILD_TAGS=extended .
ARG HUGO_BUILD_TAGS

ARG CGO=1
ENV CGO_ENABLED=${CGO}
ENV GOOS=linux
ENV GO111MODULE=on

WORKDIR /go/src/github.com/gohugoio/hugo

# gcc/g++ are required to build SASS libraries for extended version
RUN apk update && \
    apk add --no-cache gcc g++ musl-dev && \
    go get github.com/magefile/mage

ADD https://github.com/gohugoio/hugo/archive/v0.62.0.tar.gz /go/src/github.com/gohugoio/hugo/
RUN tar -xzf /go/src/github.com/gohugoio/hugo/v0.62.0.tar.gz --strip 1

RUN mage hugo && mage install

# ---

FROM alpine:3.10

COPY --from=build /go/bin/hugo /usr/bin/hugo

# libc6-compat & libstdc++ are required for extended SASS libraries
# ca-certificates are required to fetch outside resources (like Twitter oEmbeds)
RUN apk update && \
    apk add --no-cache ca-certificates libc6-compat libstdc++

VOLUME /site
WORKDIR /site