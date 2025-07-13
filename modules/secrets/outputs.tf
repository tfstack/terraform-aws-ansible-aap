# Secrets Module Outputs

output "aap_admin_secret_arn" {
  description = "ARN of the AAP admin password secret"
  value       = var.aap_admin_password_secret_arn != null ? var.aap_admin_password_secret_arn : aws_secretsmanager_secret.aap_admin_password[0].arn
}

output "db_password_secret_arn" {
  description = "ARN of the database password secret"
  value       = var.db_password_secret_arn != null ? var.db_password_secret_arn : aws_secretsmanager_secret.db_password[0].arn
}

output "aap_admin_username" {
  description = "AAP admin username"
  value       = var.aap_admin_username
}

output "db_username" {
  description = "Database username"
  value       = var.db_username
}

output "db_password" {
  description = "Plaintext database password (sensitive)"
  value       = local.db_password_plaintext
  sensitive   = true
}
