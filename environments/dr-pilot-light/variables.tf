variable "db_username" {
  description = "Database username for DR environment"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password for DR environment"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana in DR environment"
  type        = string
  sensitive   = true
}