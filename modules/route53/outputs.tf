output "zone_id" {
  description = "The ID of the hosted zone"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "The name servers of the hosted zone"
  value       = aws_route53_zone.main.name_servers
}

output "primary_health_check_id" {
  description = "ID of the primary health check"
  value       = aws_route53_health_check.primary.id
}

output "dr_health_check_id" {
  description = "ID of the DR health check"
  value       = aws_route53_health_check.dr.id
}