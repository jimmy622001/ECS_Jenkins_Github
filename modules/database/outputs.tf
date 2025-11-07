output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.db_instance.id
}

output "db_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.db_instance.endpoint
}

output "db_instance_name" {
  description = "Name of the database"
  value       = aws_db_instance.db_instance.db_name
}

output "db_instance_username" {
  description = "Username for the database"
  value       = aws_db_instance.db_instance.username
  sensitive   = true
}
