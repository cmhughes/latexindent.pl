FROM perl:5.41.13-slim-threaded-bookworm
#
# GitHub codespaces necessary file
#
# See https://github.com/cmhughes/latexindent.pl/issues/442 for original discussion
#
RUN apt-get update \
    && apt-get install \
    build-essential \
    ca-certificates \
    cmake \
    git \
    wget \
    locales \
    locales-all \
    -y -qq --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN locale-gen en_US.UTF-8

RUN cpanm YAML::Tiny && \
    cpanm File::HomeDir && \
    cpanm Unicode::GCString
