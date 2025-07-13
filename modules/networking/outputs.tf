# Networking Module Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = local.vpc_id
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = local.subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = var.create_vpc ? module.vpc[0].public_subnet_ids : []
}

output "aap_controller_security_group_id" {
  description = "Security group ID for AAP controller"
  value       = aws_security_group.aap_controller.id
}

output "rds_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = local.availability_zones
}
