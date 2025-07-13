# # Main Outputs
# output "aap_web_url" {
#   description = "URL to access the AAP web interface"
#   value       = module.ansible_aap.aap_web_url
# }

# output "admin_login_info" {
#   description = "AAP admin login information"
#   value       = module.ansible_aap.admin_login_info
# }

# output "ssh_command" {
#   description = "SSH command to connect to AAP controller"
#   value       = module.ansible_aap.ssh_command
# }

# output "ssm_session_command" {
#   description = "AWS CLI command to start SSM session"
#   value       = module.ansible_aap.ssm_session_command
# }

# output "cloudwatch_dashboard_url" {
#   description = "CloudWatch dashboard URL for monitoring"
#   value       = module.ansible_aap.cloudwatch_dashboard_url
# }

# Infrastructure Details
output "vpc_id" {
  description = "VPC ID where resources are deployed"
  value       = module.ansible_aap.vpc_id
}

# output "instance_id" {
#   description = "EC2 instance ID of the AAP controller"
#   value       = module.ansible_aap.aap_controller_instance_id
# }

# output "rds_endpoint" {
#   description = "RDS PostgreSQL endpoint"
#   value       = module.ansible_aap.rds_endpoint
# }

# output "s3_bucket_name" {
#   description = "S3 bucket name for AAP installer"
#   value       = module.ansible_aap.s3_bucket_name
# }

# output "test" {
#   value = module.ansible_aap
# }
