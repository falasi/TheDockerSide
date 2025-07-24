# ZeroTier Docker Setup

This guide will help you get a ZeroTier container running and set up a moon node using Docker.

## Prerequisites

Make sure you’ve already built the Docker image:

## Running the ZeroTier Container

Start the container with the necessary capabilities and device access:

```bash
sudo docker run -d \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_ADMIN \
  --device=/dev/net/tun \
  --name zerotier \
  zerotier-bookworm:1.14.0
```

## Initialize and Configure Moon Node

Access the container shell:

```bash
sudo docker exec -it zerotier /bin/bash
```

Inside the container, run the following commands:

1. **Initialize the moon node using the public identity key:**

   ```bash
   zerotier-idtool initmoon /var/lib/zerotier-one/identity.public > /var/lib/zerotier-one/moon.json
   ```

2. **Generate the moon identity:**

   ```bash
   zerotier-idtool genmoon /var/lib/zerotier-one/moon.json
   ```

3. **Verify ZeroTier service is running:**

   ```bash
   zerotier-cli info
   ```

---


