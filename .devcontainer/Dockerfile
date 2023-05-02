FROM perl:5.36.1-slim-threaded-buster
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
