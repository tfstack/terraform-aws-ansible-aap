# Database Module - RDS PostgreSQL

locals {
  rds_name = "${var.name}-ansible-aap"
}

module "rds" {
  source  = "tfstack/rds-postgres/aws"
  version = ">= 1.0"

  ############################################
  # Core settings
  ############################################
  name                 = local.rds_name
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  multi_az             = var.multi_az
  read_replica_enabled = var.read_replica_enabled

  ############################################
  # Authentication & Credentials
  ############################################
  master_username        = var.master_username
  master_password        = var.master_password
  create_random_password = var.create_random_password

  ############################################
  # Storage & performance
  ############################################
  allocated_storage                     = var.allocated_storage
  max_allocated_storage                 = var.max_allocated_storage
  storage_type                          = var.storage_type
  storage_encrypted                     = var.storage_encrypted
  kms_key_arn                           = var.kms_key_arn
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  allow_major_version_upgrade           = var.allow_major_version_upgrade
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  ############################################
  # Networking
  ############################################
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = var.publicly_accessible

  ############################################
  # Maintenance & monitoring
  ############################################
  backup_retention_period             = var.backup_retention_period
  maintenance_window                  = var.maintenance_window
  apply_immediately                   = var.apply_immediately
  monitoring_enabled                  = var.monitoring_enabled
  monitoring_interval                 = var.monitoring_interval
  create_monitoring_role              = var.create_monitoring_role
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  ############################################
  # Deletion / Snapshot behavior
  ############################################
  deletion_protection   = var.deletion_protection
  skip_final_snapshot   = var.skip_final_snapshot
  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  force_destroy         = var.force_destroy

  ############################################
  # Tags
  ############################################
  tags = var.tags
}
