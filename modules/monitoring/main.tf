# Security Group for Prometheus and Grafana
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Security group for Prometheus and Grafana"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Prometheus UI"
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    description     = "Grafana UI"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "HTTPS to internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP to internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-sg"
  }
}

# CloudWatch logs for Prometheus and Grafana
resource "aws_cloudwatch_log_group" "prometheus_logs" {
  name              = "/ecs/prometheus"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "grafana_logs" {
  name              = "/ecs/grafana"
  retention_in_days = 30
}

# EFS for persistent storage
resource "aws_efs_file_system" "monitoring_data" {
  encrypted        = true
  performance_mode = "generalPurpose"

  tags = {
    Name = "monitoring-data"
  }
}

resource "aws_efs_mount_target" "monitoring_mount" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.monitoring_data.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.monitoring_sg.id]
}

# Prometheus Service
resource "aws_ecs_service" "prometheus" {
  name            = "prometheus"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.monitoring_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.prometheus.arn
    container_name   = "prometheus"
    container_port   = 9090
  }
}

resource "aws_lb_target_group" "prometheus" {
  name        = "prometheus-tg"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/-/healthy"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}
