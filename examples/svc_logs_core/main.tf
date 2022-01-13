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
      Project     = "Service Logs To Athena (tf-svc-logs)"
    }
  }

}

