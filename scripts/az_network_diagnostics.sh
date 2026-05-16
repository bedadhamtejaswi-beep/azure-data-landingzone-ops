#!/bin/bash
# =============================================================================
# Network Diagnostics Script
# =============================================================================
# Troubleshoots network connectivity issues in the Data Landing Zone:
# - VNet peering status
# - NSG flow analysis
# - Private endpoint connectivity
# - DNS resolution checks
#
# Usage: ./az_network_diagnostics.sh [dev|prod]
# =============================================================================

set -euo pipefail

ENV="${1:-dev}"
PREFIX="dlz-${ENV}"
NET_RG="${PREFIX}-networking-rg"

echo "=============================================="
echo "  Network Diagnostics - ${ENV^^}"
echo "  $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "=============================================="
echo ""

# VNet Peering Status
echo "--- VNet Peering Status ---"
az network vnet peering list \
    --vnet-name "${PREFIX}-hub-vnet" \
    --resource-group "$NET_RG" \
    --query "[].{name:name, state:peeringState, syncLevel:peeringSyncLevel}" \
    -o table 2>/dev/null || echo "  Hub VNet not found"

echo ""

az network vnet peering list \
    --vnet-name "${PREFIX}-spoke-vnet" \
    --resource-group "$NET_RG" \
    --query "[].{name:name, state:peeringState, syncLevel:peeringSyncLevel}" \
    -o table 2>/dev/null || echo "  Spoke VNet not found"

echo ""

# NSG Rules
echo "--- NSG Effective Rules ---"
az network nsg show \
    --name "${PREFIX}-data-nsg" \
    --resource-group "$NET_RG" \
    --query "securityRules[].{name:name, priority:priority, direction:direction, access:access, protocol:protocol, destPort:destinationPortRange}" \
    -o table 2>/dev/null || echo "  NSG not found"

echo ""

# Private Endpoints
echo "--- Private Endpoints ---"
az network private-endpoint list \
    --resource-group "$NET_RG" \
    --query "[].{name:name, subnet:subnet.id, status:privateLinkServiceConnections[0].privateLinkServiceConnectionState.status}" \
    -o table 2>/dev/null

# Check across all resource groups
for rg in "${PREFIX}-storage-rg" "${PREFIX}-keyvault-rg" "${PREFIX}-cosmosdb-rg"; do
    az network private-endpoint list \
        --resource-group "$rg" \
        --query "[].{name:name, status:privateLinkServiceConnections[0].privateLinkServiceConnectionState.status}" \
        -o table 2>/dev/null || true
done

echo ""

# Private DNS Zones
echo "--- Private DNS Zones ---"
az network private-dns zone list \
    --resource-group "$NET_RG" \
    --query "[].{name:name, records:numberOfRecordSets}" \
    -o table 2>/dev/null || echo "  No private DNS zones found"

echo ""
echo "Network diagnostics complete."

# Requires Network Contributor RBAC role
