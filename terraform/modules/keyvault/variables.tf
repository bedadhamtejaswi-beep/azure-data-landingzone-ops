variable "project_prefix" { type = string }
variable "location" { type = string; default = "centralus" }
variable "tags" { type = map(string); default = {} }

variable "allowed_subnet_ids" {
  description = "Subnet IDs allowed to access Key Vault"
  type        = list(string)
  default     = []
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = ""
}

variable "keyvault_private_dns_zone_id" {
  description = "Private DNS zone ID for Key Vault"
  type        = string
  default     = ""
}

variable "postgresql_admin_password" {
  description = "PostgreSQL admin password to store"
  type        = string
  sensitive   = true
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
  default     = ""
}
