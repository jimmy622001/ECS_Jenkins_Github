# Security Group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project}-${var.environment}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr
  }

  ingress {
    description = "Jenkins web interface"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.web_allowed_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.environment}-jenkins-sg"
    Environment = var.environment
    Project     = var.project
  }
}

# Launch Template for Jenkins
resource "aws_launch_template" "jenkins" {
  name_prefix            = "${var.project}-${var.environment}-jenkins-"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.jenkins_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install java-openjdk11 -y
    sudo yum install -y jenkins git docker
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker jenkins
    sudo systemctl restart jenkins

    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    # Install Terraform
    TERRAFORM_VERSION="1.0.0"
    wget https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip
    unzip terraform_$${TERRAFORM_VERSION}_linux_amd64.zip
    sudo mv terraform /usr/local/bin/

    # Install SSM Agent
    sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
    sudo systemctl enable amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent
  EOF
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 required for better security
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project}-${var.environment}-jenkins"
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name        = "${var.project}-${var.environment}-jenkins-volume"
      Environment = var.environment
      Project     = var.project
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group for Jenkins
resource "aws_autoscaling_group" "jenkins" {
  name                = "${var.project}-${var.environment}-jenkins-asg"
  vpc_zone_identifier = [var.subnet_id] # Using only one subnet for Jenkins
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.jenkins.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  termination_policies      = ["OldestLaunchTemplate"]
  wait_for_capacity_timeout = "10m"

  # Ensure we create new instances before destroying old ones
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
      instance_warmup        = 300
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-jenkins"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }
}

# Network Load Balancer for Jenkins
resource "aws_lb" "jenkins_nlb" {
  name               = "${var.project}-${var.environment}-jenkins-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.subnet_id]

  tags = {
    Name        = "${var.project}-${var.environment}-jenkins-nlb"
    Environment = var.environment
    Project     = var.project
  }
}

# Target group for Jenkins
resource "aws_lb_target_group" "jenkins" {
  name        = "${var.project}-${var.environment}-jenkins-tg"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 30
    port                = 8080
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.project}-${var.environment}-jenkins-tg"
    Environment = var.environment
    Project     = var.project
  }
}

# Auto Scaling attachment
resource "aws_autoscaling_attachment" "jenkins" {
  autoscaling_group_name = aws_autoscaling_group.jenkins.name
  lb_target_group_arn    = aws_lb_target_group.jenkins.arn
}

# Jenkins NLB Listener
resource "aws_lb_listener" "jenkins" {
  load_balancer_arn = aws_lb.jenkins_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}

# IAM Instance Profile for Jenkins
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.project}-${var.environment}-jenkins-profile"
  role = var.jenkins_role_name
}

# Data Sources for AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# SSM Parameter to store Jenkins URL
resource "aws_ssm_parameter" "jenkins_url" {
  name        = "/${var.project}/${var.environment}/jenkins-url"
  description = "Jenkins URL"
  type        = "String"
  value       = "http://${aws_lb.jenkins_nlb.dns_name}"

  tags = {
    Name        = "${var.project}-${var.environment}-jenkins-url"
    Environment = var.environment
    Project     = var.project
  }
}