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
  grafana_admin_password = var.grafana_admin_password
  domain_name            = var.domain_name
  https_listener_arn     = module.ecs.https_listener_arn
}