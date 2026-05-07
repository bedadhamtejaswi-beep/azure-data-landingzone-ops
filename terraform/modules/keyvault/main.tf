# ------------------------------------------------------------------------------
# Key Vault Module - Secrets & Key Management
# ------------------------------------------------------------------------------
# Provisions Azure Key Vault with:
# - RBAC-based access control
# - Soft delete and purge protection (HIPAA requirement)
# - Private endpoint connectivity
# - Secret rotation policies
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

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "keyvault" {
  name     = "${var.project_prefix}-keyvault-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_key_vault" "this" {
  name                          = "${var.project_prefix}-kv"
  location                      = azurerm_resource_group.keyvault.location
  resource_group_name           = azurerm_resource_group.keyvault.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  tags                          = var.tags

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }
}

# Private Endpoint
resource "azurerm_private_endpoint" "keyvault" {
  count               = var.private_endpoint_subnet_id != "" ? 1 : 0
  name                = "${var.project_prefix}-kv-pe"
  location            = azurerm_resource_group.keyvault.location
  resource_group_name = azurerm_resource_group.keyvault.name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.project_prefix}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.keyvault_private_dns_zone_id != "" ? [1] : []
    content {
      name                 = "keyvault-dns"
      private_dns_zone_ids = [var.keyvault_private_dns_zone_id]
    }
  }
}

# Store initial secrets
resource "azurerm_key_vault_secret" "postgresql_admin_password" {
  count        = var.postgresql_admin_password != "" ? 1 : 0
  name         = "postgresql-admin-password"
  value        = var.postgresql_admin_password
  key_vault_id = azurerm_key_vault.this.id
  content_type = "password"

  depends_on = [azurerm_key_vault.this]
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  count                      = var.log_analytics_workspace_id != "" ? 1 : 0
  name                       = "${var.project_prefix}-kv-diag"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
