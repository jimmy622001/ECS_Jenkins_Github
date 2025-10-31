module "ecs_jenkins_github" {
  source = "../../"
  
  aws_region            = "us-east-1"
  vpc_cidr              = "10.0.0.0/16"
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.3.0/24", "10.0.4.0/24"]
  database_subnet_cidrs = ["10.0.5.0/24", "10.0.6.0/24"]
  availability_zones    = ["us-east-1a", "us-east-1b"]
  environment           = "dev"
  project_name          = "ecs-jenkins"
  container_port        = 8080
  key_name              = "dev-key"
  jenkins_instance_type = "t3.small"
  jenkins_role_name     = "jenkins-role-dev"
  db_username           = var.db_username
  db_password           = var.db_password
  db_name               = "devappdb"
  grafana_admin_password = var.grafana_admin_password
  domain_name           = "dev.example.com"
  ec2_instance_type     = "t3.small"
  min_instance_count    = 1
  max_instance_count    = 3
  desired_instance_count = 2
  use_spot_instances    = true
  spot_price            = "0.04"
}