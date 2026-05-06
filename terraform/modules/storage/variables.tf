variable "project_prefix" { type = string }
variable "location" { type = string; default = "centralus" }
variable "tags" { type = map(string); default = {} }

variable "replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "GRS"
}

variable "soft_delete_retention_days" {
  description = "Days to retain soft-deleted blobs"
  type        = number
  default     = 30
}

variable "allowed_subnet_ids" {
  description = "Subnet IDs allowed to access storage"
  type        = list(string)
  default     = []
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = ""
}

variable "blob_private_dns_zone_id" {
  description = "Private DNS zone ID for blob"
  type        = string
  default     = ""
}

variable "dfs_private_dns_zone_id" {
  description = "Private DNS zone ID for DFS"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
  default     = ""
}
