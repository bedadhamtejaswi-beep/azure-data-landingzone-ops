# ------------------------------------------------------------------------------
# Networking Module - Hub-Spoke VNet Architecture
# ------------------------------------------------------------------------------
# This module provisions a hub-spoke network topology with:
# - Hub VNet for shared services (monitoring, DNS, firewall)
# - Spoke VNet for the Data Landing Zone workloads
# - VNet Peering between hub and spoke
# - NSGs with HIPAA-compliant security rules
# - Private DNS Zones for Azure PaaS services
# - Private Endpoints for secure service connectivity
# ------------------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# ------------------------------------------------------------------------------
# Resource Group
# ------------------------------------------------------------------------------
resource "azurerm_resource_group" "networking" {
  name     = "${var.project_prefix}-networking-rg"
  location = var.location
  tags     = var.tags
}

# ------------------------------------------------------------------------------
# Hub Virtual Network
# ------------------------------------------------------------------------------
resource "azurerm_virtual_network" "hub" {
  name                = "${var.project_prefix}-hub-vnet"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  address_space       = [var.hub_vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "hub_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_gateway_subnet_prefix]
}

resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_firewall_subnet_prefix]
}

resource "azurerm_subnet" "hub_shared_services" {
  name                 = "shared-services"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_shared_services_subnet_prefix]
}

# ------------------------------------------------------------------------------
# Spoke Virtual Network (Data Landing Zone)
# ------------------------------------------------------------------------------
resource "azurerm_virtual_network" "spoke" {
  name                = "${var.project_prefix}-spoke-vnet"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  address_space       = [var.spoke_vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "spoke_data" {
  name                 = "data-subnet"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.spoke_data_subnet_prefix]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.Sql", "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "spoke_databricks_public" {
  name                 = "databricks-public"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.spoke_databricks_public_prefix]

  delegation {
    name = "databricks-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_subnet" "spoke_databricks_private" {
  name                 = "databricks-private"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.spoke_databricks_private_prefix]

  delegation {
    name = "databricks-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_subnet" "spoke_private_endpoints" {
  name                                      = "private-endpoints"
  resource_group_name                       = azurerm_resource_group.networking.name
  virtual_network_name                      = azurerm_virtual_network.spoke.name
  address_prefixes                          = [var.spoke_private_endpoints_prefix]
  private_endpoint_network_policies_enabled = true
}

# ------------------------------------------------------------------------------
# VNet Peering (Hub <-> Spoke)
# ------------------------------------------------------------------------------
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "hub-to-spoke"
  resource_group_name          = azurerm_resource_group.networking.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "spoke-to-hub"
  resource_group_name          = azurerm_resource_group.networking.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
}

# ------------------------------------------------------------------------------
# Network Security Groups - HIPAA Compliant Rules
# ------------------------------------------------------------------------------
resource "azurerm_network_security_group" "data_subnet" {
  name                = "${var.project_prefix}-data-nsg"
  location            = azurerm_resource_group.networking.location
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags

  # Deny all inbound internet traffic
  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow inbound from Hub VNet
  security_rule {
    name                       = "AllowHubInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.hub_vnet_address_space
    destination_address_prefix = "*"
  }

  # Allow HTTPS outbound to Azure services
  security_rule {
    name                       = "AllowHTTPSOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  # Allow PostgreSQL traffic within VNet
  security_rule {
    name                       = "AllowPostgreSQLInVNet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_subnet_network_security_group_association" "data_subnet" {
  subnet_id                 = azurerm_subnet.spoke_data.id
  network_security_group_id = azurerm_network_security_group.data_subnet.id
}

# ------------------------------------------------------------------------------
# Private DNS Zones for Azure Services
# ------------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "databricks" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = var.tags
}

# Link DNS Zones to Spoke VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "blob-dns-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "dfs" {
  name                  = "dfs-dns-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.dfs.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "postgres-dns-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "keyvault-dns-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
}

# End of networking module configuration
