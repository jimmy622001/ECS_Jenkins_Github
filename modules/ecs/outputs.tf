output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = var.is_dr ? null : aws_ecs_cluster.cluster.*.id[0]
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = var.is_dr ? null : aws_ecs_cluster.cluster.*.name[0]
}

output "service_name" {
  description = "Name of the ECS service"
  value       = var.is_dr ? null : aws_ecs_service.service.*.name[0]
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = var.is_dr ? null : aws_ecs_task_definition.task_definition.*.arn[0]
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = var.is_dr ? null : aws_lb.alb.*.dns_name[0]
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = var.create_dummy_cert && !var.is_dr ? aws_lb_listener.https.*.arn[0] : null
}

# output "codedeploy_app_name" {
#   description = "Name of the CodeDeploy application"
#   value       = aws_codedeploy_app.main.name
# }
