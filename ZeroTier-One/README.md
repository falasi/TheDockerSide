# ZeroTier Docker Client

A secure, containerized ZeroTier client built on Debian Bookworm with persistent storage and health monitoring.

## Features

- 🔒 **Security-first**: Runs as non-root user with minimal required capabilities
- 💾 **Persistent storage**: Network configurations and identity survive container restarts
- 🏥 **Health monitoring**: Built-in health checks to monitor ZeroTier status
- 🐳 **Docker-optimized**: Minimal image size with proper cleanup
- 🔄 **Auto-restart**: Configured for automatic restart on failure

## Quick Start

### 1. Build the Image

```bash
docker build -t zerotier-client:1.14.0 .
```

### 2. Run the Container

```bash
docker run -d \
  --name zerotier \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_ADMIN \
  --device=/dev/net/tun \
  --restart=unless-stopped \
  -v zerotier-data:/var/lib/zerotier-one \
  zerotier-client:1.14.0
```

### 3. Join a Network

```bash
docker exec zerotier zerotier-cli join <your-network-id>
```

## Usage

### Basic Commands

Check ZeroTier status:
```bash
docker exec zerotier zerotier-cli status
```

List joined networks:
```bash
docker exec zerotier zerotier-cli listnetworks
```

Show node information:
```bash
docker exec zerotier zerotier-cli info
```

Leave a network:
```bash
docker exec zerotier zerotier-cli leave <network-id>
```

### Interactive Shell

Access the container shell for advanced configuration:
```bash
docker exec -it zerotier /bin/bash
```

## Configuration

### Environment Variables

The container doesn't require environment variables for basic operation, but you can customize the build:

```bash
docker build --build-arg VERSION=1.14.0 -t zerotier-client:1.14.0 .
```

### Persistent Data

The container uses a Docker volume to persist:
- ZeroTier identity files
- Network configurations
- Connection state

**Volume location**: `/var/lib/zerotier-one`

To backup your ZeroTier identity:
```bash
docker cp zerotier:/var/lib/zerotier-one ./zerotier-backup/
```

## Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  zerotier:
    build: .
    container_name: zerotier
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_ADMIN
    devices:
      - /dev/net/tun
    volumes:
      - zerotier-data:/var/lib/zerotier-one
    healthcheck:
      test: ["CMD", "zerotier-cli", "info"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 5s

volumes:
  zerotier-data:
```

Start with Docker Compose:
```bash
docker-compose up -d
```

## Security

### Required Capabilities

The container requires these Linux capabilities:
- `NET_ADMIN`: Network interface management
- `SYS_ADMIN`: System administration tasks
- `/dev/net/tun`: TUN/TAP device access

### Non-Root Operation

The container runs as the `zerotier` user (UID 999) with minimal privileges. Necessary capabilities are granted only to the ZeroTier binary using `setcap`.

### Network Access

ZeroTier uses UDP port 9993 for communication. The container exposes this port, but it's not required to be published unless you need specific routing.

## Troubleshooting

### Container Won't Start

Check if TUN/TAP is available:
```bash
ls -la /dev/net/tun
```

Verify capabilities are supported:
```bash
docker info | grep -i security
```

### Network Connection Issues

Check ZeroTier status:
```bash
docker exec zerotier zerotier-cli status
```

View logs:
```bash
docker logs zerotier
```

Restart the container:
```bash
docker restart zerotier
```

### Permission Issues

If you encounter permission errors, ensure the container has the required capabilities:
```bash
docker run --cap-add=NET_ADMIN --cap-add=SYS_ADMIN --device=/dev/net/tun ...
```

## Health Monitoring

The container includes a health check that runs every 30 seconds:

```bash
# Check health status
docker inspect zerotier | grep -A 10 Health

# View health check logs
docker inspect zerotier | jq '.[0].State.Health'
```

## Updating

To update to a new ZeroTier version:

1. Update the `VERSION` argument in the Dockerfile
2. Rebuild the image:
   ```bash
   docker build --build-arg VERSION=<new-version> -t zerotier-client:<new-version> .
   ```
3. Stop and remove the old container:
   ```bash
   docker stop zerotier && docker rm zerotier
   ```
4. Start with the new image (your data persists in the volume)

## Support

- **ZeroTier Documentation**: https://docs.zerotier.com/
- **Docker Documentation**: https://docs.docker.com/
- **Issues**: Open an issue in this repository

## License

This Dockerfile is provided as-is. ZeroTier itself is governed by its own license terms.

