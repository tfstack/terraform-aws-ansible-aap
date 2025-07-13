# Monitoring Module - CloudWatch and SSM Resources

# Data sources
data "aws_region" "current" {}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "aap_controller" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/ec2/${var.name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "aap_monitoring" {
  count          = var.enable_cloudwatch_dashboard ? 1 : 0
  dashboard_name = "${var.name}-aap-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.instance_id],
            [".", "NetworkIn", ".", "."],
            [".", "NetworkOut", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "EC2 Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id],
            [".", "DatabaseConnections", ".", "."],
            [".", "FreeableMemory", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.region
          title   = "RDS Metrics"
          period  = 300
        }
      }
    ]
  })
}

# SSM Associations for Patch Management
resource "aws_ssm_association" "patch_baseline" {
  name = "AWS-RunPatchBaseline"

  targets {
    key    = "InstanceIds"
    values = [var.instance_id]
  }

  schedule_expression = "cron(0 2 ? * SUN *)" # Weekly on Sunday at 2 AM

  parameters = {
    Operation = "Install"
  }

  tags = var.tags
}

resource "aws_ssm_association" "inventory" {
  name = "AWS-GatherSoftwareInventory"

  targets {
    key    = "InstanceIds"
    values = [var.instance_id]
  }

  schedule_expression = "rate(24 hours)"

  tags = var.tags
}
