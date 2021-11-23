FROM rust:latest as builder

ARG VERSION=master
ARG PROFILE=debug
ARG UPSTREAM=https://github.com/Frodo45127/rpfm.git

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    apt-transport-https \
    git \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN git clone \
      -b ${VERSION} \
      --recursive \
      --depth 1 \
      ${UPSTREAM} \
    && cd rpfm \
    && sed -i \
       's/debug\s*=\s*true//gm' \
       Cargo.toml \
    && mkdir /build \
    && cargo build \
       -vv \
       --bin rpfm_cli \
       --target-dir /build \
       $( [ "${PROFILE}" == "release" ] && echo "--${PROFILE}" )

ARG BASE_IMAGE=debian:bullseye-slim
FROM $BASE_IMAGE

ARG PROFILE=debug
ARG APP=/app

ENV APP_USER=rpfm

RUN groupadd ${APP_USER} \
 && useradd -g ${APP_USER} ${APP_USER} \
 && mkdir -p ${APP} \
 && apt-get update \
 && apt-get install -y libssl1.1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY --chown=${APP_USER}:${APP_USER} \
     --from=builder \
     /build/${PROFILE}/rpfm_cli ${APP}/

WORKDIR ${APP}
ENV PATH="${APP}:${PATH}"

ENTRYPOINT ["rpfm_cli"]
