module "ecs_jenkins_github" {
  source = "../../"
  
  aws_region            = "us-east-1"
  vpc_cidr              = "10.1.0.0/16"
  public_subnet_cidrs   = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs  = ["10.1.3.0/24", "10.1.4.0/24"]
  database_subnet_cidrs = ["10.1.5.0/24", "10.1.6.0/24"]
  availability_zones    = ["us-east-1a", "us-east-1b"]
  environment           = "prod"
  project_name          = "ecs-jenkins"
  container_port        = 8080
  key_name              = "prod-key"
  jenkins_instance_type = "t3.medium"
  jenkins_role_name     = "jenkins-role-prod"
  db_username           = var.db_username
  db_password           = var.db_password
  db_name               = "prodappdb"
  grafana_admin_password = var.grafana_admin_password
  domain_name           = "prod.example.com"
  ec2_instance_type     = "t3.large"
  min_instance_count    = 2
  max_instance_count    = 6
  desired_instance_count = 4
  use_spot_instances    = false
}