# ------------------------------------------------------------------------------
# Databricks Module Variables
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
  description = "ID of the spoke VNet for Databricks VNet injection"
  type        = string
}

variable "databricks_public_subnet_name" {
  description = "Name of the Databricks public subnet"
  type        = string
}

variable "databricks_private_subnet_name" {
  description = "Name of the Databricks private subnet"
  type        = string
}

variable "databricks_public_nsg_association_id" {
  description = "NSG association ID for the Databricks public subnet"
  type        = string
  default     = ""
}

variable "databricks_private_nsg_association_id" {
  description = "NSG association ID for the Databricks private subnet"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for diagnostic settings"
  type        = string
  default     = ""
}
