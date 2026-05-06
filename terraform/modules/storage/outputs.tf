output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.datalake.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.datalake.name
}

output "primary_dfs_endpoint" {
  description = "Primary DFS endpoint"
  value       = azurerm_storage_account.datalake.primary_dfs_endpoint
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = azurerm_storage_account.datalake.primary_blob_endpoint
}

output "filesystem_ids" {
  description = "Map of filesystem IDs"
  value = {
    raw      = azurerm_storage_data_lake_gen2_filesystem.raw.id
    curated  = azurerm_storage_data_lake_gen2_filesystem.curated.id
    enriched = azurerm_storage_data_lake_gen2_filesystem.enriched.id
    archive  = azurerm_storage_data_lake_gen2_filesystem.archive.id
  }
}
