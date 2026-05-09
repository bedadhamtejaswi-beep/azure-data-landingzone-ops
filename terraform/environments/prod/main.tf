# ------------------------------------------------------------------------------
# Production Environment - Azure Data Landing Zone
# ------------------------------------------------------------------------------
# Production-grade configuration with:
# - High availability enabled across all services
# - Geo-redundant backups
# - Zone-redundant deployments
# - Full monitoring and alerting
# - HIPAA-compliant security settings
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
  project_prefix = "dlz-prod"
  location       = "centralus"
  environment    = "prod"

  common_tags = {
    Project     = "azure-data-landingzone"
    Environment = local.environment
    ManagedBy   = "terraform"
    Owner       = "data-platform-ops"
    CostCenter  = "data-engineering"
    Compliance  = "HIPAA"
    DR          = "enabled"
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
# Monitoring
# ------------------------------------------------------------------------------
module "monitoring" {
  source = "../../modules/monitoring"

  project_prefix        = local.project_prefix
  location              = local.location
  tags                  = local.common_tags
  log_retention_days    = var.log_retention_days
  daily_quota_gb        = 10
  critical_alert_emails = var.critical_alert_emails
  warning_alert_emails  = var.warning_alert_emails
  postgresql_server_id  = module.postgresql.server_id
  cpu_threshold         = 75
  storage_threshold     = 80
}

# ------------------------------------------------------------------------------
# Key Vault
# ------------------------------------------------------------------------------
module "keyvault" {
  source = "../../modules/keyvault"

  project_prefix               = local.project_prefix
  location                     = local.location
  tags                         = local.common_tags
  private_endpoint_subnet_id   = module.networking.private_endpoints_subnet_id
  keyvault_private_dns_zone_id = module.networking.private_dns_zone_ids["keyvault"]
  allowed_subnet_ids           = [module.networking.data_subnet_id]
  postgresql_admin_password    = var.postgresql_admin_password
  log_analytics_workspace_id   = module.monitoring.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------
# Storage (Data Lake) - Production with GRS
# ------------------------------------------------------------------------------
module "storage" {
  source = "../../modules/storage"

  project_prefix             = local.project_prefix
  location                   = local.location
  tags                       = local.common_tags
  replication_type           = "GRS"
  soft_delete_retention_days = 90
  private_endpoint_subnet_id = module.networking.private_endpoints_subnet_id
  blob_private_dns_zone_id   = module.networking.private_dns_zone_ids["blob"]
  dfs_private_dns_zone_id    = module.networking.private_dns_zone_ids["dfs"]
  allowed_subnet_ids         = [module.networking.data_subnet_id]
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------
# PostgreSQL - Production with HA
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
  sku_name                   = "GP_Standard_D4s_v3"
  storage_mb                 = 262144 # 256GB
  enable_ha                  = true
  geo_redundant_backup       = true
  backup_retention_days      = 35
  databases                  = ["analytics", "metadata", "audit", "reporting"]
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------
# Databricks
# ------------------------------------------------------------------------------
module "databricks" {
  source = "../../modules/databricks"

  project_prefix                 = local.project_prefix
  location                       = local.location
  tags                           = local.common_tags
  vnet_id                        = module.networking.spoke_vnet_id
  databricks_public_subnet_name  = module.networking.databricks_public_subnet_name
  databricks_private_subnet_name = module.networking.databricks_private_subnet_name
  log_analytics_workspace_id     = module.monitoring.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------
# Cosmos DB - Production with HA and DR
# ------------------------------------------------------------------------------
module "cosmosdb" {
  source = "../../modules/cosmosdb"

  project_prefix             = local.project_prefix
  location                   = local.location
  tags                       = local.common_tags
  zone_redundant             = true
  secondary_location         = "eastus2"
  database_throughput        = 800
  container_throughput       = 400
  private_endpoint_subnet_id = module.networking.private_endpoints_subnet_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
}
