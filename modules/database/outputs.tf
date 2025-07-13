# Database Module Outputs

####################################
# Primary Instance Outputs
####################################

output "name" {
  description = "Name of the primary RDS instance"
  value       = local.rds_name
}

output "arn" {
  description = "ARN of the primary RDS instance"
  value       = module.rds.arn
}

output "id" {
  description = "ID of the primary RDS instance"
  value       = module.rds.id
}

output "identifier" {
  description = "Identifier of the primary RDS instance"
  value       = module.rds.identifier
}

output "endpoint" {
  description = "Connection endpoint"
  value       = module.rds.endpoint
}

output "port" {
  description = "Database port"
  value       = module.rds.port
}

output "engine" {
  description = "Database engine"
  value       = module.rds.engine
}

output "engine_version" {
  description = "Database engine version"
  value       = module.rds.engine_version
}

output "status" {
  description = "Status of the primary RDS instance"
  value       = module.rds.status
}

####################################
# Authentication Outputs
####################################

output "username" {
  description = "Master username for the database"
  value       = module.rds.username
}

output "password" {
  description = "Master password for the database (if generated)"
  value       = module.rds.password
  sensitive   = true
}

####################################
# Read Replica Outputs
####################################

output "replica_arn" {
  description = "ARN of the read replica (if enabled)"
  value       = module.rds.replica_arn
}

output "replica_id" {
  description = "ID of the read replica (if enabled)"
  value       = module.rds.replica_id
}

output "replica_identifier" {
  description = "Identifier of the read replica (if enabled)"
  value       = module.rds.replica_identifier
}

output "replica_endpoint" {
  description = "Connection endpoint for the read replica (if enabled)"
  value       = module.rds.replica_endpoint
}

output "replica_status" {
  description = "Status of the read replica (if enabled)"
  value       = module.rds.replica_status
}

####################################
# Infrastructure Outputs
####################################

output "db_subnet_group_name" {
  description = "Name of the DB subnet group in use"
  value       = module.rds.db_subnet_group_name
}

output "db_subnet_group_arn" {
  description = "ARN of the DB subnet group"
  value       = module.rds.db_subnet_group_arn
}

output "parameter_group_name" {
  description = "Name of the DB parameter group in use"
  value       = module.rds.parameter_group_name
}

output "kms_key_id" {
  description = "KMS key ID used for encryption (if enabled)"
  value       = module.rds.kms_key_id
}

output "monitoring_role_arn" {
  description = "ARN of the monitoring role (if created)"
  value       = module.rds.monitoring_role_arn
}
