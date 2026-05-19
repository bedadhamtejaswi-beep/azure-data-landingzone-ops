# RTO/RPO Matrix

## Recovery Objectives by Component

| Component | RPO Target | RPO Actual | RTO Target | RTO Actual | DR Strategy |
|-----------|-----------|------------|-----------|------------|-------------|
| PostgreSQL (intra-region) | 5 min | ~0 min | 15 min | 8 min | Zone-redundant HA |
| PostgreSQL (cross-region) | 1 hour | ~5 min | 4 hours | 1.5 hours | Geo-redundant backup + restore |
| Data Lake Storage | 15 min | < 15 min | 1 hour | 45 min | GRS replication |
| Cosmos DB | 5 min | ~0 min | 10 min | 5 min | Multi-region auto-failover |
| Key Vault | 24 hours | N/A | 4 hours | 2 hours | Soft delete + manual restore |
| Databricks | N/A | N/A | 4 hours | 2 hours | Re-deploy via Terraform |
| Networking | N/A | N/A | 1 hour | 30 min | Pre-provisioned in DR region |

## Business Impact by Downtime Duration

| Duration | Impact Level | Affected Systems | Business Impact |
|----------|-------------|------------------|-----------------|
| < 15 min | Low | Individual component | Minimal - automatic recovery |
| 15-60 min | Medium | Multiple components | Some analytics delayed |
| 1-4 hours | High | Platform-wide | Reporting unavailable |
| > 4 hours | Critical | Full outage | Business decision-making impacted |

## Testing Results

| Date | Test Type | Components Tested | RTO Achieved | RPO Achieved | Result |
|------|-----------|-------------------|-------------|-------------|--------|
| 2025-08-20 | Full DR | All | 1.5 hours | 3 min | ✅ Pass |
| 2025-05-15 | Component | PostgreSQL | 8 min | 0 min | ✅ Pass |
| 2025-02-10 | Tabletop | All | N/A | N/A | ✅ Pass |
