output "networking" {
  value = {
    hub_vnet_id   = module.networking.hub_vnet_id
    spoke_vnet_id = module.networking.spoke_vnet_id
  }
}

output "postgresql" {
  value = {
    server_name = module.postgresql.server_name
    server_fqdn = module.postgresql.server_fqdn
    databases   = module.postgresql.database_names
  }
}

output "databricks" {
  value = { workspace_url = module.databricks.workspace_url }
}

output "storage" {
  value = {
    account_name = module.storage.storage_account_name
    dfs_endpoint = module.storage.primary_dfs_endpoint
  }
}

output "monitoring" {
  value = { log_analytics_workspace = module.monitoring.log_analytics_workspace_name }
}

output "keyvault" {
  value = { vault_uri = module.keyvault.key_vault_uri }
}
