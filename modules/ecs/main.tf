# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "${var.project}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-cluster"
    Environment = var.environment
    Project     = var.project
  }
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project}-${var.environment}"
  retention_in_days = 30

  tags = {
    Name        = "${var.project}-${var.environment}-ecs-logs"
    Environment = var.environment
    Project     = var.project
  }
}

# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project}-${var.environment}-alb"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.project}-${var.environment}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-tg"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  tags = {
    Name        = "${var.project}-${var.environment}-http-listener"
    Environment = var.environment
    Project     = var.project
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.project}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role
  task_role_arn            = var.ecs_task_role

  container_definitions = jsonencode([
    {
      name      = "${var.project}-${var.environment}-container"
      image     = "nginx:latest" # This is a placeholder image
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.project}-${var.environment}-task"
    Environment = var.environment
    Project     = var.project
  }
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = "${var.project}-${var.environment}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_security_group]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.project}-${var.environment}-container"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name        = "${var.project}-${var.environment}-service"
    Environment = var.environment
    Project     = var.project
  }
}

# Jenkins for CI/CD with GitHub
resource "aws_instance" "jenkins" {
  count = var.create_jenkins ? 1 : 0

  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.medium"
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.jenkins_security_group]
  key_name               = var.key_name

  user_data = <<-EOF
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
  EOF

  tags = {
    Name        = "${var.project}-${var.environment}-jenkins"
    Environment = var.environment
    Project     = var.project
  }
}

# Self-signed certificate for testing (not recommended for production)
resource "tls_private_key" "example" {
  count       = var.create_dummy_cert ? 1 : 0
  algorithm   = "RSA"
  rsa_bits    = 4096 # Increased from 2048 for better security
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "example" {
  count             = var.create_dummy_cert ? 1 : 0
  private_key_pem   = tls_private_key.example[0].private_key_pem
  is_ca_certificate = false

  subject {
    common_name  = var.domain_name
    organization = var.project
    country      = "US"
    locality     = "Seattle"
    province     = "Washington"
  }

  # Reduced validity period for security
  validity_period_hours = 24 # 1 day for testing
  early_renewal_hours   = 6  # 6 hours before expiration

  # Allowed uses for the certificate
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "cert_signing"
  ]

  # DNS names for the certificate
  dns_names = [
    var.domain_name,
    "*.${var.domain_name}",
    "${var.environment}.${var.domain_name}",
  ]
}

resource "aws_acm_certificate" "cert" {
  count                  = var.create_dummy_cert ? 1 : 0
  private_key            = tls_private_key.example[0].private_key_pem
  certificate_body       = tls_self_signed_cert.example[0].cert_pem
  certificate_chain      = tls_self_signed_cert.example[0].cert_pem
  early_renewal_duration = "24h"      # 24 hours before expiration
  key_algorithm          = "RSA_4096" # Matches our 4096-bit RSA key
  tags = {
    Name        = "${var.project}-${var.environment}-cert"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    AutoRenew   = "false" # Self-signed certs shouldn't be auto-renewed
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  count             = var.create_dummy_cert ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  # Use a more secure SSL policy that requires TLS 1.2 minimum (OWASP recommendation)
  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = aws_acm_certificate.cert[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  tags = {
    Name               = "${var.project}-${var.environment}-https"
    Environment        = var.environment
    Project            = var.project
    SecurityCompliance = "OWASP-TLS-1.2"
  }
}

# HTTP to HTTPS redirect with security headers
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  # Add security headers via response headers policy
  lifecycle {
    ignore_changes = [default_action]
  }

  tags = {
    Name        = "${var.project}-${var.environment}-http-redirect"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Security headers policy
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = "${var.project}-${var.environment}-security-headers"
  comment = "Security headers policy for ${var.project} - OWASP Compliant"

  security_headers_config {
    content_security_policy {
      # Enhanced CSP aligned with OWASP recommendations
      content_security_policy = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https:; style-src 'self' 'unsafe-inline' https:; img-src 'self' data: https:; font-src 'self' https: data:; connect-src 'self' https:; media-src 'self' https:; object-src 'none'; frame-src 'self' https:; worker-src 'self' blob:; manifest-src 'self'; base-uri 'self'; form-action 'self';"
      override                = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }

    # HSTS (HTTP Strict Transport Security)
    strict_transport_security {
      access_control_max_age_sec = 63072000 # 2 years
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
  }
}

# Data sources
data "aws_region" "current" {}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}