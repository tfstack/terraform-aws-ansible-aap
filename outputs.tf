# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = module.networking.subnet_ids
}

output "aap_controller_security_group_id" {
  description = "ID of the AAP controller security group"
  value       = module.networking.aap_controller_security_group_id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = module.networking.rds_security_group_id
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.networking.availability_zones
}

# # Jumphost Outputs
# output "instance_id" {
#   description = "ID of the jumphost instance."
#   value       = module.jumphost.instance_id
# }

# output "public_ip" {
#   description = "Public IP address (or EIP) of the instance, if assigned."
#   value       = module.jumphost.public_ip
# }

# output "public_dns" {
#   description = "Public DNS name of the instance, if available."
#   value       = module.jumphost.public_dns
# }

# output "ssm_session_command" {
#   description = "Convenience AWS CLI command to open an SSM session to the instance."
#   value       = module.jumphost.ssm_session_command
# }

# output "private_ip" {
#   description = "Private IP address of the instance."
#   value       = module.jumphost.private_ip
# }

# output "security_group_id" {
#   description = "ID of the created security group (if any)."
#   value       = module.jumphost.security_group_id
# }

# output "instance_connect_endpoint_id" {
#   description = "ID of the EC2 Instance Connect Endpoint (if created)."
#   value       = module.jumphost.instance_connect_endpoint_id
# }

# output "instance_connect_endpoint_dns_name" {
#   description = "DNS name of the EC2 Instance Connect Endpoint (if created)."
#   value       = module.jumphost.instance_connect_endpoint_dns_name
# }

# output "instance_connect_command" {
#   description = "Convenience AWS CLI command to connect via EC2 Instance Connect (when enabled)."
#   value       = module.jumphost.instance_connect_command
# }


# # S3 Outputs
# output "s3_bucket_name" {
#   description = "Name of the S3 bucket containing AAP installer"
#   value       = module.storage.s3_bucket_name
# }

# output "s3_bucket_arn" {
#   description = "ARN of the S3 bucket containing AAP installer"
#   value       = module.storage.s3_bucket_arn
# }

# # Secrets Manager Outputs
# output "aap_admin_secret_arn" {
#   description = "ARN of the AAP admin password secret"
#   value       = module.secrets.aap_admin_secret_arn
# }

# output "db_password_secret_arn" {
#   description = "ARN of the database password secret"
#   value       = module.secrets.db_password_secret_arn
# }

# output "aap_admin_username" {
#   description = "AAP admin username"
#   value       = module.secrets.aap_admin_username
# }

# output "db_username" {
#   description = "Database username"
#   value       = module.secrets.db_username
# }

# output "db_password" {
#   description = "Plaintext database password (sensitive)"
#   value       = module.secrets.db_password
#   sensitive   = true
# }

# # RDS Outputs

# output "name" {
#   description = "Name of the primary RDS instance"
#   value       = module.database.name
# }

# output "arn" {
#   description = "ARN of the primary RDS instance"
#   value       = module.database.arn
# }

# output "id" {
#   description = "ID of the primary RDS instance"
#   value       = module.database.id
# }

# output "identifier" {
#   description = "Identifier of the primary RDS instance"
#   value       = module.database.identifier
# }

# output "endpoint" {
#   description = "Connection endpoint"
#   value       = module.database.endpoint
# }

# output "port" {
#   description = "Database port"
#   value       = module.database.port
# }

# output "engine" {
#   description = "Database engine"
#   value       = module.database.engine
# }

# output "engine_version" {
#   description = "Database engine version"
#   value       = module.database.engine_version
# }

# output "status" {
#   description = "Status of the primary RDS instance"
#   value       = module.database.status
# }

# output "username" {
#   description = "Master username for the database"
#   value       = module.database.username
# }

# # output "password" {
# #   description = "Master password for the database (if generated)"
# #   value       = module.rds.password
# #   sensitive   = true
# # }

# output "replica_arn" {
#   description = "ARN of the read replica (if enabled)"
#   value       = module.database.replica_arn
# }

# output "replica_id" {
#   description = "ID of the read replica (if enabled)"
#   value       = module.database.replica_id
# }

# output "replica_identifier" {
#   description = "Identifier of the read replica (if enabled)"
#   value       = module.database.replica_identifier
# }

