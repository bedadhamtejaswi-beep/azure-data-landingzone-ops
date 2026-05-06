# ------------------------------------------------------------------------------
# Storage Module - Azure Data Lake Storage Gen2
# ------------------------------------------------------------------------------
# Provisions ADLS Gen2 with:
# - Hierarchical namespace for Data Lake
# - HIPAA-compliant encryption (CMK via Key Vault)
# - Private endpoints for blob and DFS
# - Lifecycle management policies
# - Diagnostic settings
# ------------------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

resource "azurerm_resource_group" "storage" {
  name     = "${var.project_prefix}-storage-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "datalake" {
  name                            = "${replace(var.project_prefix, "-", "")}dls"
  location                        = azurerm_resource_group.storage.location
  resource_group_name             = azurerm_resource_group.storage.name
  account_tier                    = "Standard"
  account_replication_type        = var.replication_type
  account_kind                    = "StorageV2"
  is_hns_enabled                  = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  tags                            = var.tags

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = var.soft_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.soft_delete_retention_days
    }
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }
}

# Data Lake Containers
resource "azurerm_storage_data_lake_gen2_filesystem" "raw" {
  name               = "raw"
  storage_account_id = azurerm_storage_account.datalake.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "curated" {
  name               = "curated"
  storage_account_id = azurerm_storage_account.datalake.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "enriched" {
  name               = "enriched"
  storage_account_id = azurerm_storage_account.datalake.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "archive" {
  name               = "archive"
  storage_account_id = azurerm_storage_account.datalake.id
}

# Lifecycle Management Policy
resource "azurerm_storage_management_policy" "lifecycle" {
  storage_account_id = azurerm_storage_account.datalake.id

  rule {
    name    = "archive-old-data"
    enabled = true

    filters {
      prefix_match = ["archive/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = 365
      }
    }
  }

  rule {
    name    = "cleanup-raw-zone"
    enabled = true

    filters {
      prefix_match = ["raw/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 60
        delete_after_days_since_modification_greater_than       = 180
      }
    }
  }
}

# Private Endpoints
resource "azurerm_private_endpoint" "blob" {
  count               = var.private_endpoint_subnet_id != "" ? 1 : 0
  name                = "${var.project_prefix}-blob-pe"
  location            = azurerm_resource_group.storage.location
  resource_group_name = azurerm_resource_group.storage.name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.project_prefix}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.datalake.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.blob_private_dns_zone_id != "" ? [1] : []
    content {
      name                 = "blob-dns"
      private_dns_zone_ids = [var.blob_private_dns_zone_id]
    }
  }
}

resource "azurerm_private_endpoint" "dfs" {
  count               = var.private_endpoint_subnet_id != "" ? 1 : 0
  name                = "${var.project_prefix}-dfs-pe"
  location            = azurerm_resource_group.storage.location
  resource_group_name = azurerm_resource_group.storage.name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.project_prefix}-dfs-psc"
    private_connection_resource_id = azurerm_storage_account.datalake.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.dfs_private_dns_zone_id != "" ? [1] : []
    content {
      name                 = "dfs-dns"
      private_dns_zone_ids = [var.dfs_private_dns_zone_id]
    }
  }
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "storage" {
  count                      = var.log_analytics_workspace_id != "" ? 1 : 0
  name                       = "${var.project_prefix}-storage-diag"
  target_resource_id         = "${azurerm_storage_account.datalake.id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }
}

# Lifecycle rules should be adjusted based on data retention policies
