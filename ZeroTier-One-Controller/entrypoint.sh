#!/bin/bash

set -e
set -o pipefail

# Function to handle graceful shutdown
cleanup() {
    echo "Shutting down gracefully..."
    if [ ! -z "$ZTNCUI_PID" ] && kill -0 "$ZTNCUI_PID" 2>/dev/null; then
        echo "Stopping ztncui (PID: $ZTNCUI_PID)..."
        kill -TERM "$ZTNCUI_PID" 2>/dev/null
        wait "$ZTNCUI_PID" 2>/dev/null
    fi
    if [ ! -z "$ZT_PID" ] && kill -0 "$ZT_PID" 2>/dev/null; then
        echo "Stopping ZeroTier (PID: $ZT_PID)..."
        kill -TERM "$ZT_PID" 2>/dev/null
        wait "$ZT_PID" 2>/dev/null
    fi
}

# Set up signal handlers for graceful shutdown
trap cleanup SIGTERM SIGINT

# Start ZeroTier service in background and capture PID
echo "Starting ZeroTier service..."
zerotier-one &
ZT_PID=$!
echo "ZeroTier started with PID: $ZT_PID"

# Check if ZeroTier started successfully
sleep 1
if ! kill -0 "$ZT_PID" 2>/dev/null; then
    echo "ERROR: ZeroTier failed to start"
    exit 1
fi

# Wait for zerotier-one to initialize
echo "Waiting for ZeroTier to initialize..."
while [ ! -f /var/lib/zerotier-one/identity.public ]; do
  if ! kill -0 "$ZT_PID" 2>/dev/null; then
      echo "ERROR: ZeroTier process died during initialization"
      exit 1
  fi
  sleep 1
done

# Get the Node ID
NODE_ID=$(cut -d':' -f1 < /var/lib/zerotier-one/identity.public)
echo "ZeroTier Node ID: $NODE_ID"

# Wait for zerotier-one to be fully ready
sleep 3

# Enable controller mode by creating controller.d directory
CONTROLLER_DIR="/var/lib/zerotier-one/controller.d"
if [ ! -d "$CONTROLLER_DIR" ]; then
  mkdir -p "$CONTROLLER_DIR"
  echo "Controller directory created at $CONTROLLER_DIR"
fi

# Create controller database directory structure
mkdir -p "$CONTROLLER_DIR/network"
mkdir -p "$CONTROLLER_DIR/trace"

# Set proper permissions
chown -R zerotier-one:zerotier-one /var/lib/zerotier-one/controller.d 2>/dev/null || true

# Wait a bit more for the controller to initialize
sleep 5

# Verify controller is running
if zerotier-cli info | grep -q "ONLINE"; then
  echo "ZeroTier controller is online and ready"
else
  echo "Warning: ZeroTier may not be fully online yet"
fi

# Setup ztncui .env
cd /opt/ztncui/src
if [ ! -f .env ]; then
  # Wait for authtoken to be available
  while [ ! -f /var/lib/zerotier-one/authtoken.secret ]; do
    if ! kill -0 "$ZT_PID" 2>/dev/null; then
        echo "ERROR: ZeroTier process died while waiting for authtoken"
        exit 1
    fi
    sleep 1
  done
  
  AUTH_TOKEN=$(cat /var/lib/zerotier-one/authtoken.secret)
  echo "ZT_TOKEN=$AUTH_TOKEN" > .env
  echo "NODE_ENV=production" >> .env
  echo "HTTP_ALL_INTERFACES=yes" >> .env
  echo "HTTP_PORT=3000" >> .env
  chmod 400 .env
  echo ".env created for ztncui"
fi

# Display controller information
echo "ZeroTier Controller Setup Complete"
echo "Node ID: $NODE_ID"
echo "Web UI will be available on port 3000"
echo "ZeroTier API available on port 9993"
echo "Controller data directory: $CONTROLLER_DIR"

# Start ztncui Web UI in background and capture PID
echo "Starting ztncui Web UI..."
npm start > /tmp/ztncui.log 2>&1 &
ZTNCUI_PID=$!
disown
echo "ztncui started with PID: $ZTNCUI_PID (logs redirected to /tmp/ztncui.log)"

# Check if ztncui started successfully
sleep 3
if ! kill -0 "$ZTNCUI_PID" 2>/dev/null; then
    echo "ERROR: ztncui failed to start"
    cleanup
    exit 1
fi

echo "Container is ready and running!"

# Wait for any process to exit using wait -n (bash 4.3+)
# Falls back to manual checking for older bash versions
if [ -n "$BASH_VERSION" ] && ( [ "${BASH_VERSINFO[0]}" -gt 4 ] || ( [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -ge 3 ] ) ); then
    # Use wait -n for bash 4.3+
    echo "Using wait -n to monitor processes..."
    wait -n "$ZT_PID" "$ZTNCUI_PID"
else
    # Fallback for older bash versions
    echo "Using manual process monitoring..."
    while kill -0 "$ZT_PID" 2>/dev/null && kill -0 "$ZTNCUI_PID" 2>/dev/null; do
        sleep 1
    done
fi

# Check which process died
if ! kill -0 "$ZT_PID" 2>/dev/null; then
    echo "ZeroTier process died (PID: $ZT_PID)"
fi
if ! kill -0 "$ZTNCUI_PID" 2>/dev/null; then
    echo "ztncui process died (PID: $ZTNCUI_PID)"
fi

# Cleanup and script will naturally exit
cleanup
