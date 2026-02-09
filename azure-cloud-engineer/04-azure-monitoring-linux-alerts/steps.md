# Steps — Azure Monitoring for Linux: Alerts

## 1) Create RG + VM

Use any existing Linux VM or create:

- `rg-monitoring-linux-uks`
- VM in UK South

## 2) Enable monitoring

- VM → Monitoring → Insights
- Enable (installs agent)

## 3) Create Action Group

- Azure Monitor → Alerts → Action groups → Create
- Add Email notification to your email
- Name: `ag-linux-alerts`

## 4) Create CPU alert rule

- Alerts → Create → Alert rule
- Scope: your VM
- Signal: Percentage CPU
- Condition: Greater than 80
- Aggregation: Average
- Duration: 5 minutes
- Action group: `ag-linux-alerts`

## 5) Trigger CPU load

On VM:

```bash
sudo apt update
sudo apt -y install stress
stress --cpu 2 --timeout 360
```

## 6) Validate fired alert

- Azure Monitor → Alerts → check Fired
- Screenshot fired state + email received

## 7) Disk alert (optional but recommended)

- Signal: Disk Used % (or Available bytes depending on metrics)
- Choose threshold and document it
