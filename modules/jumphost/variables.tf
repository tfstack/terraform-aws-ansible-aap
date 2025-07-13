variable "name" {
  description = "Name prefix for jumphost EC2 instance"
  type        = string
}

variable "ami_type" {
  description = "Logical AMI type to use. Allowed: amazonlinux2, amazonlinux2023, ubuntu."
  type        = string
  default     = "amazonlinux2"
  validation {
    condition     = contains(["amazonlinux2", "amazonlinux2023", "ubuntu"], lower(var.ami_type))
    error_message = "ami_type must be one of: amazonlinux2, amazonlinux2023, ubuntu."
  }
}

variable "subnet_id" {
  description = "Subnet ID to launch the jumphost in"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR ranges allowed to connect via SSH when create_security_group = true."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "user_data_extra" {
  description = "Additional user_data shell commands appended to the module's base user_data."
  type        = string
  default     = ""
}

variable "create_security_group" {
  description = "Create a dedicated security group allowing SSH/ICMP from allowed CIDRs if no security group IDs are supplied. If true, vpc_security_group_ids can be empty."
  type        = bool
  default     = false
}

variable "assign_eip" {
  description = "Whether to allocate and associate an Elastic IP (valid only when subnet is public)."
  type        = bool
  default     = true
}

variable "enable_instance_connect" {
  description = "Install and enable EC2 Instance Connect for SSH (Amazon Linux & Ubuntu only)."
  type        = bool
  default     = false
}

variable "enable_instance_connect_endpoint" {
  description = "Create an EC2 Instance Connect Endpoint for private subnet access (requires VPC endpoints or NAT)."
  type        = bool
  default     = false
}

variable "instance_connect_endpoint_subnet_id" {
  description = "Subnet ID for the EC2 Instance Connect Endpoint (should be private with NAT or VPC endpoints)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the jumphost EC2 instance"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID for the jumphost security group"
  type        = string
}
