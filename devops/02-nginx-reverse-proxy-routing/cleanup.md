# Cleanup Guide

## Overview

This guide walks you through properly cleaning up all resources created during the Nginx Reverse Proxy Lab.

---

## Step 1: Stop All Running Containers

Stop the containers gracefully:

```bash
docker stop nginx-proxy app1 app2
```

**Expected output:**

```text
nginx-proxy
app1
app2
```

### Verify containers are stopped

```bash
docker ps -a | grep -E "nginx-proxy|app1|app2"
```

**Expected output:**

- All three containers should show status as "Exited"

---

## Step 2: Remove Containers

Remove the stopped containers:

```bash
docker rm nginx-proxy app1 app2
```

**Expected output:**

```text
nginx-proxy
app1
app2
```

### Verify containers are removed

```bash
docker ps -a | grep -E "nginx-proxy|app1|app2"
```

**Expected output:**

- No output (containers are gone)

---

## Step 3: Remove Docker Network

Remove the custom network:

```bash
docker network rm proxy-net
```

**Expected output:**

```text
proxy-net
```

### Verify network is removed

```bash
docker network ls | grep proxy-net
```

**Expected output:**

- No output (network is gone)

---

## Step 4: Remove Nginx Configuration (Optional)

If you want to remove the nginx configuration directory:

```bash
rm -rf nginx/
```

**Note:** Only do this if you don't need the configuration for reference or future labs.

---

## Step 5: Verify Complete Cleanup

Run a comprehensive check:

```bash
echo "=== Docker Containers ==="
docker ps -a | grep -E "nginx-proxy|app1|app2"
echo ""
echo "=== Docker Networks ==="
docker network ls | grep proxy-net
echo ""
echo "=== Cleanup Complete ==="
```

**Expected output:**

```text
=== Docker Containers ===

=== Docker Networks ===

=== Cleanup Complete ===
```

---

## Quick Cleanup (One-Liner)

If you want to clean everything up quickly:

```bash
docker stop nginx-proxy app1 app2 && \
docker rm nginx-proxy app1 app2 && \
docker network rm proxy-net && \
echo "Cleanup complete!"
```

---

## Troubleshooting

### Container won't stop

If a container won't stop gracefully, force stop it:

```bash
docker kill <container-name>
```

### Container won't remove

If you get "container is running" error:

```bash
docker rm -f <container-name>
```

### Network won't remove

If you get "network has active endpoints" error:

```bash
# List containers on the network
docker network inspect proxy-net

# Stop and remove any remaining containers
docker stop <container-id>
docker rm <container-id>

# Try removing network again
docker network rm proxy-net
```

---

## What Gets Cleaned Up

✅ nginx-proxy container  
✅ app1 container  
✅ app2 container  
✅ proxy-net Docker network  

## What Remains (Intentionally)

- Docker images (nginx:alpine, nginxdemos/hello, curlimages/curl)
- nginx/default.conf file (for reference)
- Screenshots taken during the lab

---

## Removing Docker Images (Optional)

If you want to remove the images used in this lab:

```bash
docker rmi nginx:alpine
docker rmi nginxdemos/hello
docker rmi curlimages/curl
```

**Warning:** Only remove images if you don't need them for other projects.

---

## Complete System Cleanup (Nuclear Option)

⚠️ **WARNING:** This removes ALL Docker resources on your system!

```bash
# Remove all stopped containers
docker container prune -f

# Remove all unused networks
docker network prune -f

# Remove all unused images
docker image prune -a -f

# Remove all unused volumes
docker volume prune -f
```

**Use with extreme caution!**

---

## Verify Clean State

After cleanup, verify your Docker environment is clean:

```bash
docker ps -a
docker network ls
docker images
```

You should see:

- Only default Docker networks (bridge, host, none)
- No lab-specific containers
- Base images may remain (optional to keep)

---

## Next Steps

After cleanup:

- Review your screenshots and documentation
- Update your portfolio with findings
- Consider running the lab again for practice
- Move on to the next lab in the series

---

## Questions or Issues?

If you encounter cleanup issues:

1. Check for running processes using `docker ps`
2. Inspect network connections with `docker network inspect`
3. Review Docker logs with `docker logs <container-name>`
4. Use force flags (`-f`) if necessary for stuck resources

---

**Cleanup complete! Your system is ready for the next lab.**
