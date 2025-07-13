# Secrets Module - AWS Secrets Manager

# Generate random passwords for secrets (if not provided)
resource "random_password" "aap_admin_password" {
  count   = var.aap_admin_password_secret_arn == null ? 1 : 0
  length  = 16
  special = true
}

resource "random_password" "db_password" {
  count   = var.db_password_secret_arn == null ? 1 : 0
  length  = 16
  special = true
}

# Secrets Manager secrets (conditionally created)
resource "aws_secretsmanager_secret" "aap_admin_password" {
  count                   = var.aap_admin_password_secret_arn == null ? 1 : 0
  name                    = "${var.name}-aap-admin-password"
  description             = "AAP admin password for ${var.name}"
  recovery_window_in_days = var.force_destroy ? 0 : 30

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "aap_admin_password" {
  count     = var.aap_admin_password_secret_arn == null ? 1 : 0
  secret_id = aws_secretsmanager_secret.aap_admin_password[0].id
  secret_string = jsonencode({
    username = var.aap_admin_username
    password = random_password.aap_admin_password[0].result
  })
}

resource "aws_secretsmanager_secret" "db_password" {
  count                   = var.db_password_secret_arn == null ? 1 : 0
  name                    = "${var.name}-db-password"
  description             = "RDS password for ${var.name}"
  recovery_window_in_days = var.force_destroy ? 0 : 30

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  count     = var.db_password_secret_arn == null ? 1 : 0
  secret_id = aws_secretsmanager_secret.db_password[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password[0].result
  })
}

# Existing DB secret lookup
data "aws_secretsmanager_secret_version" "db_existing" {
  count     = var.db_password_secret_arn != null ? 1 : 0
  secret_id = var.db_password_secret_arn
}

# Helper local to fetch DB password value
locals {
  db_password_plaintext = var.db_password_secret_arn != null ? jsondecode(data.aws_secretsmanager_secret_version.db_existing[0].secret_string).password : random_password.db_password[0].result
}
