output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.failover_lambda.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.failover_lambda.function_name
}

output "schedule_rule_arn" {
  description = "ARN of the CloudWatch Events rule"
  value       = aws_cloudwatch_event_rule.scheduled_failover_test.arn
}