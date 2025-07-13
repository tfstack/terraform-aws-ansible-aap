# Monitoring Module Variables

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_dashboard" {
  description = "Enable CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch logs retention period in days"
  type        = number
  default     = 30
}

variable "instance_id" {
  description = "EC2 instance ID for monitoring"
  type        = string
}

variable "rds_instance_id" {
  description = "RDS instance ID for monitoring"
  type        = string
}
