# ------------------------------------------------------------------------------
# Dev Environment Variables
# ------------------------------------------------------------------------------

# Network
variable "hub_vnet_address_space" { default = "10.0.0.0/16" }
variable "spoke_vnet_address_space" { default = "10.1.0.0/16" }
variable "hub_gateway_subnet_prefix" { default = "10.0.1.0/24" }
variable "hub_firewall_subnet_prefix" { default = "10.0.2.0/24" }
variable "hub_shared_services_subnet_prefix" { default = "10.0.3.0/24" }
variable "spoke_data_subnet_prefix" { default = "10.1.1.0/24" }
variable "spoke_databricks_public_prefix" { default = "10.1.2.0/24" }
variable "spoke_databricks_private_prefix" { default = "10.1.3.0/24" }
variable "spoke_private_endpoints_prefix" { default = "10.1.4.0/24" }

# PostgreSQL
variable "postgresql_admin_username" {
  type      = string
  sensitive = true
}

variable "postgresql_admin_password" {
  type      = string
  sensitive = true
}

# Monitoring
variable "log_retention_days" { default = 30 }

variable "critical_alert_emails" {
  type    = list(string)
  default = []
}

variable "warning_alert_emails" {
  type    = list(string)
  default = []
}
