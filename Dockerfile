FROM alpine/openclaw:latest

USER root

# Install Linuxbrew dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    file \
    git \
    openssh-client \
    procps \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Prepare Linuxbrew home and grant ownership to the runtime user.
RUN mkdir -p /home/linuxbrew/.linuxbrew && \
    chown -R node:node /home/linuxbrew

ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

USER node

# Install Homebrew in a non-interactive, deterministic way.
RUN git clone --depth=1 https://github.com/Homebrew/brew "${HOMEBREW_REPOSITORY}" && \
    mkdir -p "${HOMEBREW_PREFIX}/bin" "${HOMEBREW_PREFIX}/sbin" && \
    ln -sf "${HOMEBREW_REPOSITORY}/bin/brew" "${HOMEBREW_PREFIX}/bin/brew" && \
    brew update --force --quiet

# Install vi editor using Homebrew
RUN brew install vim

# Make node compile cache directory and grant ownership to the runtime user.
ENV NODE_COMPILE_CACHE=/home/node/.cache/node-compile-cache
RUN mkdir -p ${NODE_COMPILE_CACHE} && \
    chown -R node:node ${NODE_COMPILE_CACHE}
