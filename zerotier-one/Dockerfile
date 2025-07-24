FROM debian:bookworm

ARG ZT_VERSION=1.14.0

# Install dependencies
RUN apt update && apt install -y \
    curl gnupg git bash \
    nodejs npm build-essential \
    iproute2 iptables ca-certificates wget

# Install ZeroTier
RUN wget https://download.zerotier.com/RELEASES/${ZT_VERSION}/dist/debian/bookworm/zerotier-one_${ZT_VERSION}_amd64.deb \
    && dpkg -i zerotier-one_${ZT_VERSION}_amd64.deb \
    && rm zerotier-one_${ZT_VERSION}_amd64.deb

# Clone ztncui and install Node modules
RUN git clone https://github.com/key-networks/ztncui /opt/ztncui \
    && cd /opt/ztncui/src \
    && npm install \
    && cp -v etc/default.passwd etc/passwd

# Expose Web UI and ZeroTier API ports
EXPOSE 3000
EXPOSE 9993

# Startup script to set up moon and ztncui
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
