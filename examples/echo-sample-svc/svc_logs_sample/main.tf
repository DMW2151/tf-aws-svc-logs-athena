terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }

  required_version = ">= 1.0.3"

}


// Locals

locals {

  // Maps public subnet IDs -> private subnet IDs for dynamiclly configuring NAT, EIP, and Route Tables...
  paired_subnets = zipmap(
    [for s in aws_subnet.public : s.id], [for s in aws_subnet.private : s.id]
  )

}

// Get Caller ID - Account ID
data "aws_caller_identity" "current" {}

// Get Current Region - 
data "aws_region" "current" {}



