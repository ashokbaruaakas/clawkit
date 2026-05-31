ARG OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:latest
FROM ${OPENCLAW_IMAGE}

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
    vim \
    && rm -rf /var/lib/apt/lists/*

# Prepare Linuxbrew home and grant ownership to the runtime user.
RUN mkdir -p /home/linuxbrew/.linuxbrew && \
    chown -R node:node /home/linuxbrew

ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

USER node

# Configure global npm installs for non-root user.
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=/home/node/.npm-global/bin:${PATH}
RUN mkdir -p ${NPM_CONFIG_PREFIX}

# Install Homebrew in a non-interactive, deterministic way.
RUN git clone --depth=1 https://github.com/Homebrew/brew "${HOMEBREW_REPOSITORY}" && \
    mkdir -p "${HOMEBREW_PREFIX}/bin" "${HOMEBREW_PREFIX}/sbin" && \
    ln -sf "${HOMEBREW_REPOSITORY}/bin/brew" "${HOMEBREW_PREFIX}/bin/brew" && \
    brew update --force --quiet

# Make node compile cache directory and grant ownership to the runtime user.
ENV NODE_COMPILE_CACHE=/home/node/.cache/node-compile-cache
RUN mkdir -p ${NODE_COMPILE_CACHE} && \
    chown -R node:node ${NODE_COMPILE_CACHE}
