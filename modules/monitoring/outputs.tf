output "prometheus_target_group_arn" {
  description = "ARN of the Prometheus target group"
  value       = aws_lb_target_group.prometheus.arn
}

output "grafana_target_group_arn" {
  description = "ARN of the Grafana target group"
  value       = aws_lb_target_group.grafana.arn
}

output "monitoring_security_group_id" {
  description = "ID of the monitoring security group"
  value       = aws_security_group.monitoring_sg.id
}

output "infrastructure_alerts_topic_arn" {
  description = "ARN of the infrastructure alerts SNS topic"
  value       = aws_sns_topic.infrastructure_alerts.arn
}
