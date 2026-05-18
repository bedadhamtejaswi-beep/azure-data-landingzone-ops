# Incident Response Runbook

## Purpose
This runbook provides step-by-step procedures for responding to incidents in the Azure Data Landing Zone platform.

## Severity Levels

| Level | Description | Response Time | Examples |
|-------|-------------|---------------|----------|
| SEV-1 | Critical - Platform down | 15 min | Database unreachable, data loss |
| SEV-2 | High - Degraded performance | 30 min | High CPU, storage > 90% |
| SEV-3 | Medium - Non-critical issue | 2 hours | Failed pipeline, warning alerts |
| SEV-4 | Low - Informational | Next business day | Log anomalies |

## Incident Response Procedures

### 1. PostgreSQL Database Unreachable (SEV-1)

**Symptoms:** Applications unable to connect, connection timeout errors

**Steps:**
1. Check PostgreSQL server status:
   ```bash
   az postgres flexible-server show --name dlz-prod-pgflex --resource-group dlz-prod-postgresql-rg --query "state"
   ```
2. Check network connectivity:
   ```bash
   ./scripts/az_network_diagnostics.sh prod
   ```
3. Review recent changes in Azure Activity Log
4. If HA is enabled, check failover status:
   ```bash
   az postgres flexible-server show --name dlz-prod-pgflex --resource-group dlz-prod-postgresql-rg --query "highAvailability"
   ```
5. If server is stopped, restart:
   ```bash
   az postgres flexible-server restart --name dlz-prod-pgflex --resource-group dlz-prod-postgresql-rg
   ```

### 2. High CPU Alert (SEV-2)

**Steps:**
1. Identify resource-intensive queries via Log Analytics
2. Check for runaway processes or jobs
3. Scale up SKU if persistent:
   ```bash
   az postgres flexible-server update --name dlz-prod-pgflex --resource-group dlz-prod-postgresql-rg --sku-name GP_Standard_D8s_v3
   ```

### 3. Storage Threshold Alert (SEV-2)

**Steps:**
1. Check current usage: `./scripts/az_capacity_forecast.sh prod`
2. Identify large tables/databases
3. Archive or clean old data
4. Increase storage if needed

### 4. Databricks Cluster Failure (SEV-3)

**Steps:**
1. Check workspace status in Azure Portal
2. Review cluster event logs
3. Verify network connectivity to Databricks control plane
4. Restart cluster or create new cluster from policy

## Escalation Path

1. **On-Call Engineer** → Initial triage and response
2. **Platform Team Lead** → SEV-1/SEV-2 not resolved within SLA
3. **Azure Support** → Infrastructure-level issues
4. **Management** → SEV-1 lasting > 1 hour

## Communication Templates

### Incident Start
```
🔴 INCIDENT: [Brief Description]
Severity: SEV-[1-4]
Impact: [Who/what is affected]
Status: Investigating
Lead: [Name]
Bridge: [Link]
```

### Incident Update
```
🟡 UPDATE: [Brief Description]
Status: [Investigating/Identified/Mitigating/Resolved]
Actions taken: [What was done]
Next steps: [What's planned]
ETA: [If known]
```
