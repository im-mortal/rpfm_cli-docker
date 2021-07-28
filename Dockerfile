FROM rust:latest as builder

ARG VERSION=master

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    apt-transport-https \
    git \
 && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN git clone -b ${VERSION} --recursive --depth 1 https://github.com/Frodo45127/rpfm.git \
    && cd rpfm \
    && mkdir /build \
    && cargo build --verbose --bin rpfm_cli  --target-dir /build

FROM debian:buster-slim

RUN apt-get update \
    && apt-get install -y openssl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/debug/rpfm_cli /app/

WORKDIR /app
ENV PATH="/app:${PATH}"

ENTRYPOINT ["rpfm_cli"]
