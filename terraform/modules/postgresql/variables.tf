# ------------------------------------------------------------------------------
# PostgreSQL Module Variables
# ------------------------------------------------------------------------------

variable "project_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "centralus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vnet_id" {
  description = "ID of the VNet for private DNS zone linking"
  type        = string
}

variable "delegated_subnet_id" {
  description = "ID of the delegated subnet for PostgreSQL"
  type        = string
}

variable "postgresql_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "15"
}

variable "admin_username" {
  description = "Administrator username for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Administrator password for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "SKU name for the PostgreSQL server (e.g., GP_Standard_D4s_v3)"
  type        = string
  default     = "GP_Standard_D4s_v3"
}

variable "storage_mb" {
  description = "Storage size in MB"
  type        = number
  default     = 131072 # 128 GB
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 35
}

variable "geo_redundant_backup" {
  description = "Enable geo-redundant backups"
  type        = bool
  default     = true
}

variable "enable_ha" {
  description = "Enable zone-redundant high availability"
  type        = bool
  default     = true
}

variable "availability_zone" {
  description = "Availability zone for the primary server"
  type        = string
  default     = "1"
}

variable "standby_availability_zone" {
  description = "Availability zone for the standby server"
  type        = string
  default     = "2"
}

variable "maintenance_day" {
  description = "Day of week for maintenance window (0=Sunday)"
  type        = number
  default     = 0
}

variable "maintenance_hour" {
  description = "Start hour for maintenance window (UTC)"
  type        = number
  default     = 4
}

variable "maintenance_minute" {
  description = "Start minute for maintenance window"
  type        = number
  default     = 0
}

variable "databases" {
  description = "List of databases to create"
  type        = list(string)
  default     = ["analytics", "metadata"]
}

variable "shared_buffers" {
  description = "PostgreSQL shared_buffers parameter value"
  type        = string
  default     = "262144" # 2GB in 8kB pages
}

variable "work_mem" {
  description = "PostgreSQL work_mem parameter value in kB"
  type        = string
  default     = "65536" # 64MB
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for diagnostic settings"
  type        = string
  default     = ""
}
