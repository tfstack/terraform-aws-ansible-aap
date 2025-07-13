# Monitoring Module Outputs

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.aap_controller[0].name : null
}

output "cloudwatch_dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = var.enable_cloudwatch_dashboard ? "https://${data.aws_region.current.region}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.region}#dashboards:name=${aws_cloudwatch_dashboard.aap_monitoring[0].dashboard_name}" : null
}
