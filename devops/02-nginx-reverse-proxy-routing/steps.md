# Nginx Reverse Proxy Lab: Path-Based Routing

## Overview

This lab demonstrates professional reverse proxy configuration including:

- Path-based routing with Nginx
- Backend service isolation
- Docker networking and DNS
- Load balancer troubleshooting techniques
- Production-ready proxy patterns

---

## STEP 0 — Lab Prerequisites

You should already have:

- Docker installed
- Non-root docker access
- Familiarity with networks & containers (Lab 1)

**Confirm environment:**

```bash
docker ps
docker network ls
```

**Expected output:**

- `docker ps` runs without sudo
- Default Docker networks visible (bridge, host, none)

---

## STEP 1 — Create a Dedicated Docker Network

We do not use the default bridge in real setups.

```bash
docker network create proxy-net
```

### Verify Network Creation

```bash
docker network inspect proxy-net
```

**Expected output:**

- Custom bridge network created
- Subnet and gateway assigned
- Driver: bridge

📸 **Screenshot:** `docker network inspect proxy-net`

---

## STEP 2 — Create Backend Application Containers

We'll use `nginxdemos/hello` because:

- It's lightweight
- It clearly shows which container handled the request
- Perfect for routing demos

### Run App 1

```bash
docker run -d \
  --name app1 \
  --network proxy-net \
  nginxdemos/hello
```

### Run App 2

```bash
docker run -d \
  --name app2 \
  --network proxy-net \
  nginxdemos/hello
```

### Verify Containers Are Running

```bash
docker ps
```

**Expected output:**

- Both `app1` and `app2` containers running
- Connected to `proxy-net`
- No host port mappings (isolated)

📸 **Screenshot:** `docker ps` showing app1 and app2

### 🔍 Important Concept

Docker provides internal DNS:

- Containers can reach each other by **container name**
- `app1:80` works inside the network
- No need for IP address management
- **This is huge for DevOps**

---

## STEP 3 — Test Backend Services Internally

### Test app1

```bash
docker run --rm \
  --network proxy-net \
  curlimages/curl \
  http://app1
```

### Test app2

```bash
docker run --rm \
  --network proxy-net \
  curlimages/curl \
  http://app2
```

**Expected output:**

- HTML response from each container
- Response includes container hostname
- Confirms Docker DNS resolution works

📸 **Screenshot:** curl output for app1 and app2

---

## STEP 4 — Create Nginx Reverse Proxy Config

### Create directory

```bash
mkdir -p nginx
```

### Create file: nginx/default.conf

```nginx
server {
    listen 80;

    location /app1/ {
        proxy_pass http://app1/;
    }

    location /app2/ {
        proxy_pass http://app2/;
    }
}
```

### 🔍 Line-by-Line Explanation (Interview Critical)

| Line | Explanation |
| ------ | ------------- |
| `listen 80;` | Nginx listens on HTTP port 80 |
| `location /app1/` | URL path-based routing (matches requests to `/app1/`) |
| `proxy_pass http://app1/;` | Forwards traffic to container `app1` using Docker DNS |

**This is the same concept as:**

- Kubernetes Ingress Controllers
- Azure Application Gateway path-based routing
- AWS Application Load Balancer (ALB) path rules

📸 **Screenshot:** nginx config file contents

---

## STEP 5 — Run Nginx Reverse Proxy Container

```bash
docker run -d \
  --name nginx-proxy \
  --network proxy-net \
  -p 80:80 \
  -v $(pwd)/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro \
  nginx:alpine
```

### Line-by-Line Explanation

| Flag | Purpose |
| ------ | --------- |
| `-p 80:80` | Expose **only** the proxy to host port 80 |
| `-v $(pwd)/nginx/...` | Mount config file into container |
| `:ro` | Read-only mount (security best practice) |
| `nginx:alpine` | Lightweight Nginx image |

**Key security concept:**

- Backend containers (`app1`, `app2`) are **not exposed** to host
- Only the reverse proxy is accessible

### Validate

```bash
docker ps
```

**Expected output:**

- `nginx-proxy` running on port 80
- `app1` and `app2` have no port mappings

📸 **Screenshot:** `docker ps` showing nginx-proxy

---

## STEP 6 — Test Routing from Host Machine

From your Linux host (or browser):

```bash
curl http://localhost/app1/
curl http://localhost/app2/
```

**Expected output:**

- `/app1/` shows response from `app1` container
- `/app2/` shows response from `app2` container
- Each response includes the container hostname

📸 **Screenshot:** curl output for both routes

---

## STEP 7 — Prove Backend Isolation (VERY IMPORTANT)

### Try accessing backends directly from host

```bash
curl http://localhost:80
curl http://localhost:8080
```

**Expected behavior:**

- ✅ Port 80 responds (nginx-proxy)
- ❌ No other ports respond
- ❌ No direct backend exposure

### Why This Matters

**Only the reverse proxy is exposed, reducing attack surface.**

In production:

- Backends run in private subnets
- Only load balancer/proxy is internet-facing
- Defense in depth security model

📸 **Screenshot:** Successful proxy access, failed direct backend access

---

## STEP 8 — Troubleshooting Drill (REAL DEVOPS SKILL)

### Break it on purpose

Stop app1:

```bash
docker stop app1
```

### Test the broken service

```bash
curl http://localhost/app1/
```

**Expected output:**

- `502 Bad Gateway` error
- This is how Nginx responds when upstream is unreachable

### Check logs

```bash
docker logs nginx-proxy | tail -n 30
```

**What to look for:**

- `connect() failed` errors
- `upstream timed out` messages
- Connection refused to `app1:80`

### Restart app1

```bash
docker start app1
```

### Re-test

```bash
curl http://localhost/app1/
```

**Expected output:**

- Service restored
- Normal HTTP 200 response

📸 **Screenshots:**

- 502 error message
- nginx-proxy logs showing connection failure
- Restored service after restart

---

## What You Learned

**Technical skills:**

✅ Path-based routing with Nginx  
✅ Docker DNS for service discovery  
✅ Backend isolation (security)  
✅ Reverse proxy configuration  
✅ Troubleshooting 502 errors  
✅ Read-only volume mounts  

**Interview talking points:**

- **"I configured Nginx as a reverse proxy with path-based routing, similar to Kubernetes Ingress or AWS ALB"**
- **"I isolated backend services by only exposing the proxy, reducing attack surface"**
- **"I used Docker's internal DNS for service discovery, avoiding hardcoded IPs"**
- **"I troubleshot 502 errors by analyzing proxy logs and upstream connectivity"**

---

## Architecture Diagram

```text
        ┌──────────────────────┐
        │   Host Machine       │
        │   Port 80 exposed    │
        └──────────┬───────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │   nginx-proxy        │
        │   (0.0.0.0:80)       │
        │   Path routing:      │
        │   /app1/ → app1      │
        │   /app2/ → app2      │
        └──────────┬───────────┘
                   │
        ┌──────────┴──────────┐
        │    proxy-net        │
        │  (Docker network)   │
        └──────────┬──────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
    ┌───▼──────┐      ┌───▼──────┐
    │  app1    │      │  app2    │
    │ (no port)│      │ (no port)│
    │ isolated │      │ isolated │
    └──────────┘      └──────────┘
```

---

## Next Steps

- Add more backend services (app3, app4)
- Implement health checks in Nginx
- Add SSL/TLS termination
- Configure load balancing (round-robin)
- Add caching headers
- Implement rate limiting
