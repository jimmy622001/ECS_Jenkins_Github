variable "db_username" {
  description = "Database username for dev environment"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password for dev environment"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana in dev environment"
  type        = string
  sensitive   = true
}