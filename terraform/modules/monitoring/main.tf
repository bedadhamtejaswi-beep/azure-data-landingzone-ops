# ------------------------------------------------------------------------------
# Monitoring Module - Azure Monitor & Log Analytics
# ------------------------------------------------------------------------------
# Provisions a comprehensive monitoring stack:
# - Log Analytics workspace for centralized logging
# - Azure Monitor action groups for alerting
# - Alert rules for CPU, memory, storage, and pipeline failures
# - Dashboard templates for platform observability
# - Application Insights for application-level telemetry
# ------------------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

resource "azurerm_resource_group" "monitoring" {
  name     = "${var.project_prefix}-monitoring-rg"
  location = var.location
  tags     = var.tags
}

# ------------------------------------------------------------------------------
# Log Analytics Workspace
# ------------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.project_prefix}-law"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.daily_quota_gb
  tags                = var.tags
}

# Log Analytics Solutions
resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.monitoring.location
  resource_group_name   = azurerm_resource_group.monitoring.name
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name        = azurerm_log_analytics_workspace.this.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# ------------------------------------------------------------------------------
# Application Insights
# ------------------------------------------------------------------------------
resource "azurerm_application_insights" "this" {
  name                = "${var.project_prefix}-appinsights"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "other"
  retention_in_days   = var.app_insights_retention_days
  tags                = var.tags
}

# ------------------------------------------------------------------------------
# Action Groups
# ------------------------------------------------------------------------------
resource "azurerm_monitor_action_group" "critical" {
  name                = "${var.project_prefix}-critical-ag"
  resource_group_name = azurerm_resource_group.monitoring.name
  short_name          = "Critical"
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.critical_alert_emails
    content {
      name                    = "email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
}

resource "azurerm_monitor_action_group" "warning" {
  name                = "${var.project_prefix}-warning-ag"
  resource_group_name = azurerm_resource_group.monitoring.name
  short_name          = "Warning"
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.warning_alert_emails
    content {
      name                    = "email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
}

# ------------------------------------------------------------------------------
# Metric Alert Rules
# ------------------------------------------------------------------------------

# High CPU Alert for PostgreSQL
resource "azurerm_monitor_metric_alert" "high_cpu" {
  count               = var.postgresql_server_id != "" ? 1 : 0
  name                = "${var.project_prefix}-high-cpu-alert"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [var.postgresql_server_id]
  description         = "Alert when CPU exceeds ${var.cpu_threshold}%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}

# Storage Alert for PostgreSQL
resource "azurerm_monitor_metric_alert" "storage_threshold" {
  count               = var.postgresql_server_id != "" ? 1 : 0
  name                = "${var.project_prefix}-storage-alert"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [var.postgresql_server_id]
  description         = "Alert when storage usage exceeds ${var.storage_threshold}%"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT1H"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.storage_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}

# Active Connections Alert
resource "azurerm_monitor_metric_alert" "active_connections" {
  count               = var.postgresql_server_id != "" ? 1 : 0
  name                = "${var.project_prefix}-connections-alert"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [var.postgresql_server_id]
  description         = "Alert when active connections exceed threshold"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "active_connections"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.connection_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.warning.id
  }
}

# ------------------------------------------------------------------------------
# Scheduled Query Rules (Log-Based Alerts)
# ------------------------------------------------------------------------------
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "failed_connections" {
  name                = "${var.project_prefix}-failed-conn-alert"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  description         = "Alert on excessive failed database connections"
  severity            = 2
  enabled             = true
  tags                = var.tags

  scopes                    = [azurerm_log_analytics_workspace.this.id]
  evaluation_frequency      = "PT10M"
  window_duration           = "PT30M"
  auto_mitigation_enabled   = true
  workspace_alerts_storage_enabled = false

  criteria {
    query = <<-QUERY
      AzureDiagnostics
      | where ResourceProvider == "MICROSOFT.DBFORPOSTGRESQL"
      | where Category == "PostgreSQLLogs"
      | where Message contains "authentication failed"
      | summarize FailedCount = count() by bin(TimeGenerated, 10m)
    QUERY
    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 10

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.critical.id]
  }
}
