# Multi-Region Module for Primary and DR deployment coordination

# Primary region provider
provider "aws" {
  alias  = "primary"
  region = var.primary_region
}

# DR region provider
provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

# SNS Topic for Multi-Region Notifications
resource "aws_sns_topic" "failover_notifications" {
  provider = aws.primary
  name     = "${var.project}-${var.environment}-failover-notifications"
  
  tags = {
    Name        = "${var.project}-${var.environment}-failover-notifications"
    Environment = var.environment
    Project     = var.project
  }
}

# To replicate SNS messages across regions
resource "aws_sns_topic_subscription" "forward_to_dr_sqs" {
  provider  = aws.primary
  topic_arn = aws_sns_topic.failover_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.dr_notification_queue.arn
}

resource "aws_sqs_queue" "dr_notification_queue" {
  provider = aws.dr
  name     = "${var.project}-${var.environment}-dr-notifications"
  
  tags = {
    Name        = "${var.project}-${var.environment}-dr-notifications"
    Environment = var.environment
    Project     = var.project
  }
}

# Connect the two regions via Route 53 for failover testing
module "route53_failover" {
  source = "../route53"
  
  domain_name                 = var.domain_name
  project                     = var.project
  environment                 = var.environment
  primary_endpoint            = var.primary_endpoint
  dr_endpoint                 = var.dr_endpoint
  health_check_path           = var.health_check_path
  primary_region              = var.primary_region
  dr_region                   = var.dr_region
  primary_alb_dns_name        = var.primary_alb_dns_name
  primary_alb_zone_id         = var.primary_alb_zone_id
  dr_alb_dns_name             = var.dr_alb_dns_name
  dr_alb_zone_id              = var.dr_alb_zone_id
  enable_latency_based_routing = var.enable_latency_based_routing
}

# Lambda function for automated failover testing
module "lambda_failover" {
  source = "../lambda"
  
  project                = var.project
  environment            = var.environment
  primary_health_check_id = module.route53_failover.primary_health_check_id
  dr_health_check_id     = module.route53_failover.dr_health_check_id
  primary_asg_name       = var.primary_asg_name
  dr_asg_name            = var.dr_asg_name
  primary_region         = var.primary_region
  dr_region              = var.dr_region
  sns_topic_arn          = aws_sns_topic.failover_notifications.arn
  test_schedule          = var.failover_test_schedule
}

# SSM Parameter to control failover mode
resource "aws_ssm_parameter" "failover_mode" {
  provider = aws.primary
  name     = "/${var.project}/${var.environment}/failover-mode"
  type     = "String"
  value    = "normal" # Can be "normal", "test", "activate_dr", "restore"
  
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Replication status indicator
resource "aws_ssm_parameter" "replication_status" {
  provider = aws.primary
  name     = "/${var.project}/${var.environment}/replication-status"
  type     = "String"
  value    = "healthy" # Status of data replication between regions
  
  tags = {
    Environment = var.environment
    Project     = var.project
  }
}