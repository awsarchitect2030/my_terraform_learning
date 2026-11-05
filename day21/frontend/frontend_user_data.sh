#!/bin/bash
# Frontend deployment script - Simplified version
set -e
exec > >(tee -a /var/log/user-data.log) 2>&1

echo "=== Frontend Deployment Started at $(date) ==="

# Update and install dependencies
echo "Installing system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y docker.io curl unzip netcat-openbsd

# Start Docker
echo "Starting Docker service..."
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Backend URL
BACKEND_URL="${backend_internal_url}"
echo "Backend URL: $BACKEND_URL"

# Verify backend connectivity before starting frontend
echo "Verifying backend connectivity..."

# Pull Docker image
echo "Pulling frontend image: ${docker_image}"
docker pull "${docker_image}"

# Extract hostname and port for connectivity test
BACKEND_HOST=$(echo "$BACKEND_URL" | sed -e 's|^[^/]*//||' -e 's|:.*$||' -e 's|/.*$||')
BACKEND_PORT=8080

echo "Testing backend connectivity at $BACKEND_HOST:$BACKEND_PORT..."
for i in {1..30}; do
    if nc -z -w 3 "$BACKEND_HOST" "$BACKEND_PORT" 2>/dev/null; then
        echo "✓ Backend is reachable"
        break
    fi

    if [ "$i" -eq 30 ]; then
        echo "ERROR: Backend is unreachable after 30 attempts"
        exit 1
    fi

    echo "Waiting for backend... ($i/30)"
    sleep 10
done

# Run frontend container
echo "Starting frontend container on port 3000..."
docker run -d \
  --name goal-tracker-frontend \
  --restart unless-stopped \
  -p 3000:3000 \
  -e PORT=3000 \
  -e BACKEND_URL="$BACKEND_URL" \
  -e NODE_ENV=production \
  "${docker_image}"

# Verify container is running
sleep 5
if docker ps | grep -q goal-tracker-frontend; then
    echo "✓ Frontend container is running"
    docker logs goal-tracker-frontend
else
    echo "✗ Frontend container failed to start"
    docker logs goal-tracker-frontend
    exit 1
fi

echo "=== Frontend Deployment Completed at $(date) ==="