# Compute Module Variables

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type for AAP controller"
  type        = string
  default     = "t3.large"
}

variable "ami_id" {
  description = "Red Hat Enterprise Linux AMI ID for EC2 instance"
  type        = string
  default     = null

  validation {
    condition     = var.ami_id == null || can(regex("^ami-[a-f0-9]{8,17}$", var.ami_id))
    error_message = "AMI ID must be a valid AWS AMI identifier (ami-xxxxxxxx) or null."
  }
}

# Networking
variable "subnet_ids" {
  description = "List of subnet IDs for EC2 instance"
  type        = list(string)
}

variable "aap_controller_security_group_id" {
  description = "Security group ID for AAP controller"
  type        = string
}

# Dependencies
variable "aap_admin_secret_arn" {
  description = "ARN of AAP admin password secret"
  type        = string
}

variable "db_password_secret_arn" {
  description = "ARN of database password secret"
  type        = string
}

variable "db_endpoint" {
  description = "RDS instance endpoint"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name containing AAP installer"
  type        = string
}

variable "s3_object_key" {
  description = "S3 object key for AAP installer"
  type        = string
}

# Monitoring
variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  type        = string
  default     = ""
}

# AAP Configuration
variable "aap_admin_username" {
  description = "AAP admin username"
  type        = string
}

variable "aap_organization" {
  description = "AAP organization name"
  type        = string
}

# Red Hat Subscription
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

# SSM Configuration
variable "enable_ssm" {
  description = "Enable AWS SSM Agent installation"
  type        = bool
  default     = true
}
