# SNS Topic for infrastructure notifications
resource "aws_sns_topic" "infrastructure_alerts" {
  name = "${var.project}-${var.environment}-infrastructure-alerts"
  
  tags = {
    Name        = "${var.project}-${var.environment}-infrastructure-alerts"
    Environment = var.environment
    Project     = var.project
  }
}

# SNS Topic Policy to allow services to publish
resource "aws_sns_topic_policy" "infrastructure_alerts_policy" {
  arn = aws_sns_topic.infrastructure_alerts.arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Default"
    Statement = [
      {
        Sid       = "AllowAWSServicesToPublish"
        Effect    = "Allow"
        Principal = {
          Service = [
            "cloudwatch.amazonaws.com",
            "autoscaling.amazonaws.com",
            "events.amazonaws.com",
            "ssm.amazonaws.com"
          ]
        }
        Action    = "SNS:Publish"
        Resource  = aws_sns_topic.infrastructure_alerts.arn
      }
    ]
  })
}