output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_key" {
  description = "Primary shared key for Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.name
}

output "application_insights_id" {
  description = "ID of Application Insights"
  value       = azurerm_application_insights.this.id
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

output "critical_action_group_id" {
  description = "ID of the critical action group"
  value       = azurerm_monitor_action_group.critical.id
}

output "warning_action_group_id" {
  description = "ID of the warning action group"
  value       = azurerm_monitor_action_group.warning.id
}
