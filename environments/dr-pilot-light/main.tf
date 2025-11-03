module "ecs_jenkins_github_dr" {
  source = "../../"

  aws_region             = "us-west-2" # Different region for DR
  vpc_cidr               = "10.2.0.0/16"
  public_subnet_cidrs    = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnet_cidrs   = ["10.2.3.0/24", "10.2.4.0/24"]
  database_subnet_cidrs  = ["10.2.5.0/24", "10.2.6.0/24"]
  availability_zones     = ["us-west-2a", "us-west-2b"]
  environment            = "dr"
  project_name           = "ecs-jenkins"
  container_port         = 8080
  key_name               = "dr-key"
  jenkins_instance_type  = "t3.micro"
  jenkins_role_name      = "jenkins-role-dr"
  db_username            = var.db_username
  db_password            = var.db_password
  db_name                = "drappdb"
  grafana_admin_password = var.grafana_admin_password
  domain_name            = "dr.example.com"
  ec2_instance_type      = "t3.small"
  min_instance_count     = 1
  max_instance_count     = 4
  desired_instance_count = 1
  use_spot_instances     = true
  spot_price             = "0.03"
  is_pilot_light         = true
}