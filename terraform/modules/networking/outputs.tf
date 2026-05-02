# ------------------------------------------------------------------------------
# Networking Module Outputs
# ------------------------------------------------------------------------------

output "resource_group_name" {
  description = "Name of the networking resource group"
  value       = azurerm_resource_group.networking.name
}

output "hub_vnet_id" {
  description = "ID of the hub virtual network"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Name of the hub virtual network"
  value       = azurerm_virtual_network.hub.name
}

output "spoke_vnet_id" {
  description = "ID of the spoke virtual network"
  value       = azurerm_virtual_network.spoke.id
}

output "spoke_vnet_name" {
  description = "Name of the spoke virtual network"
  value       = azurerm_virtual_network.spoke.name
}

output "data_subnet_id" {
  description = "ID of the data workload subnet"
  value       = azurerm_subnet.spoke_data.id
}

output "databricks_public_subnet_name" {
  description = "Name of the Databricks public subnet"
  value       = azurerm_subnet.spoke_databricks_public.name
}

output "databricks_private_subnet_name" {
  description = "Name of the Databricks private subnet"
  value       = azurerm_subnet.spoke_databricks_private.name
}

output "private_endpoints_subnet_id" {
  description = "ID of the private endpoints subnet"
  value       = azurerm_subnet.spoke_private_endpoints.id
}

output "private_dns_zone_ids" {
  description = "Map of private DNS zone IDs"
  value = {
    blob       = azurerm_private_dns_zone.blob.id
    dfs        = azurerm_private_dns_zone.dfs.id
    postgres   = azurerm_private_dns_zone.postgres.id
    keyvault   = azurerm_private_dns_zone.keyvault.id
    databricks = azurerm_private_dns_zone.databricks.id
  }
}

output "nsg_id" {
  description = "ID of the data subnet NSG"
  value       = azurerm_network_security_group.data_subnet.id
}
