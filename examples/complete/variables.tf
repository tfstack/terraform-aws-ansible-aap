variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-southeast-2"
}

variable "aap_installer_path" {
  description = "Local path to the AAP installer bundle"
  type        = string
  default     = null
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair for SSH access (optional)"
  type        = string
  default     = null
}
