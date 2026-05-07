variable "project_prefix" {
  type = string
}

variable "location" {
  type    = string
  default = "centralus"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 90
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB (-1 = unlimited)"
  type        = number
  default     = 5
}

variable "app_insights_retention_days" {
  description = "Application Insights data retention in days"
  type        = number
  default     = 90
}

variable "critical_alert_emails" {
  description = "Email addresses for critical alerts"
  type        = list(string)
  default     = []
}

variable "warning_alert_emails" {
  description = "Email addresses for warning alerts"
  type        = list(string)
  default     = []
}

variable "postgresql_server_id" {
  description = "Resource ID of the PostgreSQL server to monitor"
  type        = string
  default     = ""
}

variable "cpu_threshold" {
  description = "CPU percentage threshold for alerts"
  type        = number
  default     = 80
}

variable "storage_threshold" {
  description = "Storage percentage threshold for alerts"
  type        = number
  default     = 85
}

variable "connection_threshold" {
  description = "Active connection count threshold"
  type        = number
  default     = 100
}
