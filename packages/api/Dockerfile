FROM --platform=linux/amd64 python:3.10-slim AS base

# install system dependencies
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

# install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt-get install -y nodejs

# install noir
RUN curl -L https://raw.githubusercontent.com/noir-lang/noirup/refs/heads/main/install | bash && $HOME/.nargo/bin/noirup
ENV PATH="/root/.nargo/bin:$PATH"

# install bb
RUN curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/refs/heads/master/barretenberg/bbup/install | bash && $HOME/.bb/bbup
ENV PATH="/root/.nargo/bin:/root/.bb:/usr/local/bin:$PATH"

# install garaga
RUN pip install --no-cache-dir garaga

WORKDIR /app

# install dependencies
COPY package.json .
RUN npm install

# copy rest of the code
COPY . .

# expose port
ENV PORT=80
EXPOSE 80

CMD ["npm", "run", "dev"]
