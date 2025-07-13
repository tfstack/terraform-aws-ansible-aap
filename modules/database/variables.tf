####################################
# Basic Configuration
####################################

variable "name" {
  description = "Base name used for resource identifiers."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources that support it."
  type        = map(string)
  default     = {}
}

####################################
# Engine Configuration
####################################

variable "engine_version" {
  description = "PostgreSQL engine version to use."
  type        = string
  default     = "15.13"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.engine_version))
    error_message = "Engine version must be in format 'major.minor' (e.g., '15.13')."
  }
}

variable "instance_class" {
  description = "The instance class to use (e.g. db.t3.medium)."
  type        = string
  default     = "db.t3.medium"

  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.instance_class))
    error_message = "Instance class must be a valid RDS instance class (e.g., 'db.t3.medium')."
  }
}

####################################
# Storage Configuration
####################################

variable "allocated_storage" {
  description = "The amount of storage (in GB) to allocate for the DB instance."
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 65536
    error_message = "Allocated storage must be between 20 and 65536 GB."
  }
}

variable "max_allocated_storage" {
  description = "The upper limit (in GB) to which Amazon RDS can automatically scale storage. Set to 0 to disable autoscaling."
  type        = number
  default     = 0

  validation {
    condition     = var.max_allocated_storage == 0 || var.max_allocated_storage >= var.allocated_storage
    error_message = "Max allocated storage must be 0 (disabled) or greater than allocated_storage."
  }
}

variable "storage_type" {
  description = "One of standard | gp2 | gp3 | io1 | io2"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["standard", "gp2", "gp3", "io1", "io2"], var.storage_type)
    error_message = "Storage type must be one of: standard, gp2, gp3, io1, io2."
  }
}

variable "iops" {
  description = "The amount of provisioned IOPS to allocate for the DB instance when using io1, io2 or gp3 storage types."
  type        = number
  default     = 0

  validation {
    condition     = var.iops >= 0 && var.iops <= 80000
    error_message = "IOPS must be between 0 and 80000."
  }
}

variable "storage_encrypted" {
  description = "Whether to enable storage encryption."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of an existing KMS key to use. Leave empty to create a new one if encryption is enabled."
  type        = string
  default     = ""
}

####################################
# Network Configuration
####################################

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs must be provided for Multi-AZ deployments."
  }
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate."
  type        = list(string)
  default     = []
}

variable "multi_az" {
  description = "Whether to deploy the instance in multiple AZs."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the DB instance is publicly accessible."
  type        = bool
  default     = false
}

####################################
# Authentication & Credentials
####################################

variable "master_username" {
  description = "Master database username. Required unless snapshot_identifier provided."
  type        = string
  default     = "postgres"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.master_username))
    error_message = "Master username must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "master_password" {
  description = "Master database password. If create_random_password is true, this value will be ignored and a random password will be generated instead."
  type        = string
  default     = ""
  sensitive   = true
}

variable "create_random_password" {
  description = "Generate a random master password. When true, the master_password variable is ignored."
  type        = bool
  default     = true
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication."
  type        = bool
  default     = false
}

####################################
# Backup & Snapshot Configuration
####################################

variable "backup_retention_period" {
  description = "Days to retain automated backups. 0 disables backups."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  description = "Preferred backup window in HH:MM-HH:MM format (UTC)."
  type        = string
  default     = "03:00-05:00"

  validation {
    condition     = can(regex("^[0-2][0-9]:[0-5][0-9]-[0-2][0-9]:[0-5][0-9]$", var.backup_window))
    error_message = "Backup window must be in HH:MM-HH:MM format."
  }
}

variable "copy_tags_to_snapshot" {
  description = "Copy all DB instance tags to snapshots."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip taking a final snapshot before deletion."
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Identifier for the final snapshot. Ignored if skip_final_snapshot is true."
  type        = string
  default     = ""
}

variable "snapshot_identifier" {
  description = "DB snapshot identifier to restore from. Leave empty for fresh instance."
  type        = string
  default     = ""
}

####################################
# Maintenance Configuration
####################################

variable "maintenance_window" {
  description = "Preferred maintenance window in ddd:HH:MM-ddd:HH:MM format (UTC)."
  type        = string
  default     = "Sun:06:00-Sun:07:00"

  validation {
    condition     = can(regex("^(Mon|Tue|Wed|Thu|Fri|Sat|Sun):[0-2][0-9]:[0-5][0-9]-(Mon|Tue|Wed|Thu|Fri|Sat|Sun):[0-2][0-9]:[0-5][0-9]$", var.maintenance_window))
    error_message = "Maintenance window must be in ddd:HH:MM-ddd:HH:MM format."
  }
}

variable "apply_immediately" {
  description = "Whether changes should be applied immediately or during the next maintenance window."
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Allow automatic minor version upgrades."
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Whether major version upgrades are allowed when modifying the instance."
  type        = bool
  default     = false
}

####################################
# Monitoring Configuration
####################################

variable "monitoring_enabled" {
  description = "Enable Enhanced Monitoring."
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "Enhanced Monitoring interval in seconds (e.g. 60 | 30 | 15)."
  type        = number
  default     = 60

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "create_monitoring_role" {
  description = "Whether to create an IAM role for Enhanced Monitoring if monitoring_enabled is true."
  type        = bool
  default     = true
}

variable "monitoring_role_arn" {
  description = "ARN of an existing IAM role to use for Enhanced Monitoring. Used when create_monitoring_role is false."
  type        = string
  default     = ""
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Retention period (in days) for Performance Insights metrics (7, 731, or 2190)."
  type        = number
  default     = 7

  validation {
    condition     = contains([7, 731, 2190], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be one of: 7, 731, or 2190."
  }
}

####################################
# Parameter Group Configuration
####################################

variable "create_db_parameter_group" {
  description = "Whether to create a custom DB parameter group using parameter_group_parameters."
  type        = bool
  default     = false
}

variable "db_parameter_group_name" {
  description = "Name of an existing DB parameter group to use. Ignored if create_db_parameter_group is true."
  type        = string
  default     = ""
}

variable "parameter_group_family" {
  description = "Parameter group family to use when creating a custom group (e.g., postgres15)."
  type        = string
  default     = "postgres15"

  validation {
    condition     = can(regex("^postgres[0-9]+$", var.parameter_group_family))
    error_message = "Parameter group family must be in format 'postgresXX' (e.g., 'postgres15')."
  }
}

variable "parameter_group_parameters" {
  description = "A map of parameter names to values for the custom parameter group."
  type        = map(string)
  default     = {}
}

####################################
# Read Replica Configuration
####################################

variable "read_replica_enabled" {
  description = "Create a single read replica of the primary instance."
  type        = bool
  default     = false
}

####################################
# Security & Protection
####################################

variable "deletion_protection" {
  description = "Enable deletion protection on the instance."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Set to true to forcefully destroy associated resources such as parameter groups or automated backups when the module is destroyed. Use with caution."
  type        = bool
  default     = false
}
