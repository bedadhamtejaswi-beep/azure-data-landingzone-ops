# ------------------------------------------------------------------------------
# Databricks Module Outputs
# ------------------------------------------------------------------------------

output "workspace_id" {
  description = "ID of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.id
}

output "workspace_url" {
  description = "URL of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.workspace_url
}

output "managed_resource_group_id" {
  description = "ID of the Databricks managed resource group"
  value       = azurerm_databricks_workspace.this.managed_resource_group_id
}

output "workspace_name" {
  description = "Name of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.name
}
