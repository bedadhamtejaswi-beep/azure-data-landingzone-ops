# ------------------------------------------------------------------------------
# Cosmos DB Module - NoSQL Database
# ------------------------------------------------------------------------------
# Provisions an Azure Cosmos DB account with:
# - Multi-region writes for high availability
# - Configurable consistency levels
# - Private endpoint connectivity
# - Automatic failover
# - HIPAA-compliant encryption and network rules
# ------------------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

resource "azurerm_resource_group" "cosmosdb" {
  name     = "${var.project_prefix}-cosmosdb-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_cosmosdb_account" "this" {
  name                          = "${var.project_prefix}-cosmos"
  location                      = azurerm_resource_group.cosmosdb.location
  resource_group_name           = azurerm_resource_group.cosmosdb.name
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  enable_automatic_failover     = true
  public_network_access_enabled = false
  tags                          = var.tags

  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.max_interval_in_seconds
    max_staleness_prefix    = var.max_staleness_prefix
  }

  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = var.zone_redundant
  }

  dynamic "geo_location" {
    for_each = var.secondary_location != "" ? [var.secondary_location] : []
    content {
      location          = geo_location.value
      failover_priority = 1
    }
  }

  # HIPAA compliance: disable key-based metadata write access
  access_key_metadata_writes_enabled = false

  backup {
    type                = "Periodic"
    interval_in_minutes = var.backup_interval_minutes
    retention_in_hours  = var.backup_retention_hours
    storage_redundancy  = "Geo"
  }
}

# SQL Database
resource "azurerm_cosmosdb_sql_database" "this" {
  name                = var.database_name
  resource_group_name = azurerm_resource_group.cosmosdb.name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = var.database_throughput
}

# SQL Container for event data
resource "azurerm_cosmosdb_sql_container" "events" {
  name                  = "events"
  resource_group_name   = azurerm_resource_group.cosmosdb.name
  account_name          = azurerm_cosmosdb_account.this.name
  database_name         = azurerm_cosmosdb_sql_database.this.name
  partition_key_path    = "/partitionKey"
  partition_key_version = 2
  throughput            = var.container_throughput

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/\"_etag\"/?"
    }
  }

  default_ttl = var.default_ttl
}

# Private Endpoint
resource "azurerm_private_endpoint" "cosmosdb" {
  count               = var.private_endpoint_subnet_id != "" ? 1 : 0
  name                = "${var.project_prefix}-cosmos-pe"
  location            = azurerm_resource_group.cosmosdb.location
  resource_group_name = azurerm_resource_group.cosmosdb.name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.project_prefix}-cosmos-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "cosmosdb" {
  count                      = var.log_analytics_workspace_id != "" ? 1 : 0
  name                       = "${var.project_prefix}-cosmos-diag"
  target_resource_id         = azurerm_cosmosdb_account.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DataPlaneRequests"
  }

  enabled_log {
    category = "QueryRuntimeStatistics"
  }

  enabled_log {
    category = "PartitionKeyStatistics"
  }

  metric {
    category = "Requests"
    enabled  = true
  }
}

# Session consistency balances latency and freshness for analytics
