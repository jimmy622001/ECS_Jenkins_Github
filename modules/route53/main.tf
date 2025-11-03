# Route 53 module for DNS failover between primary and DR regions

# Hosted zone for the domain
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name        = "${var.project}-${var.environment}-zone"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Health check for the primary environment
resource "aws_route53_health_check" "primary" {
  fqdn              = var.primary_endpoint
  port              = 443
  type              = "HTTPS"
  resource_path     = var.health_check_path
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "${var.project}-primary-health-check"
  }
}

# Health check for the DR environment
resource "aws_route53_health_check" "dr" {
  fqdn              = var.dr_endpoint
  port              = 443
  type              = "HTTPS"
  resource_path     = var.health_check_path
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "${var.project}-dr-health-check"
  }
}

# Primary record with failover routing policy
resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier  = "primary"
  health_check_id = aws_route53_health_check.primary.id

  alias {
    name                   = var.primary_alb_dns_name
    zone_id                = var.primary_alb_zone_id
    evaluate_target_health = true
  }
}

# Secondary record with failover routing policy
resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier  = "secondary"
  health_check_id = aws_route53_health_check.dr.id

  alias {
    name                   = var.dr_alb_dns_name
    zone_id                = var.dr_alb_zone_id
    evaluate_target_health = true
  }
}

# Latency-based records for geo-distribution if both regions are active
resource "aws_route53_record" "latency_primary" {
  count   = var.enable_latency_based_routing ? 1 : 0
  zone_id = aws_route53_zone.main.zone_id
  name    = "latency.${var.domain_name}"
  type    = "A"

  latency_routing_policy {
    region = var.primary_region
  }

  set_identifier = "latency-primary"

  alias {
    name                   = var.primary_alb_dns_name
    zone_id                = var.primary_alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "latency_secondary" {
  count   = var.enable_latency_based_routing ? 1 : 0
  zone_id = aws_route53_zone.main.zone_id
  name    = "latency.${var.domain_name}"
  type    = "A"

  latency_routing_policy {
    region = var.dr_region
  }

  set_identifier = "latency-secondary"

  alias {
    name                   = var.dr_alb_dns_name
    zone_id                = var.dr_alb_zone_id
    evaluate_target_health = true
  }
}