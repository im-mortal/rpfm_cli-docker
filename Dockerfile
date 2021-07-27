FROM rust:1.40 as builder

ENV VERSION=v2.5.3

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    apt-transport-https \
    git \
 && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN git clone -b ${VERSION} --recursive --depth 1 https://github.com/Frodo45127/rpfm.git \
    && cd rpfm \
    && cargo build --verbose --bin rpfm_cli \
    && ls -Ashl \
    && cargo test --verbose


FROM debian:buster-slim
COPY --from=builder /usr/src/app /app

WORKDIR /app

CMD ["rpfm-cli"]
