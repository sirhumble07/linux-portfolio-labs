# Self-Hosted GitHub Actions Runner Lab

## Overview

This lab demonstrates how to configure and manage a self-hosted GitHub Actions runner on a Linux VM. You'll learn how enterprise CI/CD pipelines work by running GitHub Actions workflows on your own infrastructure instead of GitHub's shared runners.

**Skills demonstrated:**

- CI/CD infrastructure setup
- GitHub Actions runner configuration
- Linux service management
- Docker integration with CI/CD
- Runner troubleshooting and monitoring

---

## STEP 0 — Prerequisites

### Requirements

You need:

- A Linux VM (Azure VM, AWS EC2, or local VM)
- Docker installed (from DevOps Lab 1)
- A GitHub repository you control
- SSH access to your VM
- Basic understanding of Git and GitHub

### Verify Environment

SSH into your VM and confirm:

```bash
docker --version
uname -a
```

**Expected output:**

```text
Docker version 24.0.x or higher
Linux kernel information with your VM hostname
```

📸 **Screenshot:** Docker version and OS info

---

## STEP 1 — Understand CI Architecture (IMPORTANT)

### How Self-Hosted Runners Work

Before touching commands, understand the architecture:

```text
┌─────────────────────┐
│   GitHub Repo       │
│   (.github/         │
│    workflows/)      │
└──────────┬──────────┘
           │
           │ (job request via API)
           │
           ▼
┌─────────────────────┐
│ Self-Hosted Runner  │
│ (your Linux VM)     │
│                     │
│ - Pulls job         │
│ - Executes steps    │
│ - Reports results   │
└──────────┬──────────┘
           │
           │ (uses local resources)
           │
           ▼
┌─────────────────────┐
│   Docker Engine     │
│   Local Tools       │
│   Build Environment │
└─────────────────────┘
```

### Key Concepts

**Critical points to understand:**

| Point | Explanation |
| ----- | ----------- |
| GitHub does NOT run the job | Your VM executes everything locally |
| Runner must be online | If VM is down → pipeline fails |
| Enterprise pattern | This is how companies run CI/CD |
| Resource control | You control CPU, RAM, disk, network |
| Security model | Runner has full VM access |

### Comparison: GitHub-Hosted vs Self-Hosted

| Feature | GitHub-Hosted | Self-Hosted |
| ------- | ------------- | ----------- |
| Cost | Minutes-based billing | Your infrastructure cost |
| Control | Limited | Full control |
| Customization | Standard images | Custom everything |
| Security | Isolated | Your responsibility |
| Speed | Variable | Consistent (your hardware) |

**When to use self-hosted:**

- Need specific hardware (GPU, large RAM)
- Corporate security requirements
- Access to internal resources
- Cost optimization for heavy usage
- Custom build tools or dependencies

---

## STEP 2 — Create a GitHub Actions Runner Token

### Navigate to Runner Settings

1. Go to your GitHub repository
2. Click **Settings** (top navigation)
3. In left sidebar: **Actions** → **Runners**
4. Click **New self-hosted runner** (green button)

### Configure Runner Parameters

Select:

- **Operating System:** Linux
- **Architecture:** x64

### Important Notes

⚠️ **Security Alert:**

- The token shown is sensitive
- It authenticates your runner with GitHub
- Token expires after 1 hour if unused
- Each runner needs a unique token

**Leave this page open** — you'll use the commands in the next steps.

📸 **Screenshot:** Runner registration page (token partially visible/redacted)

---

## STEP 3 — Prepare Runner Directory on Linux VM

### Create Dedicated Directory

SSH into your VM:

```bash
# Create runner directory
mkdir -p ~/actions-runner
cd ~/actions-runner

# Verify location
pwd
```

**Expected output:**

```text
/home/your-username/actions-runner
```

### Why a Dedicated Directory?

- **Organization:** Keeps runner files isolated
- **Permissions:** Easier to manage access
- **Updates:** Simple to upgrade or reinstall
- **Backups:** Clear boundary for what to back up

📸 **Screenshot:** Terminal showing runner directory path

---

## STEP 4 — Download and Extract Runner

### Get Latest Runner Version

⚠️ **Important:** Use the exact version shown in your GitHub UI. The example below may be outdated.

**From your GitHub runner setup page, copy the download command:**

```bash
# Example (your version may differ)
curl -o actions-runner-linux-x64.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz
```

