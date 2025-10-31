# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-ecs-task-execution-role"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-ecs-task-role"
    Environment = var.environment
    Project     = var.project
  }
}

# Jenkins IAM Role for CI/CD pipeline
resource "aws_iam_role" "jenkins_role" {
  name = "${var.project}-${var.environment}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-jenkins-role"
    Environment = var.environment
    Project     = var.project
  }
}

# Policy for Jenkins to interact with ECS
resource "aws_iam_policy" "jenkins_ecs_policy" {
  name        = "${var.project}-${var.environment}-jenkins-ecs-policy"
  description = "Policy to allow Jenkins to deploy to ECS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "iam:PassRole"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-jenkins-ecs-policy"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_ecs_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_ecs_policy.arn
}
resource "aws_iam_policy" "prometheus_discovery" {
  name        = "prometheus-discovery"
  description = "Allow Prometheus to discover EC2 and ECS targets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ecs:ListServices",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prometheus_discovery" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.prometheus_discovery.arn
}
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# SSM Service Role
resource "aws_iam_role" "ssm_service_role" {
  name = "${var.project}-${var.environment}-ssm-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-ssm-service-role"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "ssm_service_role_policy" {
  role       = aws_iam_role.ssm_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

# EC2 Instance Profile for SSM and ECS
resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.project}-${var.environment}-ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-ec2-instance-role"
    Environment = var.environment
    Project     = var.project
  }
}

# Attach policies to EC2 instance role
resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_ecs_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project}-${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}

# CodeDeploy role for ECS blue/green deployments
resource "aws_iam_role" "codedeploy_role" {
  name = "${var.project}-${var.environment}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-codedeploy-role"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

