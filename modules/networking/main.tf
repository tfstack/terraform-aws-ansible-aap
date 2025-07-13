# Networking Module - VPC, Subnets, and Security Groups

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "existing" {
  count = var.create_vpc ? 0 : 1
  id    = var.vpc_id
}

# Locals
locals {
  # Determine availability zones
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)

  # Ensure subnet CIDR list lengths match AZ count to avoid out-of-range indexing inside upstream VPC module
  public_cidrs   = slice(var.public_subnet_cidrs, 0, length(local.availability_zones))
  private_cidrs  = slice(var.private_subnet_cidrs, 0, length(local.availability_zones))
  isolated_cidrs = length(var.isolated_subnet_cidrs) > 0 ? slice(var.isolated_subnet_cidrs, 0, length(local.availability_zones)) : []
  database_cidrs = length(var.database_subnet_cidrs) > 0 ? slice(var.database_subnet_cidrs, 0, length(local.availability_zones)) : []

  vpc_id     = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  subnet_ids = var.create_vpc ? module.vpc[0].private_subnet_ids : var.subnet_ids
}

# VPC Module (conditional)
module "vpc" {
  count   = var.create_vpc ? 1 : 0
  source  = "cloudbuildlab/vpc/aws"
  version = ">= 1.0"

  # Basic VPC Configuration
  vpc_name           = "${var.name}-vpc"
  vpc_cidr           = var.vpc_cidr
  vpc_type           = var.vpc_type
  instance_tenancy   = var.instance_tenancy
  enable_ipv6        = var.enable_ipv6
  availability_zones = local.availability_zones

  # Subnet Configuration
  public_subnet_cidrs   = local.public_cidrs
  private_subnet_cidrs  = local.private_cidrs
  isolated_subnet_cidrs = local.isolated_cidrs
  database_subnet_cidrs = local.database_cidrs

  # Gateway Configuration
  create_igw         = var.create_igw
  enable_nat_gateway = var.enable_nat_gateway
  nat_gateway_type   = var.nat_gateway_type

  # DNS Configuration
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # VPC Endpoints - Gateway Endpoints
  enable_s3_endpoint = var.enable_s3_endpoint

  # VPC Endpoints - Interface Endpoints
  enable_interface_endpoints     = var.enable_interface_endpoints
  interface_endpoints            = var.interface_endpoints
  enable_rds_endpoint            = var.enable_rds_endpoint
  enable_logs_endpoint           = var.enable_logs_endpoint
  enable_monitoring_endpoint     = var.enable_monitoring_endpoint
  enable_ssm_endpoint            = var.enable_ssm_endpoint
  enable_sqs_endpoint            = var.enable_sqs_endpoint
  enable_sns_endpoint            = var.enable_sns_endpoint
  enable_secretsmanager_endpoint = var.enable_secretsmanager_endpoint
  enable_ecr_api_endpoint        = var.enable_ecr_api_endpoint
  enable_ecr_dkr_endpoint        = var.enable_ecr_dkr_endpoint
  enable_kms_endpoint            = var.enable_kms_endpoint
  enable_ecs_endpoint            = var.enable_ecs_endpoint

  # Network Configuration
  enable_nacls        = var.enable_nacls
  enable_route_tables = var.enable_route_tables
  custom_routes       = var.custom_routes

  tags = var.tags
}

# Security Group for AAP Controller
resource "aws_security_group" "aap_controller" {
  name_prefix = "${var.name}-aap-controller-"
  description = "Security group for AAP controller"
  vpc_id      = local.vpc_id

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTP access to AAP"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTPS access to AAP"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-aap-controller-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.name}-rds-"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = local.vpc_id

  # PostgreSQL access from AAP controller
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.aap_controller.id]
    description     = "PostgreSQL access from AAP controller"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-rds-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}
