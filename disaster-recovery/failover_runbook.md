# Failover Runbook

## Purpose
Step-by-step procedure for executing a failover of the Data Landing Zone to the DR region.

## Pre-Requisites
- Azure CLI authenticated with sufficient permissions
- Access to the on-call communication bridge
- Incident declared and approved by management (SEV-1/SEV-2)

## Failover Types

### Planned Failover (Maintenance)
Used for planned maintenance windows. Zero data loss expected.

```bash
# 1. Notify stakeholders
# 2. Set maintenance window in monitoring

# 3. PostgreSQL planned failover
az postgres flexible-server restart \
    --name dlz-prod-pgflex \
    --resource-group dlz-prod-postgresql-rg \
    --failover Planned

# 4. Wait for completion (typically 60-120 seconds)

# 5. Verify
az postgres flexible-server show \
    --name dlz-prod-pgflex \
    --resource-group dlz-prod-postgresql-rg \
    --query "{state:state, haState:highAvailability.state}"
```

### Forced Failover (Emergency)
Used when primary is unreachable. Minimal data loss possible.

```bash
# 1. Declare incident

# 2. PostgreSQL forced failover
az postgres flexible-server restart \
    --name dlz-prod-pgflex \
    --resource-group dlz-prod-postgresql-rg \
    --failover Forced

# 3. Cosmos DB regional failover
az cosmosdb failover-priority-change \
    --name dlz-prod-cosmos \
    --resource-group dlz-prod-cosmosdb-rg \
    --failover-policies "eastus2=0" "centralus=1"

# 4. Verify all services
./scripts/az_health_check.sh prod
```

### Cross-Region Failover (Full DR)
Used when entire primary region is unavailable.

```bash
# 1. Declare disaster - requires VP approval

# 2. Run DR automation playbook
cd ansible
ansible-playbook playbooks/disaster_recovery.yml \
    -e "dr_type=forced" \
    -e "failover_cosmos=true"

# 3. Deploy infrastructure in DR region (if not pre-provisioned)
cd terraform/environments/prod
# Update backend and provider to DR region
terraform init
terraform apply

# 4. Restore PostgreSQL from geo-redundant backup
az postgres flexible-server geo-restore \
    --name dlz-dr-pgflex \
    --resource-group dlz-dr-postgresql-rg \
    --source-server dlz-prod-pgflex \
    --location eastus2

# 5. Update DNS/application configuration

# 6. Validate
./scripts/az_health_check.sh prod
```

## Post-Failover Checklist
- [ ] All databases accessible
- [ ] Application connectivity verified
- [ ] Monitoring operational in new region
- [ ] Stakeholders notified
- [ ] Incident timeline documented
- [ ] Root cause analysis initiated
