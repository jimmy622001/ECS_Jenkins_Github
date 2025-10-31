terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
  
  # Configure backend for state storage (uncomment and configure for production)
  /*
  backend "s3" {
    bucket         = "terraform-state-ecs-jenkins"
    key            = "master/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
  */
}

# Variables for primary and DR regions
variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "dr_region" {
  description = "Disaster Recovery AWS region"
  type        = string
  default     = "us-west-2"
}

variable "domain_name" {
  description = "Main domain name for the application"
  type        = string
}

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

# Retrieve outputs from both environments
data "terraform_remote_state" "prod" {
  backend = "local"

  config = {
    path = "${path.module}/environments/prod/terraform.tfstate"
  }
}

data "terraform_remote_state" "dr" {
  backend = "local"

  config = {
    path = "${path.module}/environments/dr-pilot-light/terraform.tfstate"
  }
}

# Coordinates multi-region failover between production and DR environments
module "multi_region" {
  source = "./modules/multi-region"
  
  project         = "ecs-jenkins"
  environment     = "global"
  primary_region  = var.primary_region
  dr_region       = var.dr_region
  domain_name     = var.domain_name
  
  # ALB information from each environment
  primary_endpoint      = "prod.${var.domain_name}"
  dr_endpoint           = "dr.${var.domain_name}"
  primary_alb_dns_name  = data.terraform_remote_state.prod.outputs.alb_dns_name
  primary_alb_zone_id   = data.terraform_remote_state.prod.outputs.alb_zone_id
  dr_alb_dns_name       = data.terraform_remote_state.dr.outputs.alb_dns_name
  dr_alb_zone_id        = data.terraform_remote_state.dr.outputs.alb_zone_id
  
  # ASG names for scaling during failover
  primary_asg_name      = data.terraform_remote_state.prod.outputs.ecs_asg_name
  dr_asg_name           = data.terraform_remote_state.dr.outputs.ecs_asg_name
  
  # Configure failover testing schedule - 3 AM on the last Saturday of each month
  failover_test_schedule = "cron(0 3 ? * 7L *)"
  
  # Enable latency-based routing if both regions should be active
  enable_latency_based_routing = false
}

output "name_servers" {
  description = "The name servers to configure in your domain registrar"
  value       = module.multi_region.name_servers
}

output "lambda_function_name" {
  description = "Name of the Lambda function for failover testing"
  value       = module.multi_region.lambda_function_name
}