FROM --platform=linux/amd64 python:3.10-slim AS base

# 1. Instalar dependencias del sistema
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

# 2. Instalar Node.js (22.x)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# 3. Instalar Yarn a nivel global
RUN corepack enable && \
    corepack prepare yarn@stable --activate

# 4. Ajustar el PATH para Noir/Barretenberg
ENV PATH="/root/.nargo/bin:/root/.bb:/usr/local/bin:$PATH"

# 5. Instalar Noir
RUN curl -L https://raw.githubusercontent.com/noir-lang/noirup/refs/heads/main/install | bash && \
    noirup

# 6. Instalar Barretenberg (bb)
RUN curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/refs/heads/master/barretenberg/bbup/install | bash && \
    $HOME/.bb/bbup

# 7. Verificar instalación de bb
RUN echo "Verificando instalación de bbup..." && \
    ls -la /root/.bb && \
    ls -la /root/.nargo/bin && \
    ./root/.bb/bb --version

# 8. Instalar Garaga via pip
RUN pip install --no-cache-dir garaga

# 9. Crear directorio de trabajo
WORKDIR /app

# 10. Copiar archivos de dependencias de Yarn
COPY package.json yarn.lock ./
# Opcional: si usás Yarn 3, copiá la carpeta .yarn y el archivo .yarnrc.yml
COPY .yarnrc.yml ./

# 5️⃣ Remover la configuración de Workspaces antes de instalar dependencias
RUN jq 'del(.workspaces)' package.json > package-docker.json && mv package-docker.json package.json

# 6️⃣ Instalar dependencias sin Workspaces
RUN yarn install

# 12. Copiar el resto del código
COPY . .


# 13. Exponer puerto y comando final
EXPOSE 5001
CMD ["yarn", "dev"]
