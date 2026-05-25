#!/bin/bash
# =============================================================================
# Backup Validation Script
# =============================================================================
# Validates backup configuration and restore readiness:
# - PostgreSQL backup status and retention
# - Storage account replication status
# - Cosmos DB backup policy verification
#
# Usage: ./az_backup_validate.sh [dev|prod]
# =============================================================================

set -euo pipefail

ENV="${1:-dev}"
PREFIX="dlz-${ENV}"

echo "=============================================="
echo "  Backup Validation - ${ENV^^}"
echo "  $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "=============================================="
echo ""

# PostgreSQL Backup
echo "--- PostgreSQL Backup Configuration ---"
PG_SERVER="${PREFIX}-pgflex"
PG_RG="${PREFIX}-postgresql-rg"

az postgres flexible-server show \
    --name "$PG_SERVER" --resource-group "$PG_RG" \
    --query "{backupRetention:backup.backupRetentionDays, geoRedundant:backup.geoRedundantBackup, earliestRestore:backup.earliestRestoreDate}" \
    -o table 2>/dev/null || echo "  PostgreSQL server not found"

echo ""

# Storage Replication
echo "--- Storage Replication ---"
STORAGE_NAME="${PREFIX//[-]/}dls"
STORAGE_RG="${PREFIX}-storage-rg"

az storage account show \
    --name "$STORAGE_NAME" --resource-group "$STORAGE_RG" \
    --query "{replication:sku.name, primaryStatus:statusOfPrimary, secondaryStatus:statusOfSecondary}" \
    -o table 2>/dev/null || echo "  Storage account not found"

echo ""

# Cosmos DB Backup
echo "--- Cosmos DB Backup Policy ---"
COSMOS_NAME="${PREFIX}-cosmos"
COSMOS_RG="${PREFIX}-cosmosdb-rg"

az cosmosdb show \
    --name "$COSMOS_NAME" --resource-group "$COSMOS_RG" \
    --query "{backupType:backupPolicy.type, intervalMinutes:backupPolicy.periodicModeProperties.backupIntervalInMinutes, retentionHours:backupPolicy.periodicModeProperties.backupRetentionIntervalInHours, redundancy:backupPolicy.periodicModeProperties.backupStorageRedundancy}" \
    -o table 2>/dev/null || echo "  Cosmos DB account not found"

echo ""
echo "Backup validation complete."

# Added error handling improvements
