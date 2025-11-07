terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

}

# Network Module
module "network" {
  source = "./modules/network"

  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  availability_zones    = var.availability_zones
  environment           = var.environment
}

module "iam" {
  source      = "./modules/iam"
  project     = var.project_name
  environment = var.environment

}

module "database" {
  source = "./modules/database"

  project             = var.project_name
  environment         = var.environment
  vpc_id              = module.network.vpc_id
  database_subnet_ids = module.network.database_subnet_ids
  db_security_group   = module.network.db_security_group
  db_username         = var.db_username
  db_password         = var.db_password
  db_name             = var.db_name
}

module "ecs" {
  source = "./modules/ecs"

  vpc_id                  = module.network.vpc_id
  public_subnets          = module.network.public_subnet_ids
  private_subnets         = module.network.private_subnet_ids
  alb_security_group      = module.network.alb_security_group
  ecs_security_group      = module.network.ecs_security_group
  ecs_task_execution_role = module.iam.ecs_task_execution_role
  ecs_task_role           = module.iam.ecs_task_role
  container_port          = var.container_port
  environment             = var.environment
  project                 = var.project_name
  domain_name             = var.domain_name
  service_desired_count   = var.desired_instance_count
  codedeploy_role_arn     = module.iam.codedeploy_role_arn
}

module "cicd" {
  source = "./modules/cicd"

  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.public_subnet_ids[0]
  key_name          = var.key_name
  instance_type     = var.jenkins_instance_type
  environment       = var.environment
  project           = var.project_name
  jenkins_role_name = var.jenkins_role_name
}
# Add EC2 module for ECS container instances
module "ec2" {
  source = "./modules/ec2"

  project                     = var.project_name
  environment                 = var.environment
  instance_type               = var.ec2_instance_type
  security_group_id           = module.network.ecs_security_group
  key_name                    = var.key_name
  instance_profile_name       = module.iam.ec2_instance_profile
  ecs_cluster_name            = module.ecs.cluster_name
  root_volume_size            = var.root_volume_size
  subnet_ids                  = module.network.private_subnet_ids
  min_size                    = var.min_instance_count
  max_size                    = var.max_instance_count
  desired_capacity            = var.desired_instance_count
  patch_schedule              = var.patch_schedule
  maintenance_window_schedule = var.maintenance_window_schedule
  ssm_service_role_arn        = module.iam.ssm_service_role_arn
  sns_topic_arn               = module.monitoring.infrastructure_alerts_topic_arn
  additional_tags = {
    ManagedBy  = "Terraform"
    AutoUpdate = "true"
  }
}

module "monitoring" {
  source = "./modules/monitoring"

  vpc_id                 = module.network.vpc_id
  private_subnet_ids     = module.network.private_subnet_ids
  alb_security_group_id  = module.network.alb_security_group
  execution_role_arn     = module.iam.ecs_execution_role_arn
  task_role_arn          = module.iam.ecs_task_role_arn
  ecs_cluster_id         = module.ecs.cluster_id
  aws_region             = var.aws_region
  environment            = var.environment
  project                = var.project_name
  grafana_admin_password = var.grafana_admin_password
  domain_name            = var.domain_name
  https_listener_arn     = module.ecs.https_listener_arn
}

# OWASP Security Module
module "security" {
  source = "./modules/security"

  project     = var.project_name
  environment = var.environment
  aws_region  = var.aws_region
  alb_arn     = module.ecs.alb_arn

  # IP addresses to block - can be customized per environment
  blocked_ip_addresses = var.blocked_ip_addresses

  # Rate limiting settings
  max_request_size    = var.max_request_size
  request_limit       = var.request_limit
  enable_security_hub = var.enable_security_hub
}
