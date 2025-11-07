output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnet.*.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private_subnet.*.id
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = aws_subnet.database_subnet.*.id
}

output "alb_security_group" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb_security_group.id
}

output "ecs_security_group" {
  description = "Security group ID for the ECS tasks"
  value       = aws_security_group.ecs_security_group.id
}

output "db_security_group" {
  description = "Security group ID for the database"
  value       = aws_security_group.db_security_group.id
}
