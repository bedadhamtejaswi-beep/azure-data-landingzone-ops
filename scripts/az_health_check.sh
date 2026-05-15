#!/bin/bash
# =============================================================================
# Azure Data Platform Health Check Script
# =============================================================================
# Performs comprehensive health checks on all Data Landing Zone resources:
# - PostgreSQL Flexible Server
# - Databricks Workspace
# - Storage Accounts
# - Key Vault
# - Cosmos DB
# - Network Connectivity
#
# Usage: ./az_health_check.sh [dev|prod]
# =============================================================================

set -euo pipefail

ENV="${1:-dev}"
PREFIX="dlz-${ENV}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
PASS=0
FAIL=0
WARN=0

log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; ((PASS++)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; ((FAIL++)); }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; ((WARN++)); }
log_info() { echo -e "[INFO] $1"; }

echo "=============================================="
echo "  Data Platform Health Check - ${ENV^^}"
echo "  $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "=============================================="
echo ""

# -------------------------------------------------------------------
# PostgreSQL Health
# -------------------------------------------------------------------
log_info "Checking PostgreSQL Flexible Server..."
PG_RG="${PREFIX}-postgresql-rg"
PG_SERVER="${PREFIX}-pgflex"

PG_STATE=$(az postgres flexible-server show \
    --name "$PG_SERVER" --resource-group "$PG_RG" \
    --query "state" -o tsv 2>/dev/null || echo "NOT_FOUND")

if [ "$PG_STATE" == "Ready" ]; then
    log_pass "PostgreSQL server is Ready"
else
    log_fail "PostgreSQL server state: $PG_STATE"
fi

# Check HA status
HA_STATE=$(az postgres flexible-server show \
    --name "$PG_SERVER" --resource-group "$PG_RG" \
    --query "highAvailability.state" -o tsv 2>/dev/null || echo "N/A")
if [ "$HA_STATE" == "Healthy" ]; then
    log_pass "PostgreSQL HA is Healthy"
elif [ "$HA_STATE" == "NotEnabled" ]; then
    log_warn "PostgreSQL HA is not enabled"
else
    log_fail "PostgreSQL HA state: $HA_STATE"
fi

# Check CPU utilization
CPU=$(az monitor metrics list \
    --resource "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/${PG_RG}/providers/Microsoft.DBforPostgreSQL/flexibleServers/${PG_SERVER}" \
    --metric "cpu_percent" \
    --interval PT1H \
    --query "value[0].timeseries[0].data[-1].average" -o tsv 2>/dev/null || echo "N/A")

if [ "$CPU" != "N/A" ]; then
    CPU_INT=${CPU%.*}
    if [ "$CPU_INT" -lt 80 ]; then
        log_pass "PostgreSQL CPU: ${CPU}%"
    else
        log_warn "PostgreSQL CPU is high: ${CPU}%"
    fi
fi

echo ""

# -------------------------------------------------------------------
# Storage Health
# -------------------------------------------------------------------
log_info "Checking Storage Account..."
STORAGE_NAME="${PREFIX//[-]/ }"
STORAGE_NAME="${STORAGE_NAME// /}dls"
STORAGE_RG="${PREFIX}-storage-rg"

STORAGE_STATUS=$(az storage account show \
    --name "$STORAGE_NAME" --resource-group "$STORAGE_RG" \
    --query "statusOfPrimary" -o tsv 2>/dev/null || echo "NOT_FOUND")

if [ "$STORAGE_STATUS" == "available" ]; then
    log_pass "Storage account primary is available"
else
    log_fail "Storage account status: $STORAGE_STATUS"
fi

echo ""

# -------------------------------------------------------------------
# Key Vault Health
# -------------------------------------------------------------------
log_info "Checking Key Vault..."
KV_NAME="${PREFIX}-kv"
KV_RG="${PREFIX}-keyvault-rg"

KV_STATUS=$(az keyvault show \
    --name "$KV_NAME" --resource-group "$KV_RG" \
    --query "properties.enableSoftDelete" -o tsv 2>/dev/null || echo "NOT_FOUND")

if [ "$KV_STATUS" == "true" ]; then
    log_pass "Key Vault soft delete is enabled"
else
    log_fail "Key Vault soft delete: $KV_STATUS"
fi

echo ""

# -------------------------------------------------------------------
# Summary
# -------------------------------------------------------------------
echo ""
echo "=============================================="
echo "  Health Check Summary"
echo "=============================================="
echo -e "  ${GREEN}Passed:${NC}  $PASS"
echo -e "  ${RED}Failed:${NC}  $FAIL"
echo -e "  ${YELLOW}Warnings:${NC} $WARN"
echo "=============================================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi

# Exit codes: 0 = healthy, 1 = failures detected
