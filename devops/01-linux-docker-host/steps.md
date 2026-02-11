# Docker Fundamentals Lab: Container Lifecycle & Persistence

## Overview

This lab demonstrates professional Docker operations including:

- Proper Docker installation and configuration
- Network isolation and container communication
- Data persistence with volumes
- Database container management
- Container lifecycle operations

---

## STEP 0 — Lab Environment Assumptions

**Prerequisites:**

- OS: Ubuntu Server 22.04+
- User has sudo access
- Internet access available

**Confirm environment:**

```bash
lsb_release -a
whoami
sudo -v
```

**Expected output:**

- Ubuntu version confirmed
- Current user shown
- Sudo password accepted (or cached)

📸 **Screenshot:** OS info + sudo confirmation

---

## STEP 1 — Install Docker Engine (Proper Way)

### Update system

```bash
sudo apt update && sudo apt -y upgrade
```

### Install Docker

```bash
sudo apt -y install docker.io
```

### Enable and start Docker

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

### Validate installation

```bash
docker --version
systemctl status docker --no-pager
```

**Expected output:**

- Docker version displayed (e.g., Docker version 24.x.x)
- Service status = `active (running)`

📸 **Screenshot:**

- `docker --version`
- `systemctl status docker`

### What Docker Actually Is (Important)

- **Docker daemon (dockerd)** runs as root
- **Docker CLI (docker)** talks to the daemon via socket
- **Containers** are Linux processes with isolation (namespaces + cgroups)
- Not VMs — they share the host kernel

---

## STEP 2 — Allow Non-Root Docker Usage (Industry Standard)

By default, Docker requires sudo. In real teams, engineers use the `docker` group.

### Add user to docker group

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Validate group membership

```bash
groups
docker ps
```

**Expected output:**

- `groups` shows `docker` in the list
- `docker ps` runs without sudo (may show empty list initially)

📸 **Screenshot:**

- `groups` showing docker
- `docker ps` running without sudo

### ⚠️ Security Note (Important for Interviews)

Adding users to the `docker` group is **equivalent to root access**:

- Users can mount any host directory
- Users can run privileged containers
- This is acceptable for DevOps engineers on controlled systems
- Production servers should use stricter controls

---

## STEP 3 — Understand Docker Objects (Before Running Anything)

### Inspect Docker system

```bash
docker info
```

**Key sections to note:**

- **Containers:** How many are running/stopped
- **Images:** Cached container templates
- **Storage Driver:** How container filesystems work (overlay2)
- **Cgroup Driver:** Resource limits (systemd or cgroupfs)

📸 **Screenshot:** `docker info` summary

---

## STEP 4 — Create a Custom Docker Network

```bash
docker network create labnet
```

### Why This Matters

Containers on the same custom network:

- ✅ Can communicate using **container names** (DNS resolution)
- ✅ Are isolated from the default bridge network
- ✅ Mirror real microservice networking patterns

### Validate network creation

```bash
docker network ls
docker network inspect labnet
```

**Expected output:**

- `labnet` appears in network list
- Inspect shows subnet, gateway, and driver info

📸 **Screenshot:** `docker network inspect labnet`

---

## STEP 5 — Create a Named Docker Volume (Data Persistence)

```bash
docker volume create labdata
```

### Why Volumes Matter

- **Containers are ephemeral** — data inside them is lost on deletion
- **Volumes survive** container deletion
- **Databases must use volumes** to persist data
- Volumes are stored in `/var/lib/docker/volumes/`

### Validate volume creation

```bash
docker volume ls
docker volume inspect labdata
```

**Expected output:**

- `labdata` appears in volume list
- Inspect shows mountpoint on host filesystem

📸 **Screenshot:** `docker volume inspect labdata`

---

## STEP 6 — Run a Database Container (PostgreSQL)

We'll run PostgreSQL because it's realistic and stateful.

```bash
docker run -d \
  --name lab-db \
  --network labnet \
  -e POSTGRES_PASSWORD=labpass \
  -v labdata:/var/lib/postgresql/data \
  postgres:16
```

### Line-by-Line Explanation

| Flag | Purpose |
| ------ | --------- |
| `-d` | Detached mode (runs in background) |
| `--name lab-db` | Predictable container name |
| `--network labnet` | Attach to custom network |
| `-e POSTGRES_PASSWORD=labpass` | Set environment variable (DB password) |
| `-v labdata:/var/lib/postgresql/data` | Mount volume for persistent storage |
| `postgres:16` | Official PostgreSQL image, version 16 |

### Validate

```bash
docker ps
docker logs lab-db | head -n 30
```

**Expected output:**

- `docker ps` shows `lab-db` container running
- Logs show PostgreSQL initialization messages

📸 **Screenshot:**

- `docker ps`
- PostgreSQL startup logs

---

## STEP 7 — Prove Persistence (CRITICAL)

### Restart the container

```bash
docker restart lab-db
```

### Check logs again

```bash
docker logs lab-db | tail -n 30
```

**Expected behavior:**

- ❌ No re-initialization of database
- ❌ No "initdb" messages
- ✅ PostgreSQL starts using existing data

### This Proves

Data lives in the **volume**, not the **container**.

**Screenshot:** Logs after restart (showing no re-initialization)

---

## STEP 8 — Inspect Runtime Details (Real DevOps Skill)

### Full container inspection

```bash
docker inspect lab-db | less
```

**Look for:**

- **NetworkSettings → Networks → labnet:** Confirms network attachment
- **Mounts → labdata:** Confirms volume is mounted
- **IPAddress:** Container's IP on labnet

### Optional: Enter the container

```bash
docker exec -it lab-db bash
ls /var/lib/postgresql/data
exit
```

**Inside the container:**

- You'll see PostgreSQL data files (base/, pg_wal/, etc.)

**Screenshot:**

- `docker inspect` mounts/network section
- Inside container filesystem

---

## STEP 9 — Cleanup Test (But Keep Volume)

### Stop and remove container

```bash
docker stop lab-db
docker rm lab-db
```

### Verify container is gone

```bash
docker ps -a
```

### Re-run container using same volume

```bash
docker run -d \
  --name lab-db \
  --network labnet \
  -e POSTGRES_PASSWORD=labpass \
  -v labdata:/var/lib/postgresql/data \
  postgres:16
```

### Validate data persistence

```bash
docker logs lab-db | tail -n 20
```

**Expected output:**

- ✅ Database starts using **existing data**
- ❌ No "initdb" in logs
- This proves volume data survived container deletion

📸 **Screenshot:** Logs showing database using existing data

---

## Summary

**What you learned:**

✅ Install and configure Docker properly  
✅ Use custom networks for container isolation  
✅ Use volumes for data persistence  
✅ Run stateful services (PostgreSQL)  
✅ Understand container lifecycle vs. data lifecycle  
✅ Inspect runtime configurations  

**Key takeaways for interviews:**

- Containers are **ephemeral** — volumes are **persistent**
- Custom networks enable **DNS-based service discovery**
- Docker group membership = **root access** (understand the security implications)
- `docker inspect` reveals all runtime details

---

## Cleanup (Optional)

### Remove everything

```bash
docker stop lab-db
docker rm lab-db
docker network rm labnet
docker volume rm labdata
```

### Verify cleanup

```bash
docker ps -a
docker network ls
docker volume ls
```
