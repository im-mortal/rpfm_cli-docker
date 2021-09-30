FROM rust:latest as builder

ARG VERSION=master
ARG PROFILE=debug

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    apt-transport-https \
    git \
 && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN git clone -b ${VERSION} --recursive --depth 1 https://github.com/Frodo45127/rpfm.git \
    && cd rpfm \
    && sed -i \
       's/debug = true//gm' \
       Cargo.toml \
    && mkdir /build \
    && cargo build \
       --verbose \
       --bin rpfm_cli \
       --target-dir /build \
       $( [ "${PROFILE}" == "release" ] && echo "--${PROFILE}" )

FROM debian:buster-slim

ARG PROFILE=debug

RUN apt-get update \
    && apt-get install -y libssl1.1 libc6-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/${PROFILE}/rpfm_cli /app/

WORKDIR /app
ENV PATH="/app:${PATH}"

ENTRYPOINT ["rpfm_cli"]
