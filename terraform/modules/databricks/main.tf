# ------------------------------------------------------------------------------
# Databricks Module - Azure Databricks Workspace
# ------------------------------------------------------------------------------
# Provisions a VNet-injected Databricks workspace with:
# - Managed resource group for Databricks-managed resources
# - VNet injection for network isolation
# - Premium SKU for Unity Catalog and advanced security
# - Cluster policies for cost governance
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
resource "azurerm_resource_group" "databricks" {
  name     = "${var.project_prefix}-databricks-rg"
  location = var.location
  tags     = var.tags
}

# ------------------------------------------------------------------------------
# Databricks Workspace (VNet Injected)
# ------------------------------------------------------------------------------
resource "azurerm_databricks_workspace" "this" {
  name                        = "${var.project_prefix}-dbw"
  location                    = azurerm_resource_group.databricks.location
  resource_group_name         = azurerm_resource_group.databricks.name
  sku                         = "premium"
  managed_resource_group_name = "${var.project_prefix}-dbw-managed-rg"
  tags                        = var.tags

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = var.vnet_id
    public_subnet_name                                   = var.databricks_public_subnet_name
    private_subnet_name                                  = var.databricks_private_subnet_name
    public_subnet_network_security_group_association_id  = var.databricks_public_nsg_association_id
    private_subnet_network_security_group_association_id = var.databricks_private_nsg_association_id
    storage_account_name                                 = "${replace(var.project_prefix, "-", "")}dbwsa"
  }

  depends_on = [var.vnet_id]
}

# ------------------------------------------------------------------------------
# Diagnostic Settings
# ------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "databricks" {
  count                      = var.log_analytics_workspace_id != "" ? 1 : 0
  name                       = "${var.project_prefix}-dbw-diag"
  target_resource_id         = azurerm_databricks_workspace.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "dbfs"
  }

  enabled_log {
    category = "clusters"
  }

  enabled_log {
    category = "accounts"
  }

  enabled_log {
    category = "jobs"
  }

  enabled_log {
    category = "notebook"
  }

  enabled_log {
    category = "workspace"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
