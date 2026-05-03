# ------------------------------------------------------------------------------
# PostgreSQL Module Outputs
# ------------------------------------------------------------------------------

output "server_id" {
  description = "ID of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.this.id
}

output "server_name" {
  description = "Name of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.this.name
}

output "server_fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_names" {
  description = "List of created database names"
  value       = [for db in azurerm_postgresql_flexible_server_database.databases : db.name]
}

output "resource_group_name" {
  description = "Name of the PostgreSQL resource group"
  value       = azurerm_resource_group.postgresql.name
}
