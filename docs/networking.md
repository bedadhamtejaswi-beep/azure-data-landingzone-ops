# Network Topology

## Overview

The Data Landing Zone uses a **hub-spoke** network architecture that provides centralized connectivity management, security controls, and isolation for data workloads.

## Address Space Allocation

### Development Environment

| VNet / Subnet | CIDR | Purpose |
|---------------|------|---------|
| Hub VNet | 10.0.0.0/16 | Shared services |
| ├── GatewaySubnet | 10.0.1.0/24 | VPN/ExpressRoute gateway |
| ├── AzureFirewallSubnet | 10.0.2.0/24 | Azure Firewall |
| └── shared-services | 10.0.3.0/24 | Monitoring, DNS |
| Spoke VNet | 10.1.0.0/16 | Data Landing Zone |
| ├── data-subnet | 10.1.1.0/24 | PostgreSQL, VMs |
| ├── databricks-public | 10.1.2.0/24 | Databricks host subnet |
| ├── databricks-private | 10.1.3.0/24 | Databricks container subnet |
| └── private-endpoints | 10.1.4.0/24 | Private endpoints |

### Production Environment

| VNet / Subnet | CIDR | Purpose |
|---------------|------|---------|
| Hub VNet | 10.10.0.0/16 | Shared services |
| ├── GatewaySubnet | 10.10.1.0/24 | VPN/ExpressRoute gateway |
| ├── AzureFirewallSubnet | 10.10.2.0/24 | Azure Firewall |
| └── shared-services | 10.10.3.0/24 | Monitoring, DNS |
| Spoke VNet | 10.11.0.0/16 | Data Landing Zone |
| ├── data-subnet | 10.11.1.0/24 | PostgreSQL, VMs |
| ├── databricks-public | 10.11.2.0/24 | Databricks host subnet |
| ├── databricks-private | 10.11.3.0/24 | Databricks container subnet |
| └── private-endpoints | 10.11.4.0/24 | Private endpoints |

## NSG Rules Summary

### Data Subnet NSG

| Priority | Direction | Access | Protocol | Port | Source | Destination |
|----------|-----------|--------|----------|------|--------|-------------|
| 100 | Inbound | Allow | * | * | Hub VNet | * |
| 200 | Inbound | Allow | TCP | 5432 | VNet | VNet |
| 4096 | Inbound | Deny | * | * | Internet | * |
| 100 | Outbound | Allow | TCP | 443 | * | AzureCloud |

## Private DNS Zones

| DNS Zone | Purpose |
|----------|---------|
| privatelink.blob.core.windows.net | Blob storage |
| privatelink.dfs.core.windows.net | Data Lake Storage |
| privatelink.postgres.database.azure.com | PostgreSQL |
| privatelink.vaultcore.azure.net | Key Vault |
| privatelink.azuredatabricks.net | Databricks |

## Connectivity Patterns

- **Hub ↔ Spoke:** VNet peering with gateway transit
- **On-premises → Azure:** ExpressRoute or VPN via Hub Gateway
- **PaaS Services:** Private Endpoints only (no public access)
- **Internet Egress:** Routed through Azure Firewall in Hub
