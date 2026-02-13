# CI/CD Concepts and Notes - Self-Hosted GitHub Actions Runner

## Table of Contents

1. [CI/CD Fundamentals](#cicd-fundamentals)
2. [GitHub Actions Architecture](#github-actions-architecture)
3. [Self-Hosted vs Cloud Runners](#self-hosted-vs-cloud-runners)
4. [Runner Configuration Deep Dive](#runner-configuration-deep-dive)
5. [Workflow Syntax and Best Practices](#workflow-syntax-and-best-practices)
6. [Security Considerations](#security-considerations)
7. [Troubleshooting Guide](#troubleshooting-guide)
8. [Advanced Patterns](#advanced-patterns)
9. [Interview Preparation](#interview-preparation)

---

## CI/CD Fundamentals

### What is CI/CD?

**Continuous Integration (CI):**

- Automatically build and test code changes
- Catch bugs early in development
- Ensure code integrates with main branch
- Run automated tests on every commit

**Continuous Deployment/Delivery (CD):**

- Automatically deploy to environments
- Continuous Delivery: Manual approval before production
- Continuous Deployment: Fully automated to production
- Reduce manual deployment errors

### CI/CD Pipeline Stages

```text
1. Source        → Developer commits code
2. Build         → Compile/package application
3. Test          → Run automated tests
4. Stage         → Deploy to staging environment
5. Production    → Deploy to production
6. Monitor       → Track application health
```

### Key Benefits

| Benefit | Impact |
| ------- | ------- |
| **Faster Feedback** | Bugs found in minutes, not days |
| **Reduced Risk** | Small, frequent changes are safer |
| **Automation** | Less manual work, fewer errors |
| **Quality** | Consistent testing on every change |
| **Speed** | Ship features faster |

---

## GitHub Actions Architecture

### Components

```text
┌─────────────────────────────────────────────┐
│              GitHub Repository              │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │      .github/workflows/ci.yml         │ │
│  │                                       │ │
│  │  Defines: triggers, jobs, steps      │ │
│  └───────────────┬───────────────────────┘ │
└──────────────────┼─────────────────────────┘
                   │
                   │ (1) Workflow triggered
                   │
                   ▼
┌─────────────────────────────────────────────┐
│           GitHub Actions Service            │
│                                             │
│  - Manages workflow execution               │
│  - Queues jobs                              │
│  - Assigns to available runners             │
└───────────────┬─────────────────────────────┘
                │
                │ (2) Job assigned
                │
                ▼
┌─────────────────────────────────────────────┐
│         Self-Hosted Runner (VM)             │
│                                             │
│  1. Polls GitHub for jobs                   │
│  2. Downloads code                          │
│  3. Executes steps                          │
│  4. Reports results                         │
└─────────────────────────────────────────────┘
```

### Workflow Execution Flow

1. **Trigger Event** → Push, PR, schedule, manual
2. **GitHub Actions Service** → Validates workflow syntax
3. **Job Queue** → Waits for available runner
4. **Runner Assignment** → Based on `runs-on` label
5. **Checkout Code** → Download repository
6. **Execute Steps** → Run commands sequentially
7. **Report Status** → Success, failure, or cancelled
8. **Cleanup** → Remove workspace artifacts

---

## Self-Hosted vs Cloud Runners

### Detailed Comparison

| Aspect | GitHub-Hosted | Self-Hosted |
| ------ | ------------- | ----------- |
| **Infrastructure** | Managed by GitHub | You manage |
| **Cost Model** | Per-minute billing | Fixed infrastructure cost |
| **Scaling** | Automatic | Manual/scripted |
| **Customization** | Limited to GitHub images | Fully customizable |
| **Network Access** | Public internet only | Access internal resources |
| **Security** | Isolated, ephemeral | Persistent, your responsibility |
| **Performance** | Variable (shared resources) | Consistent (dedicated) |
| **Maintenance** | None required | Updates, patches, monitoring |
| **Setup Time** | Immediate | 15-30 minutes |
| **Hardware** | Standard specs | Choose your specs (GPU, RAM, etc.) |

### When to Use Self-Hosted Runners

**Good Use Cases:**

- ✅ Need access to internal databases or APIs
- ✅ Require specific hardware (GPUs, large RAM)
- ✅ High build volume (cost optimization)
- ✅ Need custom software/tools not in GitHub images
- ✅ Corporate security requirements
- ✅ Need faster build times with dedicated resources

**When to Avoid:**

- ❌ Public repositories (security risk)
- ❌ Low build volume (not cost-effective)
- ❌ Don't want infrastructure management overhead
- ❌ Need automatic scaling without setup

### Cost Analysis Example

**Scenario:** 1000 build minutes/month

**GitHub-Hosted:**

- Free tier: 2000 minutes (sufficient)
- Paid: $0.008/minute = $8/month

**Self-Hosted:**

- Small VM: $20-50/month
- Maintenance time: 2 hours/month
- Break-even: ~2500 minutes/month

---

## Runner Configuration Deep Dive

### Registration Process

```bash
./config.sh \
  --url https://github.com/user/repo \  # Repository URL
  --token ABCD1234                       # Authentication token
  --name my-runner                       # Runner identifier
  --labels self-hosted,linux,docker      # Job targeting
  --work _work                           # Working directory
```

### Configuration Options Explained

| Option | Purpose | Example |
| ------ | ------- | ------- |
| `--url` | Repository/org to connect to | `github.com/company/repo` |
| `--token` | Authentication (expires in 1hr) | Generated from GitHub UI |
| `--name` | Runner identifier | `linux-prod-01` |
| `--labels` | Tags for workflow targeting | `self-hosted,gpu,large` |
| `--work` | Job execution directory | `_work` (default) |
| `--replace` | Replace existing runner | Updates registration |
| `--runnergroup` | Group assignment (orgs) | `production-runners` |

### Runner Labels Strategy

**Default labels:**

- `self-hosted` - Automatically added
- OS name - `Linux`, `Windows`, `macOS`
- Architecture - `X64`, `ARM`, `ARM64`

**Custom labels examples:**

```text
Environment-based:
- production
- staging
- development

Capability-based:
- docker
- gpu
- large-disk
- fast-network

Purpose-based:
- builds
- tests
- deployments
```

**Workflow targeting:**

```yaml
jobs:
  build:
    runs-on: [self-hosted, linux, docker]
  
  gpu-train:
    runs-on: [self-hosted, gpu, cuda]
  
  deploy:
    runs-on: [self-hosted, production]
```

### Working Directory Structure

```text
~/actions-runner/
├── _work/                   # Job execution space
│   ├── repo-name/          # Cloned repository
│   │   ├── repo-name/      # Actual code
│   │   └── _temp/          # Temporary files
│   └── _actions/           # Cached actions
├── _diag/                  # Diagnostic logs
├── bin/                    # Runner binaries
├── config.sh               # Configuration script
├── run.sh                  # Foreground execution
├── svc.sh                  # Service management
└── .runner                 # Configuration file
```

---

## Workflow Syntax and Best Practices

### Basic Workflow Structure

```yaml
name: Workflow Name

on:                          # Trigger events
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * *'      # Daily at midnight
  workflow_dispatch:          # Manual trigger

env:                         # Global environment variables
  NODE_VERSION: '18'

jobs:
  job-name:
    runs-on: self-hosted     # Runner selection
    
    env:                     # Job-specific variables
      DATABASE_URL: ${{ secrets.DB_URL }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Run command
        run: |
          echo "Hello World"
          npm test
```

### Workflow Triggers

**Push events:**

```yaml
on:
  push:
    branches:
      - main
      - 'release/**'        # Wildcard matching
    paths:
      - 'src/**'            # Only when these paths change
      - '!docs/**'          # Ignore docs changes
    tags:
      - 'v*'                # Version tags
```

**Pull request events:**

```yaml
on:
  pull_request:
    types:
      - opened
      - synchronize        # New commits
      - reopened
    branches:
      - main
```

**Schedule (cron):**

```yaml
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
    - cron: '0 0 * * 1'    # Monday at midnight
```

**Manual trigger:**

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production
```

### Best Practices

#### 1. Use Checkout Action

```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v3
    with:
      fetch-depth: 0        # Full history for proper versioning
```

#### 2. Cache Dependencies

```yaml
- name: Cache npm dependencies
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

#### 3. Use Matrix Builds

```yaml
jobs:
  test:
    runs-on: self-hosted
    strategy:
      matrix:
        node: [16, 18, 20]
        os: [ubuntu, windows]
    steps:
      - uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node }}
```

#### 4. Conditional Execution

```yaml
steps:
  - name: Deploy to production
    if: github.ref == 'refs/heads/main'
    run: ./deploy.sh production
  
  - name: Run only on PR
    if: github.event_name == 'pull_request'
    run: npm run lint
```

#### 5. Secrets Management

```yaml
steps:
  - name: Deploy
    env:
      API_KEY: ${{ secrets.API_KEY }}
      DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
    run: |
      # Secrets are masked in logs
      ./deploy.sh
```

#### 6. Job Dependencies

```yaml
jobs:
  build:
    runs-on: self-hosted
    steps:
      - run: npm run build
  
  test:
    needs: build              # Waits for build to complete
    runs-on: self-hosted
    steps:
      - run: npm test
  
  deploy:
    needs: [build, test]      # Waits for both
    runs-on: self-hosted
    steps:
      - run: ./deploy.sh
```

#### 7. Timeout and Retry

```yaml
jobs:
  test:
    runs-on: self-hosted
    timeout-minutes: 30       # Prevent hanging jobs
    
    steps:
      - name: Flaky test with retry
        uses: nick-invision/retry@v2
        with:
          timeout_minutes: 5
          max_attempts: 3
          command: npm test
```

---

## Security Considerations

### Self-Hosted Runner Security Model

⚠️ **Critical Understanding:**

When a workflow runs on a self-hosted runner:

1. Code is checked out to the runner
2. Commands execute with runner's permissions
3. Runner has access to:
   - Local files and directories
   - Network resources
   - Environment variables and secrets
   - Docker daemon (if configured)

### Security Risks

| Risk | Description | Impact |
| ---- | ----------- | ------ |
| **Code Injection** | Malicious code in workflows | Full VM compromise |
| **Secret Exposure** | Secrets logged or stored | Credential theft |
| **Resource Abuse** | Crypto mining, DDoS | Infrastructure cost |
| **Lateral Movement** | Access to internal network | Network breach |
| **Persistent Access** | Backdoors installed | Ongoing compromise |

### Security Best Practices

#### 1. Use Self-Hosted Runners Only with Private Repos

```text
✅ Private repository → self-hosted runner (safe)
❌ Public repository → self-hosted runner (DANGEROUS)
```

**Why:** Public repos allow anyone to open PRs that can execute code on your runner.

#### 2. Dedicated User Account

```bash
# Create dedicated user
sudo useradd -m -s /bin/bash github-runner

# Add to docker group (if needed)
sudo usermod -aG docker github-runner

# Do NOT give sudo access
# Do NOT add to wheel/admin group
```

#### 3. Network Segmentation

```bash
# Use firewall to restrict outbound connections
sudo ufw default deny outgoing
sudo ufw allow out 443/tcp       # HTTPS to GitHub
sudo ufw allow out 80/tcp        # HTTP (if needed)
sudo ufw enable
```

#### 4. Approve Workflow Runs (For Forks)

In GitHub repository settings:

- **Settings** → **Actions** → **General**
- "Fork pull request workflows from outside collaborators"
- Select: "Require approval for first-time contributors"

#### 5. Use Secrets Properly

```yaml
# ✅ GOOD - Secret masked in logs
- name: Deploy
  env:
    API_KEY: ${{ secrets.API_KEY }}
  run: ./deploy.sh

# ❌ BAD - Secret visible in logs
- name: Deploy
  run: echo "API_KEY=${{ secrets.API_KEY }}" && ./deploy.sh
```

#### 6. Limit Runner Permissions

```bash
# Don't run as root
whoami  # Should NOT be root

# Limit file access
chmod 700 ~/actions-runner/_work
```

#### 7. Regular Updates

```bash
# Check for runner updates
cd ~/actions-runner
./config.sh check

# Update process (documented in steps.md)
```

#### 8. Monitor and Audit

```bash
# Review logs regularly
sudo journalctl -u actions.runner.* -f

# Check for suspicious processes
ps aux | grep -v root

# Monitor network connections
sudo netstat -tulpn | grep Runner
```

---

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue 1: Runner Shows Offline

**Symptoms:**

- Runner not visible in GitHub UI
- Jobs queue indefinitely
- Status shows "Offline" or gray indicator

**Diagnosis:**

```bash
# Check service status
sudo ./svc.sh status

# Check network connectivity
ping github.com
curl -I https://github.com

# Check runner logs
sudo journalctl -u actions.runner.* -n 50
```

**Common Causes:**

| Cause | Solution |
| ----- | -------- |
| Service not running | `sudo ./svc.sh start` |
| Network issues | Check firewall, DNS, routing |
| Token expired | Re-register runner |
| VM powered off | Start VM |

**Resolution:**

```bash
# Restart service
sudo ./svc.sh restart

# If that doesn't work, re-register
./config.sh remove
./config.sh --url <URL> --token <NEW-TOKEN>
sudo ./svc.sh install
sudo ./svc.sh start
```

---

#### Issue 2: Jobs Queue But Don't Execute

**Symptoms:**

- Workflow shows "Queued"
- Runner is online (Idle)
- Jobs never start

**Diagnosis:**

```bash
# Check runner labels
cat .runner

# Check workflow targeting
# In workflow file, verify runs-on matches labels
```

**Common Causes:**

| Cause | Solution |
| ----- | -------- |
| Label mismatch | Workflow requires labels runner doesn't have |
| Runner busy | Already executing maximum jobs |
| Runner in group | Workflow targets different group |

**Resolution:**

Check workflow file:

```yaml
jobs:
  test:
    runs-on: [self-hosted, linux]  # Must match runner labels
```

Add missing labels:

```bash
./config.sh remove
./config.sh --url <URL> --token <TOKEN> --labels self-hosted,linux,required-label
sudo ./svc.sh install
sudo ./svc.sh start
```

---

#### Issue 3: Docker Permission Denied

**Symptoms:**

```text
Error: Got permission denied while trying to connect to the Docker daemon
```

**Diagnosis:**

```bash
# Check if user is in docker group
groups

# Try running docker command
docker ps
```

**Resolution:**

```bash
# Add runner user to docker group
sudo usermod -aG docker $(whoami)

# IMPORTANT: Restart runner service for group change to take effect
sudo ./svc.sh stop
sudo ./svc.sh start

# Or logout and log back in
```

**Verify:**

```bash
# Should work without sudo
docker ps
docker run --rm hello-world
```

---

#### Issue 4: Disk Space Full

**Symptoms:**

- Builds fail with "No space left on device"
- Runner slow or unresponsive

**Diagnosis:**

```bash
# Check disk usage
df -h

# Check runner work directory
du -sh ~/actions-runner/_work

# Check Docker space usage
docker system df
```

**Resolution:**

```bash
# Clean runner work directory
rm -rf ~/actions-runner/_work/*

# Clean Docker resources
docker system prune -af
docker volume prune -f

# Remove old log files
sudo journalctl --vacuum-time=7d
```

**Prevention:**

```bash
# Add cleanup step to workflows
steps:
  - name: Cleanup workspace
    if: always()
    run: |
      rm -rf ${{ github.workspace }}/*
      docker system prune -f
```

---

#### Issue 5: Workflow Hangs/Times Out

**Symptoms:**

- Job runs indefinitely
- No log output
- Eventually times out

**Diagnosis:**

```bash
# Check runner logs for errors
sudo journalctl -u actions.runner.* -f

# Check system resources
top
free -h
df -h

# Check for zombie processes
ps aux | grep defunct
```

**Common Causes:**

| Cause | Solution |
| ----- | -------- |
| Waiting for user input | Use `-y` flags, redirect stdin |
| Infinite loop | Add timeout to steps |
| Resource exhaustion | Increase VM resources |
| Network request hanging | Add timeout to curl/wget |

**Resolution:**

Add timeouts to workflows:

```yaml
jobs:
  test:
    runs-on: self-hosted
    timeout-minutes: 30        # Job-level timeout
    
    steps:
      - name: Run tests
        timeout-minutes: 10    # Step-level timeout
        run: npm test
```

---

#### Issue 6: Secret Not Available

**Symptoms:**

- Workflow fails with "Secret not found"
- Variable is empty in workflow

**Diagnosis:**

```bash
# Check if secret exists in GitHub UI
# Settings → Secrets and variables → Actions
```

**Common Causes:**

| Cause | Solution |
| ----- | -------- |
| Secret not created | Add secret in GitHub UI |
| Wrong scope | Check repo vs org secrets |
| Typo in name | Verify exact name match |
| Not available in fork PRs | Expected behavior for security |

**Resolution:**

Verify secret usage:

```yaml
steps:
  - name: Check secret
    env:
      MY_SECRET: ${{ secrets.MY_SECRET }}
    run: |
      if [ -z "$MY_SECRET" ]; then
        echo "Error: MY_SECRET not set"
        exit 1
      fi
```

---

#### Issue 7: Checkout Action Fails

**Symptoms:**

```text
Error: fatal: could not read Username for 'https://github.com'
```

**Diagnosis:**

```bash
# Check runner can access GitHub
curl -I https://github.com

# Check for git credentials
git config --list | grep credential
```

**Resolution:**

Use proper checkout action:

```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v3    # Use latest version
    with:
      token: ${{ secrets.GITHUB_TOKEN }}  # Use provided token
      fetch-depth: 0             # Full history if needed
```

---

### Debug Workflow Syntax

Enable debug logging:

In GitHub repo settings:

- **Settings** → **Secrets and variables** → **Actions**
- Add secret: `ACTIONS_STEP_DEBUG` = `true`

In workflow run:

- Click "Re-run jobs"
- Check "Enable debug logging"

View enhanced logs:

```text
##[debug]Evaluating condition for step: 'Run tests'
##[debug]Evaluating: success()
##[debug]Evaluating success:
##[debug]=> true
##[debug]Result: true
```

---

## Advanced Patterns

### Pattern 1: Runner Auto-Scaling

**Scenario:** Scale runners based on job queue.

**Approach:**

- Monitor GitHub API for queued jobs
- Spawn additional runners when queue grows
- Terminate idle runners after timeout

**Implementation (conceptual):**

```bash
#!/bin/bash
# runner-autoscaler.sh

REPO="owner/repo"
MAX_RUNNERS=5

while true; do
  QUEUED=$(curl -s "https://api.github.com/repos/$REPO/actions/runs?status=queued" | jq '.total_count')
  RUNNING=$(curl -s "https://api.github.com/repos/$REPO/actions/runs?status=in_progress" | jq '.total_count')
  
  NEEDED=$((QUEUED + RUNNING))
  CURRENT=$(count_active_runners)
  
  if [ $NEEDED -gt $CURRENT ] && [ $CURRENT -lt $MAX_RUNNERS ]; then
    spawn_new_runner
  elif [ $CURRENT -gt $NEEDED ]; then
    terminate_idle_runner
  fi
  
  sleep 60
done
```

---

### Pattern 2: Ephemeral Runners

**Scenario:** Runner that self-destructs after each job.

**Benefits:**

- Clean state for every job
- No artifact persistence
- Enhanced security

**Implementation:**

```yaml
# Workflow
jobs:
  test:
    runs-on: [self-hosted, ephemeral]
    steps:
      - uses: actions/checkout@v3
      - run: npm test
      - name: Destroy runner
        if: always()
        run: |
          sudo shutdown -h now
```

---

### Pattern 3: Runner Pools

**Scenario:** Different runners for different job types.

**Setup:**

```bash
# Production runners
./config.sh --labels self-hosted,linux,production
./config.sh --labels self-hosted,linux,production

# Development runners
./config.sh --labels self-hosted,linux,development
./config.sh --labels self-hosted,linux,development
```

**Usage:**

```yaml
jobs:
  build-dev:
    runs-on: [self-hosted, development]
  
  deploy-prod:
    runs-on: [self-hosted, production]
```

---

### Pattern 4: Matrix Builds on Self-Hosted

**Scenario:** Test across multiple versions.

```yaml
jobs:
  test:
    runs-on: self-hosted
    strategy:
      matrix:
        node: [16, 18, 20]
        database: [postgres, mysql]
    steps:
      - uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node }}
      
      - name: Start ${{ matrix.database }}
        run: docker-compose up -d ${{ matrix.database }}
      
      - run: npm test
```

---

## Interview Preparation

### Key Talking Points

#### 1. "Explain CI/CD"

> "CI/CD is the practice of automating software delivery. Continuous Integration automatically builds and tests code changes, catching bugs early. Continuous Deployment automates the release to production. I've implemented CI/CD using GitHub Actions with self-hosted runners, where I configured Linux VMs to execute workflows, integrated Docker for builds, and managed runners as systemd services for reliability."

#### 2. "Why use self-hosted runners?"

> "Self-hosted runners give you control over the build environment. I used them when I needed specific hardware, like GPUs, or access to internal resources like databases. They're also cost-effective for high build volumes. I configured mine as systemd services with automatic restart, implemented health monitoring, and tested failure scenarios to ensure pipeline reliability."

#### 3. "How do you secure CI/CD pipelines?"

> "Security starts with using self-hosted runners only for private repositories—public repos are too risky. I create dedicated user accounts without sudo access, use GitHub Secrets for sensitive data, and implement network restrictions with firewall rules. I also enable workflow approval for external contributors and regularly review runner logs for suspicious activity."

#### 4. "Troubleshoot a failing pipeline"

> "I follow a systematic approach: First, check if the runner is online and the service is running. Then review workflow logs for error messages. Common issues include wrong runner labels, Docker permission problems, or disk space. I use 'journalctl' for service logs, verify network connectivity, and check resource usage with 'top' and 'df'. For persistent issues, I enable debug logging in GitHub Actions."

#### 5. "Describe a complex CI/CD setup"

> "I built a CI/CD pipeline with multiple stages: code checkout, build, test, security scanning, and deployment. I used self-hosted runners with Docker for isolated builds, implemented caching to speed up builds, and configured matrix builds to test across multiple Node versions. I also set up conditional deployments—only main branch goes to production, while PR builds deploy to staging."

---

### Common Interview Questions

**Q: What happens when a self-hosted runner is offline?**

A: Jobs targeting that runner will queue indefinitely until a matching runner becomes available or the job times out (default 360 minutes). In production, I implement monitoring to alert when runners go offline and have documented recovery procedures.

---

**Q: How do GitHub Actions runners authenticate?**

A: During registration, a token authenticates the runner with GitHub. This creates a persistent connection where the runner polls GitHub's API for jobs. The token expires after 1 hour if unused, but once registered, the runner uses a different authentication mechanism stored in the `.runner` file.

---

**Q: Can you run multiple jobs simultaneously on one runner?**

A: Yes, by default a runner can execute multiple jobs concurrently. However, this can be limited using the `--disableupdate` flag during configuration or by managing runner capacity through labels and pools.

---

**Q: What's the difference between `uses` and `run` in workflows?**

A: `uses` executes a pre-built action (reusable component), while `run` executes shell commands directly. For example, `uses: actions/checkout@v3` uses GitHub's checkout action, while `run: npm test` runs a command on the runner.

---

**Q: How do you handle secrets in CI/CD?**

A: Secrets are stored in GitHub repository settings and accessed in workflows via `${{ secrets.SECRET_NAME }}`. They're automatically masked in logs. For sensitive operations, I use secrets for API keys, credentials, and tokens, never hardcoding them in workflows or code.

---

#### Q: Explain workflow triggers

A: Workflows can be triggered by: push events (code changes), pull requests, scheduled cron jobs, manual dispatch, or webhook events. Each trigger can be filtered by branches, paths, or tags. For example, `on: push: branches: [main]` only triggers on main branch pushes.

---

**Q: How do you debug failing workflows?**

A: I start by examining workflow logs in GitHub UI, looking for error messages and exit codes. I enable debug logging by setting `ACTIONS_STEP_DEBUG` secret to `true`. I also check runner logs with `journalctl`, verify the runner is online, and ensure all required secrets and variables are configured.

---

**Q: What's the workflow execution order?**

A: Jobs run in parallel by default unless dependencies are specified with `needs`. Within a job, steps execute sequentially. If a step fails, subsequent steps are skipped unless `if: always()` is used. The workflow fails if any job fails unless configured otherwise.

---

### Scenario-Based Questions

#### Scenario: Pipeline fails only on self-hosted runner, works on GitHub-hosted

**Answer:** This indicates an environment-specific issue. I would:

1. Compare runner environment (OS, tools, versions) with GitHub-hosted
2. Check for missing dependencies or configurations
3. Verify Docker/container permissions
4. Look for hardcoded paths or environment variables
5. Test the exact commands locally on the runner VM

---

#### Scenario Question: Builds succeed but deployments intermittently fail

**Answer:** Intermittent failures suggest:

1. Network connectivity issues (timeouts)
2. Race conditions in deployment scripts
3. Resource contention (multiple jobs competing)
4. External service instability

I would add retries with exponential backoff, implement health checks, add more detailed logging, and potentially separate deployment to a dedicated runner pool.

---

#### Scenario: Runner performance degrades over time**

**Answer:** This points to resource accumulation:

1. Check disk space (`df -h`)
2. Review Docker image/container buildup (`docker system df`)
3. Look for memory leaks (`free -h`, `top`)
4. Check log file growth (`du -sh /var/log`)

Solution: Implement cleanup steps in workflows, schedule regular maintenance, add disk space monitoring, and configure Docker garbage collection.

---

## Summary

### Key Concepts Checklist

- ✅ Understand CI/CD fundamentals and benefits
- ✅ Know GitHub Actions architecture and components
- ✅ Compare self-hosted vs GitHub-hosted runners
- ✅ Configure runners with appropriate labels and settings
- ✅ Write workflows with proper syntax and best practices
- ✅ Implement security measures for self-hosted infrastructure
- ✅ Troubleshoot common runner and workflow issues
- ✅ Apply advanced patterns (scaling, pools, matrices)
- ✅ Articulate CI/CD experience in interviews

### Next Learning Steps

1. **Explore Actions Marketplace** - Find reusable actions
2. **Implement Caching** - Speed up builds with dependency caching
3. **Try Matrix Builds** - Test across multiple environments
4. **Add Security Scanning** - Integrate tools like Snyk or Trivy
5. **Set Up Notifications** - Slack/Email on build failures
6. **Deploy to Cloud** - Automate AWS/Azure deployments
7. **Monitor Pipelines** - Track build metrics and trends

---

**This comprehensive guide covers everything you need to understand, implement, and discuss CI/CD with self-hosted GitHub Actions runners!**
