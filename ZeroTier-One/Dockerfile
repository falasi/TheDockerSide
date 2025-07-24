# Release: https://download.zerotier.com/RELEASES/
# sudo docker build -t zerotier-bookworm:1.14.0 .
# sudo docker run -d --cap-add=NET_ADMIN --cap-add=SYS_ADMIN --device=/dev/net/tun --name zerotier zerotier-bookworm:1.14.0
# sudo docker exec -it zerotier /bin/bash

FROM debian:bookworm-slim

ARG VERSION=1.14.0

RUN apt-get update && apt-get install -y curl iproute2 iptables libcap2-bin \
  && curl -LO https://download.zerotier.com/RELEASES/${VERSION}/dist/debian/bookworm/zerotier-one_${VERSION}_amd64.deb \
  && dpkg -i zerotier-one_${VERSION}_amd64.deb \
  && rm zerotier-one_${VERSION}_amd64.deb \
  && rm -rf /var/lib/apt/lists/*

CMD ["/usr/sbin/zerotier-one"]
