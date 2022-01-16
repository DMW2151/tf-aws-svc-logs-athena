
terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }

  required_version = ">= 1.0.3"

}

// Providers
provider "aws" {
  region = "us-west-2"
  alias  = "usw2"

  default_tags {
    tags = {
      Environment = "Test"
      Project     = "Test Service Logs Athena"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"

  default_tags {
    tags = {
      Environment = "Test"
      Project     = "Test Service Logs Athena"
    }
  }
}

// Variables

variable "build_domain" {
  type        = string
  description = "..."
  default     = "dmw2151.com"
}


// NOTE: This assumes a pre-configured hosted zone in AWS that can be used as a test environment
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "build" {
  name         = var.build_domain
  private_zone = false
}

// Random Name for Resources
// Resource: https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet
resource "random_pet" "random" {}

module "echo_us_east" {

  // Config  
  source = "./svc_logs_sample"
  providers = {
    aws = aws.use1
  }

  // Vars
  build_domain   = var.build_domain
  logging_bucket = aws_s3_bucket.svc_logs
  random         = random_pet.random.id

}


module "echo_us_west" {

  // Config  
  source = "./svc_logs_sample"
  providers = {
    aws = aws.usw2
  }

  // Vars
  build_domain   = var.build_domain
  logging_bucket = aws_s3_bucket.svc_logs
  random         = random_pet.random.id

  // Region Specific Vars - See `svc_logs_sample` variables file for 
  // details on finding region specific values for these...
  regional_lb_account_id = "797873946194"
  instance_ami           = "ami-0ec2e33c6e1161e98"

  public_subnet_numbers = {
    "us-west-2a" = 1
    "us-west-2b" = 2
  }

  private_subnet_numbers = {
    "us-west-2a" = 3
    "us-west-2b" = 4
  }

}

// Regional Routing Between US-EAST and US-WEST
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record 
resource "aws_route53_record" "alb_east" {

  // General
  zone_id = data.aws_route53_zone.build.zone_id
  name    = "alb-${random_pet.random.id}.${var.build_domain}"
  type    = "CNAME"
  ttl     = "300"

  // Routing
  geolocation_routing_policy {
    country     = "US"
    subdivision = "NY"
  }

  // Record
  set_identifier = "east"
  records = [
    module.echo_us_east.alb
  ]
}


// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record 
resource "aws_route53_record" "alb_usa" {

  // General
  zone_id = data.aws_route53_zone.build.zone_id
  name    = "alb-${random_pet.random.id}.${var.build_domain}"
  type    = "CNAME"
  ttl     = "300"

  // Routing
  geolocation_routing_policy {
    country = "US"
  }

  // Record
  set_identifier = "usa"
  records = [
    module.echo_us_west.alb
  ]
}
