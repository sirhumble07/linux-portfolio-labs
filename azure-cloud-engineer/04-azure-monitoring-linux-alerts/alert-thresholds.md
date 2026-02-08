# Alert Thresholds and Justifications - Lab 04

## Understanding Alert Thresholds

Alert thresholds define the **trigger points** for generating alerts based on metric values. Setting appropriate thresholds is critical to avoid:

- **False positives**: Alerts triggered for normal operations (alert fatigue)
- **Missed incidents**: Thresholds set too high, missing real problems

---

## CPU Alert: Percentage CPU

### CPU Threshold Configuration

| Parameter | Value | Reasoning |
| --------- | ----- | --------- |
| **Metric** | Percentage CPU | Standard CPU utilization metric |
| **Operator** | Greater than | Alerts when CPU exceeds threshold |
| **Threshold** | 80% | Industry standard for high CPU |
| **Aggregation** | Average | Smooths out brief spikes |
| **Time window** | 5 minutes | Balances responsiveness and stability |
| **Frequency** | 1 minute | Checks metric every minute |

### Threshold Justification: 80%

**Why 80%?**

- **Industry Standard**: Most organizations use 70-85% as high CPU threshold
- **Headroom**: Leaves 20% capacity for burst workloads
- **Performance Impact**: Above 80%, applications often experience slowdowns
- **Sustained Load**: Using "Average" over 5 minutes filters out brief spikes

**Alternative Thresholds**:

- **70%**: More conservative, suitable for production critical systems
- **85-90%**: Less sensitive, acceptable for dev/test environments
- **95%**: Only for detection of extreme conditions (near saturation)

### When to Adjust

✅ **Lower threshold (60-70%)** if:

- Application is latency-sensitive (e.g., real-time systems)
- VM is production-critical
- Historical data shows performance degradation at lower CPU

✅ **Higher threshold (85-90%)** if:

- Application can tolerate high CPU briefly
- Cost optimization is priority (run hotter)
- Historical data shows no issues at higher CPU

---

## CPU Alert: Time Window and Aggregation

### Time Window: 5 Minutes

**Why 5 minutes?**

- **Filters noise**: Brief CPU spikes (seconds) won't trigger alerts
- **Captures real issues**: Sustained high CPU for 5 minutes indicates a problem
- **Actionable**: Gives time to investigate before critical impact

**Alternatives**:

- **1-2 minutes**: For highly sensitive systems needing immediate response
- **10-15 minutes**: For workloads with expected CPU variations

### Aggregation: Average

**Why Average?**

- **Smooths spikes**: A single 100% spike averaged with lower values may stay below 80%
- **Sustained load detection**: Consistently high CPU will trigger the alert
- **Reduces false positives**: Temporary bursts don't cause alerts

**Alternatives**:

- **Maximum**: Alerts if CPU ever hits threshold (more sensitive, more false positives)
- **Minimum**: Rarely used for CPU (useful for detecting idle/hung processes)

---

## Disk Usage Alert

### Disk Threshold Configuration

| Parameter | Value | Reasoning |
| --------- | ----- | --------- |
| **Metric** | Disk Used % (or Available Bytes) | Disk space utilization |
| **Operator** | Greater than | Alerts when disk usage exceeds threshold |
| **Threshold** | 85% | Standard for disk space warnings |
| **Aggregation** | Average | Consistent disk usage measurement |
| **Time window** | 5 minutes | Disk usage changes slowly |
| **Frequency** | 5 minutes | Less frequent checks (disk is slower to change) |

### Threshold Justification: 85%

**Why 85%?**

- **Critical Threshold**: Most Linux systems start experiencing issues at 90%+
- **Time to Act**: Leaves margin for investigation and remediation
- **OS Reserve**: Linux often reserves 5% for root (so 95% user-visible = 100% actual)
- **Log Growth**: Prevents logs from filling disk unexpectedly

