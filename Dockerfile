FROM perl:5.40.0-slim-threaded-buster
#
# Docker necessary file
#
# Build:
#   docker build . \
#     -t <maintainer>/latexindent:<version tag> \
#     --build-arg LATEXINDENT_VERSION=<version tag>
#
# Run:
#   docker run --rm -it <maintainer>/latexindent:<version tag> -h
#
# Publish:
#   docker push <maintainer>/latexindent:<version tag>
#
# Note: see also .github/workflows/release-docker-ghcr.yml
#

ARG LATEXINDENT_VERSION
ENV LATEXINDENT_VERSION ${LATEXINDENT_VERSION:-V3.24.4}

RUN apt-get update \
    && apt-get install \
    build-essential \
    ca-certificates \
    cmake \
    git \
    wget \
    -y -qq --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

RUN git clone --depth 1 https://github.com/cmhughes/latexindent.pl --branch "${LATEXINDENT_VERSION}"

WORKDIR /latexindent.pl/helper-scripts

RUN echo "Y" | perl latexindent-module-installer.pl

WORKDIR /latexindent.pl/build

RUN cmake ../path-helper-files && make install && ln -s /usr/local/bin/latexindent.pl /usr/local/bin/latexindent

WORKDIR /

ENTRYPOINT ["latexindent"]
