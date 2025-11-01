variable "enable_prometheus" {
  description = "Whether to enable Prometheus"
  type        = bool
  default     = true
}

variable "enable_grafana" {
  description = "Whether to enable Grafana"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags for monitoring resources"
  type        = map(string)
  default     = {}
}