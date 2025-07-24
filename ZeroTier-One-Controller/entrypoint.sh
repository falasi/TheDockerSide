#!/bin/bash

# Start ZeroTier service
zerotier-one &

# Wait for zerotier-one to init
echo "Waiting for ZeroTier to initialize..."
while [ ! -f /var/lib/zerotier-one/identity.public ]; do
  sleep 1
done

# Setup moon (controller)
if [ ! -f /var/lib/zerotier-one/moon.json ]; then
  zerotier-idtool initmoon /var/lib/zerotier-one/identity.public > /var/lib/zerotier-one/moon.json
  zerotier-idtool genmoon /var/lib/zerotier-one/moon.json
  cp /var/lib/zerotier-one/moons.d/* /var/lib/zerotier-one/
  echo "Moon created and loaded."
fi

# Orbit self
NODE_ID=$(cut -d':' -f1 < /var/lib/zerotier-one/identity.public)
MOON_ID=000000000000000a
zerotier-cli orbit "$NODE_ID" "$MOON_ID" || true

# Setup ztncui .env
cd /opt/ztncui/src
if [ ! -f .env ]; then
  AUTH_TOKEN=$(cat /var/lib/zerotier-one/authtoken.secret)
  echo "ZT_TOKEN=$AUTH_TOKEN" > .env
  echo "NODE_ENV=production" >> .env
  echo "HTTP_ALL_INTERFACES=yes" >> .env
  chmod 400 .env
  echo ".env created for ztncui"
fi

# Start ztncui Web UI
npm start
