# Storage Module Variables

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# AAP Package Configuration
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

variable "s3_object_key" {
  description = "S3 object key for the uploaded installer"
  type        = string
  default     = "aap-installer.tar.gz"
}
