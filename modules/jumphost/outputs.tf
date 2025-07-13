output "instance_id" {
  description = "ID of the jumphost instance."
  value       = module.jumphost.instance_id
}

output "public_ip" {
  description = "Public IP address (or EIP) of the instance, if assigned."
  value       = module.jumphost.public_ip
}

output "public_dns" {
  description = "Public DNS name of the instance, if available."
  value       = module.jumphost.public_dns
}

output "ssm_session_command" {
  description = "Convenience AWS CLI command to open an SSM session to the instance."
  value       = module.jumphost.ssm_session_command
}

output "private_ip" {
  description = "Private IP address of the instance."
  value       = module.jumphost.private_ip
}

output "security_group_id" {
  description = "ID of the created security group (if any)."
  value       = module.jumphost.security_group_id
}

output "instance_connect_endpoint_id" {
  description = "ID of the EC2 Instance Connect Endpoint (if created)."
  value       = module.jumphost.instance_connect_endpoint_id
}

output "instance_connect_endpoint_dns_name" {
  description = "DNS name of the EC2 Instance Connect Endpoint (if created)."
  value       = module.jumphost.instance_connect_endpoint_dns_name
}

output "instance_connect_command" {
  description = "Convenience AWS CLI command to connect via EC2 Instance Connect (when enabled)."
  value       = module.jumphost.instance_connect_command
}
