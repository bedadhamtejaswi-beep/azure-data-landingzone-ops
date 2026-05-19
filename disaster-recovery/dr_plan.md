# Disaster Recovery Plan

## Document Information
| Field | Value |
|-------|-------|
| **Owner** | Data Platform Operations Team |
| **Last Updated** | 2025-09-15 |
| **Review Frequency** | Quarterly |
| **Classification** | Confidential |

## 1. Overview

This document defines the Disaster Recovery (DR) strategy for the Azure Data Landing Zone platform. It covers all critical components including databases, storage, compute, and networking.

## 2. DR Objectives

| Metric | Target | Current |
|--------|--------|---------|
| **RTO (Recovery Time Objective)** | 4 hours | 2 hours (tested) |
| **RPO (Recovery Point Objective)** | 1 hour | ~5 minutes (continuous backup) |
| **DR Test Frequency** | Quarterly | Quarterly |
| **Last DR Test** | 2025-08-20 | Passed |

## 3. Architecture

### Primary Region: Central US
- All production workloads
- Hub-spoke network topology
- Active Databricks workspace

### DR Region: East US 2
- Geo-replicated PostgreSQL backups
- GRS storage replication
- Cosmos DB multi-region writes
- Standby networking (pre-provisioned via Terraform)

## 4. Component DR Strategy

### 4.1 PostgreSQL Flexible Server
- **Strategy:** Zone-redundant HA + Geo-redundant backups
- **Failover:** Automatic (within region), Manual (cross-region)
- **RPO:** ~5 minutes (continuous WAL archiving)
- **RTO:** < 10 minutes (intra-region), < 2 hours (cross-region)
- **Procedure:** See `ansible/playbooks/disaster_recovery.yml`

### 4.2 Azure Data Lake Storage
- **Strategy:** GRS (Geo-Redundant Storage)
- **Failover:** Microsoft-managed or customer-initiated
- **RPO:** < 15 minutes
- **RTO:** < 1 hour

### 4.3 Cosmos DB
- **Strategy:** Multi-region with automatic failover
- **Failover:** Automatic (configured)
- **RPO:** ~0 (strong consistency) to ~5 min (session consistency)
- **RTO:** < 10 minutes

### 4.4 Azure Databricks
- **Strategy:** Re-deploy workspace in DR region via Terraform
- **RTO:** < 2 hours (Terraform apply)
- **Data:** Backed up via underlying ADLS

### 4.5 Key Vault
- **Strategy:** Soft delete + Purge protection, manual recreation if needed
- **Secrets:** Backed up and stored securely

## 5. Failover Procedure

### Phase 1: Assessment (0-15 minutes)
1. Confirm outage scope and impact
2. Declare disaster (requires VP approval for production)
3. Activate DR communication bridge

### Phase 2: Failover Execution (15 min - 2 hours)
1. Run automated DR playbook:
   ```bash
   ansible-playbook ansible/playbooks/disaster_recovery.yml -e "dr_type=forced"
   ```
2. Verify database connectivity in DR region
3. Update DNS records if needed
4. Validate application connectivity

### Phase 3: Validation (2-3 hours)
1. Run health check: `./scripts/az_health_check.sh prod`
2. Verify data integrity
3. Test critical business workflows
4. Confirm monitoring is operational in DR region

### Phase 4: Communication
1. Notify stakeholders of successful failover
2. Update status page
3. Begin root cause analysis on primary region

## 6. Failback Procedure

1. Confirm primary region is stable
2. Resynchronize data from DR to primary
3. Run parallel validation
4. Execute planned failback during maintenance window
5. Verify all services operational in primary region

## 7. DR Testing Schedule

| Quarter | Test Type | Scope |
|---------|-----------|-------|
| Q1 | Tabletop | Full scenario walkthrough |
| Q2 | Component | PostgreSQL failover test |
| Q3 | Full | Complete DR failover and failback |
| Q4 | Tabletop + Lessons learned | Review and improve |
