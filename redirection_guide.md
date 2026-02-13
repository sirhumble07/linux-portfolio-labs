# Comprehensive Guide to Linux I/O Redirection

## Table of Contents

1. [Overview](#1-overview)
2. [Understanding File Descriptors](#2-understanding-file-descriptors)
3. [Output Redirection](#3-output-redirection)
4. [Input Redirection](#4-input-redirection)
5. [Error Redirection](#5-error-redirection)
6. [Advanced Redirection](#6-advanced-redirection)
7. [Practical Labs](#7-practical-labs)
8. [Real-World Use Cases](#8-real-world-use-cases)
9. [Common Pitfalls](#9-common-pitfalls)
10. [Interview Questions](#10-interview-questions)

---

## 1. Overview

In Linux, every process starts with three data streams:

- **STDIN (0):** Standard Input - where data comes from (default: keyboard)
- **STDOUT (1):** Standard Output - where normal output goes (default: terminal/screen)
- **STDERR (2):** Standard Error - where error messages go (default: terminal/screen)

### Why Redirection Matters

Redirection allows you to:

- Save command output to files
- Chain commands together
- Separate errors from normal output
- Automate processes without user interaction
- Create logs and audit trails

---

## 2. Understanding File Descriptors

### What Are File Descriptors?

File descriptors are numeric identifiers that the system uses to track open files/streams.

| FD | Name   | Symbol | Default  | Description            |
|:---|:-------|:-------|:---------|:-----------------------|
| 0  | STDIN  | `<`    | Keyboard | Standard input stream  |
| 1  | STDOUT | `>`    | Terminal | Standard output stream |
| 2  | STDERR | `2>`   | Terminal | Standard error stream  |

### Visualizing Data Flow

```text
┌─────────────┐
│   Command   │
└──────┬──────┘
       │
   ┌───┴───┐
   │       │
   ▼       ▼
STDOUT   STDERR
  (1)      (2)
   │       │
   ▼       ▼
Terminal Terminal
```

#### Lab 2.1: Viewing File Descriptors

```bash
# Create a test directory
mkdir -p ~/redirection-lab
cd ~/redirection-lab

# View file descriptors for current shell
ls -l /proc/$$/fd

# Expected output shows:
# 0 -> /dev/pts/0 (stdin)
# 1 -> /dev/pts/0 (stdout)
# 2 -> /dev/pts/0 (stderr)
```

📸 **Screenshot:** Output of `ls -l /proc/$$/fd`

---

## 3. Output Redirection

### 3.1 Basic Output Redirection (`>`)

**Syntax:** `command > file`

**Behavior:**

- Creates file if it doesn't exist
- **Overwrites** file if it exists
- Redirects only STDOUT (fd 1)

#### Lab 3.1.1: Basic Overwrite

```bash
# Create initial file
echo "First message" > output.txt

# Verify content
cat output.txt
# Output: First message

# Overwrite the file
echo "Second message" > output.txt

# Verify content (first message is gone!)
cat output.txt
# Output: Second message
```

📸 **Screenshot:** Before and after overwriting

#### Lab 3.1.2: Capturing Command Output

```bash
# Save directory listing to file
ls -lh /etc > directory_listing.txt

# View the file
head directory_listing.txt

# Save system information
uname -a > system_info.txt
cat system_info.txt
```

📸 **Screenshot:** Contents of captured files

---

### 3.2 Append Output Redirection (`>>`)

**Syntax:** `command >> file`

**Behavior:**

- Creates file if it doesn't exist
- **Appends** to end of file if it exists
- Does not delete existing content

#### Lab 3.2.1: Building a Log File

```bash
# Create initial log entry
echo "=== System Log ===" > system.log
echo "Started: $(date)" >> system.log

# Add more entries
echo "User: $(whoami)" >> system.log
echo "Host: $(hostname)" >> system.log
echo "Uptime: $(uptime)" >> system.log

# View complete log
cat system.log
```

📸 **Screenshot:** Complete log file

#### Lab 3.2.2: Continuous Monitoring

```bash
# Create a monitoring script
echo "#!/bin/bash" > monitor.sh
echo "while true; do" >> monitor.sh
echo "  echo \"\$(date): System check\" >> monitor.log" >> monitor.sh
echo "  df -h / >> monitor.log" >> monitor.sh
echo "  echo \"---\" >> monitor.log" >> monitor.sh
echo "  sleep 5" >> monitor.sh
echo "done" >> monitor.sh

chmod +x monitor.sh

# Run for a short time (Ctrl+C to stop)
./monitor.sh &
MONITOR_PID=$!
sleep 15
kill $MONITOR_PID

# View the log
cat monitor.log
```

📸 **Screenshot:** Accumulated monitoring data

---

### 3.3 Truncate with Redirection

**Syntax:** `> file` (no command)

**Behavior:**

- Empties the file immediately
- Useful for clearing log files

#### Lab 3.3.1: Clearing Files

```bash
# Create a file with content
echo "Old data" > temp.txt
cat temp.txt

# Truncate (empty) the file
> temp.txt

# Verify it's empty (no output)
cat temp.txt

# Check file still exists but size is 0
ls -lh temp.txt
```

📸 **Screenshot:** File size before and after truncation

---

## 4. Input Redirection

### 4.1 Basic Input Redirection (`<`)

**Syntax:** `command < file`

**Behavior:**

- Reads file content as input to command
- Instead of typing, data comes from file

#### Lab 4.1.1: Feeding Input from Files

```bash
# Create a list of numbers
cat > numbers.txt << 'EOF'
10
25
30
15
20
EOF

# Sort the numbers using file as input
sort -n < numbers.txt

# Count lines, words, characters
wc < numbers.txt
```

📸 **Screenshot:** Input redirection results

#### Lab 4.1.2: Email Simulation

```bash
# Create email body
cat > email_body.txt << 'EOF'
Subject: System Report

Hello Team,

This is an automated system report.

Best regards,
Admin
EOF

# Simulate sending email (using mail command if available)
# mail -s "Report" user@example.com < email_body.txt

# Alternative: demonstrate with cat
cat < email_body.txt
```

📸 **Screenshot:** Email content read from file

---

### 4.2 Here Document (`<<`)

**Syntax:**

```bash
command << DELIMITER
content
DELIMITER
```

**Behavior:**

- Passes multi-line text to a command
- Useful for scripts and automation
- Delimiter can be any word (commonly EOF, END, etc.)

#### Lab 4.2.1: Creating Multi-line Files

```bash
# Create configuration file using heredoc
cat << EOF > config.conf
[Database]
host=localhost
port=5432
user=admin

[Application]
debug=true
max_connections=100
EOF

# Verify content
cat config.conf
```

📸 **Screenshot:** Generated configuration file

#### Lab 4.2.2: Heredoc with Variable Expansion

```bash
# Variables are expanded by default
USERNAME=$(whoami)
CURRENT_DATE=$(date)

cat << EOF > report.txt
System Report Generated
=======================
User: $USERNAME
Date: $CURRENT_DATE
Home: $HOME
EOF

cat report.txt
```

📸 **Screenshot:** Report with expanded variables

#### Lab 4.2.3: Heredoc WITHOUT Variable Expansion**

```bash
# Quote the delimiter to prevent expansion
cat << 'EOF' > script.sh
#!/bin/bash
echo "Username: $USER"
echo "Home: $HOME"
EOF

# Variables are literal, not expanded
cat script.sh
```

📸 **Screenshot:** Script with literal variable names

#### Lab 4.2.4: SQL Script Generation

```bash
# Generate SQL script
cat << 'SQL' > create_tables.sql
-- Database initialization script
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
SQL

cat create_tables.sql
```

📸 **Screenshot:** Generated SQL script

#### Lab 4.2.5: Interactive SSH Commands

```bash
# Simulate SSH session with multiple commands
cat << 'EOF' > remote_commands.sh
#!/bin/bash
# This would normally be: ssh user@server << 'ENDSSH'
cat << 'ENDSSH'
whoami
pwd
ls -la
df -h
ENDSSH
EOF

cat remote_commands.sh
```

📸 **Screenshot:** Multi-command script

---

### 4.3 Here String (`<<<`)

**Syntax:** `command <<< "string"`

**Behavior:**

- Passes a single string as input
- Useful for quick one-liners
- Variables are expanded

#### Lab 4.3.1: String Processing

```bash
# Count characters in a string
wc -c <<< "Hello World"

# Convert to uppercase
tr '[:lower:]' '[:upper:]' <<< "linux is awesome"

# Count words
wc -w <<< "This is a test sentence"
```

📸 **Screenshot:** String processing results

#### Lab 4.3.2: Variable Processing

```bash
# Process variable content
MY_TEXT="Docker Kubernetes Terraform"

# Extract first word
awk '{print $1}' <<< "$MY_TEXT"

# Count words in variable
wc -w <<< "$MY_TEXT"

# Replace text
sed 's/Docker/Podman/' <<< "$MY_TEXT"
```

📸 **Screenshot:** Variable manipulation

#### Lab 4.3.3: Base64 Encoding

```bash
# Encode string
base64 <<< "SecretPassword123"

# Decode (save encoded value first)
ENCODED=$(base64 <<< "SecretPassword123")
base64 -d <<< "$ENCODED"
```

📸 **Screenshot:** Encoding/decoding process

#### Lab 4.3.4: Read into Variables

```bash
# Read from here string into variable
read -r line <<< "This is a single line"
echo "Read: $line"

# Multiple variables
read -r first second rest <<< "One Two Three Four"
echo "First: $first"
echo "Second: $second"
echo "Rest: $rest"
```

📸 **Screenshot:** Variable reading results

---

## 5. Error Redirection

### 5.1 Error-Only Redirection (`2>`)

**Syntax:** `command 2> error_file`

**Behavior:**

- Redirects only STDERR (fd 2)
- STDOUT still goes to terminal
- Useful for separating errors

#### Lab 5.1.1: Capturing Errors

```bash
# Command that will fail
ls /nonexistent_directory 2> errors.txt

# Terminal shows nothing (error redirected)
# Check the error file
cat errors.txt
```

📸 **Screenshot:** Error captured in file

#### Lab 5.1.2: Separating Output and Errors

```bash
# Mix of success and failure
ls /etc /fake_dir > success.txt 2> errors.txt

# Check successful output
cat success.txt

# Check error output
cat errors.txt
```

📸 **Screenshot:** Separated outputs

#### Lab 5.1.3: Silent Error Suppression**

```bash
# Redirect errors to /dev/null (discard)
find / -name "*.conf" 2> /dev/null > found_configs.txt

# Only successful finds are saved
head found_configs.txt
```

📸 **Screenshot:** Clean output without permission errors

---

### 5.2 Combined Redirection (`&>` or `>&`)

**Syntax:** `command &> file`

**Behavior:**

- Redirects both STDOUT and STDERR to same file
- Bash shorthand for `> file 2>&1`

#### Lab 5.2.1: Complete Command Capture

```bash
# Capture everything
ls /etc /fake_dir &> complete_output.txt

# View combined output
cat complete_output.txt
```

📸 **Screenshot:** Combined output and errors

#### Lab 5.2.2: Script Logging

```bash
# Create a script that logs everything
cat > full_backup.sh << 'EOF'
#!/bin/bash

# Log everything to file
exec &> backup_$(date +%Y%m%d).log

echo "=== Backup Started ==="
echo "Date: $(date)"

# Simulate backup commands
tar -czf backup.tar.gz /etc/hosts 2>&1 || true
tar -czf backup2.tar.gz /fake_path 2>&1 || true

echo "=== Backup Complete ==="
EOF

chmod +x full_backup.sh
./full_backup.sh

# Check the log
cat backup_*.log
```

📸 **Screenshot:** Complete script execution log

---

### 5.3 Redirecting to Different Files

**Syntax:** `command > output.txt 2> error.txt`

**Behavior:**

- STDOUT goes to one file
- STDERR goes to another file
- Clean separation of outputs

#### Lab 5.3.1: Dual Logging

```bash
# Create a script with both success and errors
cat > test_script.sh << 'EOF'
#!/bin/bash
echo "This is normal output"
ls /etc/passwd
echo "More normal output"
ls /nonexistent_file
echo "Final output"
EOF

chmod +x test_script.sh

# Run with separated outputs
./test_script.sh > stdout.log 2> stderr.log

# View separated logs
echo "=== STDOUT ==="
cat stdout.log
echo ""
echo "=== STDERR ==="
cat stderr.log
```

📸 **Screenshot:** Separated log files

---

### 5.4 Redirecting STDERR to STDOUT (`2>&1`)

**Syntax:** `command > file 2>&1`

**Behavior:**

- Redirects STDERR to wherever STDOUT is going
- Order matters! Must come after `>`
- Allows piping errors

#### Lab 5.4.1: Understanding Order

```bash
# WRONG order (doesn't work as expected)
ls /etc /fake 2>&1 > wrong.txt
# Errors still go to terminal!

# CORRECT order
ls /etc /fake > correct.txt 2>&1
cat correct.txt
```

📸 **Screenshot:** Comparison of wrong vs correct order

#### Lab 5.4.2: Piping Errors

```bash
# Search through both output and errors
find / -name "*.conf" 2>&1 | grep -v "Permission denied" > configs.txt

# View found configs
head configs.txt
```

📸 **Screenshot:** Filtered results

#### Lab 5.4.3: Logging to File and Terminal

```bash
# Use tee to send to both file and screen
ls /etc /fake 2>&1 | tee dual_output.txt

# Now it's both on screen and in file
cat dual_output.txt
```

📸 **Screenshot:** Dual destination output

---

## 6. Advanced Redirection

### 6.1 Swapping STDOUT and STDERR

**Syntax:** `command 3>&1 1>&2 2>&3`

**Behavior:**

- Temporarily uses fd 3 as swap space
- Errors go to STDOUT, output goes to STDERR

#### Lab 6.1.1: Stream Swapping

```bash
# Normal behavior
echo "Normal" > normal.txt 2>&1

# Swap streams
(echo "Output"; ls /fake) 3>&1 1>&2 2>&3 > swapped.txt

cat swapped.txt
```

📸 **Screenshot:** Swapped streams demonstration

---

### 6.2 Multiple Redirections

#### Lab 6.2.1: Complex Logging System

```bash
# Create comprehensive logging script
cat > complex_log.sh << 'EOF'
#!/bin/bash

# Setup log files
STDOUT_LOG="stdout_$(date +%Y%m%d_%H%M%S).log"
STDERR_LOG="stderr_$(date +%Y%m%d_%H%M%S).log"
COMBINED_LOG="combined_$(date +%Y%m%d_%H%M%S).log"

# Redirect stdout to file and keep copy for combined
exec 1> >(tee -a "$STDOUT_LOG" "$COMBINED_LOG")

# Redirect stderr to file and keep copy for combined
exec 2> >(tee -a "$STDERR_LOG" "$COMBINED_LOG" >&2)

# Now run commands
echo "=== Starting Process ==="
echo "Date: $(date)"

# Successful command
ls /etc/hosts

# Failed command
ls /nonexistent_path

echo "=== Process Complete ==="
EOF

chmod +x complex_log.sh
./complex_log.sh

# View the logs
ls -lh *.log
```

📸 **Screenshot:** Multiple log files created

---

### 6.3 Redirecting Within Scripts

#### Lab 6.3.1: Script-Level Redirection

```bash
cat > redirect_script.sh << 'EOF'
#!/bin/bash

# Redirect all output for entire script
exec > script_output.log 2>&1

echo "This goes to the log file"
date
ls /etc
ls /fake_dir
echo "Script complete"
EOF

chmod +x redirect_script.sh
./redirect_script.sh

# Nothing shows on screen, check the log
cat script_output.log
```

📸 **Screenshot:** Script output in log file

---

### 6.4 Using `/dev/null`

**Behavior:**

- Black hole device
- Discards all data written to it
- Useful for suppressing output

#### Lab 6.4.1: Suppressing Output

```bash
# Suppress all output
find / -name "*.conf" > /dev/null 2>&1

# Suppress only errors
find / -name "*.conf" 2> /dev/null > found.txt

# Suppress only standard output
ls -la / > /dev/null

# Check if command succeeds silently
if grep -q "root" /etc/passwd > /dev/null 2>&1; then
    echo "Root user exists"
fi
```

📸 **Screenshot:** Silent command execution

---

### 6.5 Named Pipes (FIFOs)

#### Lab 6.5.1: Using Named Pipes

```bash
# Create a named pipe
mkfifo my_pipe

# Writer process (background)
ls -la /etc > my_pipe &

# Reader process
cat < my_pipe

# Cleanup
rm my_pipe
```

📸 **Screenshot:** Named pipe in action

---

## 7. Practical Labs

### Lab 7.1: Build a System Health Monitor

```bash
#!/bin/bash
# System health monitoring script

LOG_FILE="health_$(date +%Y%m%d).log"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Redirect all errors to separate file
exec 2> health_errors.log

log "=== System Health Check Started ==="

# CPU usage
log "CPU Usage:"
top -bn1 | head -5 | tee -a "$LOG_FILE"

# Memory usage
log "Memory Usage:"
free -h | tee -a "$LOG_FILE"

# Disk usage
log "Disk Usage:"
df -h | tee -a "$LOG_FILE"

# Check for failed services (might generate errors)
log "Checking services:"
systemctl --failed 2>&1 | tee -a "$LOG_FILE" || true

log "=== Health Check Complete ==="

# Check if there were any errors
if [ -s health_errors.log ]; then
    log "WARNINGS: Errors were encountered. Check health_errors.log"
else
    log "SUCCESS: No errors detected"
    rm health_errors.log
fi
```

📸 **Screenshot:** Health monitoring output

---

### Lab 7.2: Automated Backup Script with Logging

```bash
#!/bin/bash
# Backup script with comprehensive logging

BACKUP_DIR="/tmp/backups"
LOG_DIR="/tmp/backup_logs"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# Setup logging
STDOUT_LOG="$LOG_DIR/backup_success_$DATE.log"
STDERR_LOG="$LOG_DIR/backup_errors_$DATE.log"
FULL_LOG="$LOG_DIR/backup_full_$DATE.log"

# Log to all destinations
exec 1> >(tee -a "$STDOUT_LOG" "$FULL_LOG")
exec 2> >(tee -a "$STDERR_LOG" "$FULL_LOG" >&2)

echo "=== Backup Started at $(date) ==="

# Backup home directory
tar -czf "$BACKUP_DIR/home_$DATE.tar.gz" "$HOME" 2>&1

# Backup system configs (may have permission issues)
tar -czf "$BACKUP_DIR/etc_$DATE.tar.gz" /etc 2>&1

# Try to backup non-existent directory (will error)
tar -czf "$BACKUP_DIR/fake_$DATE.tar.gz" /nonexistent 2>&1 || echo "Expected failure logged"

echo "=== Backup Completed at $(date) ==="
echo "Logs saved to: $LOG_DIR"
echo "Backups saved to: $BACKUP_DIR"
```

📸 **Screenshot:** Backup script execution and logs

---

### Lab 7.3: Error Recovery Pattern

```bash
#!/bin/bash
# Demonstrates error handling with redirection

ERROR_LOG="critical_errors.log"
SUCCESS_LOG="success.log"

# Clear old logs
> "$ERROR_LOG"
> "$SUCCESS_LOG"

# Function to attempt command with error logging
try_command() {
    local cmd="$1"
    local description="$2"
    
    echo "Attempting: $description"
    
    if eval "$cmd" >> "$SUCCESS_LOG" 2>> "$ERROR_LOG"; then
        echo "✓ Success: $description"
        return 0
    else
        echo "✗ Failed: $description (check $ERROR_LOG)"
        return 1
    fi
}

# Try various commands
try_command "ls /etc/passwd" "List password file"
try_command "ls /nonexistent" "List fake directory"
try_command "date" "Show current date"
try_command "cat /etc/shadow" "Read shadow file (will fail)"

# Summary
echo ""
echo "=== Summary ==="
echo "Successful operations:"
cat "$SUCCESS_LOG"
echo ""
echo "Failed operations:"
cat "$ERROR_LOG"
```

📸 **Screenshot:** Error recovery in action

---

## 8. Real-World Use Cases

### 8.1 DevOps Automation

```bash
#!/bin/bash
# Deployment script with logging

DEPLOY_LOG="/var/log/deploy_$(date +%Y%m%d_%H%M%S).log"

exec &> "$DEPLOY_LOG"

echo "=== Deployment Started ==="
git pull origin main 2>&1
docker-compose down 2>&1
docker-compose build 2>&1
docker-compose up -d 2>&1
echo "=== Deployment Complete ==="

# Email log on failure
if [ $? -ne 0 ]; then
    mail -s "Deployment Failed" admin@example.com < "$DEPLOY_LOG"
fi
```

---

### 8.2 Database Backup

```bash
#!/bin/bash
# Database backup with error handling

DB_NAME="production_db"
BACKUP_FILE="backup_$(date +%Y%m%d).sql"
ERROR_LOG="db_errors.log"

# Backup with error logging
pg_dump "$DB_NAME" > "$BACKUP_FILE" 2> "$ERROR_LOG"

# Check for errors
if [ -s "$ERROR_LOG" ]; then
    echo "Backup failed! Errors:" | mail -s "DB Backup Failed" admin@example.com < "$ERROR_LOG"
else
    echo "Backup successful: $BACKUP_FILE" | mail -s "DB Backup Success" admin@example.com
    rm "$ERROR_LOG"
fi
```

---

### 8.3 Cron Job Logging

```bash
# In crontab: 0 2 * * * /path/to/backup.sh

#!/bin/bash
# Cron-friendly script

LOGFILE="/var/log/nightly_backup.log"

# Append to log with timestamp
{
    echo "=== Backup started at $(date) ==="
    tar -czf /backups/nightly_$(date +%Y%m%d).tar.gz /important/data 2>&1
    echo "=== Backup completed at $(date) ==="
    echo ""
} >> "$LOGFILE" 2>&1
```

---

## 9. Common Pitfalls

### 9.1 Order Matters

```bash
# WRONG - errors still go to terminal
command 2>&1 > file

# CORRECT - errors go to file
command > file 2>&1
```

### 9.2 Overwriting Important Files

```bash
# Dangerous - accidentally overwrites source
cat file1.txt > file1.txt  # File becomes empty!

# Safe - use different name
cat file1.txt > file1_processed.txt
```

### 9.3 Forgetting to Append

```bash
# Log only shows last entry
for i in {1..5}; do
    echo "Iteration $i" > log.txt  # Overwrites each time!
done

# Correct - append
for i in {1..5}; do
    echo "Iteration $i" >> log.txt
done
```

### 9.4 Permission Issues

```bash
# May fail silently
command > /root/file.txt 2> /dev/null

# Better - check permissions first
if [ -w /root ]; then
    command > /root/file.txt
else
    echo "Error: No write permission" >&2
    exit 1
fi
```

---

## 10. Interview Questions

### Q1: What's the difference between `>` and `>>`?

**Answer:**

- `>` overwrites the file completely
- `>>` appends to the end of the file
- Both create the file if it doesn't exist

**Example:**

```bash
echo "Line 1" > file.txt   # Creates/overwrites
echo "Line 2" >> file.txt  # Appends
# Result: file has both lines
```

---

### Q2: How do you redirect both STDOUT and STDERR to the same file?

**Answer:**
Three methods:

```bash
# Method 1: Modern Bash shorthand
command &> file

# Method 2: Traditional
command > file 2>&1

# Method 3: Explicit
command 1> file 2>&1
```

**Order matters:** STDERR redirection must come after STDOUT redirection.

---

### Q3: How do you suppress all output from a command?

**Answer:**

```bash
command > /dev/null 2>&1

# Or using shorthand
command &> /dev/null
```

`/dev/null` is a special device that discards all data written to it.

---

### Q4: What's the difference between `<<` and `<<<`?

**Answer:**

- `<<` (heredoc): Multi-line input with delimiter
- `<<<` (here string): Single string input

```bash
# Heredoc - multiple lines
cat << EOF
Line 1
Line 2
EOF

# Here string - single string
wc -w <<< "Count these words"
```

---

### Q5: How do you read a file line by line in a script?

**Answer:**

```bash
# Method 1: Using input redirection
while IFS= read -r line; do
    echo "Processing: $line"
done < input.txt

# Method 2: Using pipe
cat input.txt | while IFS= read -r line; do
    echo "Processing: $line"
done
```

---

### Q6: How do you redirect output to multiple files?

**Answer:**
Use `tee`:

```bash
# To file and screen
command | tee output.txt

# To multiple files
command | tee file1.txt file2.txt

# Append mode
command | tee -a output.txt
```

---

### Q7: What happens with this command: `ls > file 2>&1`?

**Answer:**

1. STDOUT is redirected to `file`
2. STDERR is redirected to wherever STDOUT is going (the file)
3. Both outputs end up in `file`

---

### Q8: How do you swap STDOUT and STDERR?

**Answer:**

```bash
command 3>&1 1>&2 2>&3
```

- fd 3 is used as temporary holder
- STDOUT goes to STDERR
- STDERR goes to STDOUT

---

## 11. Quick Reference Card

```bash
# OUTPUT REDIRECTION
command > file          # Overwrite file with output
command >> file         # Append output to file
command 2> file         # Redirect errors only
command &> file         # Redirect both output and errors
command | tee file      # Output to both screen and file

# INPUT REDIRECTION
command < file          # Read input from file
command << EOF         # Here document (multi-line)
...
EOF
command <<< "string"    # Here string (single line)

# COMBINING
command > out.txt 2> err.txt    # Separate files
command > file 2>&1             # Same file (correct order)
command 2>&1 | tee file         # Pipe both to tee

# SUPPRESSING
command > /dev/null             # Suppress output
command 2> /dev/null            # Suppress errors
command &> /dev/null            # Suppress everything

# ADVANCED
exec > file                     # Redirect all script output
exec 2> file                    # Redirect all script errors
exec &> file                    # Redirect everything in script
```

---

## 12. Practice Exercises

### Exercise 1: Log Parser

Create a script that:

1. Reads log entries from a file
2. Separates errors and warnings into different files
3. Creates a summary report

### Exercise 2: Backup System

Build a backup script that:

1. Logs all operations
2. Separates errors from success messages
3. Emails admin on failure
4. Keeps last 7 days of logs

### Exercise 3: Service Monitor

Create a monitoring script that:

1. Checks multiple services
2. Logs status to rotating log files
3. Alerts on errors
4. Generates daily summary

---

## Summary

**Key Takeaways:**

- Redirection controls where data flows
- `>` overwrites, `>>` appends
- `2>` redirects errors, `&>` redirects both
- Order matters: `> file 2>&1` not `2>&1 > file`
- Use `/dev/null` to discard output
- Use `tee` for multiple destinations
- Here documents (`<<`) for multi-line input
- Here strings (`<<<`) for single strings

**Real-World Impact:**

- Essential for automation and scripting
- Critical for logging and monitoring
- Fundamental DevOps skill
- Used in CI/CD pipelines
- Required for system administration

---

**This guide is comprehensive for both learning and reference. Practice each lab to master Linux I/O redirection!**