### Extract Archive

```bash
tar xzf actions-runner-linux-x64.tar.gz
```

### Validate Installation

```bash
ls -la
```

**Expected files:**

```text
config.sh       # Configuration script
run.sh          # Foreground runner
svc.sh          # Service management
bin/            # Runner binaries
externals/      # Dependencies
_diag/          # Diagnostics
```

### Verify Executables

```bash
# Check permissions
ls -lh *.sh

# Should show executable permissions (-rwxr-xr-x)
```

📸 **Screenshot:** Extracted runner files with permissions

---

## STEP 5 — Register the Runner (CRITICAL STEP)

### Understanding Registration

Registration connects your VM to your GitHub repository. This is a **one-time setup** that:

- Authenticates the runner
- Assigns labels for job targeting
- Configures work directory
- Establishes secure communication

### Run Configuration Script

From your GitHub setup page, copy the configuration command:

```bash
./config.sh \
  --url https://github.com/<YOUR-USERNAME>/<YOUR-REPO> \
  --token <RUNNER-TOKEN>
```

**Replace:**

- `<YOUR-USERNAME>` with your GitHub username
- `<YOUR-REPO>` with your repository name
- `<RUNNER-TOKEN>` with the token from GitHub UI

### Interactive Prompts

Answer the configuration prompts:

```text
Enter the name of the runner:
→ linux-runner-01

This runner will have the following labels: 'self-hosted', 'Linux', 'X64'
Enter any additional labels (ex. label-1,label-2):
→ devops,docker

Enter name of work folder:
→ [Press Enter for default: _work]
```

### Configuration Breakdown

| Prompt | Recommendation | Why |
| ------ | -------------- | --- |
| Runner name | `linux-runner-01` | Descriptive, allows multiple runners |
| Labels | `self-hosted,linux,devops,docker` | For job targeting in workflows |
| Work folder | Default (`_work`) | Standard location for job execution |

### Expected Output

```text
√ Runner successfully added
√ Runner connection is good
```

**What just happened:**

1. ✅ Your VM authenticated with GitHub
2. ✅ Runner is now registered and visible in GitHub UI
3. ✅ Configuration saved to `.runner` file
4. ⚠️ Runner is registered but NOT running yet

### Verify Registration in GitHub UI

Go back to your GitHub repo:

