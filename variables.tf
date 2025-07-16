# Module identification
variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Networking variables
variable "vpc_id" {
  description = "VPC ID where resources will be created. If not provided, a new VPC will be created"
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_ids" {
  description = "List of subnet IDs for RDS and EC2. If not provided, subnets from the VPC module will be used"
  type        = list(string)
  default     = []
}

variable "create_vpc" {
  description = "Whether to create a new VPC using the cloudbuildlab/vpc/aws module"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of availability zones to use (minimum 2 for RDS). Leave empty to auto-select."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.availability_zones) == 0 || length(var.availability_zones) >= 2
    error_message = "If availability_zones is provided, it must contain at least 2 AZs to satisfy RDS subnet group requirements."
  }
}

# # Jumphost variables

# variable "ami_type" {
#   description = "Logical AMI type to use. Allowed: amazonlinux2, amazonlinux2023, ubuntu."
#   type        = string
#   default     = "amazonlinux2"
#   validation {
#     condition     = contains(["amazonlinux2", "amazonlinux2023", "ubuntu"], lower(var.ami_type))
#     error_message = "ami_type must be one of: amazonlinux2, amazonlinux2023, ubuntu."
#   }
# }

# variable "create_security_group" {
#   description = "Create a dedicated security group allowing SSH/ICMP from allowed CIDRs if no security group IDs are supplied. If true, vpc_security_group_ids can be empty."
#   type        = bool
#   default     = false
# }

# variable "assign_eip" {
#   description = "Whether to allocate and associate an Elastic IP (valid only when subnet is public)."
#   type        = bool
#   default     = true
# }

# variable "enable_instance_connect" {
#   description = "Install and enable EC2 Instance Connect for SSH (Amazon Linux & Ubuntu only)."
#   type        = bool
#   default     = false
# }

variable "redhat_org" {
  description = "Red Hat organization ID for subscription registration"
  type        = string
  default     = ""
}

variable "redhat_activation_key" {
  description = "Red Hat activation key for subscription registration"
  type        = string
  default     = ""
}

variable "enable_ssm" {
  description = "Enable AWS SSM Agent installation on AAP controller"
  type        = bool
  default     = true
}

# variable "user_data_extra" {
#   description = "Additional user_data shell commands appended to the module's base user_data."
#   type        = string
#   default     = ""
# }

# AAP Package handling variables
variable "aap_package_mode" {
  description = "Mode for AAP package handling: 'upload' to upload local file, 'existing' to use existing S3 object"
  type        = string
  default     = "upload"
  validation {
    condition     = contains(["upload", "existing"], var.aap_package_mode)
    error_message = "aap_package_mode must be either 'upload' or 'existing'."
  }
}

variable "aap_installer_path" {
  description = "Local path to AAP installer bundle (required when aap_package_mode is 'upload')"
  type        = string
  default     = null
}

variable "aap_installer_s3_bucket" {
  description = "S3 bucket containing AAP installer (required when aap_package_mode is 'existing')"
  type        = string
  default     = null
}

variable "aap_installer_s3_key" {
  description = "S3 key for AAP installer (required when aap_package_mode is 'existing')"
  type        = string
  default     = null
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type for AAP controller"
  type        = string
  default     = "t3.large"
}

variable "key_pair_name" {
  description = "EC2 Key Pair name for SSH access (optional, SSM Session Manager is recommended)"
  type        = string
  default     = null
}

variable "ami_id" {
  description = "Red Hat Enterprise Linux AMI ID for EC2 instance. If not provided, latest RHEL 9 will be used"
  type        = string
  default     = null

  validation {
    condition     = var.ami_id == null || can(regex("^ami-[a-f0-9]{8,17}$", var.ami_id))
    error_message = "AMI ID must be a valid AWS AMI identifier (ami-xxxxxxxx) or null."
  }
}

# RDS Configuration
variable "db_instance_class" {
  description = "RDS instance class for PostgreSQL database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "storage_encrypted" {
  description = "Whether to enable storage encryption."
  type        = bool
  default     = true
}

variable "db_max_allocated_storage" {
  description = "RDS maximum allocated storage in GB for autoscaling"
  type        = number
  default     = 100
}

variable "db_backup_retention_period" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "RDS backup window in UTC"
  type        = string
  default     = "03:00-06:00"
}

variable "db_enable_deletion_protection" {
  description = "RDS deletion protection enabled"
  type        = bool
  default     = false
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.13"
}

# Security and Access
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access AAP web interface"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed SSH access to jumphost (your IP address)"
  type        = list(string)
  default     = []
}

variable "allowed_instance_connect_cidr_blocks" {
  description = "CIDR blocks allowed to use EC2 Instance Connect for keyless SSH access"
  type        = list(string)
  default     = []
}

# Secrets Management
variable "aap_admin_password_secret_arn" {
  description = "ARN of AWS Secret containing AAP admin password. If not provided, a new secret will be created"
  type        = string
  default     = null
}

variable "db_password_secret_arn" {
  description = "ARN of AWS Secret containing RDS password. If not provided, a new secret will be created"
  type        = string
  default     = null
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "ansible"
}

# Resource Management
variable "force_destroy" {
  description = "Allow forceful destruction of resources (S3 buckets, RDS without final snapshot)"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying RDS instance"
  type        = bool
  default     = false
}

# Monitoring and Logging
variable "enable_cloudwatch_dashboard" {
  description = "Enable CloudWatch dashboard for monitoring"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for EC2 and application logs"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch logs retention period in days"
  type        = number
  default     = 30
}

# AAP Configuration
variable "aap_admin_username" {
  description = "AAP admin username"
  type        = string
  default     = "admin"
}

variable "aap_organization" {
  description = "AAP default organization name"
  type        = string
  default     = "Default"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-2"
}
