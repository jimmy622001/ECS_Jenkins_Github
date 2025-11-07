module "ecs_jenkins_github" {
  source = "../../"

  aws_region                  = var.aws_region
  vpc_cidr                    = var.vpc_cidr
  public_subnet_cidrs         = var.public_subnet_cidrs
  private_subnet_cidrs        = var.private_subnet_cidrs
  database_subnet_cidrs       = var.database_subnet_cidrs
  availability_zones          = var.availability_zones
  environment                 = var.environment
  domain_name                 = var.domain_name
  project_name                = var.project_name
  container_port              = var.container_port
  key_name                    = var.key_name
  jenkins_instance_type       = var.jenkins_instance_type
  jenkins_role_name           = var.jenkins_role_name
  db_username                 = var.db_username
  db_password                 = var.db_password
  db_name                     = var.db_name
  grafana_admin_password      = var.grafana_admin_password
  ec2_instance_type           = var.ec2_instance_type
  min_instance_count          = var.min_instance_count
  max_instance_count          = var.max_instance_count
  desired_instance_count      = var.desired_instance_count
  use_spot_instances          = var.use_spot_instances
  spot_price                  = var.spot_price
  maintenance_window_schedule = var.maintenance_window_schedule
  patch_schedule              = var.patch_schedule



  # OWASP Security settings
  blocked_ip_addresses = var.blocked_ip_addresses
  max_request_size     = var.max_request_size
  request_limit        = var.request_limit
  enable_security_hub  = var.enable_security_hub
}
