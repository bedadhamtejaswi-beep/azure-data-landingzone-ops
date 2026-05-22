# Troubleshooting Guide

## Common Issues and Resolutions

### 1. Terraform Plan/Apply Failures

#### Issue: "Error acquiring state lock"
**Cause:** Another Terraform operation is running or a previous run crashed.
**Resolution:**
```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

#### Issue: "Provider version constraint mismatch"
**Cause:** Provider version in lock file doesn't match constraint.
**Resolution:**
```bash
terraform init -upgrade
```

#### Issue: "Subnet not found" during apply
**Cause:** Dependencies between resources not properly defined.
**Resolution:** Ensure `depends_on` is set or use module outputs as inputs.

---

### 2. PostgreSQL Connectivity Issues

#### Issue: Connection timeout from application
**Diagnosis:**
```bash
# Check server status
az postgres flexible-server show --name <server> --resource-group <rg> --query "state"

# Verify NSG rules
./scripts/az_network_diagnostics.sh <env>

# Test connectivity from a VM in the VNet
psql "host=<fqdn> port=5432 dbname=analytics user=pgadmin sslmode=require"
```

#### Issue: SSL/TLS connection errors
**Cause:** Client not using TLS 1.2+
**Resolution:** Ensure connection string includes `sslmode=require` and client supports TLS 1.2.

---

### 3. Databricks Workspace Issues

#### Issue: Cluster fails to start
**Diagnosis:**
1. Check Databricks workspace event log
2. Verify VNet injection subnets have available IPs
3. Check NSG rules allow Databricks control plane traffic

#### Issue: Cannot access Data Lake from Databricks
**Cause:** Missing service principal permissions or firewall rules.
**Resolution:**
1. Verify service principal has Storage Blob Data Contributor role
2. Check storage account firewall allows Databricks subnet

---

### 4. GitHub Actions Pipeline Failures

#### Issue: Terraform init fails in CI
**Cause:** Azure credentials not configured or expired.
**Resolution:**
1. Verify GitHub secrets are set: `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, etc.
2. Check service principal has required roles
3. Verify service principal hasn't expired

#### Issue: Liquibase migration fails
**Cause:** Database unreachable from GitHub-hosted runner.
**Resolution:** Use self-hosted runner in the VNet or Azure Bastion for tunneling.

---

### 5. Monitoring and Alerting

#### Issue: No data in Log Analytics
**Diagnosis:**
1. Check diagnostic settings are enabled:
   ```bash
   az monitor diagnostic-settings list --resource <resource_id>
   ```
2. Verify Azure Monitor Agent is running on VMs:
   ```bash
   systemctl status azuremonitoragent
   ```

#### Issue: False positive alerts
**Resolution:** Adjust alert thresholds in `terraform/modules/monitoring/main.tf` or via Azure Portal.

---

## Useful Commands Reference

```bash
# Health check
./scripts/az_health_check.sh [dev|prod]

# Capacity forecast
./scripts/az_capacity_forecast.sh [dev|prod] [days]

# Backup validation
./scripts/az_backup_validate.sh [dev|prod]

# Network diagnostics
./scripts/az_network_diagnostics.sh [dev|prod]

# Liquibase status
liquibase --changeLogFile=changelog/db.changelog-master.xml status

# Ansible playbook (dry run)
ansible-playbook ansible/playbooks/configure_vm.yml --check --diff
```
