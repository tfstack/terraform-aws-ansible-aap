# Compute Module Outputs

output "aap_controller_instance_id" {
  description = "ID of the AAP controller EC2 instance"
  value       = aws_instance.aap_controller.id
}

output "aap_controller_private_ip" {
  description = "Private IP address of the AAP controller"
  value       = aws_instance.aap_controller.private_ip
}

output "aap_controller_public_ip" {
  description = "Public IP address of the AAP controller"
  value       = aws_instance.aap_controller.public_ip
}

output "aap_controller_iam_role_arn" {
  description = "ARN of the IAM role for AAP controller"
  value       = aws_iam_role.aap_controller.arn
}

output "aap_controller_instance_profile_name" {
  description = "Name of the instance profile for AAP controller"
  value       = aws_iam_instance_profile.aap_controller.name
}
