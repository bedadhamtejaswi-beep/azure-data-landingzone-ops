# Capacity Planning Runbook

## Overview
This runbook outlines the procedures for monitoring, forecasting, and managing capacity across the Azure Data Landing Zone.

## Monthly Capacity Review Checklist

- [ ] Run capacity forecast script: `./scripts/az_capacity_forecast.sh prod 30`
- [ ] Review PostgreSQL storage growth trend
- [ ] Review Data Lake storage volume by zone (raw/curated/enriched/archive)
- [ ] Check Cosmos DB RU consumption vs. provisioned
- [ ] Review Databricks cluster utilization patterns
- [ ] Update capacity forecast spreadsheet
- [ ] File tickets for any needed scaling

## Capacity Thresholds

| Resource | Warning | Critical | Action |
|----------|---------|----------|--------|
| PostgreSQL CPU | 70% avg | 85% avg | Scale up SKU |
| PostgreSQL Storage | 75% | 90% | Expand storage |
| PostgreSQL Connections | 80% of max | 95% of max | Increase max connections or scale |
| Data Lake Storage | 80% of budget | 90% of budget | Archive/cleanup or increase budget |
| Cosmos DB RU | 70% of provisioned | 90% of provisioned | Increase RU or enable autoscale |

## Scaling Procedures

### PostgreSQL Vertical Scaling
```bash
# Scale up compute
az postgres flexible-server update \
    --name dlz-prod-pgflex \
    --resource-group dlz-prod-postgresql-rg \
    --sku-name GP_Standard_D8s_v3

# Increase storage (cannot be reduced)
az postgres flexible-server update \
    --name dlz-prod-pgflex \
    --resource-group dlz-prod-postgresql-rg \
    --storage-size 524288
```

### Cosmos DB Throughput Scaling
```bash
# Update database throughput
az cosmosdb sql database throughput update \
    --account-name dlz-prod-cosmos \
    --resource-group dlz-prod-cosmosdb-rg \
    --name platform_events \
    --throughput 1200
```

## Forecasting Guidelines

1. Collect 90 days of historical metrics
2. Calculate average daily growth rate
3. Project forward 90/180/365 days
4. Plan scaling actions 30 days before projected threshold breach
