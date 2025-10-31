variable "db_username" {
  description = "Database username for production environment"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password for production environment"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana in production environment"
  type        = string
  sensitive   = true
}