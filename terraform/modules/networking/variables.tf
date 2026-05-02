# ------------------------------------------------------------------------------
# Networking Module Variables
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

# Hub VNet
variable "hub_vnet_address_space" {
  description = "Address space for the hub VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "hub_gateway_subnet_prefix" {
  description = "Address prefix for the hub gateway subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "hub_firewall_subnet_prefix" {
  description = "Address prefix for the Azure Firewall subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "hub_shared_services_subnet_prefix" {
  description = "Address prefix for shared services subnet"
  type        = string
  default     = "10.0.3.0/24"
}

# Spoke VNet
variable "spoke_vnet_address_space" {
  description = "Address space for the spoke (data landing zone) VNet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "spoke_data_subnet_prefix" {
  description = "Address prefix for the data workload subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "spoke_databricks_public_prefix" {
  description = "Address prefix for the Databricks public subnet"
  type        = string
  default     = "10.1.2.0/24"
}

variable "spoke_databricks_private_prefix" {
  description = "Address prefix for the Databricks private subnet"
  type        = string
  default     = "10.1.3.0/24"
}

variable "spoke_private_endpoints_prefix" {
  description = "Address prefix for the private endpoints subnet"
  type        = string
  default     = "10.1.4.0/24"
}
