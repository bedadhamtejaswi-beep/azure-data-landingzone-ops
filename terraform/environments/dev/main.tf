# ------------------------------------------------------------------------------
# Dev Environment - Azure Data Landing Zone
# ------------------------------------------------------------------------------
# This is the development environment configuration that composes all
# infrastructure modules for the Azure Data Landing Zone.
# ------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

locals {
  project_prefix = "dlz-dev"
  location       = "centralus"
  environment    = "dev"

  common_tags = {
    Project     = "azure-data-landingzone"
    Environment = local.environment
    ManagedBy   = "terraform"
    Owner       = "data-platform-ops"
    CostCenter  = "data-engineering"
    Compliance  = "HIPAA"
  }
}

# ------------------------------------------------------------------------------
# Networking
# ------------------------------------------------------------------------------
module "networking" {
  source = "../../modules/networking"

  project_prefix = local.project_prefix
  location       = local.location
  tags           = local.common_tags

  hub_vnet_address_space            = var.hub_vnet_address_space
  spoke_vnet_address_space          = var.spoke_vnet_address_space
  hub_gateway_subnet_prefix         = var.hub_gateway_subnet_prefix
  hub_firewall_subnet_prefix        = var.hub_firewall_subnet_prefix
  hub_shared_services_subnet_prefix = var.hub_shared_services_subnet_prefix
  spoke_data_subnet_prefix          = var.spoke_data_subnet_prefix
  spoke_databricks_public_prefix    = var.spoke_databricks_public_prefix
  spoke_databricks_private_prefix   = var.spoke_databricks_private_prefix
  spoke_private_endpoints_prefix    = var.spoke_private_endpoints_prefix
}

# ------------------------------------------------------------------------------
# Monitoring (deployed early - other modules depend on LAW ID)
# ------------------------------------------------------------------------------
module "monitoring" {
  source = "../../modules/monitoring"

  project_prefix       = local.project_prefix
  location             = local.location
  tags                 = local.common_tags
  log_retention_days   = var.log_retention_days
  critical_alert_emails = var.critical_alert_emails
  warning_alert_emails  = var.warning_alert_emails
  postgresql_server_id  = module.postgresql.server_id
}

# ------------------------------------------------------------------------------
# Key Vault
# ------------------------------------------------------------------------------
module "keyvault" {
  source = "../../modules/keyvault"

  project_prefix             = local.project_prefix
  location                   = local.location
  tags                       = local.common_tags
  private_endpoint_subnet_id = module.networking.private_endpoints_subnet_id
  keyvault_private_dns_zone_id = module.networking.private_dns_zone_ids["keyvault"]
  allowed_subnet_ids         = [module.networking.data_subnet_id]
  postgresql_admin_password  = var.postgresql_admin_password
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------
# Storage (Data Lake)
# ------------------------------------------------------------------------------
module "storage" {
  source = "../../modules/storage"

  project_prefix             = local.project_prefix
  location                   = local.location
  tags                       = local.common_tags
  replication_type           = "LRS" # Dev uses LRS for cost savings
  private_endpoint_subnet_id = module.networking.private_endpoints_subnet_id
  blob_private_dns_zone_id   = module.networking.private_dns_zone_ids["blob"]
  dfs_private_dns_zone_id    = module.networking.private_dns_zone_ids["dfs"]
  allowed_subnet_ids         = [module.networking.data_subnet_id]
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------
# PostgreSQL
# ------------------------------------------------------------------------------
module "postgresql" {
  source = "../../modules/postgresql"

  project_prefix             = local.project_prefix
  location                   = local.location
  tags                       = local.common_tags
  vnet_id                    = module.networking.spoke_vnet_id
  delegated_subnet_id        = module.networking.data_subnet_id
  admin_username             = var.postgresql_admin_username
  admin_password             = var.postgresql_admin_password
  sku_name                   = "GP_Standard_D2s_v3" # Smaller SKU for dev
  storage_mb                 = 65536                  # 64GB for dev
  enable_ha                  = false                  # No HA in dev
  geo_redundant_backup       = false                  # No geo-backup in dev
  databases                  = ["analytics", "metadata", "audit"]
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------
# Databricks
# ------------------------------------------------------------------------------
module "databricks" {
  source = "../../modules/databricks"

  project_prefix                        = local.project_prefix
  location                              = local.location
  tags                                  = local.common_tags
  vnet_id                               = module.networking.spoke_vnet_id
  databricks_public_subnet_name         = module.networking.databricks_public_subnet_name
  databricks_private_subnet_name        = module.networking.databricks_private_subnet_name
  log_analytics_workspace_id            = module.monitoring.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------
# Cosmos DB
# ------------------------------------------------------------------------------
module "cosmosdb" {
  source = "../../modules/cosmosdb"

  project_prefix             = local.project_prefix
  location                   = local.location
  tags                       = local.common_tags
  zone_redundant             = false # Cost savings in dev
  database_throughput        = 400
  container_throughput       = 400
  private_endpoint_subnet_id = module.networking.private_endpoints_subnet_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
}
