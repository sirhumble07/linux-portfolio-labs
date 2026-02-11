# Cleanup Guide: Docker Fundamentals Lab

This guide covers how to clean up resources created during the lab.

---

## Quick Cleanup (Remove Everything)

If you want to remove all lab resources at once:

```bash
# Stop and remove container
docker stop lab-db
docker rm lab-db

# Remove network
docker network rm labnet

# Remove volume (WARNING: deletes all data)
docker volume rm labdata

# Remove PostgreSQL image (optional, saves disk space)
docker rmi postgres:16
```

### Verify cleanup

```bash
docker ps -a
docker network ls
docker volume ls
docker images
```

---

## Step-by-Step Cleanup

### 1. Stop and Remove Container

```bash
# Stop the container
docker stop lab-db

# Remove the container
docker rm lab-db

# Verify
docker ps -a | grep lab-db
```

**Expected:** No output (container is gone)

---

### 2. Remove Custom Network

```bash
# Remove network
docker network rm labnet

# Verify
docker network ls | grep labnet
```

**Expected:** No output (network is gone)

---

### 3. Remove Volume (Data Will Be Lost)

⚠️ **Warning:** This deletes all PostgreSQL data permanently.

```bash
# Remove volume
docker volume rm labdata

# Verify
docker volume ls | grep labdata
```

**Expected:** No output (volume is gone)

---

### 4. Remove Docker Image (Optional)

This frees up disk space but will require re-download if you run the lab again.

```bash
# Check image size first
docker images postgres:16

# Remove image
docker rmi postgres:16

# Verify
docker images | grep postgres
```

**Expected:** No output (image is gone)

---

## Partial Cleanup (Keep Some Resources)

### Keep Volume, Remove Container

Useful if you want to preserve data but stop the container:

```bash
docker stop lab-db
docker rm lab-db
# Volume 'labdata' still exists with data intact
```

### Keep Image, Remove Container

Useful to avoid re-downloading the image later:

```bash
docker stop lab-db
docker rm lab-db
docker network rm labnet
docker volume rm labdata
# Image 'postgres:16' remains cached
```

---

## Check Disk Space Usage

### Before cleanup

```bash
docker system df
```

### After cleanup

```bash
docker system df
```

**Compare:**

- Images space freed
- Containers space freed
- Volumes space freed

---

## Nuclear Option: Remove All Docker Resources

⚠️ **DANGER:** This removes **ALL** Docker resources on your system, not just this lab.

```bash
# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Remove all volumes
docker volume rm $(docker volume ls -q)

# Remove all networks (except defaults)
docker network prune -f

# Remove all unused resources
docker system prune -a --volumes -f
```

**Use only if:**

- This is a dedicated lab machine
- You want to start completely fresh
- You understand this affects ALL Docker resources

---

## Uninstall Docker (Complete Removal)

If you want to remove Docker entirely from your system:

```bash
# Stop Docker service
sudo systemctl stop docker

# Remove Docker packages
sudo apt remove -y docker.io

# Remove Docker data directory (WARNING: deletes everything)
sudo rm -rf /var/lib/docker

# Remove user from docker group
sudo deluser $USER docker

# Verify
which docker
groups | grep docker
```

**Expected:**

- `which docker` returns nothing
- `groups` does not show `docker`

---

## Troubleshooting Cleanup

### Container won't stop

```bash
# Force stop
docker stop -t 0 lab-db

# Force remove
docker rm -f lab-db
```

### Volume in use

```bash
# Check what's using it
docker ps -a --filter volume=labdata

# Stop containers using it first
docker stop <container-id>
docker rm <container-id>

# Then remove volume
docker volume rm labdata
```

### Network in use

```bash
# Check connected containers
docker network inspect labnet

# Disconnect containers first
docker network disconnect labnet <container-name>

# Then remove network
docker network rm labnet
```

### Permission denied errors

```bash
# Use sudo for system-level cleanup
sudo docker system prune -a --volumes -f
sudo rm -rf /var/lib/docker/volumes/labdata
```

---

## Post-Cleanup Verification

Run these commands to confirm everything is cleaned up:

```bash
# Should show no lab-related resources
docker ps -a
docker images
docker volume ls
docker network ls

# Should show reduced usage
docker system df
```

---

## Re-Running the Lab

After cleanup, you can re-run the lab from the beginning:

```bash
# Start from STEP 4 (assuming Docker is still installed)
docker network create labnet
docker volume create labdata
docker run -d \
  --name lab-db \
  --network labnet \
  -e POSTGRES_PASSWORD=labpass \
  -v labdata:/var/lib/postgresql/data \
  postgres:16
```

---

## Summary

**Safe cleanup** (recommended for this lab):

```bash
docker stop lab-db && docker rm lab-db
docker network rm labnet
docker volume rm labdata
```

**Keep image cached** (faster re-runs):

```bash
# Clean everything except the postgres:16 image
docker stop lab-db && docker rm lab-db
docker network rm labnet
docker volume rm labdata
docker images postgres:16  # Still there
```

**Complete removal** (free all disk space):

```bash
docker stop lab-db && docker rm lab-db
docker network rm labnet
docker volume rm labdata
docker rmi postgres:16
```
