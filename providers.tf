terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  #   default_tags {
  #     tags = {
  #       Module    = "terraform-aws-ansible-aap"
  #       ManagedBy = "Terraform"
  #     }
  #   }
}
