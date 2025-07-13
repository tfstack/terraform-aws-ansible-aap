# Networking Module Variables

####################################
# Basic Configuration
####################################

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

####################################
# VPC Configuration - New VPC Creation
####################################

variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_type" {
  description = "Type of VPC to create. Allowed values: 'internal' (no public subnets, no NAT Gateway), 'dmz' (public subnets and NAT Gateway allowed)."
  type        = string
  default     = "dmz"

  validation {
    condition     = contains(["internal", "dmz"], var.vpc_type)
    error_message = "vpc_type must be either 'internal' or 'dmz'."
  }
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated"], var.instance_tenancy)
    error_message = "Instance tenancy must be either 'default' or 'dedicated'."
  }
}

variable "enable_ipv6" {
  description = "Whether to enable IPv6 support"
  type        = bool
  default     = true
}

# Availability Zones
variable "availability_zones" {
  description = "List of availability zones to use (minimum 2 for RDS). Leave empty to let the module choose automatically."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.availability_zones) == 0 || length(var.availability_zones) >= 2
    error_message = "If availability_zones is provided, it must contain at least 2 AZs to satisfy RDS subnet group requirements."
  }
}

# Subnet Configuration
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) > 0 || var.enable_nat_gateway == false
    error_message = "You must provide at least one public subnet CIDR if NAT Gateway is enabled."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "isolated_subnet_cidrs" {
  description = "CIDR blocks for isolated subnets (one per AZ)"
  type        = list(string)
  default     = []
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets (one per AZ)"
  type        = list(string)
  default     = []
}

# Gateway Configuration
variable "create_igw" {
  description = "Whether to create an Internet Gateway for public subnets"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "nat_gateway_type" {
  description = "NAT Gateway deployment type. 'single' for one NAT Gateway, 'one_per_az' for high availability"
  type        = string
  default     = "single"

  validation {
    condition     = contains(["single", "one_per_az"], var.nat_gateway_type)
    error_message = "NAT Gateway type must be either 'single' or 'one_per_az'."
  }
}

# VPC Endpoints - Gateway Endpoints
variable "enable_s3_endpoint" {
  description = "Whether to enable S3 VPC endpoint"
  type        = bool
  default     = false
}

# VPC Endpoints - Interface Endpoints
variable "enable_interface_endpoints" {
  description = "Whether to enable interface VPC endpoints"
  type        = bool
  default     = false
}

variable "interface_endpoints" {
  description = "List of interface endpoints to enable"
  type        = list(string)
  default     = []
}

variable "enable_rds_endpoint" {
  description = "Whether to enable RDS VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_logs_endpoint" {
  description = "Whether to enable CloudWatch Logs VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_monitoring_endpoint" {
  description = "Whether to enable CloudWatch Monitoring VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_ssm_endpoint" {
  description = "Whether to enable Systems Manager VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_sqs_endpoint" {
  description = "Whether to enable SQS VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_sns_endpoint" {
  description = "Whether to enable SNS VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_secretsmanager_endpoint" {
  description = "Whether to enable Secrets Manager VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_ecr_api_endpoint" {
  description = "Whether to enable ECR API VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_ecr_dkr_endpoint" {
  description = "Whether to enable ECR DKR VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_kms_endpoint" {
  description = "Whether to enable KMS VPC endpoint"
  type        = bool
  default     = false
}

variable "enable_ecs_endpoint" {
  description = "Whether to enable ECS VPC endpoint"
  type        = bool
  default     = false
}

# Network Configuration
variable "enable_nacls" {
  description = "Whether to create default Network ACLs for subnets. Set to false to manage NACLs outside the module."
  type        = bool
  default     = true
}

variable "enable_route_tables" {
  description = "Whether to create and configure route tables for subnets"
  type        = bool
  default     = true
}

variable "custom_routes" {
  description = "Custom routes configuration per route table type"
  type = object({
    public = optional(object({
      use_only = bool
      routes = list(object({
        cidr_block                = string
        gateway_id                = optional(string)
        nat_gateway_id            = optional(string)
        network_interface_id      = optional(string)
        transit_gateway_id        = optional(string)
        vpc_peering_connection_id = optional(string)
      }))
    }), null)
    private = optional(object({
      use_only = bool
      routes = list(object({
        cidr_block                = string
        gateway_id                = optional(string)
        nat_gateway_id            = optional(string)
        network_interface_id      = optional(string)
        transit_gateway_id        = optional(string)
        vpc_peering_connection_id = optional(string)
      }))
    }), null)
    isolated = optional(object({
      use_only = bool
      routes = list(object({
        cidr_block                = string
        gateway_id                = optional(string)
        nat_gateway_id            = optional(string)
        network_interface_id      = optional(string)
        transit_gateway_id        = optional(string)
        vpc_peering_connection_id = optional(string)
      }))
    }), null)
    database = optional(object({
      use_only = bool
      routes = list(object({
        cidr_block                = string
        gateway_id                = optional(string)
        nat_gateway_id            = optional(string)
        network_interface_id      = optional(string)
        transit_gateway_id        = optional(string)
        vpc_peering_connection_id = optional(string)
      }))
    }), null)
  })
  default = {}
}

####################################
# VPC Configuration - Existing VPC Usage
####################################

variable "vpc_id" {
  description = "Existing VPC ID (required if create_vpc is false)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs (required if create_vpc is false)"
  type        = list(string)
  default     = []
}

####################################
# VPC DNS Configuration
####################################

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

####################################
# Security Group Configuration
####################################

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access AAP web interface"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