**Severity Levels**:

| Disk Usage | Severity | Action |
|------------|----------|--------|
| **< 70%** | Normal | No action |
| **70-85%** | Warning | Monitor, plan cleanup |
| **85-90%** | Alert | **This lab's threshold** - Investigate and remediate |
| **90-95%** | Critical | Immediate action required |
| **> 95%** | Emergency | System may become unstable |

### Alternative Thresholds

- **75-80%**: More proactive, gives more time to react
- **90%**: More aggressive, suitable if automated cleanup exists
- **Use Available Bytes instead**: e.g., "Alert when < 5GB free" (absolute value)

### When to Adjust

✅ **Lower threshold (75-80%)** if:
- Disk cleanup is manual and slow
- Application writes large files unpredictably
- System is production-critical

✅ **Higher threshold (90%)** if:

- Automated cleanup scripts exist
- Disk can be expanded quickly (cloud auto-scaling)
- Historical data shows no issues at higher usage

---

## Memory Alert (Optional/Recommended)

### Memory Threshold Configuration

| Parameter | Value | Reasoning |
| --------- | ----- | --------- |
| **Metric** | Available Memory Bytes | Actual free memory |
| **Operator** | Less than | Alerts when memory drops below threshold |
| **Threshold** | 200 MB (or 10% of total) | Minimum for stable operation |
| **Aggregation** | Average | Consistent measurement |
| **Time window** | 5 minutes | Memory usage can fluctuate |

### Threshold Justification

**Why monitor memory?**

- **OOM Killer**: Linux Out-Of-Memory killer terminates processes when memory is exhausted
- **Swap Thrashing**: Low memory causes excessive swapping, killing performance
- **Application Crashes**: Many apps fail gracefully when memory is low

**Recommended Thresholds**:

- **< 100-200 MB available**: Critical (VM likely to experience OOM)
- **< 10% available**: Warning
- **> 80% used**: Alternative metric (memory pressure)

---

## Network Alerts (Advanced)

### Inbound/Outbound Bytes

| Parameter | Value | Reasoning |
| --------- | ----- | --------- |
| **Metric** | Network In/Out Total | Bandwidth usage |
| **Operator** | Greater than | Detect unusual traffic |
| **Threshold** | 100 MB/min (baseline + 50%) | Depends on normal traffic |
| **Aggregation** | Total | Sum of bytes over period |

**Use Cases**:

- **DDoS Detection**: Sudden spike in inbound traffic
- **Data Exfiltration**: Unusual outbound traffic
- **Cost Management**: High bandwidth = high egress charges

---

## Best Practices for Setting Thresholds

### 1. Baseline Your Metrics

Before setting thresholds, **collect baseline data**:

```bash
# Collect CPU baseline for 1 week
az monitor metrics list \
  --resource <vm-id> \
  --metric "Percentage CPU" \
  --start-time 2024-02-01T00:00:00Z \
  --end-time 2024-02-08T00:00:00Z \
  --aggregation Average \
  --interval PT1H
```

**Analysis**:

- **Normal operation**: What's the average and max during normal load?
- **Peak hours**: What's the 95th percentile during busy times?
- **Off-hours**: What's the baseline when idle?

**Set thresholds**: Peak + 10-20% margin

---

### 2. Use Percentiles, Not Absolutes

Instead of "CPU > 80% triggers alert", consider:

- **P95 over 5 min > 80%**: Alerts if 95% of samples exceed 80%
- **P99 over 5 min > 90%**: Alerts only if nearly all samples are high

Azure Monitor uses **aggregation** for this:

- **Average**: Good for sustained load
- **Maximum**: Sensitive to brief spikes
- **Minimum**: Useful for detecting idle/stuck processes

---

### 3. Implement Alert Tiers

Instead of one alert, use multiple severity levels:

