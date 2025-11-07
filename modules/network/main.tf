resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false # Not assigning public IPs by default

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

resource "aws_subnet" "database_subnet" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "database-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "main-nat-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "database_subnet_association" {
  count          = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# KMS Key for S3 bucket encryption
resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags = {
    Name        = "s3-kms-key-${var.environment}"
    Environment = var.environment
  }
}

# S3 Bucket for ALB logs
resource "aws_s3_bucket" "alb_logs" {
  bucket        = "alb-logs-${var.environment}-${random_string.suffix.result}"
  force_destroy = true

  tags = {
    Name        = "alb-access-logs"
    Environment = var.environment
  }
}

# S3 Bucket for ALB logs access logging
resource "aws_s3_bucket" "alb_logs_access_logs" {
  bucket        = "alb-logs-access-${var.environment}-${random_string.suffix.result}"
  force_destroy = true

  tags = {
    Name        = "alb-access-logs-access"
    Environment = var.environment
  }
}

# S3 Bucket for cross-region replication logs
resource "aws_s3_bucket" "replication_logs" {
  bucket        = "replication-logs-${var.environment}-${random_string.suffix.result}"
  force_destroy = true

  tags = {
    Name        = "replication-logs"
    Environment = var.environment
  }
}

# IAM role for S3 replication
resource "aws_iam_role" "replication" {
  name = "s3-replication-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "replication" {
  name = "s3-replication-policy-${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.alb_logs.arn,
          aws_s3_bucket.alb_logs_access_logs.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ],
        Resource = [
          "${aws_s3_bucket.alb_logs.arn}/*",
          "${aws_s3_bucket.alb_logs_access_logs.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Resource = [
          "${aws_s3_bucket.alb_logs.arn}/*",
          "${aws_s3_bucket.alb_logs_access_logs.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "alb_logs_versioning" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs_encryption" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Enable access logging for the ALB logs bucket
resource "aws_s3_bucket_logging" "alb_logs_logging" {
  bucket = aws_s3_bucket.alb_logs.id

  target_bucket = aws_s3_bucket.alb_logs_access_logs.id
  target_prefix = "log/"
}

# Enable access logging for the access logs bucket itself
resource "aws_s3_bucket_logging" "alb_logs_access_logging" {
  bucket = aws_s3_bucket.alb_logs_access_logs.id

  target_bucket = aws_s3_bucket.alb_logs_access_logs.id
  target_prefix = "self-log/"
}

# Enable access logging for the replication logs bucket
resource "aws_s3_bucket_logging" "replication_logs_logging" {
  bucket = aws_s3_bucket.replication_logs.id

  target_bucket = aws_s3_bucket.alb_logs_access_logs.id
  target_prefix = "replication-log/"
}

# Enable versioning for the access logs bucket
resource "aws_s3_bucket_versioning" "alb_logs_access_versioning" {
  bucket = aws_s3_bucket.alb_logs_access_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption with KMS for access logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs_access_encryption" {
  bucket = aws_s3_bucket.alb_logs_access_logs.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Enable server-side encryption with KMS for replication logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "replication_logs_encryption" {
  bucket = aws_s3_bucket.replication_logs.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Enable versioning for the replication logs bucket
resource "aws_s3_bucket_versioning" "replication_logs_versioning" {
  bucket = aws_s3_bucket.replication_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access to the replication logs bucket
resource "aws_s3_bucket_public_access_block" "replication_logs_public_access" {
  bucket = aws_s3_bucket.replication_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Block public access to the S3 buckets
resource "aws_s3_bucket_public_access_block" "alb_logs_public_access" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Block public access to the access logs bucket
resource "aws_s3_bucket_public_access_block" "alb_logs_access_public_access" {
  bucket = aws_s3_bucket.alb_logs_access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable cross-region replication for ALB logs bucket
# S3 replication configurations removed for POC
# Enable lifecycle rule to manage log files
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs_lifecycle" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    id     = "log"
    status = "Enabled"

    expiration {
      days = 90 # Keep logs for 90 days
    }
  }
}

# Lifecycle configuration for access logs bucket
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs_access_lifecycle" {
  bucket = aws_s3_bucket.alb_logs_access_logs.id

  rule {
    id     = "access-logs"
    status = "Enabled"

    expiration {
      days = 90 # Keep access logs for 90 days
    }
  }
}

# Lifecycle configuration for replication logs bucket
resource "aws_s3_bucket_lifecycle_configuration" "replication_logs_lifecycle" {
  bucket = aws_s3_bucket.replication_logs.id

  rule {
    id     = "replication-logs"
    status = "Enabled"

    expiration {
      days = 90 # Keep replication logs for 90 days
    }
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::elb-account-id:root" # Replace with actual ALB account ID
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}

# Flow logs
resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
  iam_role_arn         = aws_iam_role.vpc_flow_logs_role.arn
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.logs_key.arn
}

resource "aws_kms_key" "logs_key" {
  description             = "KMS key for VPC flow logs"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Security Group for ALB
resource "aws_security_group" "alb_security_group" {
  name        = "alb-security-group"
  description = "Security group for application load balancer"
  vpc_id      = aws_vpc.vpc.id

  # Allow incoming HTTPS traffic only
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP for redirection only (will be redirected to HTTPS)
  ingress {
    description = "HTTP from internet (for redirection to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Restricted egress rules
  egress {
    description = "HTTP to ECS services"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block] # Allow traffic to any private IP in the VPC
  }

  egress {
    description = "HTTPS to internet for external resources"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-security-group"
  }
}

# ECS Security Group
resource "aws_security_group" "ecs_security_group" {
  name        = "ecs-security-group"
  description = "Security group for ECS Fargate tasks"
  vpc_id      = aws_vpc.vpc.id

  # Allow incoming HTTP traffic from VPC CIDR
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  # Allow internal traffic for service discovery
  ingress {
    description = "Inter-container communication"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    self        = true
  }

  # Restricted egress rules
  egress {
    description = "HTTPS to internet for external resources"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "Database access"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.db_security_group.id]
  }

  tags = {
    Name = "ecs-security-group"
  }
}

# Database Security Group
resource "aws_security_group" "db_security_group" {
  name        = "db-security-group"
  description = "Security group for database instances"
  vpc_id      = aws_vpc.vpc.id

  # Allow incoming database traffic from VPC
  ingress {
    description = "Database port from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  # Allow response traffic to VPC
  egress {
    description = "Response traffic to VPC"
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  tags = {
    Name = "db-security-group"
  }
}

# Default Security Group restriction
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  # No ingress or egress rules - effectively blocking all traffic
}
