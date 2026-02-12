#!/bin/bash

# Nginx Reverse Proxy Lab - Quick Start Script
# This script automates the setup of backend services and reverse proxy

set -e  # Exit on error

echo "=================================="
echo "Starting Nginx Reverse Proxy Lab"
echo "=================================="
echo ""

# Step 1: Create Docker Network
echo "Creating Docker network: proxy-net"
if docker network inspect proxy-net >/dev/null 2>&1; then
    echo "Network 'proxy-net' already exists. Skipping creation."
else
    docker network create proxy-net
    echo "Network 'proxy-net' created successfully"
fi
echo ""

# Step 2: Start Backend App1
echo "Starting backend service: app1"
if docker ps -a --format '{{.Names}}' | grep -q "^app1$"; then
    echo "⚠️  Container 'app1' already exists. Removing old container..."
    docker rm -f app1 >/dev/null 2>&1
fi
docker run -d \
  --name app1 \
  --network proxy-net \
  nginxdemos/hello
echo "app1 started successfully"
echo ""

# Step 3: Start Backend App2
echo "🚀 Starting backend service: app2"
if docker ps -a --format '{{.Names}}' | grep -q "^app2$"; then
    echo "⚠️  Container 'app2' already exists. Removing old container..."
    docker rm -f app2 >/dev/null 2>&1
fi
docker run -d \
  --name app2 \
  --network proxy-net \
  nginxdemos/hello
echo "app2 started successfully"
echo ""

# Step 4: Create Nginx Config Directory
echo "Creating nginx configuration directory"
mkdir -p nginx
echo "Directory created"
echo ""

# Step 5: Create Nginx Configuration File
echo "Creating nginx configuration file"
cat > nginx/default.conf << 'EOF'
server {
    listen 80;

    location /app1/ {
        proxy_pass http://app1/;
    }

    location /app2/ {
        proxy_pass http://app2/;
    }
}
EOF
echo "Configuration file created: nginx/default.conf"
echo ""

# Step 6: Start Nginx Reverse Proxy
echo "Starting nginx reverse proxy"
if docker ps -a --format '{{.Names}}' | grep -q "^nginx-proxy$"; then
    echo "⚠️  Container 'nginx-proxy' already exists. Removing old container..."
    docker rm -f nginx-proxy >/dev/null 2>&1
fi
docker run -d \
  --name nginx-proxy \
  --network proxy-net \
  -p 80:80 \
  -v "$(pwd)/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro" \
  nginx:alpine
echo "✅ nginx-proxy started successfully"
echo ""

# Step 7: Wait for services to be ready
echo "Waiting for services to initialize..."
sleep 3
echo ""

# Step 8: Verify Setup
echo "=================================="
echo "Verifying Setup"
echo "=================================="
echo ""

echo "Running Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAMES|nginx-proxy|app1|app2"
echo ""

echo "Docker Network:"
docker network inspect proxy-net --format '{{.Name}}: {{len .Containers}} containers connected'
echo ""

# Step 9: Test Services
echo "=================================="
echo "Testing Services"
echo "=================================="
echo ""

echo "Testing /app1/ endpoint:"
if curl -s -o /dev/null -w "%{http_code}" http://localhost/app1/ | grep -q "200"; then
    echo "✅ app1 is responding (HTTP 200)"
else
    echo "❌ app1 failed to respond"
fi
echo ""

echo "Testing /app2/ endpoint:"
if curl -s -o /dev/null -w "%{http_code}" http://localhost/app2/ | grep -q "200"; then
    echo "✅ app2 is responding (HTTP 200)"
else
    echo "❌ app2 failed to respond"
fi
echo ""

# Final Summary
echo "=================================="
echo "Setup Complete!"
echo "=================================="
echo ""
echo "Your reverse proxy is now running!"
echo ""
echo "Test the services:"
echo "   curl http://localhost/app1/"
echo "   curl http://localhost/app2/"
echo ""
echo "Or open in browser:"
echo "   http://localhost/app1/"
echo "   http://localhost/app2/"
echo ""
echo "View container logs:"
echo "   docker logs nginx-proxy"
echo "   docker logs app1"
echo "   docker logs app2"
echo ""
echo "To clean up when done:"
echo "   ./scripts/cleanup.sh"
echo ""
echo "=================================="