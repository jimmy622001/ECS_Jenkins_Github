output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.cluster.id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.cluster.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.service.name
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.task_definition.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = var.create_dummy_cert ? aws_lb_listener.https[0].arn : null
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.alb.arn
}

# Commented out until CodeDeploy app is implemented
#output "codedeploy_app_name" {
#  description = "Name of the CodeDeploy application"
#  value       = aws_codedeploy_app.main.name
#}
