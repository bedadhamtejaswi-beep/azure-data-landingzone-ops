variable "hub_vnet_address_space" { default = "10.10.0.0/16" }
variable "spoke_vnet_address_space" { default = "10.11.0.0/16" }
variable "hub_gateway_subnet_prefix" { default = "10.10.1.0/24" }
variable "hub_firewall_subnet_prefix" { default = "10.10.2.0/24" }
variable "hub_shared_services_subnet_prefix" { default = "10.10.3.0/24" }
variable "spoke_data_subnet_prefix" { default = "10.11.1.0/24" }
variable "spoke_databricks_public_prefix" { default = "10.11.2.0/24" }
variable "spoke_databricks_private_prefix" { default = "10.11.3.0/24" }
variable "spoke_private_endpoints_prefix" { default = "10.11.4.0/24" }

variable "postgresql_admin_username" {
  type      = string
  sensitive = true
}

variable "postgresql_admin_password" {
  type      = string
  sensitive = true
}

variable "log_retention_days" { default = 90 }

variable "critical_alert_emails" {
  type    = list(string)
  default = []
}

variable "warning_alert_emails" {
  type    = list(string)
  default = []
}
