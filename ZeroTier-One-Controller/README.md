# ZeroTier Controller

A Docker container that runs a ZeroTier network controller with the ztncui web interface for easy network management.

## What This Builds

This creates a **ZeroTier network controller** (not a moon/root server) that can:
- Create and manage ZeroTier networks
- Authorize/deauthorize network members
- Configure network settings and routing rules
- Provide a web interface for easy management

## Build

```bash
docker build -t zerotier-controller:1.14.0 .
```

## Run
### Create a moon directory on your host machine:
```
sudo mkdir -p /opt/docker/zerotier-moons
sudo cp /path/to/your/*.moon /opt/docker/zerotier-moons/
sudo chmod 644 /opt/docker/zerotier-moons/*.moon
```

### Run Zerotier Controller Container (Recommended: Host Networking)
```bash
sudo docker run -d \
  --name zerotier-controller \
  --network host \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_ADMIN \
  --device=/dev/net/tun \
  --restart unless-stopped \
  -v zerotier-data:/var/lib/zerotier-one \
  -v /opt/docker/zerotier-moons:/var/lib/zerotier-one/moons.d:ro \
  zerotier-controller:1.14.0
```

## Access Web Interface

Once running, access the web interface at:
```
http://YOUR_SERVER_IP:3000
```

## Default Credentials

- **Username:** `admin`
- **Password:** `password`

⚠️ **Change the default password immediately after first login!**

## Usage

1. **First Login:** Use the default credentials above
2. **Change Password:** Go to user settings and update your password
3. **Create Networks:** Use the web interface to create new ZeroTier networks
4. **Get Network ID:** Copy the 16-character network ID for clients to join
5. **Authorize Members:** Approve devices that request to join your networks

## Client Connection

To connect clients to networks managed by this controller:

1. Install ZeroTier on client devices
2. Join the network: `zerotier-cli join NETWORK_ID`
3. Authorize the client in the web interface
4. Client will receive network configuration and IP assignment

## Data Persistence

The container uses a named volume `zerotier-data` to persist:
- Network configurations
- Controller identity/keys
- Member authorizations
- Network rules and settings

## Logs

View container logs:
```bash
docker logs zerotier-controller
```

View ztncui web interface logs:
```bash
docker exec zerotier-controller cat /tmp/ztncui.log
```

## Health Check

The container includes a health check. View status:
```bash
docker ps  # Shows health status
```

## Troubleshooting

### Container won't start
- Ensure `/dev/net/tun` exists on host
- Check that required capabilities are available
- Verify ports 3000 and 9993 aren't in use

### Can't access web interface
- Check if port 3000 is accessible from your network
- Verify firewall settings on host
- Try using host IP instead of localhost

### Networks not working
- Ensure controller has proper network connectivity
- Check that clients can reach the controller on port 9993
- Verify network routes and firewall rules

## Security Notes

- Change default password immediately
- Consider running behind a reverse proxy with HTTPS
- Restrict access to port 3000 to trusted networks
- Keep the container updated regularly
