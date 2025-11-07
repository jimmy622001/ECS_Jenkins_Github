output "web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.owasp_top10_protection.id
}

output "web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.owasp_top10_protection.arn
}

output "security_alerts_topic_arn" {
  description = "ARN of the SNS topic for security alerts"
  value       = aws_sns_topic.security_alerts.arn
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = aws_guardduty_detector.security_detector.id
}

output "s3_waf_logs_bucket" {
  description = "S3 bucket for WAF logs"
  value       = aws_s3_bucket.waf_logs.bucket
}

output "s3_config_bucket" {
  description = "S3 bucket for AWS Config"
  value       = aws_s3_bucket.config_bucket.bucket
}

output "security_dashboard_name" {
  description = "Name of the CloudWatch dashboard for security monitoring"
  value       = aws_cloudwatch_dashboard.security_dashboard.dashboard_name
}
