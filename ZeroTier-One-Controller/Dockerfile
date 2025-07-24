FROM debian:bookworm

ARG ZT_VERSION=1.14.0

# Install dependencies in a single layer with cleanup
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    git \
    bash \
    nodejs \
    npm \
    build-essential \
    iproute2 \
    iptables \
    ca-certificates \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install ZeroTier with error handling
RUN wget "https://download.zerotier.com/RELEASES/${ZT_VERSION}/dist/debian/bookworm/zerotier-one_${ZT_VERSION}_amd64.deb" \
    && dpkg -i "zerotier-one_${ZT_VERSION}_amd64.deb" || apt-get install -f -y \
    && rm "zerotier-one_${ZT_VERSION}_amd64.deb"

# Create zerotier-one user and directories with proper permissions
RUN useradd -r -s /bin/false zerotier-one || true \
    && mkdir -p /var/lib/zerotier-one \
    && chown zerotier-one:zerotier-one /var/lib/zerotier-one

# Clone ztncui and install Node modules
RUN git clone https://github.com/key-networks/ztncui /opt/ztncui \
    && cd /opt/ztncui/src \
    && npm install --omit=dev \
    && cp -v etc/default.passwd etc/passwd \
    && npm cache clean --force

# Create log directory
RUN mkdir -p /tmp && chmod 1777 /tmp

# Expose Web UI and ZeroTier API ports
EXPOSE 3000 9993

# Copy and set up entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000 || exit 1

# Use ENTRYPOINT for better signal handling
ENTRYPOINT ["/entrypoint.sh"]
