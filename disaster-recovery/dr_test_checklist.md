# DR Test Checklist

Use this checklist during quarterly DR tests.

## Pre-Test Preparation

- [ ] Schedule maintenance window
- [ ] Notify all stakeholders
- [ ] Verify DR region resources are provisioned
- [ ] Confirm backup currency for all databases
- [ ] Set up communication bridge
- [ ] Assign roles: Incident Commander, DB Lead, Network Lead, Comms Lead

## During Test

### Phase 1: Failover

- [ ] Run pre-failover health check: `./scripts/az_health_check.sh prod`
- [ ] Document current state metrics (connections, CPU, storage)
- [ ] Initiate PostgreSQL failover
- [ ] Initiate Cosmos DB failover (if testing)
- [ ] Initiate storage failover (if testing)
- [ ] Record failover start time: __________
- [ ] Record failover completion time: __________

### Phase 2: Validation

- [ ] PostgreSQL is accessible from application subnet
- [ ] All databases are present and accessible
- [ ] Run data integrity checks
- [ ] Cosmos DB reads/writes functioning
- [ ] Storage accounts accessible
- [ ] Databricks workspace operational (if redeployed)
- [ ] Key Vault secrets accessible
- [ ] Monitoring and alerting operational
- [ ] Record validation completion time: __________

### Phase 3: Failback

- [ ] Initiate failback to primary region
- [ ] Verify data synchronization
- [ ] Confirm all services operational in primary
- [ ] Record failback completion time: __________

## Post-Test

- [ ] Calculate actual RTO: __________
- [ ] Calculate actual RPO: __________
- [ ] Compare against targets
- [ ] Document lessons learned
- [ ] Update DR plan with improvements
- [ ] File follow-up tickets for gaps
- [ ] Update RTO/RPO matrix
- [ ] Send test report to stakeholders
