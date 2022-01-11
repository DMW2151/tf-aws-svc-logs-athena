terraform {

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 3.70"
      configuration_aliases = [aws.this]
    }
  }

}