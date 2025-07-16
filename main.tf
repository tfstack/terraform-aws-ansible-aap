# Root Module - Orchestrates all submodules for AAP deployment

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Locals
locals {
  common_tags = merge(var.tags, {
    Name        = var.name
    Environment = var.environment
    # Module      = "terraform-aws-ansible-aap"
  })
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  name = var.name
  tags = local.common_tags

  # VPC Configuration
  create_vpc           = var.create_vpc
  vpc_id               = var.vpc_id
  vpc_cidr             = var.vpc_cidr
  subnet_ids           = var.subnet_ids
  availability_zones   = var.availability_zones
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # Security Groups
  allowed_cidr_blocks = var.allowed_cidr_blocks
}

# # Jumphost Module
# module "jumphost" {
#   source = "./modules/jumphost"

#   name = var.name
#   tags = local.common_tags

#   ami_type                            = var.ami_type
#   subnet_id                           = module.networking.subnet_ids[0]
#   vpc_id                              = module.networking.vpc_id
#   create_security_group               = var.create_security_group
#   assign_eip                          = var.assign_eip
#   enable_instance_connect             = var.enable_instance_connect
#   enable_instance_connect_endpoint    = var.enable_instance_connect_endpoint
#   instance_connect_endpoint_subnet_id = module.networking.subnet_ids[0]
#   allowed_cidr_blocks                 = var.allowed_cidr_blocks
#   user_data_extra                     = var.user_data_extra
# }

# Storage Module
module "storage" {
  source = "./modules/storage"

  name = var.name
  tags = local.common_tags

  # AAP Package Configuration
  aap_package_mode        = var.aap_package_mode
  aap_installer_path      = var.aap_installer_path
  aap_installer_s3_bucket = var.aap_installer_s3_bucket
  aap_installer_s3_key    = var.aap_installer_s3_key
}

# Secrets Module
module "secrets" {
  source = "./modules/secrets"

  name          = var.name
  tags          = local.common_tags
  force_destroy = var.force_destroy

  # AAP Configuration
  aap_admin_username            = var.aap_admin_username
  aap_admin_password_secret_arn = var.aap_admin_password_secret_arn

  # Database Configuration
  db_username            = var.db_username
  db_password_secret_arn = var.db_password_secret_arn
}

# Database Module
module "database" {
  source = "./modules/database"

  # Basic Configuration
  name = var.name
  tags = local.common_tags

  # Engine Configuration
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Storage Configuration
  allocated_storage = var.db_allocated_storage
  storage_encrypted = var.storage_encrypted

  # Network Configuration
  subnet_ids             = module.networking.subnet_ids
  vpc_security_group_ids = [module.networking.rds_security_group_id]

  # Authentication & Credentials (using Secrets module)
  master_username        = module.secrets.db_username
  master_password        = module.secrets.db_password
  create_random_password = false

  # Backup & Management
  backup_retention_period = var.db_backup_retention_period
  backup_window           = var.db_backup_window
  deletion_protection     = var.db_enable_deletion_protection
  force_destroy           = var.force_destroy
  skip_final_snapshot     = var.skip_final_snapshot
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  name = var.name
  tags = local.common_tags

  # EC2 Configuration
  instance_type = var.instance_type
  ami_id        = var.ami_id

  # Networking
  subnet_ids                       = module.networking.subnet_ids
  aap_controller_security_group_id = module.networking.aap_controller_security_group_id

  # Dependencies from other modules
  aap_admin_secret_arn   = module.secrets.aap_admin_secret_arn
  db_password_secret_arn = module.secrets.db_password_secret_arn
  db_endpoint            = module.database.endpoint
  db_name                = module.database.name
  s3_bucket_name         = module.storage.s3_bucket_name
  s3_object_key          = module.storage.s3_object_key

  # Monitoring (will be empty initially, updated after monitoring module)
  enable_cloudwatch_logs    = var.enable_cloudwatch_logs
  cloudwatch_log_group_name = ""

  # AAP Configuration
  aap_admin_username = module.secrets.aap_admin_username
  aap_organization   = var.aap_organization

  # Red Hat Subscription
  redhat_org            = var.redhat_org
  redhat_activation_key = var.redhat_activation_key
}

# # Monitoring Module (created after compute to avoid circular dependency)
# module "monitoring" {
#   source = "./modules/monitoring"

#   name = var.name
#   tags = local.common_tags

#   # CloudWatch Configuration
#   enable_cloudwatch_logs      = var.enable_cloudwatch_logs
#   enable_cloudwatch_dashboard = var.enable_cloudwatch_dashboard
#   log_retention_days          = var.log_retention_days

#   # Instance dependencies
#   instance_id     = module.compute.aap_controller_instance_id
#   rds_instance_id = module.database.rds_instance_id

#   depends_on = [module.compute]
# }
