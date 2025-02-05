FROM --platform=linux/amd64 python:3.10-slim AS base

# 1. Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    curl \
    jq \
    build-essential \
    libssl-dev \
    pkg-config \
    cmake \
    clang \
    clang-16 \
    ninja-build \
    libstdc++-12-dev \
    libgmp-dev \
    libstdc++6 \
    libc++-dev \
    libc++abi-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt-get install -y nodejs

RUN corepack enable && corepack prepare yarn@stable --activate

RUN curl -L https://raw.githubusercontent.com/noir-lang/noirup/refs/heads/main/install | bash && noirup

RUN curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/refs/heads/master/barretenberg/bbup/install | bash && $HOME/.bb/bbup
ENV PATH="/root/.nargo/bin:/root/.bb:/usr/local/bin:$PATH"

# Verify Barretenberg installation
RUN echo "Verifing Barretenberg installation..." && \
    ls -la /root/.bb && \
    ls -la /root/.nargo/bin && \
    ./root/.bb/bb --version

# Install garaga
RUN pip install --no-cache-dir garaga

WORKDIR /app

COPY package.json yarn.lock ./
COPY .yarnrc.yml ./

RUN jq 'del(.workspaces)' package.json > package-docker.json && mv package-docker.json package.json
RUN yarn install

COPY . .

EXPOSE 5001
CMD ["yarn", "dev"]
