variable "project_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "centralus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "consistency_level" {
  description = "Cosmos DB consistency level"
  type        = string
  default     = "Session"
}

variable "max_interval_in_seconds" {
  description = "Max staleness interval (for BoundedStaleness)"
  type        = number
  default     = 10
}

variable "max_staleness_prefix" {
  description = "Max staleness prefix (for BoundedStaleness)"
  type        = number
  default     = 200
}

variable "zone_redundant" {
  description = "Enable zone redundancy"
  type        = bool
  default     = true
}

variable "secondary_location" {
  description = "Secondary region for geo-replication"
  type        = string
  default     = ""
}

variable "database_name" {
  description = "Name of the SQL database"
  type        = string
  default     = "platform_events"
}

variable "database_throughput" {
  description = "Throughput (RU/s) for the database"
  type        = number
  default     = 400
}

variable "container_throughput" {
  description = "Throughput (RU/s) for the container"
  type        = number
  default     = 400
}

variable "default_ttl" {
  description = "Default TTL for documents in seconds (-1 = off)"
  type        = number
  default     = -1
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = ""
}

variable "backup_interval_minutes" {
  description = "Backup interval in minutes"
  type        = number
  default     = 240
}

variable "backup_retention_hours" {
  description = "Backup retention in hours"
  type        = number
  default     = 720
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = ""
}
