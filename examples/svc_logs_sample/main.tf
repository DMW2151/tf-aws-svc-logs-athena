terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.71.0"
    }
  }

  required_version = ">= 1.0.3"

}

// Providers - AWS Provider 
provider "aws" {

  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "Test"
      Owner       = "terraform"
      Project     = "Service Logs To Athena"
    }
  }

}

// Locals

locals {

  // Maps public subnet IDs -> private subnet IDs for dynamiclly configuring NAT, EIP, and Route Tables...
  paired_subnets = zipmap(
    [for s in aws_subnet.public : s.id], [for s in aws_subnet.private : s.id]
  )

}


// Data

// Get Caller ID - Account ID
data "aws_caller_identity" "current" {}

// Misc

// Generate random name for resources (bucket and ALB endpoint)
// Resource: https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet
resource "random_pet" "random" {}