| Severity | CPU Threshold | Disk Threshold | Action |
| -------- | ------------- | -------------- | ------ |
| **Informational** | 60% | 70% | Log only, no notification |
| **Warning** | 70% | 80% | Email to team |
| **Critical** | 80% | 90% | Email + SMS + Runbook |
| **Emergency** | 95% | 95% | Page on-call engineer |

---

### 4. Adjust for Time of Day

Some workloads have predictable patterns:

- **Business hours**: Higher thresholds acceptable (70-80% CPU)
- **Off-hours/weekends**: Lower thresholds (50-60% CPU)

Use **dynamic thresholds** (Azure Monitor ML-based) for this.

---

### 5. Alert on Trends, Not Absolutes

Instead of "Disk > 85%", consider:

- **Disk growth rate**: "Disk increased by 10% in 24 hours"
- **Time to full**: "At current rate, disk will be full in 7 days"

Azure Monitor supports these via Log Analytics queries.

---

## Lab-Specific Threshold Choices

### Why 80% CPU for This Lab?

✅ **Easy to trigger**: Using `stress` command, we can reliably hit 80%  
✅ **Clearly demonstrates alerts**: High enough to be meaningful, not so high we risk VM instability  
✅ **Standard threshold**: Aligns with industry best practices  
✅ **Visible impact**: At 80% CPU, you'll notice slowdown in SSH responsiveness  

### Why 85% Disk for This Lab?

✅ **Safe margin**: Won't risk filling disk and breaking VM  
✅ **Realistic threshold**: Mirrors production usage  
✅ **Observable**: Easy to simulate by creating large files  

---

## Testing Your Thresholds

### CPU Test

```bash
# Install stress tool
sudo apt update && sudo apt -y install stress

# Generate CPU load (2 cores, 6 minutes)
stress --cpu 2 --timeout 360

# Monitor in real-time
top
```

Expected: Alert fires after ~5 minutes (threshold + time window)

---

### Disk Test

```bash
# Check current disk usage
df -h

# Create a large file to simulate disk usage
# WARNING: Adjust size based on available space
dd if=/dev/zero of=/tmp/testfile bs=1G count=5

# Check usage again
df -h

# Clean up
rm /tmp/testfile
```

Expected: Alert fires if disk exceeds 85%

---

## Alert Fatigue: Avoiding False Positives

### Common Causes

- **Thresholds too low**: Normal operations trigger alerts
- **Time window too short**: Brief spikes cause alerts
- **Aggregation wrong**: Using "Maximum" instead of "Average"
- **No suppression**: Same alert fires repeatedly

### Solutions

✅ **Tune thresholds** based on historical data  
✅ **Increase time windows** to filter noise  
✅ **Use aggregation wisely** (Average for most cases)  
✅ **Implement alert suppression** (don't alert more than once per hour)  
✅ **Use action groups effectively** (different actions for different severities)  

---

## Production Recommendations

For production environments:

1. **Start conservative**: Lower thresholds, adjust upward based on false positive rate
2. **Use dynamic thresholds**: Azure Monitor ML-based thresholds adapt to patterns
3. **Implement auto-remediation**: Combine alerts with Azure Automation runbooks
4. **Regular reviews**: Quarterly review of alert thresholds and effectiveness
5. **Document everything**: Why each threshold was chosen, what action to take

---

## Summary: Lab Threshold Choices

| Metric   | Threshold | Time Window | Aggregation | Justification                                          |
| -------- | --------- | ----------- | ----------- | ------------------------------------------------------ |
| **CPU**  | 80%       | 5 minutes   | Average     | Standard for sustained high CPU, filters brief spikes  |
| **Disk** | 85%       | 5 minutes   | Average     | Critical level with safe margin, time to remediate     |

These thresholds balance:

- **Sensitivity**: Catch real problems
- **Specificity**: Avoid false alarms
- **Actionability**: Give time to respond

**Next Steps**: In production, baseline your specific workload and adjust thresholds accordingly.
