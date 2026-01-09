FROM node:20-slim

# Install CLI tool
RUN npm install -g @charmland/crush

# Install additional tools including iptables and jq. Everything after jq is project specific.
RUN apt-get update && apt-get install -y \
    git \
    curl \
    python3 \
    python3-pip \
    ca-certificates \
    iptables \
    iproute2 \
    jq \
    pipx \
    python-is-python3 \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Use existing node user (UID 1000) for running CLI tool
# No need to create a new user - node:20-slim already has 'node' user with UID 1000

USER 1000

ENV PATH="$PATH:/home/node/.local/bin"

RUN pipx install poetry

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

ENV PATH="$PATH:/home/node/.cargo/bin"

RUN rustup default stable

# Set working directory
WORKDIR /workspace

USER root

# Create firewall initialization script (runs as root)
COPY init-firewall.sh /usr/local/bin/init-firewall.sh

RUN chmod 755 /usr/local/bin/init-firewall.sh

# Normalize line endings to LF for scripts created from Dockerfile heredocs (fixes Windows CRLF issues)
RUN sed -i 's/\r$//' /usr/local/bin/init-firewall.sh || true

# Create comprehensive test script (runs as node)
COPY run-tests.sh /usr/local/bin/run-tests.sh

RUN sed -i 's/\r$//' /usr/local/bin/run-tests.sh || true
RUN chmod 755 /usr/local/bin/run-tests.sh

# Create entrypoint script that runs as root, then drops to node
COPY entrypoint.sh /entrypoint.sh

RUN sed -i 's/\r$//' /entrypoint.sh || true
RUN chmod 755 /entrypoint.sh

# Set ownership of workspace
RUN chown -R node:node /workspace

# Copy CLI

RUN mkdir -p /home/node/.local/share/crush
COPY crush.json /home/node/.local/share/crush/crush.json
RUN chown -R node:node /home/node/.local/share/crush

# Default command: entrypoint handles privilege separation
ENTRYPOINT ["/entrypoint.sh"]