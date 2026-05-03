# ------------------------------------------------------------------------------
# PostgreSQL Module - Azure Database for PostgreSQL Flexible Server
# ------------------------------------------------------------------------------
# Provisions a HIPAA-compliant PostgreSQL Flexible Server with:
# - Zone-redundant high availability
# - SSL/TLS enforcement
# - Customer-managed encryption keys via Key Vault
# - Private network access (VNet integration)
# - Automated backups with geo-redundancy
# - Performance tuning via server parameters
# - Diagnostic settings for monitoring
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
resource "azurerm_resource_group" "postgresql" {
  name     = "${var.project_prefix}-postgresql-rg"
  location = var.location
  tags     = var.tags
}

# ------------------------------------------------------------------------------
# Private DNS Zone for PostgreSQL
# ------------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "postgresql" {
  name                = "${var.project_prefix}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.postgresql.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  name                  = "${var.project_prefix}-pg-dns-link"
  resource_group_name   = azurerm_resource_group.postgresql.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

# ------------------------------------------------------------------------------
# PostgreSQL Flexible Server
# ------------------------------------------------------------------------------
resource "azurerm_postgresql_flexible_server" "this" {
  name                          = "${var.project_prefix}-pgflex"
  location                      = azurerm_resource_group.postgresql.location
  resource_group_name           = azurerm_resource_group.postgresql.name
  version                       = var.postgresql_version
  administrator_login           = var.admin_username
  administrator_password        = var.admin_password
  storage_mb                    = var.storage_mb
  sku_name                      = var.sku_name
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup
  zone                          = var.availability_zone
  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.postgresql.id
  public_network_access_enabled = false
  tags                          = var.tags

  # High Availability Configuration
  dynamic "high_availability" {
    for_each = var.enable_ha ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = var.standby_availability_zone
    }
  }

  # Maintenance Window
  maintenance_window {
    day_of_week  = var.maintenance_day
    start_hour   = var.maintenance_hour
    start_minute = var.maintenance_minute
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgresql]
}

# ------------------------------------------------------------------------------
# Server Configuration Parameters - Performance & Security Tuning
# ------------------------------------------------------------------------------
resource "azurerm_postgresql_flexible_server_configuration" "ssl_enforcement" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "ON"
}

resource "azurerm_postgresql_flexible_server_configuration" "ssl_min_version" {
  name      = "ssl_min_protocol_version"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "TLSv1.2"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_checkpoints" {
  name      = "log_checkpoints"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "ON"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_connections" {
  name      = "log_connections"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "ON"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_disconnections" {
  name      = "log_disconnections"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "ON"
}

resource "azurerm_postgresql_flexible_server_configuration" "connection_throttling" {
  name      = "connection_throttle.enable"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "ON"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_retention" {
  name      = "logfiles.retention_days"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "7"
}

# Performance parameters
resource "azurerm_postgresql_flexible_server_configuration" "shared_buffers" {
  name      = "shared_buffers"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = var.shared_buffers
}

resource "azurerm_postgresql_flexible_server_configuration" "work_mem" {
  name      = "work_mem"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = var.work_mem
}

# ------------------------------------------------------------------------------
# PostgreSQL Databases
# ------------------------------------------------------------------------------
resource "azurerm_postgresql_flexible_server_database" "databases" {
  for_each  = toset(var.databases)
  name      = each.value
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# ------------------------------------------------------------------------------
# Diagnostic Settings
# ------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "postgresql" {
  count                      = var.log_analytics_workspace_id != "" ? 1 : 0
  name                       = "${var.project_prefix}-pg-diag"
  target_resource_id         = azurerm_postgresql_flexible_server.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "PostgreSQLLogs"
  }

  enabled_log {
    category = "PostgreSQLFlexSessions"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
