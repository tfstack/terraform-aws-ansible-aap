# Secrets Module Variables

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "Allow forceful destruction of secrets"
  type        = bool
  default     = false
}

# AAP Configuration
variable "aap_admin_username" {
  description = "AAP admin username"
  type        = string
  default     = "admin"
}

variable "aap_admin_password_secret_arn" {
  description = "ARN of existing AAP admin password secret"
  type        = string
  default     = null
}

# Database Configuration
variable "db_username" {
  description = "Database username"
  type        = string
  default     = "ansible"
}

variable "db_password_secret_arn" {
  description = "ARN of existing database password secret"
  type        = string
  default     = null
}
