# ------------------------------------------------------------------------------
# Dev Environment Outputs
# ------------------------------------------------------------------------------

output "networking" {
  description = "Networking module outputs"
  value = {
    hub_vnet_id   = module.networking.hub_vnet_id
    spoke_vnet_id = module.networking.spoke_vnet_id
  }
}

output "postgresql" {
  description = "PostgreSQL module outputs"
  value = {
    server_name = module.postgresql.server_name
    server_fqdn = module.postgresql.server_fqdn
    databases   = module.postgresql.database_names
  }
}

output "databricks" {
  description = "Databricks module outputs"
  value = {
    workspace_url = module.databricks.workspace_url
  }
}

output "storage" {
  description = "Storage module outputs"
  value = {
    account_name  = module.storage.storage_account_name
    dfs_endpoint  = module.storage.primary_dfs_endpoint
  }
}

output "monitoring" {
  description = "Monitoring module outputs"
  value = {
    log_analytics_workspace = module.monitoring.log_analytics_workspace_name
  }
}

output "keyvault" {
  description = "Key Vault module outputs"
  value = {
    vault_uri = module.keyvault.key_vault_uri
  }
}