- **Settings** → **Actions** → **Runners**
- You should see your runner listed
- Status will show **Offline** (we haven't started it yet)

📸 **Screenshot:** Successful runner registration in terminal

📸 **Screenshot:** Runner visible in GitHub UI (showing offline status)

---

## STEP 6 — Start the Runner (Foreground Test)

### Why Start in Foreground First?

Before running as a service, test in foreground mode to:

- See real-time logs
- Verify connectivity
- Troubleshoot any issues
- Understand runner behavior

### Start Runner

```bash
./run.sh
```

**Expected output:**

```text
√ Connected to GitHub

Current runner version: 'x.xxx.x'
2024-02-13 10:30:45Z: Listening for Jobs
```

### What This Means

| Status | Explanation |
| ------ | ----------- |
| Connected to GitHub | SSL/TLS connection established |
| Listening for Jobs | Polling GitHub for workflow runs |
| Session started | Runner is active and ready |

### Monitor Runner Status

**In GitHub UI:**

1. Go to **Settings** → **Actions** → **Runners**
2. Runner should now show **Idle** (green indicator)

**In Terminal:**

- Leave the terminal open
- Runner will show activity when jobs execute

### 🔍 Understanding Runner States

```text
Offline (Gray)  → Runner not running or can't reach GitHub
Idle (Green)    → Running and waiting for jobs
Active (Yellow) → Executing a job
```

📸 **Screenshot:** Terminal showing "Listening for Jobs" message

📸 **Screenshot:** GitHub UI showing runner status as "Idle"

---

## STEP 7 — Create a CI Pipeline (Runs on YOUR VM)

### Understanding Workflow Targeting

To run jobs on your self-hosted runner, use:

```yaml
runs-on: self-hosted
```

This tells GitHub: "Send this job to my runner, not GitHub's shared runners."

### Create Workflow File

In your repository, create the following directory structure:

```bash
.github/
  └── workflows/
      └── ci.yml
```

### Workflow Content

Create `.github/workflows/ci.yml`:

```yaml
name: Self Hosted CI Test

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:  # Allows manual trigger

jobs:
  test:
    runs-on: self-hosted
    
    steps:
      - name: Show runner information
        run: |
          echo "=== Runner Information ==="
          echo "Hostname: $(hostname)"
          echo "User: $(whoami)"
          echo "Working Directory: $(pwd)"
          echo ""
          
      - name: Show system information
        run: |
          echo "=== System Information ==="
          echo "OS: $(cat /etc/os-release | grep PRETTY_NAME)"
          echo "Kernel: $(uname -r)"
          echo "Architecture: $(uname -m)"
          echo ""
          
      - name: Show Docker information
        run: |
          echo "=== Docker Information ==="
          docker --version
          docker info | grep -E "Server Version|Storage Driver|Operating System"
          echo ""
          
      - name: Test Docker functionality
        run: |
          echo "=== Testing Docker ==="
          docker run --rm hello-world
```

### Workflow Breakdown

| Step | Purpose | What It Proves |
| ---- | ------- | -------------- |
| Show runner info | Displays VM identity | Job runs on your VM, not GitHub's |
| Show system info | OS and kernel details | Environment visibility |
| Show Docker info | Docker availability | Docker integration works |
| Test Docker | Run a container | Full Docker functionality |

### Commit and Push

```bash
# Add the workflow file
git add .github/workflows/ci.yml

# Commit
git commit -m "Add self-hosted runner CI workflow"

# Push to main branch
git push origin main
```

📸 **Screenshot:** Workflow file in repository (GitHub UI)

---

## STEP 8 — Validate Job Execution (THIS IS THE PROOF)

### Monitor in GitHub UI

1. Go to your repository
2. Click **Actions** tab
3. You should see your workflow run starting

**Expected sequence:**

```text
Queued → In progress → Completed
```

### Examine Workflow Logs

Click on the workflow run to see detailed logs:

**Look for these key indicators:**

```text
Runner name: 'linux-runner-01'
Hostname: your-vm-hostname
User: your-username
Docker version: 24.0.x
```

### Verify on VM Terminal

**In your SSH session where `./run.sh` is running:**

You should see activity:

```text
2024-02-13 10:35:12Z: Running job: test
2024-02-13 10:35:15Z: Starting: Show runner information
2024-02-13 10:35:16Z: Finishing: Show runner information
...
2024-02-13 10:35:45Z: Job test completed with result: Succeeded
```

### 🎯 Success Criteria

Your job is successfully running on your self-hosted runner if:

✅ GitHub logs show your VM's hostname  
✅ Docker commands execute from your VM  
✅ Terminal shows job execution activity  
✅ Workflow completes successfully  

### Compare: Self-Hosted vs GitHub-Hosted

To see the difference, create a comparison workflow:

```yaml
name: Runner Comparison

on: workflow_dispatch

jobs:
  github-hosted:
    runs-on: ubuntu-latest
    steps:
      - name: Show GitHub runner info
        run: hostname
  
  self-hosted:
    runs-on: self-hosted
    steps:
      - name: Show self-hosted runner info
        run: hostname
```

Run both jobs and compare the hostnames!

📸 **Screenshot:** GitHub Actions workflow logs showing your VM details

📸 **Screenshot:** Runner terminal showing job execution activity

📸 **Screenshot:** Successful workflow run (green checkmark)

---

## STEP 9 — Run Runner as a Service (Production Mode)

### Why Use Service Mode?

| Foreground (`./run.sh`) | Service (`svc.sh`) |
| ----------------------- | ------------------- |
| ❌ Stops when SSH disconnects | ✅ Runs in background |
| ❌ Must be manually restarted | ✅ Auto-starts on boot |
| ✅ Good for testing | ✅ Production-ready |
| ✅ See logs in terminal | ✅ Managed by systemd |

### Stop Foreground Runner

In your terminal where the runner is running:

```bash
# Press Ctrl + C to stop
^C
```

**Expected output:**

```text
Runner listener exit with 0 return code, stop the service, no retry needed.
Exiting runner...
```

### Install as System Service

```bash
# Install the service (creates systemd unit)
sudo ./svc.sh install

# Start the service
sudo ./svc.sh start

# Enable auto-start on boot
sudo systemctl enable actions.runner.$(whoami).$(hostname).service
```

### Verify Service Status

```bash
# Check service status
sudo ./svc.sh status

# Alternative: use systemctl directly
sudo systemctl status actions.runner.*
```

**Expected output:**

```text
● actions.runner.username.hostname.service - GitHub Actions Runner
   Loaded: loaded
   Active: active (running)
   Main PID: 12345
```

### Service Management Commands

```bash
# Start service
sudo ./svc.sh start

# Stop service
sudo ./svc.sh stop

# Restart service
sudo ./svc.sh restart

# Check status
sudo ./svc.sh status

# Uninstall service (removes from systemd)
sudo ./svc.sh uninstall
```

### View Service Logs

```bash
# Real-time logs
sudo journalctl -u actions.runner.* -f

# Last 50 lines
sudo journalctl -u actions.runner.* -n 50

# Logs since boot
sudo journalctl -u actions.runner.* -b
```

#### Verify Service in GitHub UI

After starting the service:

1. Go to **Settings** → **Actions** → **Runners**
2. Runner should show **Idle** status
3. Trigger a workflow to confirm it works

📸 **Screenshot:** Service status output showing "active (running)"

📸 **Screenshot:** systemctl status output

---

## STEP 10 — Failure Test (Real-World Resilience Check)

### Why Test Failures?

In production, runners can fail due to:

- VM maintenance or reboots
- Network issues
- Service crashes
- Resource exhaustion

**You must know how to identify and recover from these scenarios.**

### Test 1: Offline Runner

#### Stop the Service

```bash
sudo ./svc.sh stop
```

#### Verify Runner Offline

In GitHub UI:

- **Settings** → **Actions** → **Runners**
- Runner should show **Offline** (gray indicator)

#### Trigger a Workflow

```bash
# Make a trivial change and push
echo "# Testing offline runner" >> README.md
git add README.md
git commit -m "Test offline runner behavior"
git push origin main
```

#### Observe Behavior

In GitHub Actions:

- Job status shows **Queued**
- Waiting for runner message appears
- Job will eventually timeout (default: 360 minutes)

**Expected log message:**

```text
Waiting for a runner to pick up this job...
No runners are online for this repository.
```

📸 **Screenshot:** Workflow stuck in "Queued" state

📸 **Screenshot:** GitHub showing "No runners online" message

#### Recover the Runner

```bash
# Start the service
sudo ./svc.sh start

# Verify it's running
sudo ./svc.sh status
```

#### Re-Run Failed Workflow

In GitHub Actions:

1. Click on the failed workflow run
2. Click **Re-run failed jobs**
3. Job should now execute successfully

📸 **Screenshot:** Successful workflow run after recovery

---

### Test 2: Service Crash Simulation

#### Simulate a Crash

```bash
# Find the runner process
ps aux | grep Runner.Listener

# Kill it forcefully (simulates crash)
sudo pkill -9 -f Runner.Listener
```

#### Check Service Recovery

```bash
# Check if systemd auto-restarts it
sudo ./svc.sh status

# View restart logs
sudo journalctl -u actions.runner.* -n 20
```

**Systemd should automatically restart the service.**

---

### Test 3: VM Reboot Resilience

#### Reboot the VM

```bash
sudo reboot
```

#### After Reboot

```bash
# SSH back in after VM restarts

# Check if runner started automatically
sudo ./svc.sh status

# Verify in GitHub UI
# Runner should be online (Idle)
```

#### Trigger Test Workflow

```bash
# Make a change and push
echo "# Test post-reboot" >> README.md
git add README.md
git commit -m "Test runner after reboot"
git push origin main
```

**Expected:** Workflow runs successfully without manual intervention.

📸 **Screenshot:** Runner online after reboot

📸 **Screenshot:** Successful workflow after reboot

---

## STEP 11 — Advanced Configuration

### Configure Runner Labels

Labels allow you to target specific runners in workflows.

#### Add Custom Labels

```bash
# Stop runner
sudo ./svc.sh stop

# Re-configure with new labels
./config.sh remove  # Remove old config
./config.sh \
  --url https://github.com/<YOUR-USERNAME>/<YOUR-REPO> \
  --token <NEW-TOKEN> \
  --labels self-hosted,linux,docker,gpu,production

# Restart service
sudo ./svc.sh start
```

#### Use Labels in Workflow

```yaml
jobs:
  gpu-job:
    runs-on: [self-hosted, gpu]
    steps:
      - name: Run GPU workload
        run: nvidia-smi
  
  docker-job:
    runs-on: [self-hosted, docker]
    steps:
      - name: Build Docker image
        run: docker build -t myapp .
```

---

### Set Runner Working Directory

Control where jobs execute:

```bash
./config.sh \
  --url https://github.com/<YOUR-USERNAME>/<YOUR-REPO> \
  --token <TOKEN> \
  --work /data/ci-builds
```

---

### Configure Runner as a User Service

Run as non-root user (more secure):

```bash
# Install as user service (no sudo)
./svc.sh install <username>

# Start as user service
./svc.sh start

# Check status
./svc.sh status
```

---

## STEP 12 — Monitoring and Maintenance

### Monitor Runner Health

#### Create Monitoring Script

```bash
cat > ~/monitor-runner.sh << 'EOF'
#!/bin/bash

RUNNER_SERVICE="actions.runner.$(whoami).$(hostname).service"

echo "=== Runner Status ==="
sudo systemctl is-active $RUNNER_SERVICE

echo ""
echo "=== Service Uptime ==="
sudo systemctl status $RUNNER_SERVICE | grep "Active:"

echo ""
echo "=== Recent Logs ==="
sudo journalctl -u $RUNNER_SERVICE -n 10 --no-pager

echo ""
echo "=== Disk Usage (Work Directory) ==="
du -sh ~/actions-runner/_work
EOF

chmod +x ~/monitor-runner.sh
```

#### Run Monitoring

```bash
./monitor-runner.sh
```

---

### Log Rotation

Configure log rotation to prevent disk space issues:

```bash
sudo tee /etc/logrotate.d/github-runner << 'EOF'
/home/*/actions-runner/_diag/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
EOF
```

---

### Update Runner

When new versions are released:

```bash
# Stop service
sudo ./svc.sh stop

# Remove old runner
./config.sh remove

# Download new version (check GitHub for latest)
curl -o actions-runner-linux-x64.tar.gz -L \
  https://github.com/actions/runner/releases/download/vX.XXX.X/actions-runner-linux-x64-X.XXX.X.tar.gz

# Extract
tar xzf actions-runner-linux-x64.tar.gz

# Re-configure
./config.sh --url <URL> --token <TOKEN>

# Reinstall and start service
sudo ./svc.sh install
sudo ./svc.sh start
```

---

## STEP 13 — Security Best Practices

### 1. Use Dedicated User Account

```bash
# Create dedicated user
sudo useradd -m -s /bin/bash github-runner

# Add to docker group
sudo usermod -aG docker github-runner

# Set up runner as that user
sudo su - github-runner
```

### 2. Limit Runner Permissions

```bash
# Don't give runner sudo access
# Use specific tool installations instead
```

### 3. Use Private Repositories Only

⚠️ **Warning:** Self-hosted runners on public repos can execute untrusted code!

**Best practice:** Only use self-hosted runners with private repositories.

### 4. Network Security

```bash
# Restrict outbound connections (firewall rules)
sudo ufw allow out 443/tcp  # HTTPS to GitHub
sudo ufw default deny outgoing
```

### 5. Secrets Management

```yaml
# Use GitHub Secrets for sensitive data
jobs:
  deploy:
    runs-on: self-hosted
    steps:
      - name: Deploy
        env:
          API_KEY: ${{ secrets.API_KEY }}
        run: ./deploy.sh
```

---

## STEP 14 — Troubleshooting Guide

### Problem: Runner Shows Offline

**Possible causes:**

1. Service not running
2. Network connectivity issues
3. Authentication token expired

**Solutions:**

```bash
# Check service
sudo ./svc.sh status

# Check network
curl -I https://github.com

# Check logs
sudo journalctl -u actions.runner.* -n 50

# Restart service
sudo ./svc.sh restart
```

---

### Problem: Jobs Queue But Don't Start

**Possible causes:**

1. Label mismatch in workflow
2. Runner at capacity (already running max jobs)
3. Runner crashed mid-job

**Solutions:**

```bash
# Verify labels match
./config.sh --help  # Shows current labels

# Check running jobs
ps aux | grep Runner

# Restart runner
sudo ./svc.sh restart
```

---

### Problem: Docker Permission Denied

**Cause:** Runner user not in docker group

**Solution:**

```bash
# Add user to docker group
sudo usermod -aG docker $(whoami)

# Restart runner service
sudo ./svc.sh restart

# Verify
docker ps
```

---

### Problem: Disk Space Full

**Cause:** Old job artifacts and Docker images

**Solution:**

```bash
# Clean runner work directory
rm -rf ~/actions-runner/_work/*

# Clean Docker
docker system prune -af

# Check disk space
df -h
```

---

## STEP 15 — Real-World Use Cases

### Use Case 1: Building Docker Images

```yaml
name: Build Docker Image

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker image
        run: |
          docker build -t myapp:${{ github.sha }} .
          docker tag myapp:${{ github.sha }} myapp:latest
      
      - name: Push to registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker push myapp:${{ github.sha }}
          docker push myapp:latest
```

---

### Use Case 2: Running Integration Tests

```yaml
name: Integration Tests

on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: self-hosted
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: testpass
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run integration tests
        env:
          DATABASE_URL: postgresql://postgres:testpass@postgres:5432/testdb
        run: |
          npm install
          npm run test:integration
```

---

### Use Case 3: Deployment Pipeline

```yaml
name: Deploy to Production

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: [self-hosted, production]
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy application
        run: |
          ./deploy.sh production
      
      - name: Health check
        run: |
          curl -f https://api.example.com/health || exit 1
```

---

## Summary

### What You've Accomplished

✅ Installed and configured a GitHub Actions self-hosted runner  
✅ Understood CI/CD architecture and data flow  
✅ Created workflows targeting your runner  
✅ Configured runner as a production service  
✅ Tested failure scenarios and recovery  
✅ Implemented monitoring and maintenance  
✅ Secured your runner environment  

### Key Takeaways

| Concept | Real-World Impact |
| ------- | ----------------- |
| Self-hosted runners | Control over build environment |
| Service management | Production-grade reliability |
| Failure testing | Confidence in recovery procedures |
| Security practices | Protect your infrastructure |
| Monitoring | Proactive issue detection |

### Skills for Resume

- Configured and managed GitHub Actions self-hosted runners on Linux
- Implemented CI/CD pipelines with custom build environments
- Deployed runners as systemd services with auto-recovery
- Integrated Docker containerization with CI/CD workflows
- Troubleshot runner connectivity and performance issues

---

## Interview Talking Points

### "Tell me about your CI/CD experience"

> "I configured a self-hosted GitHub Actions runner on a Linux VM, which gave me hands-on experience with the full CI/CD pipeline. I set it up as a systemd service for production reliability, implemented failure recovery procedures, and integrated it with Docker for containerized builds. This mirrors how enterprise organizations run their CI/CD infrastructure, where you need control over the build environment and resources."

### "How do you handle CI/CD failures?"

> "I've tested various failure scenarios including runner downtime, service crashes, and VM reboots. I configured the runner as a systemd service with automatic restart policies, implemented monitoring scripts to track runner health, and documented recovery procedures. When a failure occurs, I check service status, review logs with journalctl, and verify network connectivity to GitHub."

### "What's the difference between GitHub-hosted and self-hosted runners?"

> "GitHub-hosted runners are ephemeral VMs managed by GitHub, great for standard builds but limited in customization. Self-hosted runners run on your own infrastructure, giving you control over hardware, installed tools, and network access. I've worked with self-hosted runners for scenarios requiring specific dependencies, GPU access, or internal resource connectivity that GitHub-hosted runners can't provide."

---

## Next Steps

After mastering this lab:

1. **Add multiple runners** for load distribution
2. **Implement runner pools** for different job types
3. **Configure ephemeral runners** that self-destruct after each job
4. **Integrate with Docker Compose** for complex test environments
5. **Set up runner auto-scaling** with cloud VMs
6. **Implement secrets management** with HashiCorp Vault
7. **Add monitoring** with Prometheus and Grafana

---

## Cleanup

To remove the runner:

```bash
# Stop service
sudo ./svc.sh stop

# Uninstall service
sudo ./svc.sh uninstall

# Remove runner configuration
./config.sh remove

# Remove runner directory
cd ~
rm -rf actions-runner/
```

To remove from GitHub:

1. **Settings** → **Actions** → **Runners**
2. Click on your runner
3. Click **Remove runner**

---

## Additional Resources

- [GitHub Actions Runner Documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Runner Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Monitoring Runners](https://docs.github.com/en/actions/hosting-your-own-runners/monitoring-and-troubleshooting-self-hosted-runners)

---

**Lab Complete!** You now understand how to set up and manage production-grade CI/CD infrastructure with self-hosted GitHub Actions runners.