# output "replica_endpoint" {
#   description = "Connection endpoint for the read replica (if enabled)"
#   value       = module.database.replica_endpoint
# }

# output "replica_status" {
#   description = "Status of the read replica (if enabled)"
#   value       = module.database.replica_status
# }

# output "db_subnet_group_name" {
#   description = "Name of the DB subnet group in use"
#   value       = module.database.db_subnet_group_name
# }

# output "db_subnet_group_arn" {
#   description = "ARN of the DB subnet group"
#   value       = module.database.db_subnet_group_arn
# }

# output "parameter_group_name" {
#   description = "Name of the DB parameter group in use"
#   value       = module.database.parameter_group_name
# }

# output "kms_key_id" {
#   description = "KMS key ID used for encryption (if enabled)"
#   value       = module.database.kms_key_id
# }

# output "monitoring_role_arn" {
#   description = "ARN of the monitoring role (if created)"
#   value       = module.database.monitoring_role_arn
# }

















# # EC2 Outputs
# output "aap_controller_instance_id" {
#   description = "ID of the AAP controller EC2 instance"
#   value       = module.compute.aap_controller_instance_id
# }

# output "aap_controller_private_ip" {
#   description = "Private IP address of the AAP controller"
#   value       = module.compute.aap_controller_private_ip
# }

# output "aap_controller_public_ip" {
#   description = "Public IP address of the AAP controller (if in public subnet)"
#   value       = module.compute.aap_controller_public_ip
# }

# # AAP Web Interface
# output "aap_web_url" {
#   description = "URL to access the AAP web interface"
#   value       = "https://${module.compute.aap_controller_public_ip != "" ? module.compute.aap_controller_public_ip : module.compute.aap_controller_private_ip}"
# }

# # CloudWatch Outputs
# output "cloudwatch_dashboard_url" {
#   description = "URL to the CloudWatch dashboard for monitoring AAP"
#   value       = module.monitoring.cloudwatch_dashboard_url
# }

# output "cloudwatch_log_group_name" {
#   description = "Name of the CloudWatch log group for AAP logs"
#   value       = module.monitoring.cloudwatch_log_group_name
# }

# # Security Group Outputs
# output "aap_controller_security_group_id" {
#   description = "ID of the security group for AAP controller"
#   value       = module.networking.aap_controller_security_group_id
# }

# output "rds_security_group_id" {
#   description = "ID of the security group for RDS"
#   value       = module.networking.rds_security_group_id
# }

# # IAM Outputs
# output "aap_controller_iam_role_arn" {
#   description = "ARN of the IAM role for AAP controller EC2 instance"
#   value       = module.compute.aap_controller_iam_role_arn
# }

# output "aap_controller_instance_profile_name" {
#   description = "Name of the instance profile for AAP controller"
#   value       = module.compute.aap_controller_instance_profile_name
# }

# # Connection Information
# output "ssh_command" {
#   description = "SSH command to connect to the AAP controller (if key pair is configured)"
#   value       = var.key_pair_name != null ? "ssh -i ${var.key_pair_name}.pem ec2-user@${module.compute.aap_controller_public_ip != "" ? module.compute.aap_controller_public_ip : module.compute.aap_controller_private_ip}" : "SSH not configured - use SSM Session Manager"
# }

# output "ssm_session_command" {
#   description = "AWS CLI command to start SSM session with AAP controller"
#   value       = "aws ssm start-session --target ${module.compute.aap_controller_instance_id}"
# }

# # Installation Status
# output "installation_log_command" {
#   description = "Command to view AAP installation logs"
#   value       = "aws logs get-log-events --log-group-name ${module.monitoring.cloudwatch_log_group_name != null ? module.monitoring.cloudwatch_log_group_name : "/var/log/aap-install.log"} --log-stream-name ${module.compute.aap_controller_instance_id}/aap-install"
# }

# # Admin Login Information
# output "admin_login_info" {
#   description = "Information about AAP admin login"
#   value = {
#     username            = module.secrets.aap_admin_username
#     password_secret_arn = module.secrets.aap_admin_secret_arn
#     web_url             = "https://${module.compute.aap_controller_public_ip != "" ? module.compute.aap_controller_public_ip : module.compute.aap_controller_private_ip}"
#   }
#   sensitive = false
# }

# Resource Tags
output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}
