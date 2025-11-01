terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# Define environment-specific configurations
locals {
  environment_config = {
    dev = {
      instance_type         = "t3.small"
      min_instance_count    = 1
      max_instance_count    = 2
      desired_count         = 1
      use_spot_instances   = true
      is_pilot_light       = false
    }
    prod = {
      instance_type         = "t3.large"
      min_instance_count    = 2
      max_instance_count    = 10
      desired_count         = 4
      use_spot_instances   = false
      is_pilot_light       = false
    }
    dr = {
      instance_type         = "t3.medium"
      min_instance_count    = 1
      max_instance_count    = 4
      desired_count         = 1
      use_spot_instances   = true
      is_pilot_light       = true
    }
  }
  
  # Merge with default values
  env = merge(
    local.environment_config[terraform.workspace],
    {
      # Default values if not specified in environment config
      instance_type         = "t3.medium"
      min_instance_count    = 1
      max_instance_count    = 2
      desired_count         = 1
      use_spot_instances   = true
      is_pilot_light       = false
    }
  )
}

# Configure the AWS Provider with profile based on workspace
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile != "" ? var.aws_profile : null
  
  # DR region override
  dynamic "endpoints" {
    for_each = terraform.workspace == "dr" ? [1] : []
    content {
      ec2 = "https://ec2.${var.aws_region}.amazonaws.com"
      rds = "https://rds.${var.aws_region}.amazonaws.com"
      # Add other service endpoints as needed
    }
  }
}

# Create a null_resource to validate the workspace is valid
resource "null_resource" "validate_workspace" {
  # This will fail if the workspace is not one of the expected values
  count = contains(["dev", "prod", "dr"], terraform.workspace) ? 0 : 1
  
  # This will cause a failure with a helpful message
  provisioner "local-exec" {
    command = <<-EOT
      echo "Error: Workspace '${terraform.workspace}' is not valid. Please use one of: dev, prod, dr"
      exit 1
    EOT
  }
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
  project               = var.project_name
}

# IAM Module
module "iam" {
  source      = "./modules/iam"
  project     = var.project_name
  environment = var.environment
}

# Database Module - Only create in non-DR environments or if explicitly enabled for DR
module "database" {
  count = (terraform.workspace == "dr" && !var.create_database) ? 0 : 1
  
  source = "./modules/database"

  project             = var.project_name
  environment         = var.environment
  vpc_id              = module.network.vpc_id
  database_subnet_ids = module.network.database_subnet_ids
  db_security_group   = module.network.db_security_group
  db_username         = var.db_username
  db_password         = var.db_password
  db_name             = var.db_name
  
  # Use snapshot in DR environment if specified
  snapshot_identifier = var.db_snapshot_identifier
}

# ECS Module
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
  service_desired_count   = local.env.desired_count
  codedeploy_role_arn     = module.iam.codedeploy_role_arn
  
  # DR-specific settings
  is_dr = terraform.workspace == "dr"
}

# CICD Module - Skip in DR environment
module "cicd" {
  count = terraform.workspace == "dr" ? 0 : 1
  
  source = "./modules/cicd"

  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.public_subnet_ids[0]
  key_name          = var.key_name
  instance_type     = var.jenkins_instance_type
  environment       = var.environment
  project           = var.project_name
  jenkins_role_name = var.jenkins_role_name
}

# EC2 Module for ECS container instances
module "ec2" {
  source = "./modules/ec2"

  project                  = var.project_name
  environment              = var.environment
  instance_type            = local.env.instance_type
  security_group_id        = module.network.ecs_security_group
  key_name                 = var.key_name
  instance_profile_name    = module.iam.ec2_instance_profile
  ecs_cluster_name         = module.ecs.cluster_name
  root_volume_size         = var.root_volume_size
  subnet_ids               = module.network.private_subnet_ids
  min_size                 = local.env.min_instance_count
  max_size                 = local.env.max_instance_count
  desired_capacity         = local.env.desired_count
  patch_schedule           = var.patch_schedule
  maintenance_window_schedule = var.maintenance_window_schedule
  ssm_service_role_arn     = module.iam.ssm_service_role_arn
  sns_topic_arn            = module.monitoring.infrastructure_alerts_topic_arn
  use_spot_instances       = local.env.use_spot_instances
  is_pilot_light           = local.env.is_pilot_light
  
  # Add additional tags
  additional_tags = merge(
    var.additional_tags,
    {
      ManagedBy  = "Terraform"
      AutoUpdate = "true"
      Environment = var.environment
      Project     = var.project_name
    }
  )
}

# Monitoring Module - Optional in DR environment if minimal setup
module "monitoring" {
  count = (terraform.workspace == "dr" && var.disable_monitoring) ? 0 : 1
  
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
  
  # Enable/disable specific monitoring components based on environment
  enable_prometheus = terraform.workspace != "dr" || var.enable_dr_monitoring
  enable_grafana    = terraform.workspace != "dr" || var.enable_dr_monitoring
  
  # Additional tags for all monitoring resources
  additional_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}