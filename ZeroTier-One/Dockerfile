# Release: https://download.zerotier.com/RELEASES/
# Build: docker build -t zerotier-bookworm:1.14.0 .
# Run: docker run -d --cap-add=NET_ADMIN --cap-add=SYS_ADMIN --device=/dev/net/tun \
#      --name zerotier --restart=unless-stopped \
#      -v zerotier-data:/var/lib/zerotier-one \
#      zerotier-bookworm:1.14.0
# Join network: docker exec zerotier zerotier-cli join <network-id>
# Status: docker exec zerotier zerotier-cli status

FROM debian:bookworm-slim

ARG VERSION=1.14.0
ARG DEBIAN_FRONTEND=noninteractive

# Create zerotier user for better security
RUN groupadd -g 999 zerotier && \
    useradd -r -u 999 -g zerotier -d /var/lib/zerotier-one -s /bin/false zerotier

# Install dependencies and ZeroTier
RUN apt-get update && apt-get install -y \
    curl \
    iproute2 \
    iptables \
    libcap2-bin \
    ca-certificates \
  && curl -fsSL https://download.zerotier.com/RELEASES/${VERSION}/dist/debian/bookworm/zerotier-one_${VERSION}_amd64.deb \
     -o zerotier-one.deb \
  && dpkg -i zerotier-one.deb || true \
  && apt-get install -f -y \
  && rm zerotier-one.deb \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set proper permissions for zerotier data directory
RUN mkdir -p /var/lib/zerotier-one && \
    chown -R zerotier:zerotier /var/lib/zerotier-one && \
    chmod 700 /var/lib/zerotier-one

# Create volume for persistent data
VOLUME ["/var/lib/zerotier-one"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD zerotier-cli info || exit 1

# Set capabilities to allow running as non-root user
RUN setcap 'cap_net_admin,cap_net_raw,cap_sys_admin+ep' /usr/sbin/zerotier-one

# Switch to zerotier user
USER zerotier

# Expose ZeroTier port (though not strictly necessary for client)
EXPOSE 9993/udp

CMD ["/usr/sbin/zerotier-one"]
