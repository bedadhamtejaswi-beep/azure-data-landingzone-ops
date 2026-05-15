#!/bin/bash
# =============================================================================
# Capacity Forecasting Script
# =============================================================================
# Analyzes resource utilization trends and forecasts capacity needs:
# - PostgreSQL storage and connection trends
# - Storage account usage
# - Data Lake volume analysis
#
# Usage: ./az_capacity_forecast.sh [dev|prod] [days_lookback]
# =============================================================================

set -euo pipefail

ENV="${1:-dev}"
LOOKBACK="${2:-30}"
PREFIX="dlz-${ENV}"

echo "=============================================="
echo "  Capacity Forecast Report - ${ENV^^}"
echo "  Lookback: ${LOOKBACK} days"
echo "  $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "=============================================="
echo ""

# -------------------------------------------------------------------
# PostgreSQL Capacity
# -------------------------------------------------------------------
echo "--- PostgreSQL Flexible Server ---"
PG_SERVER="${PREFIX}-pgflex"
PG_RG="${PREFIX}-postgresql-rg"
SUB_ID=$(az account show --query id -o tsv)

RESOURCE_ID="/subscriptions/${SUB_ID}/resourceGroups/${PG_RG}/providers/Microsoft.DBforPostgreSQL/flexibleServers/${PG_SERVER}"

# Storage usage
echo "Storage Utilization (last ${LOOKBACK} days):"
az monitor metrics list \
    --resource "$RESOURCE_ID" \
    --metric "storage_percent" \
    --interval P1D \
    --start-time "$(date -d "-${LOOKBACK} days" '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -v-${LOOKBACK}d '+%Y-%m-%dT%H:%M:%SZ')" \
    --query "value[0].timeseries[0].data[*].{date:timeStamp, avg:average}" \
    -o table 2>/dev/null || echo "  Unable to retrieve metrics"

# Connection trends
echo ""
echo "Active Connections (last ${LOOKBACK} days):"
az monitor metrics list \
    --resource "$RESOURCE_ID" \
    --metric "active_connections" \
    --interval P1D \
    --start-time "$(date -d "-${LOOKBACK} days" '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -v-${LOOKBACK}d '+%Y-%m-%dT%H:%M:%SZ')" \
    --query "value[0].timeseries[0].data[*].{date:timeStamp, max:maximum, avg:average}" \
    -o table 2>/dev/null || echo "  Unable to retrieve metrics"

echo ""

# -------------------------------------------------------------------
# Storage Account Capacity
# -------------------------------------------------------------------
echo "--- Storage Account ---"
STORAGE_NAME="${PREFIX//[-]/}dls"
STORAGE_RG="${PREFIX}-storage-rg"

echo "Used Capacity:"
az monitor metrics list \
    --resource "/subscriptions/${SUB_ID}/resourceGroups/${STORAGE_RG}/providers/Microsoft.Storage/storageAccounts/${STORAGE_NAME}" \
    --metric "UsedCapacity" \
    --interval P1D \
    --start-time "$(date -d "-${LOOKBACK} days" '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -v-${LOOKBACK}d '+%Y-%m-%dT%H:%M:%SZ')" \
    --query "value[0].timeseries[0].data[*].{date:timeStamp, bytes:average}" \
    -o table 2>/dev/null || echo "  Unable to retrieve metrics"

echo ""
echo "=============================================="
echo "  Forecast complete. Review trends above."
echo "=============================================="
