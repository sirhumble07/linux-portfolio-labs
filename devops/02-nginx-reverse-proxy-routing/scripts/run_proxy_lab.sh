#!/usr/bin/env bash
set -euo pipefail

# This script sets up a simple nginx reverse proxy lab with two backend applications.
docker network create proxy-net >/dev/null 2>&1 || true 
docker rm -f app1 app2 nginx-proxy >/dev/null 2>&1 || true

# Using the official nginx demo app for simplicity. In a real lab, you could replace these with your own applications.
docker run -d --name app1 --network proxy-net nginxdemos/hello
docker run -d --name app2 --network proxy-net nginxdemos/hello

# The nginx configuration file should define the reverse proxy rules. For example:
# server {
#     listen 80;
#     location /app1/ {
#         proxy_pass http://app1:80/;
#     }
#     location /app2/ {
#         proxy_pass http://app2:80/;
#     }
# }

# Make sure to create the nginx/default.conf file with the above content before running this script.
echo "Make sure nginx/default.conf exists in the current folder."
docker run -d \
  --name nginx-proxy \
  --network proxy-net \
  -p 80:80 \
  -v "$(pwd)/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro" \
  nginx:alpine

# Wait for the containers to start
docker ps
echo "Test: curl http://localhost/app1/ and /app2/"
