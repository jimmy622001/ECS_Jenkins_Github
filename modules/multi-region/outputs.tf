output "route53_zone_id" {
  description = "The ID of the Route53 hosted zone"
  value       = module.route53_failover.zone_id
}

output "name_servers" {
  description = "The name servers of the hosted zone"
  value       = module.route53_failover.name_servers
}

output "primary_health_check_id" {
  description = "ID of the primary health check"
  value       = module.route53_failover.primary_health_check_id
}

output "dr_health_check_id" {
  description = "ID of the DR health check"
  value       = module.route53_failover.dr_health_check_id
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_failover.lambda_function_arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_failover.lambda_function_name
}

output "failover_notification_topic_arn" {
  description = "ARN of the SNS topic for failover notifications"
  value       = aws_sns_topic.failover_notifications.arn
}